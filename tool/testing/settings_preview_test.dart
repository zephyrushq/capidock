// Local fixture previews only: flutter test tool/testing/settings_preview_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:capidock/app.dart';
import 'package:capidock/features/coolify/data/coolify_access.dart';
import 'package:capidock/features/coolify/presentation/coolify_access_button.dart';
import 'package:capidock/features/settings/app_preferences.dart';
import 'package:capidock/features/workspaces/domain/dock_controller.dart';
import 'package:capidock/l10n/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/test_support.dart';

void main() {
  testWidgets('Render settings, welcome and observed token access', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final sdk = Platform.environment['FLUTTER_ROOT'];
      if (sdk == null) {
        throw StateError('Set FLUTTER_ROOT to the Flutter SDK directory');
      }
      final font = FontLoader('Roboto');
      font.addFont(
        File('$sdk/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf')
            .readAsBytes()
            .then(ByteData.sublistView),
      );
      await font.load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    final controller = DockController(MemoryWorkspaceStore());
    await controller.initialize();
    final locales = LocaleController(
      initialLocale: const Locale('pt', 'PT'),
      preferences: MemoryPreferences(),
    );
    final prefs = AppPreferences(preferences: MemoryPreferences());
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: CapidockApp(
          controller: controller,
          localeController: locales,
          preferences: prefs,
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
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final pixels = await boundary.toImage(pixelRatio: 2);
        final bytes = await pixels.toByteData(format: ui.ImageByteFormat.png);
        final directory = Directory('build/previews')
          ..createSync(recursive: true);
        await File('${directory.path}/$name.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        pixels.dispose();
      });
    }

    await capture('welcome-refined');
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await capture('app-settings');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    final access = CoolifyAccess()
      ..succeeded('GET', '/projects')
      ..refused({'write', 'read:sensitive'});
    final context = tester.element(find.byType(Scaffold));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Coolify')),
          body: CoolifyAccessButton(access: access),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();
    await capture('token-access');
    await tester.pumpWidget(const SizedBox());
    access.dispose();
    controller.dispose();
    locales.dispose();
    prefs.dispose();
  });
}
