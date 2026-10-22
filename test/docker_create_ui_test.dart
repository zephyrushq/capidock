import 'dart:async';

import 'package:capidock/core/app_theme.dart';
import 'package:capidock/features/docker/data/docker_command.dart';
import 'package:capidock/features/docker/presentation/docker_container_page.dart';
import 'package:capidock/features/docker/presentation/docker_create_page.dart';
import 'package:capidock/features/docker/presentation/docker_panel.dart';
import 'package:capidock/l10n/locale_controller.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'docker_test_support.dart';

Future<void> launch(
  WidgetTester tester,
  FakeDockerConnection ssh, {
  bool panel = false,
  Locale locale = const Locale('en', 'GB'),
}) => tester.pumpWidget(
  MaterialApp(
    theme: buildTheme(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: panel
        ? Scaffold(
            body: DockerPanel(connection: ssh, connect: () async {}),
          )
        : DockerCreatePage(connection: ssh),
  ),
);
Future<void> goTo(WidgetTester tester, String key) async {
  final scroll = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scroll).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(
    find.byKey(ValueKey(key)),
    160,
    scrollable: scroll,
  );
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String key, String text) async {
  await goTo(tester, key);
  await tester.enterText(find.byKey(ValueKey(key)), text);
  await tester.pump();
}

Future<void> tap(WidgetTester tester, String key) async {
  await goTo(tester, key);
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
}

Future<void> identity(WidgetTester tester) async {
  await enter(tester, 'docker-create-image', 'nginx:alpine');
  await enter(tester, 'docker-create-name', 'new-web');
}

void pause(WidgetTester tester) {
  for (final state in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

void resume(WidgetTester tester) {
  for (final state in [
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

void main() {
  testWidgets(
    'Creation entry validates and sends nothing before final confirmation',
    (tester) async {
      final ssh = FakeDockerConnection();
      await launch(tester, ssh, panel: true);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('docker-create-container')));
      await tester.pumpAndSettle();
      await tap(tester, 'docker-review-create');
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        ssh.requests.where((r) => r.operation == DockerOperation.create),
        isEmpty,
      );
      await identity(tester);
      await tap(tester, 'docker-add-port');
      await enter(tester, 'docker-port-host-0', '8080');
      await enter(tester, 'docker-port-target-0', '80');
      await tap(tester, 'docker-add-env');
      await enter(tester, 'docker-env-name-0', 'TOKEN');
      await enter(tester, 'docker-env-value-0', "test-secret ' \$(id)");
      await tap(tester, 'docker-add-mount');
      await enter(tester, 'docker-mount-source-0', 'web-data');
      await enter(tester, 'docker-mount-target-0', '/data');
      await tap(tester, 'docker-review-create');
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.textContaining('test-secret'),
        ),
        findsNothing,
      );
      expect(find.text('TOKEN=••••'), findsOneWidget);
      expect(
        ssh.requests.where((r) => r.operation == DockerOperation.create),
        isEmpty,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tap(tester, 'docker-review-create');
      await tester.tap(find.byKey(const ValueKey('docker-confirm-create')));
      await tester.pumpAndSettle();
      expect(
        ssh.requests.where((r) => r.operation == DockerOperation.create),
        hasLength(1),
      );
      expect(
        ssh.requests.where((r) => r.operation == DockerOperation.start),
        isEmpty,
      );
      expect(ssh.createdSpec!.environment.single.value, "test-secret ' \$(id)");
      expect(ssh.createdSpec!.ports.single.binding, '127.0.0.1:8080:80/tcp');
      expect(ssh.createdSpec!.mounts.single.source, 'web-data');
      expect(find.byType(DockerContainerPage), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      ssh.dispose();
    },
  );
  testWidgets(
    'Unknown create outcome blocks resubmission and automatic retries',
    (tester) async {
      final ssh = FakeDockerConnection()
        ..failure = const DockerException(DockerFailure.timeout)
        ..failingOperation = DockerOperation.create;
      await launch(tester, ssh);
      await tester.pumpAndSettle();
      await identity(tester);
      await tap(tester, 'docker-review-create');
      await tester.tap(find.byKey(const ValueKey('docker-confirm-create')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('docker-review-create')), findsNothing);
      expect(find.textContaining('The container may exist.'), findsOneWidget);
      await tester.pump(const Duration(minutes: 4));
      await tester.pumpAndSettle();
      expect(
        ssh.requests.where((r) => r.operation == DockerOperation.create),
        hasLength(1),
      );
      await tester.pumpWidget(const SizedBox());
      ssh.dispose();
    },
  );
  testWidgets(
    'Background clears the secret draft and dismisses review without creating',
    (tester) async {
      final ssh = FakeDockerConnection();
      await launch(tester, ssh);
      await tester.pumpAndSettle();
      await identity(tester);
      await tap(tester, 'docker-add-env');
      await enter(tester, 'docker-env-name-0', 'TOKEN');
      await enter(tester, 'docker-env-value-0', 'private-value');
      await tap(tester, 'docker-review-create');
      pause(tester);
      resume(tester);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(ssh.requests.where((r) => r.mutates), isEmpty);
      await goTo(tester, 'docker-env-value-0');
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('docker-env-value-0')))
            .controller!
            .text,
        isEmpty,
      );
      await tester.pumpWidget(const SizedBox());
      ssh.dispose();
    },
  );
  testWidgets('Disconnect cancels pending creation and ignores late success', (
    tester,
  ) async {
    final ssh = FakeDockerConnection();
    await launch(tester, ssh);
    await tester.pumpAndSettle();
    await identity(tester);
    await tap(tester, 'docker-review-create');
    ssh.pending = Completer();
    await tester.tap(find.byKey(const ValueKey('docker-confirm-create')));
    await tester.pump();
    final token = ssh.lastToken!;
    ssh.disconnect();
    await tester.pump();
    expect(token.cancelled, isTrue);
    ssh.pending!.complete(DockerCommandResult(ssh.createdId, '', 0));
    await tester.pumpAndSettle();
    expect(find.byType(DockerCreatePage), findsOneWidget);
    await goTo(tester, 'docker-create-expired');
    expect(find.textContaining('draft was cleared'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    ssh.dispose();
  });
  for (final language in AppLanguage.values) {
    testWidgets(
      'Creation form and review fit ${language.locale} with enlarged text',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.8;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final ssh = FakeDockerConnection();
        await launch(tester, ssh, locale: language.locale);
        await tester.pumpAndSettle();
        await identity(tester);
        await tap(tester, 'docker-add-port');
        await enter(tester, 'docker-port-host-0', '8080');
        await enter(tester, 'docker-port-target-0', '80');
        await tap(tester, 'docker-add-env');
        await enter(tester, 'docker-env-name-0', 'TOKEN');
        await enter(tester, 'docker-env-value-0', 'secret');
        await tap(tester, 'docker-add-mount');
        await enter(tester, 'docker-mount-source-0', 'data');
        await enter(tester, 'docker-mount-target-0', '/data');
        await tap(tester, 'docker-review-create');
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        ssh.dispose();
      },
    );
  }
}
