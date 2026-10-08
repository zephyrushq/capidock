import 'dart:async';

import 'package:capidock/core/security/device_lock.dart';
import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/connections/data/ssh_connection.dart';
import 'package:capidock/features/coolify/data/coolify_session.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/features/workspaces/domain/dock_workspace.dart';
import 'package:capidock/l10n/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'connections_test.dart' show coolify;
import 'test_support.dart';

class DelayedStore extends MemoryWorkspaceStore {
  final loaded = Completer<List<DockWorkspace>?>();
  @override
  Future<List<DockWorkspace>?> load() => loaded.future;
}

class DelayedSaveStore extends MemoryWorkspaceStore {
  final saved = Completer<void>();
  @override
  Future<void> save(List<DockWorkspace> workspaces) async {
    await saved.future;
    await super.save(workspaces);
  }
}

class FakeAuthenticator implements DeviceAuthenticator {
  bool accepted = false;
  @override
  Future<bool> unlock(String reason) async => accepted;
}

void main() {
  test('Background lock discards an in-flight decrypted vault load', () async {
    final store = DelayedStore();
    final controller = DockController(store);
    final loading = controller.initialize();
    await Future<void>.delayed(Duration.zero);
    controller.lock();
    store.loaded.complete([DockWorkspace(id: 'w', name: 'Private')]);
    await loading;
    expect(controller.workspaces, isEmpty);
    expect(controller.isLoading, isTrue);
    await expectLater(
      controller.createWorkspace('Forbidden'),
      throwsStateError,
    );
    controller.dispose();
  });

  test(
    'A pending save completes without restoring secrets to a locked controller',
    () async {
      final store = DelayedSaveStore();
      final controller = DockController(store);
      await controller.initialize();
      final saving = controller.createWorkspace('Persisted');
      controller.lock();
      store.saved.complete();
      await saving;
      expect(controller.workspaces, isEmpty);
      expect(store.data!.single.name, 'Persisted');
      await controller.initialize();
      expect(controller.workspaces.single.name, 'Persisted');
      controller.dispose();
    },
  );

  testWidgets('Device authentication is required again after backgrounding', (
    tester,
  ) async {
    final store = MemoryWorkspaceStore();
    final controller = DockController(store);
    final auth = FakeAuthenticator();
    final locales = LocaleController(
      initialLocale: const Locale('en', 'GB'),
      preferences: MemoryPreferences(),
    );
    await tester.pumpWidget(
      DeviceLock(controller: controller, locales: locales, authenticator: auth),
    );
    expect(controller.isLoading, isTrue);
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.text('Capidock locked'), findsOneWidget);
    auth.accepted = true;
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();
    expect(find.text('Capidock locked'), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    expect(controller.workspaces, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('Capidock locked'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    locales.dispose();
  });

  test('Disconnect wipes terminal and server information', () {
    final ssh = SshConnection(fixtureInstances.first);
    ssh.terminal.write('private-output');
    ssh.information = 'private-info';
    ssh.informationError = 'private-error';
    ssh.updatedAt = DateTime.now();
    ssh.disconnect();
    expect(ssh.terminal.buffer.getText(), isNot(contains('private-output')));
    expect(ssh.information, isNull);
    expect(ssh.informationError, isNull);
    expect(ssh.updatedAt, isNull);
    ssh.dispose();
  });

  test(
    'Ambiguous API paths fail before credentials leave the device',
    () async {
      var sent = 0;
      final client = CoolifyClient(
        client: MockClient((_) async {
          sent++;
          return http.Response('{}', 200);
        }),
      );
      for (final path in [
        '/../projects',
        '/%2e%2e/projects',
        '/a%2fb',
        '/a%5cb',
        '/%252e%252e',
        '/%00',
        '/bad%zz',
      ]) {
        await expectLater(
          client.request(coolify, 'GET', path),
          throwsArgumentError,
        );
      }
      expect(sent, 0);
      client.close();
    },
  );

  test(
    'A foreground Coolify session reuses connections and cancels stale replies',
    () async {
      var created = 0;
      final reply = Completer<http.Response>();
      final session = CoolifySession(
        coolify,
        createClient: () {
          created++;
          return CoolifyClient(client: MockClient((_) => reply.future));
        },
      );
      final first = session.request('GET', '/projects');
      final second = session.request('GET', '/servers');
      final assertions = Future.wait([
        expectLater(first, throwsA(isA<CoolifyException>())),
        expectLater(second, throwsA(isA<CoolifyException>())),
      ]);
      session.didChangeAppLifecycleState(AppLifecycleState.paused);
      reply.complete(http.Response('{}', 200));
      await assertions;
      expect(created, 1);
      session.dispose();
    },
  );
}
