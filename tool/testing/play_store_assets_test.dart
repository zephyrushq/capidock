// Render actual Flutter screens and branded assets for the Google Play listing.
// Run with: FLUTTER_ROOT=/path/to/flutter flutter test tool/testing/play_store_assets_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:capidock/app.dart';
import 'package:capidock/l10n/locale_controller.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/test_support.dart';

const storeDevices = [
  (name: 'phone', size: Size(1080, 1920), ratio: 2.5),
  (name: 'tablet-7', size: Size(1920, 1080), ratio: 1.5),
  (name: 'tablet-10', size: Size(2560, 1440), ratio: 1.6),
];

Future<void> renderBrandAssets(String tag) async {
  final copy = jsonDecode(
    await File('docs/play-store/$tag/listing.json').readAsString(),
  ) as Map<String, dynamic>;
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) throw StateError('Set FLUTTER_ROOT to your Flutter SDK.');
  final font = FontLoader('Roboto')
    ..addFont(
      File('$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf')
          .readAsBytes()
          .then(ByteData.sublistView),
    );
  await font.load();
  final codec = await ui.instantiateImageCodec(
    await File('assets/branding/capidock-mark.png').readAsBytes(),
  );
  final mark = (await codec.getNextFrame()).image;
  final source = Rect.fromLTWH(
    0,
    0,
    mark.width.toDouble(),
    mark.height.toDouble(),
  );
  Future<void> save(
    ui.PictureRecorder recorder,
    String name,
    int w,
    int h,
  ) async {
    final picture = recorder.endRecording();
    final pixels = await picture.toImage(w, h);
    final bytes = await pixels.toByteData(format: ui.ImageByteFormat.png);
    await File('docs/play-store/$tag/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    pixels.dispose();
    picture.dispose();
  }

  final iconRecorder = ui.PictureRecorder();
  final iconCanvas = Canvas(iconRecorder);
  iconCanvas.drawRect(
    const Rect.fromLTWH(0, 0, 512, 512),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff39205c), Color(0xff160e2b)],
      ).createShader(const Rect.fromLTWH(0, 0, 512, 512)),
  );
  iconCanvas.drawImageRect(
    mark,
    source,
    const Rect.fromLTWH(12, 12, 488, 488),
    Paint()..filterQuality = FilterQuality.high,
  );
  await save(iconRecorder, 'app-icon', 512, 512);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  const bounds = Rect.fromLTWH(0, 0, 1024, 500);
  canvas.drawRect(
    bounds,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xff2d1652), Color(0xff431f75), Color(0xff211039)],
      ).createShader(bounds),
  );
  final line = Paint()
    ..color = const Color(0xff9260cf).withValues(alpha: .18)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  for (var i = 0; i < 6; i++) {
    canvas.drawCircle(Offset(980, 250), 160 + i * 45, line);
  }
  void text(
    String value,
    double x,
    double y,
    double size,
    Color colour, {
    FontWeight weight = FontWeight.w400,
    double? spacing,
    double maxWidth = 490,
  }) {
    TextPainter measure(double fontSize) => TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: fontSize,
          fontWeight: weight,
          color: colour,
          letterSpacing: spacing,
          height: 1.08,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var painter = measure(size);
    while (painter.width > maxWidth && size > 12) {
      painter.dispose();
      size -= .5;
      painter = measure(size);
    }
    expect(painter.width, lessThanOrEqualTo(maxWidth), reason: '$tag: $value');
    painter.paint(canvas, Offset(x, y));
    painter.dispose();
  }

  const white = Color(0xfff5efff);
  const lavender = Color(0xffc8acec);
  canvas.drawImageRect(
    mark,
    source,
    const Rect.fromLTWH(83, 55, 52, 52),
    Paint()..filterQuality = FilterQuality.high,
  );
  text('Capidock', 145, 65, 32, white, weight: FontWeight.w700);
  text(
    copy['headline'][0] as String,
    96,
    154,
    61,
    white,
    weight: FontWeight.w700,
  );
  text(
    copy['headline'][1] as String,
    96,
    224,
    61,
    white,
    weight: FontWeight.w700,
  );
  text(copy['subtitle'] as String, 98, 313, 20, lavender);
  text(
    copy['topics'] as String,
    98,
    407,
    17,
    lavender,
    spacing: 1,
    maxWidth: 830,
  );

  const panel = Rect.fromLTWH(635, 95, 291, 276);
  canvas.drawRRect(
    RRect.fromRectAndRadius(panel, const Radius.circular(20)),
    Paint()..color = const Color(0xff25143e),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(panel, const Radius.circular(20)),
    Paint()
      ..color = const Color(0xff8054ac)
      ..style = PaintingStyle.stroke,
  );
  text('Homelab', 660, 118, 22, white, weight: FontWeight.w700);
  text('WORKSPACE', 660, 148, 11, lavender, spacing: 1.4);
  final rows = [
    ('homelab-server', 'SSH'),
    ('coolify', 'Coolify'),
    ('staging-server', 'SSH'),
  ];
  for (var i = 0; i < rows.length; i++) {
    final y = 180.0 + i * 57;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(651, y, 259, 47),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xff35204f),
    );
    if (i == 1) {
      final diamond = Path()
        ..moveTo(675, y + 13)
        ..lineTo(685, y + 23)
        ..lineTo(675, y + 33)
        ..lineTo(665, y + 23)
        ..close();
      canvas.drawPath(diamond, Paint()..color = lavender);
    } else {
      text('>_', 664, y + 13, 19, lavender);
    }
    text(rows[i].$1, 699, y + 8, 16, white);
    text(rows[i].$2, 699, y + 28, 11, lavender);
  }
  await save(recorder, 'feature-graphic', 1024, 500);
  mark.dispose();
  codec.dispose();
}

