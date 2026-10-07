import 'dart:convert';

import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/connections/data/host_key_store.dart';
import 'package:capidock/features/connections/data/ssh_connection.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'test_support.dart';

const coolify = ServerInstance(
  id: 'api',
  name: 'API',
  type: InstanceType.coolify,
  host: 'https://coolify.example.com:8443/',
  port: 8443,
  apiToken: 'test-token',
);

void main() {
  test(
    'Coolify reads actual resource fields and sends auth only in the header',
    () async {
      final client = CoolifyClient(
        client: MockClient((request) async {
          expect(
            request.url.toString(),
            'https://coolify.example.com:8443/api/v1/resources',
          );
          expect(request.headers['Authorization'], 'Bearer test-token');
          expect(request.followRedirects, isFalse);
          expect(request.method, 'GET');
          return http.Response(
            jsonEncode([
              {
                'uuid': 'real-id',
                'name': 'Own app',
                'type': 'application',
                'status': 'running:healthy',
              },
            ]),
            200,
          );
        }),
      );
      final result = await client.resources(coolify);
      expect(result.single.name, 'Own app');
      expect(result.single.status, 'running:healthy');
      client.close();
    },
  );

  test('An empty API response is an empty resource list', () async {
    final client = CoolifyClient(
      client: MockClient((_) async => http.Response('[]', 200)),
    );
    expect(await client.resources(coolify), isEmpty);
    client.close();
  });

  for (final code in [301, 401, 403, 404, 429, 500]) {
    test(
      'HTTP $code reports a useful error without echoing remote secrets',
      () async {
        final client = CoolifyClient(
          client: MockClient(
            (_) async => http.Response(
              'remote-secret',
              code,
              headers: {'location': 'http://untrusted.example.com'},
            ),
          ),
        );
        await expectLater(
          client.resources(coolify),
          throwsA(
            isA<CoolifyException>().having(
              (e) => e.message,
              'message',
              isNot(contains('remote-secret')),
            ),
          ),
        );
        client.close();
      },
    );
  }

  test('Unexpected API payloads do not invent resource statuses', () async {
    for (final payload in [
      '<html>login</html>',
      '{"data":[]}',
      '[{"status":12}]',
    ]) {
      final client = CoolifyClient(
        client: MockClient((_) async => http.Response(payload, 200)),
      );
      await expectLater(
        client.resources(coolify),
        throwsA(isA<CoolifyException>()),
      );
      client.close();
    }
  });

  test('Initial SSH trust must be explicitly accepted and persisted', () async {
    final secrets = MemorySecretStore();
    final store = HostKeyStore(secrets: secrets);
    final instance = fixtureInstances.first;
    expect(
      await store.verify(
        instance,
        'ssh-ed25519',
        'SHA256:first',
        (_, _, _) async => false,
        isActive: () => true,
      ),
      isFalse,
    );
    expect(secrets.values, isEmpty);
    expect(
      await store.verify(instance, 'ssh-ed25519', 'SHA256:first', (
        _,
        _,
        old,
      ) async {
        expect(old, isNull);
        return true;
      }, isActive: () => true),
      isTrue,
    );
    expect(
      await store.verify(
        instance,
        'ssh-ed25519',
        'SHA256:first',
        (_, _, _) async => throw StateError('Should not prompt again'),
        isActive: () => true,
      ),
      isTrue,
    );
    expect(
      await store.verify(instance, 'ssh-ed25519', 'SHA256:changed', (
        _,
        _,
        old,
      ) async {
        expect(old, 'SHA256:first');
        return false;
      }, isActive: () => true),
      isFalse,
    );
    expect(secrets.values.values.single, contains('SHA256:first'));
  });

  test(
    'Changed endpoint and cancelled sessions cannot silently trust a key',
    () async {
      final secrets = MemorySecretStore();
      final store = HostKeyStore(secrets: secrets);
      final original = fixtureInstances.first;
      await store.verify(
        original,
        'ssh-ed25519',
        'SHA256:first',
        (_, _, _) async => true,
        isActive: () => true,
      );
      final changed = ServerInstance.fromJson({
        ...original.toJson(),
        'host': 'other.example.com',
      });
      var active = true;
      final before = Map.of(secrets.values);
      expect(
        await store.verify(changed, 'ssh-ed25519', 'SHA256:first', (
          _,
          _,
          old,
        ) async {
          expect(old, isNull);
          active = false;
          return true;
        }, isActive: () => active),
        isFalse,
      );
      expect(secrets.values, before);
    },
  );

  test('SSH trust fails closed when the secure write fails', () async {
    final store = HostKeyStore(secrets: MemorySecretStore()..failWrite = true);
    await expectLater(
      store.verify(
        fixtureInstances.first,
        'ssh-ed25519',
        'SHA256:first',
        (_, _, _) async => true,
        isActive: () => true,
      ),
      throwsStateError,
    );
    expect(
      sshErrorMessage(SSHAuthFailError('sensitive-password')),
      isNot(contains('sensitive-password')),
    );
  });
}
