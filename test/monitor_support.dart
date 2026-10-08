import 'package:capidock_monitor_bridge/capidock_monitor_bridge.dart';

class FakeMonitorBridge extends MonitorBridge {
  bool online = true;
  final messages = <String>[];
  final alerts = <String>[];
  @override
  Future<void> publishAlert(String kind) async {
    alerts.add(kind);
  }

  Future<void> pending = Future.value();
  @override
  Future<T> transaction<T>(Future<T> Function() action) {
    final next = pending.then((_) => action());
    pending = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }

  @override
  Future<bool> networkAvailable() async => online;
  @override
  Future<bool> notificationsAllowed({bool request = false}) async => true;
  @override
  Future<void> notify(int id, String body) async {
    messages.add(body);
  }

  @override
  Future<void> clear([int? id]) async {
    messages.clear();
    alerts.clear();
  }
}
