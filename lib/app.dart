import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'features/monitoring/foreground_monitor.dart';
import 'features/monitoring/monitor_alert_overlay.dart';
import 'features/settings/app_preferences.dart';
import 'features/workspaces/domain/dock_controller.dart';
import 'features/workspace/workspace_screen.dart';
import 'l10n/locale_controller.dart';
import 'l10n/localization.dart';

class CapidockApp extends StatefulWidget {
  const CapidockApp({
    super.key,
    required this.controller,
    this.localeController,
    this.preferences,
  });
  final DockController controller;
  final LocaleController? localeController;
  final AppPreferences? preferences;
  @override
  State<CapidockApp> createState() => _CapidockAppState();
}

class _CapidockAppState extends State<CapidockApp> {
  late final LocaleController _locales =
      widget.localeController ?? LocaleController();
  late final AppPreferences _preferences =
      widget.preferences ?? AppPreferences();
  @override
  void dispose() {
    if (widget.localeController == null) _locales.dispose();
    if (widget.preferences == null) _preferences.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPreferencesScope(
    controller: _preferences,
    child: AppLocaleScope(
      controller: _locales,
      child: ListenableBuilder(
        listenable: _locales,
        builder: (context, _) => MaterialApp(
          title: 'Capidock',
          builder: (context, child) =>
              MonitorAlertOverlay(child: child ?? const SizedBox()),
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          themeMode: ThemeMode.dark,
          darkTheme: buildTheme(),
          locale: _locales.locale,
          supportedLocales: AppLanguage.values.map(
            (language) => language.locale,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: ForegroundMonitor(
            controller: widget.controller,
            child: WorkspaceScreen(controller: widget.controller),
          ),
        ),
      ),
    ),
  );
}
