import 'package:flutter/widgets.dart';

/// Present only inside an authenticated app. No insecure fallback authentication.
class SecurityControls extends InheritedWidget {
  const SecurityControls({
    super.key,
    required super.child,
    required this.lock,
    required this.clearData,
  });
  final VoidCallback lock;
  final Future<void> Function(String reason) clearData;
  static SecurityControls? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SecurityControls>();
  @override
  bool updateShouldNotify(SecurityControls oldWidget) => false;
}
