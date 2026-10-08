/// Availability is observed from this device, never inferred between checks.
enum Health { up, down, offline, authentication, identity, unknown }

class HealthCheck {
  const HealthCheck(
    this.health, {
    this.latency,
    this.deployments,
    this.resources,
  });
  final Health health;
  final int? latency;
  final Map<String, String>? deployments, resources;
}

class MonitorState {
  MonitorState({
    this.fingerprint = '',
    this.samples = const [],
    this.events = const [],
    this.failures = 0,
    this.downAlerted = false,
    this.problem = '',
    this.deployments,
    this.resources,
    this.lastObservation,
  });
  final Map<String, dynamic>? lastObservation;
  Map<String, dynamic>? get latest => lastObservation ?? samples.lastOrNull;
  final String fingerprint;
  final List<Map<String, dynamic>> samples, events;
  final int failures;
  final bool downAlerted;
  final String problem;
  final Map<String, String>? deployments, resources;
  factory MonitorState.fromJson(Map<String, dynamic> json) => MonitorState(
    fingerprint: json['fingerprint'] as String? ?? '',
    lastObservation: json['lastObservation'] == null
        ? null
        : Map<String, dynamic>.from(json['lastObservation'] as Map),
    samples: (json['samples'] as List? ?? [])
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(),
    events: (json['events'] as List? ?? [])
        .cast<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(),
    failures: json['failures'] as int? ?? 0,
    downAlerted: json['downAlerted'] == true,
    problem: json['problem'] as String? ?? '',
    deployments: json['deployments'] == null
        ? null
        : Map<String, String>.from(json['deployments'] as Map),
    resources: json['resources'] == null
        ? null
        : Map<String, String>.from(json['resources'] as Map),
  );
  Map<String, dynamic> toJson() => {
    'fingerprint': fingerprint,
    'lastObservation': lastObservation,
    'samples': samples,
    'events': events,
    'failures': failures,
    'downAlerted': downAlerted,
    'problem': problem,
    'deployments': deployments,
    'resources': resources,
  };
  double? get uptime {
    final known = samples
        .where((s) => ['up', 'down', 'authentication'].contains(s['health']))
        .toList();
    if (known.isEmpty) return null;
    return 100 *
        known.where((s) => s['health'] != 'down').length /
        known.length;
  }

  /// Authentication rejection proves reachability but not usable access. Unknown
  /// and offline samples break a failure streak, without claiming recovery.
  (MonitorState, List<String>) record(
    HealthCheck check,
    DateTime now,
    String identity, {
    Duration sampleInterval = Duration.zero,
  }) {
    final current = fingerprint == identity
        ? this
        : MonitorState(fingerprint: identity);
    final alerts = <String>[];
    final stale =
        current.latest != null &&
        now.millisecondsSinceEpoch - (current.latest!['at'] as int) >
            const Duration(hours: 2).inMilliseconds;
    final failures = check.health == Health.down
        ? (stale ? 0 : current.failures) + 1
        : 0;
    var downAlerted = current.downAlerted;
    if (failures >= 2 && !downAlerted) {
      alerts.add('down');
      downAlerted = true;
    }
    if (check.health == Health.up || check.health == Health.authentication) {
      if (downAlerted) alerts.add('recovery');
      downAlerted = false;
    }
    final problem =
        [
          Health.authentication,
          Health.identity,
          Health.unknown,
        ].contains(check.health)
        ? check.health.name
        : '';
    if (problem.isNotEmpty && current.problem != problem) alerts.add(problem);
    if (check.deployments != null && current.deployments != null) {
      for (final entry in check.deployments!.entries) {
        final previous = current.deployments![entry.key];
        if (previous == entry.value || previous == 'other') continue;
        final event = switch (entry.value) {
          'in_progress' => 'deploymentStarted',
          'finished' => 'deploymentSucceeded',
          'cancelled' => 'deploymentCancelled',
          'failed' => 'deployment',
          _ => null,
        };
        if (event != null && !alerts.contains(event)) alerts.add(event);
      }
    }
    if (check.resources != null && current.resources != null) {
      for (final entry in check.resources!.entries) {
        final previous = current.resources![entry.key];
        final unhealthy =
            entry.value.contains('unhealthy') ||
            const {'failed', 'error', 'dead'}.contains(entry.value);
        final wasUnhealthy =
            previous?.contains('unhealthy') == true ||
            const {'failed', 'error', 'dead'}.contains(previous);
        if (unhealthy && !wasUnhealthy && !alerts.contains('resource')) {
          alerts.add('resource');
        }
        // A newly discovered resource is its baseline, not a state change.
        if (previous != null &&
            previous != 'other' &&
            previous != 'unknown' &&
            entry.value != 'unknown' &&
            previous != entry.value &&
            !alerts.contains('resourceChanged')) {
          alerts.add('resourceChanged');
        }
      }
    }
    final cutoff = now
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
    final samples = [
      ...current.samples.where((e) => (e['at'] as int) >= cutoff),
      if (current.samples.isEmpty ||
          now.millisecondsSinceEpoch - (current.samples.last['at'] as int) >=
              sampleInterval.inMilliseconds)
        {
          'at': now.millisecondsSinceEpoch,
          'health': check.health.name,
          'latency': check.latency,
        },
    ];
    final events = [
      ...current.events.where((e) => (e['at'] as int) >= cutoff),
      for (final alert in alerts)
        {'at': now.millisecondsSinceEpoch, 'kind': alert},
    ];
    return (
      MonitorState(
        fingerprint: identity,
        lastObservation: {
          'at': now.millisecondsSinceEpoch,
          'health': check.health.name,
          'latency': check.latency,
        },
        samples: samples
            .skip(samples.length > 3000 ? samples.length - 3000 : 0)
            .toList(),
        events: events
            .skip(events.length > 100 ? events.length - 100 : 0)
            .toList(),
        failures: failures,
        downAlerted: downAlerted,
        problem: problem,
        deployments: _remember(current.deployments, check.deployments),
        resources: _remember(current.resources, check.resources),
      ),
      alerts,
    );
  }
}

Map<String, String>? _remember(
  Map<String, String>? previous,
  Map<String, String>? incoming,
) {
  if (incoming == null) return previous;
  final merged = {...?previous};
  for (final entry in incoming.entries) {
    merged.remove(entry.key);
    merged[entry.key] = entry.value;
  }
  return Map.fromEntries(
    merged.entries.skip(merged.length > 500 ? merged.length - 500 : 0),
  );
}
