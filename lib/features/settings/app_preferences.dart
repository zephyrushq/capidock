import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences({SharedPreferencesAsync? preferences})
    : _provided = preferences;
  final SharedPreferencesAsync? _provided;
  SharedPreferencesAsync? _platform;
  SharedPreferencesAsync get _preferences =>
      _provided ?? (_platform ??= SharedPreferencesAsync());
  static const terminalKey = 'capidock.terminal-font.v1';
  static const sizes = [12.0, 14.0, 16.0, 18.0];
  double terminalFontSize = 14;
  bool saving = false;
  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> initialize() async {
    try {
      final value = double.tryParse(
        await _preferences.getString(terminalKey) ?? '',
      );
      if (sizes.contains(value)) terminalFontSize = value!;
    } catch (_) {
      /* Non-sensitive preferences must not prevent unlocking. */
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> setTerminalFontSize(double value) async {
    if (saving || !sizes.contains(value)) return;
    saving = true;
    if (!_disposed) notifyListeners();
    try {
      await _preferences.setString(terminalKey, '$value');
      terminalFontSize = value;
    } finally {
      saving = false;
      if (!_disposed) notifyListeners();
    }
  }
}

class AppPreferencesScope extends InheritedNotifier<AppPreferences> {
  const AppPreferencesScope({
    super.key,
    required AppPreferences controller,
    required super.child,
  }) : super(notifier: controller);
  static AppPreferences? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppPreferencesScope>()
      ?.notifier;
}
