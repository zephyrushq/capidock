import 'package:flutter/foundation.dart';

import 'dart:math';

import '../../instances/domain/server_instance.dart';
import '../data/workspace_store.dart';
import 'dock_workspace.dart';

class DockController extends ChangeNotifier {
  DockController(this._store);

  final WorkspaceStore _store;
  List<DockWorkspace> _workspaces = [];
  String? _workspaceId;
  final Map<String, String> _selectedByWorkspace = {};
  int _generation = 0;
  bool _locked = false;
  Future<void>? _pendingSave;
  bool isLoading = true;
  bool isSaving = false;
  String? loadError;

  List<DockWorkspace> get workspaces => List.unmodifiable(_workspaces);
  DockWorkspace? get activeWorkspace =>
      _workspaces.where((w) => w.id == _workspaceId).firstOrNull;
  List<ServerInstance> get instances => activeWorkspace?.instances ?? const [];
  ServerInstance? get selected =>
      instances
          .where((i) => i.id == _selectedByWorkspace[_workspaceId])
          .firstOrNull ??
      instances.firstOrNull;
  void lock() {
    _generation++;
    _locked = true;
    _workspaces = [];
    _workspaceId = null;
    _selectedByWorkspace.clear();
    isLoading = true;
    loadError = null;
    notifyListeners();
  }

  Future<void> clearLocalData() async {
    lock();
    try {
      await _pendingSave;
    } catch (_) {
      /* Failed saves must not prevent erasure. */
    }
    if (_store is! SecureWorkspaceStore) {
      throw StateError('Secure storage required');
    }
    await _store.clearLocalData();
  }

