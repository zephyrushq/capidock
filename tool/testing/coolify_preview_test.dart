// Internal UI review with synthetic API responses; never use these as store screenshots.
// FLUTTER_ROOT=/path/to/flutter flutter test tool/testing/coolify_preview_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:capidock/core/app_theme.dart';
import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/coolify/data/coolify_catalog.dart';
import 'package:capidock/features/coolify/data/coolify_session.dart';
import 'package:capidock/features/coolify/presentation/coolify_workspace_page.dart';
import 'package:capidock/features/coolify/presentation/coolify_hierarchy_page.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final tablet in [false, true]) {
    testWidgets('Coolify internal preview ${tablet ? 'tablet' : 'phone'}', (
      tester,
    ) async {
      tester.view.physicalSize = tablet
          ? const Size(1280, 800)
          : const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        final font = FontLoader('Roboto')
          ..addFont(
            File(
              '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
            ).readAsBytes().then(ByteData.sublistView),
          );
        await font.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
        // Flutter widget tests do not resolve system monospace fonts.
        final mono = FontLoader('monospace')
          ..addFont(
            File(
              Platform.environment['COOLIFY_PREVIEW_MONO_FONT'] ?? '/usr/share/fonts/liberation-mono-fonts/LiberationMono-Regular.ttf',
            ).readAsBytes().then(ByteData.sublistView),
          );
        await mono.load();
      });
      final catalog = (await tester.runAsync(CoolifyCatalog.load))!;
      const instance = ServerInstance(
        id: 'fixture',
        name: 'Internal preview',
        type: InstanceType.coolify,
        host: 'https://fixture.example.com',
        port: 443,
        apiToken: 'fixture',
      );
      final session = CoolifySession(
        instance,
        createClient: () => CoolifyClient(
          client: MockClient(
            (request) async => http.Response(
              request.url.path.endsWith('/environments')
                  ? '[{"uuid":"fixture-env","name":"production"}]'
                  : request.url.path.endsWith('/fixture-env')
                  ? '{"name":"production","description":"Ambiente de demonstração visual","applications":[{"uuid":"app","name":"Web application","status":"running:healthy","fqdn":"app.example.com"},{"uuid":"queue","name":"Queue worker","status":"running:healthy"}],"postgresqls":[{"uuid":"db","name":"PostgreSQL","status":"running:healthy"}],"redis":[{"uuid":"redis","name":"Redis","status":"running:healthy"}]}'
                  : request.url.path.endsWith('/fixture-project')
                  ? '{"name":"Internal preview","description":"Projeto de demonstração visual"}'
                  : request.url.path.endsWith('/envs')
                  ? '[{"key":"APP_ENV","value":"production","is_preview":false},{"key":"DATABASE_URL","value":"private-fixture","is_preview":false},{"key":"API_URL","value":"https://preview.example.com","is_preview":true}]'
                  : '{"uuid":"fixture-app","name":"Internal preview","status":"running:healthy","fqdn":"https://fixture.example.com","description":"Synthetic response for layout review"}',
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            ),
          ),
        ),
      );
      addTearDown(session.dispose);
      final boundaryKey = GlobalKey();
      await tester.runAsync(() async {
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: MaterialApp(
              theme: buildTheme(),
              locale: const Locale('pt', 'PT'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: CoolifyResourcePage(
                session: session,
                catalog: catalog,
                collection: 'applications',
                uuid: 'fixture-app',
                name: 'Internal preview',
                onTerminal: () {},
              ),
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await tester.pumpAndSettle();
      for (final environment in [false, true]) {
        if (environment) {
          await tester.runAsync(() async {
            await tester.tap(find.text('Variáveis de ambiente'));
            await Future<void>.delayed(const Duration(milliseconds: 20));
          });
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        expect(
          find.textContaining('A API devolveu uma resposta inesperada'),
          findsNothing,
        );
        await tester.runAsync(() async {
          final boundary =
              boundaryKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/tmp/capidock-coolify-${tablet ? 'tablet' : 'phone'}-${environment ? 'env' : 'details'}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      for (final environment in [false, true]) {
        await tester.runAsync(() async {
          await tester.pumpWidget(
            RepaintBoundary(
              key: boundaryKey,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: buildTheme(),
                locale: const Locale('pt', 'PT'),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                home: CoolifyHierarchyPage(
                  key: ValueKey(environment),
                  session: session,
                  catalog: catalog,
                  kind: environment ? 'environments' : 'projects',
                  uuid: environment ? 'fixture-env' : 'fixture-project',
                  projectUuid: environment ? 'fixture-project' : null,
                  projectName: environment ? 'Internal preview' : null,
                  name: environment ? 'production' : 'Internal preview',
                  onTerminal: () {},
                ),
              ),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 30));
        });
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.textContaining('A API devolveu uma resposta inesperada'),
          findsNothing,
        );
        await tester.runAsync(() async {
          final boundary =
              boundaryKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '/tmp/capidock-coolify-${tablet ? 'tablet' : 'phone'}-${environment ? 'environment' : 'project'}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
