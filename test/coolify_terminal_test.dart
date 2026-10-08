import 'dart:convert';

import 'package:capidock/features/coolify/terminal/container_target.dart';
import 'package:capidock/features/coolify/terminal/terminal_link_store.dart';
import 'package:capidock/features/coolify/terminal/coolify_terminal_page.dart';
import 'package:capidock/features/coolify/data/coolify_session.dart';
import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/connections/data/ssh_connection.dart';
import 'package:capidock/features/connections/data/host_key_store.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/features/workspaces/domain/dock_workspace.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'test_support.dart';
import 'connections_test.dart' show coolify;

const ssh = ServerInstance(
  id: 'ssh',
  name: 'Production SSH',
  type: InstanceType.ssh,
  host: 'server.example',
  port: 22,
  username: 'operator',
  password: 'test-only',
);
const target = CoolifyTerminalTarget(
  kind: 'applications',
  uuid: 'resource-uuid',
  name: 'Webcore',
  details: {'server_uuid': 'server-uuid'},
);
final containerId = List.filled(64, 'a').join();
String row(String id, String name, String labels) => jsonEncode({
  'ID': id,
  'Names': name,
  'Labels': labels,
  'Image': 'test-image',
});

class FakeSsh extends SshConnection {
  FakeSsh(super.instance)
    : super(hostKeys: HostKeyStore(secrets: MemorySecretStore()));
  String? opened;
  bool disconnected = false;
  String output = row(
    containerId,
    'webcore',
    'coolify.applicationUuid=resource-uuid',
  );
  @override
  Future<void> connect(ConfirmHostKey confirm, {bool openShell = true}) async {
    expect(openShell, isFalse);
    status = ConnectionStatus.connected;
    notifyListeners();
  }

  @override
  Future<String> discoverContainers() async => output;
  @override
  Future<void> openTerminal({String? containerId, String shell = 'sh'}) async {
    opened = containerId;
    terminal.onOutput = (_) {};
    notifyListeners();
  }

  @override
  void disconnect() {
    disconnected = true;
    super.disconnect();
  }
}

