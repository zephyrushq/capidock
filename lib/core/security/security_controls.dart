import 'package:flutter/widgets.dart';

typedef ProtectedDocumentAction = Future<T?> Function<T>(
  String reason,
  Future<T?> Function() action,
);

/// Present only inside an authenticated app. No insecure fallback authentication.
class SecurityControls extends InheritedWidget {
  const SecurityControls({
    super.key,
    required super.child,
    required this.lock,
    required this.clearData,
    this.reauthenticate,
    this.documentAction,
  });
  final VoidCallback lock;
  final Future<void> Function(String reason) clearData;
  final Future<bool> Function(String reason)? reauthenticate;
  final ProtectedDocumentAction? documentAction;
  static SecurityControls? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SecurityControls>();
  @override
  bool updateShouldNotify(SecurityControls oldWidget) => false;
}
