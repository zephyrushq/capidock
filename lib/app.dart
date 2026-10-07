import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/workspaces/domain/dock_controller.dart';
import 'features/workspace/workspace_screen.dart';
import 'l10n/locale_controller.dart';
import 'l10n/localization.dart';

class CapidockApp extends StatefulWidget {
  const CapidockApp({
    super.key,
    required this.controller,
    this.localeController,
  });
  final DockController controller;
  final LocaleController? localeController;
  @override
  State<CapidockApp> createState() => _CapidockAppState();
}

class _CapidockAppState extends State<CapidockApp> {
  late final LocaleController _locales =
      widget.localeController ?? LocaleController();
  @override
  void dispose() {
    if (widget.localeController == null) _locales.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppLocaleScope(
    controller: _locales,
    child: ListenableBuilder(
      listenable: _locales,
      builder: (context, _) => MaterialApp(
        title: 'Capidock',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        themeMode: ThemeMode.dark,
        darkTheme: buildTheme(),
        locale: _locales.locale,
        supportedLocales: AppLanguage.values.map((language) => language.locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: WorkspaceScreen(controller: widget.controller),
      ),
    ),
  );
}
