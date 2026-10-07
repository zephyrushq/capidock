import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:capidock/features/workspaces/data/secret_store.dart';
import 'package:capidock/features/workspaces/data/workspace_store.dart';
import 'package:capidock/features/workspaces/domain/dock_workspace.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryWorkspaceStore implements WorkspaceStore {
  List<DockWorkspace>? data;
  bool failSave = false;
  bool failLoad = false;
  int saves = 0;

  @override
  Future<List<DockWorkspace>?> load() async {
    if (failLoad) throw StateError('Storage unavailable');
    return data;
  }

  @override
  Future<void> save(List<DockWorkspace> instances) async {
    if (failSave) throw StateError('Storage unavailable');
    data = List.of(instances);
    saves++;
  }
}

class MemoryPreferences implements SharedPreferencesAsync {
  final values = <String, String>{};
  final _failures = <String>{};
  bool get failSave => _failures.contains('save');
  set failSave(bool value) {
    if (value) {
      _failures.add('save');
    } else {
      _failures.remove('save');
    }
  }

  @override
  Future<String?> getString(String key) async => values[key];
  @override
  Future<void> setString(String key, String value) async {
    if (failSave) throw StateError('Storage unavailable');
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    if (failSave) throw StateError('Storage unavailable');
    values.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MemorySecretStore implements SecretStore {
  final values = <String, String>{};
  bool failWrite = false;
  bool failRead = false;
  bool dropWrites = false;
  @override
  Future<String?> read(String key) async {
    if (failRead) throw StateError('Keystore unavailable');
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failWrite) throw StateError('Keystore unavailable');
    if (!dropWrites) values[key] = value;
  }
}

const fixtureInstances = [
  ServerInstance(
    id: 'test-production',
    name: 'produção',
    type: InstanceType.ssh,
    host: 'server.example.com',
    port: 22,
    username: 'deploy',
  ),
  ServerInstance(
    id: 'test-staging',
    name: 'staging',
    type: InstanceType.ssh,
    host: 'staging.example.com',
    port: 22,
    username: 'ubuntu',
  ),
  ServerInstance(
    id: 'test-coolify',
    name: 'meu-coolify',
    type: InstanceType.coolify,
    host: 'https://coolify.example.com',
    port: 443,
  ),
];
List<DockWorkspace> fixtureWorkspaces() => [
  DockWorkspace(
    id: defaultWorkspaceId,
    name: 'Pessoal',
    instances: fixtureInstances,
  ),
];
