import 'dart:async';
import 'dart:convert';

import 'package:capidock/core/app_theme.dart';
import 'package:capidock/features/connections/data/ssh_connection.dart';
import 'package:capidock/features/connections/presentation/instance_connection_page.dart';
import 'package:capidock/features/docker/data/docker_command.dart';
import 'package:capidock/features/docker/data/docker_models.dart';
import 'package:capidock/features/docker/presentation/docker_container_page.dart';
import 'package:capidock/features/docker/presentation/docker_panel.dart';
import 'package:capidock/l10n/locale_controller.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'docker_test_support.dart';

Future<void> launchDocker(
  WidgetTester tester,
  FakeDockerConnection ssh, {
  bool details = false,
  bool navigation = false,
  Locale locale = const Locale('en', 'GB'),
}) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: details
        ? DockerContainerPage(
            connection: ssh,
            container: DockerContainer(dockerRow(dockerId, 'web', 'running')),
          )
        : navigation
        ? Scaffold(
            body: InstanceConnectionPage(
              instance: ssh.instance,
              onEdit: () {},
              createConnection: (_) => ssh,
            ),
          )
        : Scaffold(
            body: DockerPanel(
              connection: ssh,
              connect: () =>
                  ssh.connect((_, _, _) async => true, openShell: false),
            ),
          ),
  ),
);

