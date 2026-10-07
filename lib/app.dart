import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_theme.dart';
import 'features/workspaces/domain/dock_controller.dart';
import 'features/workspace/workspace_screen.dart';

class CapidockApp extends StatelessWidget {
  const CapidockApp({super.key, required this.controller});
  final DockController controller;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Capidock',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    themeMode: ThemeMode.dark,
    darkTheme: buildTheme(),
    locale: const Locale('pt', 'PT'),
    supportedLocales: const [Locale('pt', 'PT')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: WorkspaceScreen(controller: controller),
  );
}
