import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../instances/domain/server_instance.dart';
import '../domain/dock_workspace.dart';
import 'secret_store.dart';

abstract interface class WorkspaceStore {
  /// Null means first launch. Both null and an empty list open onboarding.
  Future<List<DockWorkspace>?> load();
  Future<void> save(List<DockWorkspace> workspaces);
}

class SecureWorkspaceStore implements WorkspaceStore {
  SecureWorkspaceStore({
    this._secrets = const AndroidSecretStore(),
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const storageKey = 'capidock.workspaces.v3';
  static const previousStorageKey = 'capidock.workspaces.v2';
  static const legacyStorageKey = 'capidock.instances.v1';
  final SecretStore _secrets;
  final SharedPreferencesAsync _preferences;

  @override
  Future<List<DockWorkspace>?> load() async {
    final raw = await _secrets.read(storageKey);
    if (raw != null) {
      final workspaces = _decode(raw, 3);
      // Resume cleanup if the process stopped after the verified secure write.
      await _removePlaintext();
      return workspaces;
    }
    final previous = await _preferences.getString(previousStorageKey);
    final legacy = previous == null
        ? await _preferences.getString(legacyStorageKey)
        : null;
    if (previous == null && legacy == null) return null;
    final workspaces = previous != null
        ? _decode(previous, 2)
        : _decodeLegacy(legacy!);
    final migrated = <DockWorkspace>[];
    for (final workspace in workspaces) {
      final real = workspace.instances.where((i) => !i.isDemo).toList();
      final isUntouchedStarter =
          workspace.id == defaultWorkspaceId &&
          workspace.name == 'Meu workspace' &&
          real.isEmpty &&
          (workspace.instances.any((i) => i.isDemo) || previous == null);
      if (!isUntouchedStarter) {
        migrated.add(workspace.copyWith(instances: real));
      }
    }
    await save(migrated);
    return migrated;
  }

  @override
  Future<void> save(List<DockWorkspace> workspaces) async {
    _validateIds(workspaces);
    if (workspaces.any((w) => w.instances.any((i) => i.isDemo))) {
      throw const FormatException('Dados de demonstração não são permitidos.');
    }
    final encoded = jsonEncode({
      'version': 3,
      'workspaces': workspaces.map((w) => w.toJson()).toList(),
    });
    await _secrets.write(storageKey, encoded);
    if (await _secrets.read(storageKey) != encoded) {
      throw StateError('Não foi possível verificar o armazenamento seguro.');
    }
    await _removePlaintext();
  }

  Future<void> _removePlaintext() async {
    await _preferences.remove(previousStorageKey);
    await _preferences.remove(legacyStorageKey);
  }

  List<DockWorkspace> _decode(String raw, int version) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    if (data['version'] != version) {
      throw const FormatException('Versão de armazenamento não suportada.');
    }
    final workspaces = (data['workspaces'] as List)
        .map((item) => DockWorkspace.fromJson(item as Map<String, dynamic>))
        .toList();
    _validateIds(workspaces);
    if (version == 3 &&
        workspaces.any((w) => w.instances.any((i) => i.isDemo))) {
      throw const FormatException('Armazenamento seguro inválido.');
    }
    return workspaces;
  }

  List<DockWorkspace> _decodeLegacy(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    if (data['version'] != 1) {
      throw const FormatException('Versão de armazenamento não suportada.');
    }
    final workspaces = [
      DockWorkspace(
        id: defaultWorkspaceId,
        name: 'Meu workspace',
        instances: (data['instances'] as List)
            .map(
              (item) => ServerInstance.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      ),
    ];
    _validateIds(workspaces);
    return workspaces;
  }

  void _validateIds(List<DockWorkspace> workspaces) {
    final ids = <String>{};
    final instanceIds = <String>{};
    for (final workspace in workspaces) {
      if (!ids.add(workspace.id)) {
        throw const FormatException('Workspaces duplicados.');
      }
      for (final instance in workspace.instances) {
        if (!instanceIds.add(instance.id)) {
          throw const FormatException(
            'Identificadores de instância duplicados.',
          );
        }
      }
    }
  }
}
