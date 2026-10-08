import 'package:flutter/foundation.dart';

import 'coolify_route_permissions.dart';

enum AccessEvidence { unknown, available, denied }

/// Observations are session-only, not an assertion of the token's actual scopes.
/// Public Coolify API endpoints do not expose a token's abilities or root status.
class CoolifyAccess extends ChangeNotifier {
  static const scopes = [
    'read',
    'read:sensitive',
    'write',
    'write:sensitive',
    'deploy',
    'root',
  ];
  final Map<String, AccessEvidence> _observations = {};
  AccessEvidence evidence(String scope) =>
      _observations[scope] ?? AccessEvidence.unknown;

  static List<String> requirements(String method, String path) {
    final segments = path.split('/');
    for (final (routeMethod, template, scopes) in coolifyRoutePermissions) {
      if (method != routeMethod) continue;
      final parts = template.split('/');
      if (parts.length != segments.length) continue;
      var matches = true;
      for (var i = 0; i < parts.length; i++) {
        if (parts[i].startsWith('{') && parts[i].endsWith('}')) {
          if (segments[i].isEmpty) matches = false;
        } else if (parts[i] != segments[i]) {
          matches = false;
        }
      }
      if (matches) return scopes;
    }
    return const [];
  }

  final Set<String> _refusedOperations = {};
  bool allows(String method, String path) {
    if (_refusedOperations.contains('$method $path')) return false;
    final scopes = requirements(method, path);
    // API middleware accepts any listed ability. Unknown routes remain actionable.
    return scopes.isEmpty ||
        scopes.any((scope) => evidence(scope) != AccessEvidence.denied);
  }

  void succeeded(String method, String path) {
    final scopes = requirements(method, path);
    // With alternative abilities we cannot know which one authorized the request.
    if (scopes.length == 1) {
      _observations[scopes.single] = AccessEvidence.available;
    }
    notifyListeners();
  }

  void refusedOperation(String method, String path, Set<String> scopes) {
    _refusedOperations.add('$method $path');
    refused(scopes);
  }

  void refused(Set<String> scopes) {
    for (final scope in scopes) {
      if (CoolifyAccess.scopes.contains(scope) && scope != 'root') {
        _observations[scope] = AccessEvidence.denied;
      }
    }
    notifyListeners();
  }

  void clear() {
    _observations.clear();
    _refusedOperations.clear();
    notifyListeners();
  }
}
