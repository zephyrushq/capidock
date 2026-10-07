import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  const AppLanguage(this.locale, this.name);
  final Locale locale;
  final String name;
  static const values = [
    AppLanguage(Locale('en', 'GB'), 'English (United Kingdom)'),
    AppLanguage(Locale('en', 'US'), 'English (United States)'),
    AppLanguage(Locale('pt', 'PT'), 'Português (Portugal)'),
    AppLanguage(Locale('pt', 'BR'), 'Português (Brasil)'),
    AppLanguage(Locale('es', 'ES'), 'Español (España)'),
  ];
}

class LocaleController extends ChangeNotifier {
  LocaleController({
    Locale initialLocale = const Locale('pt', 'PT'),
    SharedPreferencesAsync? preferences,
  }) : _locale = resolve([initialLocale]),
       _preferences = preferences ?? SharedPreferencesAsync();
  static const preferenceKey = 'capidock.language.v1';
  final SharedPreferencesAsync _preferences;
  Locale _locale;
  bool _saving = false;
  Locale get locale => _locale;
  AppLanguage get language =>
      AppLanguage.values.firstWhere((l) => l.locale == locale);
  static Locale resolve(List<Locale> preferred) {
    for (final locale in preferred) {
      for (final language in AppLanguage.values) {
        if (language.locale == locale) return language.locale;
      }
      for (final language in AppLanguage.values) {
        if (language.locale.languageCode == locale.languageCode) {
          return language.locale;
        }
      }
    }
    return const Locale('en', 'GB');
  }

  Future<void> initialize(List<Locale> deviceLocales) async {
    Locale? saved;
    try {
      final tag = await _preferences.getString(preferenceKey);
      for (final language in AppLanguage.values) {
        if (language.locale.toLanguageTag() == tag) saved = language.locale;
      }
    } catch (_) {
      // Preference failures must never prevent access to workspaces.
    }
    _locale = saved ?? resolve(deviceLocales);
    notifyListeners();
  }

  Future<void> select(Locale locale) async {
    if (_saving || locale == _locale) return;
    if (!AppLanguage.values.any((l) => l.locale == locale)) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported locale');
    }
    _saving = true;
    try {
      await _preferences.setString(preferenceKey, locale.toLanguageTag());
      _locale = locale;
      notifyListeners();
    } finally {
      _saving = false;
    }
  }
}

class AppLocaleScope extends InheritedNotifier<LocaleController> {
  const AppLocaleScope({
    super.key,
    required LocaleController controller,
    required super.child,
  }) : super(notifier: controller);
  static LocaleController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppLocaleScope>()!.notifier!;
}
