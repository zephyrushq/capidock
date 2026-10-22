// Run with FLUTTER_ROOT set to the Flutter SDK directory.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:capidock/core/app_theme.dart';
import 'package:capidock/features/connections/presentation/instance_connection_page.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/docker_test_support.dart';

void main() {
  testWidgets(
    'Render Docker list, details and logs with preview-only observations',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        final root = Platform.environment['FLUTTER_ROOT']!;
        final font = FontLoader('Roboto')
          ..addFont(
            File('$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf')
                .readAsBytes()
                .then(ByteData.sublistView),
          );
        await font.load();
        final monoPath = Platform.environment['CAPIDOCK_MONO_FONT'];
        final mono = FontLoader('monospace')
          ..addFont(
            File(
              monoPath ??
                  '$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
            ).readAsBytes().then(ByteData.sublistView),
          );
        await mono.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
      final ssh = FakeDockerConnection();
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            locale: const Locale('pt', 'BR'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: Scaffold(
              appBar: AppBar(title: const Text('servidor-pessoal')),
              body: InstanceConnectionPage(
                instance: ssh.instance,
                onEdit: () {},
                createConnection: (_) => ssh,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Docker'));
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        expect(tester.takeException(), isNull);
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final pixels = await boundary.toImage(pixelRatio: 2);
          final bytes = await pixels.toByteData(format: ui.ImageByteFormat.png);
          await File('docs/previews/docker-$name.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          pixels.dispose();
        });
      }

      await capture('containers');
      await tester.tap(find.byKey(ValueKey('docker-container-$dockerId')));
      await tester.pumpAndSettle();
      await capture('details');
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();
      await capture('logs');
      await tester.pumpWidget(const SizedBox());
    },
  );
}