void main() {
  test('Exec accepts only full immutable IDs and fixed shells', () {
    expect(
      containerShellCommand(containerId, 'sh'),
      'docker exec -it $containerId sh',
    );
    for (final id in [
      'name',
      '-i',
      '$containerId;id',
      'abcd',
      '$containerId\n',
    ]) {
      expect(() => containerShellCommand(id, 'sh'), throwsFormatException);
    }
    expect(
      () => containerShellCommand(containerId, 'sh;id'),
      throwsFormatException,
    );
  });
  test(
    'UUID ownership excludes other installations and rejects numeric IDs alone',
    () {
      final raw = [
        row(containerId, 'webcore', 'coolify.applicationUuid=resource-uuid'),
        row(List.filled(64, 'b').join(), 'other', 'coolify.applicationId=1'),
        row(
          List.filled(64, 'c').join(),
          'resource-uuid-legacy',
          'coolify.applicationId=2',
        ),
        row(
          List.filled(64, 'd').join(),
          'resource-uuid-wrong',
          'coolify.applicationUuid=other,coolify.applicationId=2,com.docker.compose.project=resource-uuid',
        ),
      ].join('\n');
      expect(resourceContainers(raw, target).map((c) => c.name), [
        'resource-uuid-legacy',
        'webcore',
      ]);
      expect(resourceContainers(raw, null), hasLength(4));
    },
  );
  test(
    'Service components match the parent service and compose legacy labels',
    () {
      const component = CoolifyTerminalTarget(
        kind: 'databases',
        uuid: 'component',
        name: 'DB',
        parentServiceUuid: 'service-uuid',
      );
      expect(
        resourceContainers(
          row(
            containerId,
            'postgres',
            'coolify.serviceId=4,com.docker.compose.project=service-uuid',
          ),
          component,
        ),
        hasLength(1),
      );
      expect(
        resourceContainers(
          row(containerId, 'postgres', 'coolify.serviceUuid=other'),
          component,
        ),
        isEmpty,
      );
      expect(
        () => resourceContainers('not-json', target),
        throwsFormatException,
      );
      expect(
        () => resourceContainers(row('malicious;id', 'app', ''), null),
        throwsFormatException,
      );
    },
  );
  test(
    'Encrypted associations bind both endpoints and never copy credentials',
    () async {
      final secrets = MemorySecretStore();
      final links = TerminalLinkStore(secrets: secrets);
      await links.write(coolify, 'server-uuid', ssh);
      expect(await links.read(coolify, 'server-uuid', [ssh]), 'ssh');
      expect(secrets.values.values.single, isNot(contains('test-only')));
      expect(secrets.values.values.single, isNot(contains(coolify.apiToken)));
      const changed = ServerInstance(
        id: 'ssh',
        name: 'SSH',
        type: InstanceType.ssh,
        host: 'other.example',
        port: 22,
        username: 'operator',
      );
      expect(await links.read(coolify, 'server-uuid', [changed]), isNull);
      expect(await links.read(coolify, 'server-uuid', []), isNull);
      expect(await links.read(coolify, 'another-server', [ssh]), isNull);
      final moved = ServerInstance(
        id: coolify.id,
        name: coolify.name,
        type: InstanceType.coolify,
        host: 'https://different.example',
        port: coolify.port,
        apiToken: coolify.apiToken,
      );
      expect(await links.read(moved, 'server-uuid', [ssh]), isNull);
    },
  );
  for (final locale in [
    const Locale('en', 'GB'),
    const Locale('en', 'US'),
    const Locale('pt', 'PT'),
    const Locale('pt', 'BR'),
    const Locale('es', 'ES'),
  ]) {
    testWidgets(
      'Container terminal, keyboard and background close in $locale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryWorkspaceStore()
          ..data = [
            DockWorkspace(
              id: 'w',
              name: 'Real workspace',
              instances: [coolify, ssh],
            ),
          ];
        final controller = DockController(store);
        await controller.initialize();
        addTearDown(controller.dispose);
        final links = TerminalLinkStore(secrets: MemorySecretStore());
        await links.write(coolify, 'server-uuid', ssh);
        final session = CoolifySession(
          coolify,
          createClient: () => CoolifyClient(
            client: MockClient((request) async {
              expect(request.method, 'GET');
              expect(request.url.path, '/api/v1/servers');
              return http.Response(
                jsonEncode([
                  {
                    'uuid': 'server-uuid',
                    'name': 'Production',
                    'ip': 'server.example',
                  },
                ]),
                200,
              );
            }),
          ),
        );
        addTearDown(session.dispose);
        final connection = FakeSsh(ssh);
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: CoolifyTerminalPage(
              session: session,
              controller: controller,
              target: target,
              links: links,
              createConnection: (_) => connection,
            ),
          ),
        );
        await tester.runAsync(() async {
          await tester.pump();
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FilledButton).first);
        await tester.pumpAndSettle();
        final dropdown = find.byType(DropdownButtonFormField<String>).at(2);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('webcore').last);
        await tester.pumpAndSettle();
        final open = find.byType(FilledButton).first;
        if (locale.countryCode == 'GB') {
          connection.output = '';
          await tester.ensureVisible(open);
          await tester.tap(open);
          await tester.pumpAndSettle();
          expect(connection.opened, isNull);
          expect(find.textContaining('no longer running'), findsOneWidget);
          connection.output = row(
            containerId,
            'webcore',
            'coolify.applicationUuid=resource-uuid',
          );
          final refresh = find.widgetWithIcon(TextButton, Icons.refresh);
          await tester.ensureVisible(refresh);
          await tester.tap(refresh);
          await tester.pumpAndSettle();
          await tester.ensureVisible(dropdown);
          await tester.tap(dropdown);
          await tester.pumpAndSettle();
          await tester.tap(find.text('webcore').last);
          await tester.pumpAndSettle();
        }
        await tester.ensureVisible(open);
        await tester.tap(open);
        await tester.pumpAndSettle();
        expect(connection.opened, containerId);
        expect(find.text('Ctrl+C'), findsOneWidget);
        expect(find.text('Tab'), findsOneWidget);
        expect(tester.takeException(), isNull);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        expect(connection.disconnected, isTrue);
        expect(connection.terminal.onOutput, isNull);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
