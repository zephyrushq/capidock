import 'dart:convert';

import 'package:flutter/services.dart';

class CoolifyOperation {
  CoolifyOperation(this.data);
  final Map<String, dynamic> data;
  String get id => data['id'] as String;
  String get method => data['method'] as String;
  String get path => data['path'] as String;
  String get group => data['group'] as String;
  String get title => data['title'] as String;
  String get description => data['description'] as String;
  bool get upload => data['upload'] == true;
  bool get mutates => method != 'GET';
  bool get destructive =>
      method == 'DELETE' ||
      path.endsWith('/imports') ||
      path.endsWith('/disable');
  List<Map<String, dynamic>> get parameters =>
      (data['parameters'] as List).cast<Map<String, dynamic>>();
  Map<String, dynamic> get schema => data['body'] as Map<String, dynamic>;
  Map<String, dynamic> get properties =>
      (schema['properties'] as Map<String, dynamic>?) ?? {};
  List<String> get requiredFields =>
      ((schema['required'] as List?) ?? []).cast<String>();
  bool get bodyRequired => data['bodyRequired'] == true;

  String resolvePath(Map<String, String> values) {
    return path.replaceAllMapped(RegExp(r'\{([^}]+)\}'), (match) {
      final value = values[match[1]]?.trim();
      if (value == null || value.isEmpty || value == '.' || value == '..') {
        throw const FormatException('Missing path parameter');
      }
      return Uri.encodeComponent(value);
    });
  }
}

class CoolifyCatalog {
  CoolifyCatalog(this.operations);
  final List<CoolifyOperation> operations;
  static Future<CoolifyCatalog>? _loading;
  // Only bundled public API metadata is cached. Server responses never enter it.
  static Future<CoolifyCatalog> load() => _loading ??= _load();
  static Future<CoolifyCatalog> _load() async {
    try {
      final data = jsonDecode(
        await rootBundle.loadString('assets/coolify/operations.json'),
      ) as Map<String, dynamic>;
      return CoolifyCatalog(
        List.unmodifiable(
          (data['operations'] as List).map(
            (v) => CoolifyOperation(_freeze(v) as Map<String, dynamic>),
          ),
        ),
      );
    } catch (_) {
      _loading = null;
      rethrow;
    }
  }

  static Object? _freeze(Object? value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.unmodifiable(
        value.map((key, entry) => MapEntry(key, _freeze(entry))),
      );
    }
    if (value is List) return List.unmodifiable(value.map(_freeze));
    return value;
  }

  CoolifyOperation? find(String method, String path) {
    for (final op in operations) {
      if (op.method == method && op.path == path) return op;
    }
    return null;
  }

  List<CoolifyOperation> forResource(String collection) => operations
      .where((o) => o.path.startsWith('/$collection/{uuid}'))
      .toList();
}

/// Recursively redact secrets; an explicit reveal is never persisted.
Object? redactCoolify(Object? value, {bool environment = false}) {
  if (value is List) {
    return value
        .map((v) => redactCoolify(v, environment: environment))
        .toList();
  }
  if (value is Map) {
    return value.map((key, entry) {
      final name = key.toString().toLowerCase();
      final hidden = RegExp(
        r'password|passphrase|secret|token|private_key|api_key|credential|connection_url|database_url|docker_compose|dockerfile|command|logs?|output|stderr|stdout|^value$|^content$',
      ).hasMatch(name);
      return MapEntry(
        key.toString(),
        hidden && entry != null
            ? '••••••••'
            : redactCoolify(entry, environment: environment),
      );
    });
  }
  return value;
}
