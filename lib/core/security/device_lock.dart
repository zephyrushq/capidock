import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../app.dart';
import '../../features/legal/legal_page.dart';
import '../../features/workspaces/domain/dock_controller.dart';
import '../../l10n/locale_controller.dart';
import '../../l10n/localization.dart';
import '../app_theme.dart';
import 'security_controls.dart';
import '../../features/settings/app_preferences.dart';

abstract interface class DeviceAuthenticator {
  Future<bool> unlock(String reason);
}

class PlatformDeviceAuthenticator implements DeviceAuthenticator {
  final _auth = LocalAuthentication();
  @override
  Future<bool> unlock(String reason) async {
    if (!await _auth.isDeviceSupported()) return false;
    return _auth.authenticate(localizedReason: reason);
  }
}

/// Unmounts the entire navigator and its sessions before dropping vault references.
class DeviceLock extends StatefulWidget {
  const DeviceLock({
    super.key,
    required this.controller,
    required this.locales,
    required this.authenticator,
  });
  final DockController controller;
  final LocaleController locales;
  final DeviceAuthenticator authenticator;
  @override
  State<DeviceLock> createState() => _DeviceLockState();
}

class _DeviceLockState extends State<DeviceLock> with WidgetsBindingObserver {
  bool _unlocked = false, _busy = false, _obscured = false;
  bool _authenticating = false;
  int _generation = 0;
  final _preferences = AppPreferences();
  String? _resetError;
  bool _erasing = false;
  void _lockNow() {
    _generation++;
    widget.controller.lock();
    setState(() {
      _unlocked = false;
      _obscured = false;
    });
  }

  Future<void> _clearData(String reason) async {
    if (_busy || _authenticating || _erasing) return;
    final current = _generation;
    _authenticating = true;
    bool accepted = false;
    try {
      accepted = await widget.authenticator.unlock(reason);
    } catch (_) {}
    _authenticating = false;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (!mounted || current != _generation) return;
    if (lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.hidden ||
        lifecycle == AppLifecycleState.detached) {
      _lockNow();
      return;
    }
    if (!accepted) return;
    _lockNow();
    _erasing = true;
    setState(() {
      _busy = true;
      _resetError = null;
    });
    // Dispose navigators, terminals and trust dialogs before erasing their storage.
    await WidgetsBinding.instance.endOfFrame;
    try {
      await widget.controller.clearLocalData();
    } catch (_) {
      if (mounted) setState(() => _resetError = 'localEraseFailed');
    }
    _erasing = false;
    if (mounted) setState(() => _busy = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _preferences.initialize();
  }

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    _preferences.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // OS authentication itself can temporarily make the activity inactive.
    if (_authenticating) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _generation++;
      widget.controller.lock();
      setState(() {
        _unlocked = false;
        _busy = false;
        _obscured = false;
      });
    } else {
      setState(() => _obscured = state == AppLifecycleState.inactive);
    }
  }

  Future<void> _unlock(String reason) async {
    if (_busy || _erasing) return;
    final current = _generation;
    setState(() => _busy = true);
    _authenticating = true;
    bool accepted = false;
    try {
      accepted = await widget.authenticator.unlock(reason);
    } catch (_) {
      // Cancellation, missing device security and platform failures stay locked.
    }
    _authenticating = false;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.hidden ||
        lifecycle == AppLifecycleState.detached) {
      accepted = false;
    }
    if (!mounted || current != _generation) return;
    if (accepted) {
      await widget.controller.initialize();
      if (!mounted || current != _generation) return;
    }
    setState(() {
      _busy = false;
      _unlocked = accepted;
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.locales,
    builder: (context, _) {
      if (_unlocked) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Offstage(
              offstage: _obscured,
              child: SecurityControls(
                lock: _lockNow,
                clearData: _clearData,
                child: CapidockApp(
                  controller: widget.controller,
                  localeController: widget.locales,
                  preferences: _preferences,
                ),
              ),
            ),
            if (_obscured)
              const Positioned.fill(
                child: ColoredBox(color: Color(0xff100f16)),
              ),
          ],
        );
      }
      return MaterialApp(
        locale: widget.locales.locale,
        supportedLocales: AppLanguage.values.map((language) => language.locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 48),
                        const SizedBox(height: 24),
                        Text(
                          context.l10n.deviceLocked,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.deviceLockHelp,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (_resetError != null)
                          Text(localizedMessage(context, _resetError!)),
                        const LegalLinks(),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _busy || _erasing
                              ? null
                              : () => _unlock(context.l10n.deviceUnlockReason),
                          child: _busy
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(),
                                )
                              : Text(context.l10n.deviceUnlock),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
