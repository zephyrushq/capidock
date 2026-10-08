import 'dart:async';

import '../connections/data/ssh_connection.dart';
import '../connections/data/coolify_client.dart';
import '../instances/domain/server_instance.dart';
import 'monitor_state.dart';
import 'monitor_cancellation.dart';

Future<HealthCheck> probeInstance(
  ServerInstance instance, {
  MonitorCancellation? cancellation,
}) async {
  if (cancellation?.cancelled == true) return const HealthCheck(Health.unknown);
  final timer = Stopwatch()..start();
  if (instance.type == InstanceType.ssh) {
    final connection = SshConnection(instance);
    cancellation?.attach(connection.dispose);
    try {
      await connection
          .connect((_, _, _) async => false, openShell: false)
          .timeout(const Duration(seconds: 40));
      return HealthCheck(
        connection.status == ConnectionStatus.connected
            ? Health.up
            : switch (connection.failureKind) {
                SshFailure.authentication => Health.authentication,
                SshFailure.identity => Health.identity,
                SshFailure.unreachable => Health.down,
                _ => Health.unknown,
              },
        latency: timer.elapsedMilliseconds,
      );
    } on TimeoutException {
      return const HealthCheck(Health.down);
    } finally {
      cancellation?.detach(connection.dispose);
      if (cancellation?.cancelled != true) connection.dispose();
    }
  }
  final client = CoolifyClient();
  cancellation?.attach(client.close);
  Future<HealthCheck> check() async {
    try {
      await client.request(instance, 'GET', '/version');
      if (cancellation?.cancelled == true) {
        return const HealthCheck(Health.unknown);
      }
      Map<String, String>? deployments, resources;
      var health = Health.up;
      try {
        deployments = monitorItems(
          await client.request(
            instance,
            'GET',
            '/deployments',
            query: {'skip': '0', 'take': '20'},
          ),
          deployments: true,
        );
        if (cancellation?.cancelled == true) {
          return const HealthCheck(Health.unknown);
        }
        resources = monitorItems(
          await client.request(instance, 'GET', '/resources'),
          deployments: false,
        );
      } on CoolifyException catch (error) {
        health = [401, 403].contains(error.statusCode)
            ? Health.authentication
            : Health.unknown;
      } on FormatException {
        health = Health.unknown;
      }
      return HealthCheck(
        health,
        latency: timer.elapsedMilliseconds,
        deployments: deployments,
        resources: resources,
      );
    } on CoolifyException catch (error) {
      return HealthCheck(
        [401, 403].contains(error.statusCode)
            ? Health.authentication
            : error.transportFailure
            ? Health.down
            : Health.unknown,
        latency: timer.elapsedMilliseconds,
      );
    }
  }

  try {
    return await check().timeout(const Duration(seconds: 80));
  } on TimeoutException {
    return const HealthCheck(Health.unknown);
  } finally {
    cancellation?.detach(client.close);
    client.close();
  }
}

/// Keep only opaque identifiers and health, never names, logs or API bodies.
Map<String, String> monitorItems(Object? data, {required bool deployments}) {
  if (data is Map) {
    data = data[deployments ? 'deployments' : 'resources'] ?? data['data'];
  }
  if (data is! List || data.length > 1000) {
    throw const FormatException('Unexpected monitoring response');
  }
  final result = <String, String>{};
  for (final entry in data) {
    if (entry is! Map) continue;
    final id = entry[deployments ? 'deployment_uuid' : 'uuid'] ?? entry['uuid'];
    final status = entry['status'];
    if (id is! String || id.isEmpty || id.length > 128 || status is! String) {
      continue;
    }
    result[id] = normalizedMonitorStatus(status, deployments: deployments);
  }
  return result;
}

/// Store only recognised protocol states; an arbitrary API string must not
/// become history or notification content.
String normalizedMonitorStatus(String status, {required bool deployments}) {
  final value = status.trim().toLowerCase();
  if (deployments) {
    return switch (value) {
      'queued' => 'queued',
      'in_progress' => 'in_progress',
      'finished' => 'finished',
      'failed' => 'failed',
      'cancelled' || 'cancelled-by-user' || 'canceled' => 'cancelled',
      _ => 'unknown',
    };
  }
  final parts = value.split(':');
  if (parts.length > 2 ||
      !const {
        'running',
        'starting',
        'restarting',
        'exited',
        'stopped',
        'paused',
        'dead',
        'removing',
        'unhealthy',
        'healthy',
        'error',
        'failed',
        'unknown',
      }.contains(parts.first)) {
    return 'unknown';
  }
  if (parts.length == 2 &&
      !const {
        'healthy',
        'unhealthy',
        'unknown',
        'starting',
      }.contains(parts.last)) {
    return 'unknown';
  }
  return value;
}