void main() {
  testWidgets(
    'SSH navigation exposes Docker and reuses the selected connection',
    (tester) async {
      final ssh = FakeDockerConnection();
      await tester.pumpWidget(
        MaterialApp(
          theme: buildTheme(),
          locale: const Locale('en', 'GB'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: InstanceConnectionPage(
              instance: ssh.instance,
              onEdit: () {},
              createConnection: (_) => ssh,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(ssh.requests, isEmpty);
      await tester.tap(find.text('Docker'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('docker-panel')), findsOneWidget);
      expect(ssh.requests.single.operation, DockerOperation.list);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'List includes stopped containers, filters and navigates to details',
    (tester) async {
      final ssh = FakeDockerConnection();
      await launchDocker(tester, ssh);
      await tester.pumpAndSettle();
      expect(find.text('web'), findsOneWidget);
      expect(find.text('worker'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'worker');
      await tester.pumpAndSettle();
      expect(find.text('web'), findsNothing);
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('docker-container-$dockerId')));
      await tester.pumpAndSettle();
      expect(find.text('1.25%'), findsOneWidget);
      expect(find.textContaining('25MiB'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('127.0.0.1:8080'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('127.0.0.1:8080'), findsOneWidget);
      expect(
        ssh.requests.where((r) => r.operation == DockerOperation.logs),
        isEmpty,
      );
      await tester.pumpWidget(const SizedBox());
      ssh.dispose();
    },
  );
  testWidgets(
    'Disconnected Docker requires explicit connection and reports missing Docker',
    (tester) async {
      final ssh = FakeDockerConnection(connected: false);
      ssh.failure = const DockerException(DockerFailure.notInstalled);
      await launchDocker(tester, ssh);
      await tester.pumpAndSettle();
      expect(ssh.requests, isEmpty);
      await tester.tap(find.text('Connect to instance'));
      await tester.pumpAndSettle();
      expect(
        find.text('Docker was not found in the SSH command path.'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      ssh.dispose();
    },
  );
  testWidgets('Actions require confirmation and timeout does not retry', (
    tester,
  ) async {
    final ssh = FakeDockerConnection();
    await launchDocker(tester, ssh, details: true);
    await tester.pumpAndSettle();
    final restart = find.byKey(const ValueKey('docker-action-restart'));
    await tester.ensureVisible(restart);
    await tester.tap(restart);
    await tester.pumpAndSettle();
    expect(ssh.requests.where((r) => r.mutates), isEmpty);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(ssh.requests.where((r) => r.mutates), isEmpty);
    ssh.failure = const DockerException(DockerFailure.timeout);
    ssh.failingOperation = DockerOperation.restart;
    await tester.drag(find.byType(ListView), const Offset(0, 500));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      restart,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(restart);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('docker-confirm-action')));
    await tester.pumpAndSettle();
    expect(ssh.requests.where((r) => r.mutates), hasLength(1));
    expect(
      find.text(
        'The operation may have reached the server. Refresh the state before trying again.',
      ),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    expect(ssh.requests.where((r) => r.mutates), hasLength(1));
    await tester.pumpWidget(const SizedBox());
    ssh.dispose();
  });
  testWidgets(
    'Confirmed stop refreshes state and disables terminal and metrics',
    (tester) async {
      final ssh = FakeDockerConnection();
      await launchDocker(tester, ssh, details: true);
      await tester.pumpAndSettle();
      final stop = find.byKey(const ValueKey('docker-action-stop'));
      await tester.ensureVisible(stop);
      await tester.tap(stop);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('docker-confirm-action')));
      await tester.pumpAndSettle();
      expect(ssh.running, isFalse);
      expect(find.text('1.25%'), findsNothing);
      final terminal = tester.widget<FilledButton>(
        find.byKey(const ValueKey('docker-open-terminal')),
      );
      expect(terminal.onPressed, isNull);
      final start = tester.widget<OutlinedButton>(
        find.byKey(const ValueKey('docker-action-start')),
      );
      expect(start.onPressed, isNotNull);
      await tester.pumpWidget(const SizedBox());
      ssh.dispose();
    },
  );
  testWidgets('Logs are fetched on demand and cleared on disconnect', (
    tester,
  ) async {
    final ssh = FakeDockerConnection();
    await launchDocker(tester, ssh, details: true);
    await tester.pumpAndSettle();
    expect(
      ssh.requests.where((r) => r.operation == DockerOperation.logs),
      isEmpty,
    );
    await tester.tap(find.text('Logs'));
    await tester.pumpAndSettle();
    expect(find.textContaining('hello from stdout'), findsOneWidget);
    expect(find.textContaining('stderr entry'), findsOneWidget);
    final reads = ssh.requests.length;
    await tester.pump(const Duration(seconds: 11));
    await tester.pumpAndSettle();
    expect(ssh.requests.length, reads);
    ssh.disconnect();
    await tester.pumpAndSettle();
    expect(find.textContaining('hello from stdout'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    ssh.dispose();
  });
  testWidgets('Container terminal uses a separate channel and fixed shell', (
    tester,
  ) async {
    final ssh = FakeDockerConnection();
    await launchDocker(tester, ssh, details: true);
    await tester.pumpAndSettle();
    final terminal = find.byKey(const ValueKey('docker-open-terminal'));
    await tester.scrollUntilVisible(
      terminal,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(terminal);
    await tester.pumpAndSettle();
    expect(ssh.openedId, dockerId);
    expect(ssh.openedShell, 'sh');
    expect(find.byKey(const ValueKey('docker-terminal')), findsOneWidget);
    await tester.tap(find.text('Ctrl+C'));
    await tester.pump();
    expect(ssh.opened!.sent, contains('\x03'));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(ssh.opened!.active, isFalse);
    expect(ssh.status, ConnectionStatus.connected);
    expect(
      ssh.terminal.buffer.getText(),
      contains('host shell remains intact'),
    );
    await tester.pumpWidget(const SizedBox());
    ssh.dispose();
  });
  testWidgets(
    'Backgrounding cancels a late detail response and clears memory',
    (tester) async {
      final ssh = FakeDockerConnection()..pending = Completer();
      await launchDocker(tester, ssh, details: true);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(ssh.lastToken!.cancelled, isTrue);
      ssh.pending!.complete(
        DockerCommandResult(jsonEncode(dockerDetail(dockerId)), '', 0),
      );
      await tester.pumpAndSettle();
      expect(find.text('nginx:alpine'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      ssh.dispose();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    },
  );
  testWidgets('Backgrounding while confirming cannot send an action later', (
    tester,
  ) async {
    final ssh = FakeDockerConnection();
    await launchDocker(tester, ssh, details: true);
    await tester.pumpAndSettle();
    final restart = find.byKey(const ValueKey('docker-action-restart'));
    await tester.ensureVisible(restart);
    await tester.tap(restart);
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.tap(find.byKey(const ValueKey('docker-confirm-action')));
    await tester.pumpAndSettle();
    expect(ssh.requests.where((r) => r.mutates), isEmpty);
    await tester.pumpWidget(const SizedBox());
    ssh.dispose();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });
  for (final language in AppLanguage.values) {
    for (final details in [false, true]) {
      testWidgets(
        'Docker ${details ? 'details' : 'list'} fits ${language.locale} with large text',
        (tester) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = 1.8;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final ssh = FakeDockerConnection();
          await launchDocker(
            tester,
            ssh,
            details: details,
            navigation: !details,
            locale: language.locale,
          );
          await tester.pumpAndSettle();
          if (!details) {
            await tester.tap(find.text('Docker'));
            await tester.pumpAndSettle();
          }
          await tester.drag(find.byType(ListView), const Offset(0, -1500));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (details) {
            final strings = tester
                .element(find.byType(DockerContainerPage))
                .l10n;
            await tester.tap(find.text(strings.coolifyLogs));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          await tester.pumpWidget(const SizedBox());
          if (details) ssh.dispose();
        },
      );
    }
  }
}
