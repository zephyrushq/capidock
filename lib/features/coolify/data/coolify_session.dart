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
  CoolifyClient? _client;
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
    final client = _client ??= _createClient();
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
      if (write && current == generation) _writing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      active = false;
      generation++;
      _client?.close();
      _client = null;
      _writing = false;
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
    _client?.close();
    _client = null;
    super.dispose();
  }
}
