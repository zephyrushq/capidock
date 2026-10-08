import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/security/device_lock.dart';
import 'l10n/locale_controller.dart';
import 'features/workspaces/data/workspace_store.dart';
import 'features/workspaces/domain/dock_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  final controller = DockController(SecureWorkspaceStore());
  final locales = LocaleController();
  await locales.initialize(WidgetsBinding.instance.platformDispatcher.locales);
  runApp(
    DeviceLock(
      controller: controller,
      locales: locales,
      authenticator: PlatformDeviceAuthenticator(),
    ),
  );
}