void main() {
  for (final language in AppLanguage.values) {
    final locale = language.locale;
    final tag = locale.toLanguageTag();
    testWidgets('Render $tag store icon and feature graphic', (tester) async {
      await tester.runAsync(() => renderBrandAssets(tag));
    });
    for (final device in storeDevices) {
      for (final view in [
        'welcome',
        'connection',
        'overview',
        'channels',
        'coolify',
      ]) {
        testWidgets('Render $tag ${device.name} $view preview', (tester) async {
          tester.view.physicalSize = device.size;
          tester.view.devicePixelRatio = device.ratio;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          // Widget tests use Ahem by default; load the SDK's real font for documentation.
          await tester.runAsync(() async {
            final root = Platform.environment['FLUTTER_ROOT'];
            if (root == null) {
              throw StateError(
                'Set FLUTTER_ROOT to the Flutter SDK directory.',
              );
            }
            final font = FontLoader('Roboto');
            font.addFont(
              File(
                '$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
              ).readAsBytes().then(ByteData.sublistView),
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
              child: CapidockApp(
                controller: controller,
                localeController: LocaleController(
                  initialLocale: locale,
                  preferences: MemoryPreferences(),
                ),
              ),
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
              final pixels = await boundary.toImage(pixelRatio: device.ratio);
              final bytes = await pixels.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final folder = Directory('docs/play-store/$tag/${device.name}');
              await folder.create(recursive: true);
              await File('${folder.path}/$name.png')
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
            await tester.tap(find.byKey(const ValueKey('language-selector')));
            await tester.pumpAndSettle();
            await capture('languages');
            return;
          }
          await tester.enterText(
            find.byKey(const ValueKey('onboarding-workspace')),
            'Homelab',
          );
          await next();
          await tester.enterText(
            find.byKey(const ValueKey('instance-name')),
            'homelab-server',
          );
          await next();

          await tester.enterText(
            find.byKey(const ValueKey('instance-host')),
            'server.example.com',
          );
          await tester.enterText(
            find.byKey(const ValueKey('instance-user')),
            'deploy',
          );
          await tester.enterText(
            find.byKey(const ValueKey('instance-password')),
            'preview-only',
          );
          if (view == 'connection') {
            FocusManager.instance.primaryFocus?.unfocus();
            await capture(view);
            return;
          }
          await next();
          if (view == 'overview') {
            await capture(view);
            return;
          }
          await controller.upsert(
            const ServerInstance(
              id: 'preview-coolify',
              name: 'coolify',
              type: InstanceType.coolify,
              host: 'https://coolify.example.com',
              port: 443,
              apiToken: 'preview-only',
            ),
          );
          await controller.upsert(
            const ServerInstance(
              id: 'preview-staging',
              name: 'staging-server',
              type: InstanceType.ssh,
              host: 'staging.example.com',
              port: 22,
              username: 'deploy',
              password: 'preview-only',
            ),
          );
          controller.select(
            view == 'coolify'
                ? 'preview-coolify'
                : controller.instances.first.id,
          );
          await tester.pumpAndSettle();
          if (view == 'coolify') {
            await capture(view);
            return;
          }
          // Wide tablet layouts already show the instance navigation sidebar.
          if (device.size.width / device.ratio < 900) {
            // Resolve the tooltip from the MaterialApp subtree, which owns localisation.
            final workspaceContext = tester.element(
              find.byKey(const ValueKey('language-selector')).first,
            );
            await tester.tap(
              find.byTooltip(workspaceContext.l10n.openInstances),
            );
            await tester.pumpAndSettle();
          }
          await capture('channels');
          await tester.pumpWidget(const SizedBox.shrink());
        });
      }
    }
  }
}
