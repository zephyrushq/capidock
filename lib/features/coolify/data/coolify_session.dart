import 'package:flutter/widgets.dart';
import 'package:file_selector/file_selector.dart';

import '../../connections/data/coolify_client.dart';
import '../../instances/domain/server_instance.dart';

/// No response cache or persistence. Backgrounding cancels pending API requests.
class CoolifySession extends ChangeNotifier with WidgetsBindingObserver {
  CoolifySession(this.instance, {CoolifyClient Function()? createClient})
    : _createClient = createClient ?? CoolifyClient.new {
    WidgetsBinding.instance.addObserver(this);
  }
  final ServerInstance instance;
  final CoolifyClient Function() _createClient;
  final Set<CoolifyClient> _pending = {};
  int generation = 0;
  bool active = true;
  bool _disposed = false, _writing = false;
  Future<Object?> request(
    String method,
    String path, {
    Map<String, String> query = const {},
    Object? body,
    XFile? file,
  }) async {
    if (!active || _disposed) throw const CoolifyException('coolifyCancelled');
    final write = method != 'GET';
    if (write && _writing) throw const CoolifyException('coolifyConflict');
    final current = generation;
    final client = _createClient();
    _pending.add(client);
    if (write) _writing = true;
    try {
      final response = await client.request(
        instance,
        method,
        path,
        query: query,
        body: body,
        file: file,
      );
      if (_disposed || !active || current != generation) {
        throw const CoolifyException('coolifyCancelled');
      }
      return response;
    } finally {
      if (write) _writing = false;
      _pending.remove(client);
      client.close();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      active = false;
      generation++;
      for (final client in _pending.toList()) {
        client.close();
      }
      _pending.clear();
      notifyListeners();
    } else if (state == AppLifecycleState.resumed) {
      active = true;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    generation++;
    WidgetsBinding.instance.removeObserver(this);
    for (final client in _pending) {
      client.close();
    }
    _pending.clear();
    super.dispose();
  }
}
