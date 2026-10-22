// Run with FLUTTER_ROOT set to the Flutter SDK directory.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:capidock/core/app_theme.dart';
import 'package:capidock/features/monitoring/monitor_state.dart';
import 'package:capidock/features/workspace/workspace_screen.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/workspace_overview_test.dart' as fixtures;

void main() {
  for (final width in [390.0, 1024.0]) {
    testWidgets('Render workspace dashboard at $width', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
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
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
      final controller = await fixtures.controller();
      final now = DateTime.now().millisecondsSinceEpoch;
      // Preview-only observations never enter the production vault.
      final service = fixtures.OverviewService()
        ..states = {
          'test-production': MonitorState(
            lastObservation: {'at': now - 60000, 'health': 'up'},
            events: [
              {'at': now - 60000, 'kind': 'deploymentSucceeded'},
              {'at': now - 180000, 'kind': 'deploymentStarted'},
            ],
          ),
          'test-staging': MonitorState(
            lastObservation: {'at': now - 120000, 'health': 'authentication'},
          ),
        };
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            locale: const Locale('pt', 'PT'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: WorkspaceScreen(
              controller: controller,
              monitorService: service,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        for (final element in find.byType(Image).evaluate()) {
          await precacheImage((element.widget as Image).image, element);
        }
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final pixels = await boundary.toImage(pixelRatio: 2);
        final bytes = await pixels.toByteData(format: ui.ImageByteFormat.png);
        await File('docs/previews/workspace-dashboard-${width.toInt()}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        pixels.dispose();
      });
      await tester.pumpWidget(const SizedBox());
    });
  }
}
