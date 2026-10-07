// Run with: flutter test tool/testing/preview_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:capidock/app.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/test_support.dart';

void main() {
  for (final view in ['welcome', 'connection', 'overview', 'channels']) {
    testWidgets('Render $view preview', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      // Widget tests use Ahem by default; load the SDK's real font for documentation.
      await tester.runAsync(() async {
        final root = Platform.environment['FLUTTER_ROOT'];
        if (root == null) {
          throw StateError('Set FLUTTER_ROOT to the Flutter SDK directory.');
        }
        final font = FontLoader('Roboto');
        font.addFont(
          File('$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf')
              .readAsBytes()
              .then(ByteData.sublistView),
        );
        await font.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
      final controller = DockController(MemoryWorkspaceStore());
      await controller.initialize();
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: CapidockApp(controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
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
          await File('docs/previews/$name.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          pixels.dispose();
        });
      }

      Future<void> next() async {
        await tester.ensureVisible(
          find.byKey(const ValueKey('onboarding-next')),
        );
        await tester.tap(find.byKey(const ValueKey('onboarding-next')));
        await tester.pumpAndSettle();
      }

      if (view == 'welcome') {
        await capture(view);
        return;
      }
      await tester.enterText(
        find.byKey(const ValueKey('onboarding-workspace')),
        'Homelab',
      );
      await next();
      await tester.enterText(
        find.byKey(const ValueKey('instance-name')),
        'servidor-pessoal',
      );
      await next();
      if (view == 'connection') {
        await capture(view);
        return;
      }
      await tester.enterText(
        find.byKey(const ValueKey('instance-host')),
        'servidor.exemplo.pt',
      );
      await tester.enterText(
        find.byKey(const ValueKey('instance-user')),
        'deploy',
      );
      await tester.enterText(
        find.byKey(const ValueKey('instance-password')),
        'preview-only',
      );
      await next();
      if (view == 'overview') {
        await capture(view);
        return;
      }
      await tester.tap(find.byTooltip('Abrir instâncias'));
      await tester.pumpAndSettle();
      await capture('channels');
    });
  }
}