  Future<void> initialize() async {
    final current = ++_generation;
    _locked = false;
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      await _pendingSave;
      if (_locked || current != _generation) return;
      final saved = await _store.load();
      if (_locked || current != _generation) return;
      final next = saved ?? <DockWorkspace>[];
      _workspaces = List.of(next);
      _workspaceId = _workspaces.firstOrNull?.id;
    } catch (_) {
      if (_locked || current != _generation) return;
      // Never replace unreadable user data with an empty onboarding state.
      loadError = 'Não foi possível carregar os workspaces guardados.';
    }
    if (_locked || current != _generation) return;
    isLoading = false;
    notifyListeners();
  }

  void selectWorkspace(String id) {
    if (!_workspaces.any((w) => w.id == id)) return;
    _workspaceId = id;
    notifyListeners();
  }

  void select(String id) {
    if (!instances.any((i) => i.id == id)) return;
    _selectedByWorkspace[_workspaceId!] = id;
    notifyListeners();
  }

  Future<void> createWorkspace(String name) async {
    final workspace = DockWorkspace(
      id: 'workspace-${DateTime.now().microsecondsSinceEpoch}',
      name: _validName(name),
    );
    await _persist([
      ..._workspaces,
      workspace,
    ], () => _workspaceId = workspace.id);
  }

  /// Add imported copies atomically. Fresh IDs prevent imported credentials from
  /// matching an existing instance's trusted SSH fingerprint or live session.
  Future<void> importWorkspaces(List<DockWorkspace> imported) async {
    final random = Random.secure();
    String id(String prefix) =>
        '$prefix-${List.generate(16, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join()}';
    final copies = imported
        .map(
          (workspace) => DockWorkspace(
            id: id('workspace'),
            name: _validName(workspace.name),
            instances: workspace.instances
                .map(
                  (instance) => ServerInstance.fromJson({
                    ...instance.toJson(),
                    'id': id('instance'),
                  }),
                )
                .toList(),
          ),
        )
        .toList();
    await _persist([..._workspaces, ...copies], () {
      if (copies.isNotEmpty) _workspaceId = copies.first.id;
    });
  }

  Future<void> createFirstWorkspace(
    String name,
    ServerInstance instance,
  ) async {
    if (_workspaces.isNotEmpty) throw StateError('O dock já tem workspaces.');
    final workspace = DockWorkspace(
      id: 'workspace-${DateTime.now().microsecondsSinceEpoch}',
      name: _validName(name),
      instances: [instance],
    );
    await _persist([workspace], () {
      _workspaceId = workspace.id;
      _selectedByWorkspace[workspace.id] = instance.id;
    });
  }

  Future<void> renameWorkspace(String id, String name) async {
    final workspace = _workspace(id);
    final renamed = workspace.copyWith(name: _validName(name));
    await _persist(_workspaces.map((w) => w.id == id ? renamed : w).toList());
  }

  Future<void> removeWorkspace(String id) async {
    _workspace(id);
    await _persist(_workspaces.where((w) => w.id != id).toList(), () {
      _selectedByWorkspace.remove(id);
      if (_workspaceId == id) _workspaceId = _workspaces.firstOrNull?.id;
    });
  }

  Future<void> upsert(ServerInstance instance, {String? workspaceId}) async {
    final workspace = _workspace(workspaceId ?? _workspaceId);
    if (_workspaces.any(
      (w) =>
          w.id != workspace.id && w.instances.any((i) => i.id == instance.id),
    )) {
      throw StateError('Esta instância pertence a outro workspace.');
    }
    final next = List<ServerInstance>.of(workspace.instances);
    final index = next.indexWhere((i) => i.id == instance.id);
    if (index < 0) {
      next.add(instance);
    } else {
      next[index] = instance;
    }
    await _persist(
      _workspaces
          .map((w) => w.id == workspace.id ? w.copyWith(instances: next) : w)
          .toList(),
      () {
        _workspaceId = workspace.id;
        _selectedByWorkspace[workspace.id] = instance.id;
      },
    );
  }

  Future<void> remove(String id) async {
    final workspace = _workspaces
        .where((w) => w.instances.any((i) => i.id == id))
        .firstOrNull;
    if (workspace == null) return;
    await _persist(
      _workspaces
          .map(
            (w) => w.id == workspace.id
                ? w.copyWith(
                    instances: w.instances.where((i) => i.id != id).toList(),
                  )
                : w,
          )
          .toList(),
      () {
        if (_selectedByWorkspace[workspace.id] == id) {
          _selectedByWorkspace.remove(workspace.id);
        }
      },
    );
  }

  Future<void> moveInstance(String id, String targetId) async {
    final target = _workspace(targetId);
    final source = _workspaces
        .where((w) => w.instances.any((i) => i.id == id))
        .firstOrNull;
    if (source == null) throw StateError('Instância não encontrada.');
    if (source.id == target.id) return;
    final instance = source.instances.firstWhere((i) => i.id == id);
    await _persist(
      _workspaces.map((w) {
        if (w.id == source.id) {
          return w.copyWith(
            instances: w.instances.where((i) => i.id != id).toList(),
          );
        }
        if (w.id == target.id) {
          return w.copyWith(instances: [...w.instances, instance]);
        }
        return w;
      }).toList(),
      () {
        if (_selectedByWorkspace[source.id] == id) {
          _selectedByWorkspace.remove(source.id);
        }
        _workspaceId = target.id;
        _selectedByWorkspace[target.id] = id;
      },
    );
  }

  DockWorkspace _workspace(String? id) =>
      _workspaces.where((w) => w.id == id).firstOrNull ??
      (throw StateError('Workspace não encontrado.'));

  String _validName(String name) {
    final value = name.trim();
    if (value.isEmpty || value.length > 40) {
      throw ArgumentError('Nome de workspace inválido.');
    }
    return value;
  }

  Future<void> _persist(
    List<DockWorkspace> next, [
    VoidCallback? onSaved,
  ]) async {
    if (_locked || isSaving || isLoading || loadError != null) {
      throw StateError('O armazenamento não está disponível.');
    }
    final current = _generation;
    isSaving = true;
    notifyListeners();
    try {
      final save = _store.save(next);
      _pendingSave = save;
      await save;
      if (_locked || current != _generation) return;
      _workspaces = next;
      onSaved?.call();
    } finally {
      _pendingSave = null;
      isSaving = false;
      notifyListeners();
    }
  }
}
