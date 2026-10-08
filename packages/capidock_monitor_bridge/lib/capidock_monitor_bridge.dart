import 'package:flutter/services.dart';

/// Registered in foreground and WorkManager Flutter engines. Shared native
/// ownership serialises vault/config/history mutations across isolates.
class MonitorBridge {
  static final alerts = const EventChannel(
    'com.zephyrushq.capidock/monitor/events',
  ).receiveBroadcastStream().where((event) => event is String).cast<String>();
  Future<void> publishAlert(String kind) =>
      channel.invokeMethod<void>('event', {'kind': kind});
  static const channel = MethodChannel('com.zephyrushq.capidock/monitor');
  static Future<void> _pending = Future.value();
  Future<T> transaction<T>(Future<T> Function() action) {
    final next = _pending.then((_) => _transaction(action));
    _pending = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }

  Future<T> _transaction<T>(Future<T> Function() action) async {
    final token = await channel.invokeMethod<String>('acquire');
    if (token == null) throw StateError('Monitoring transaction unavailable');
    try {
      return await action();
    } finally {
      await channel.invokeMethod<void>('release', {'token': token});
    }
  }

  Future<bool> networkAvailable() async =>
      await channel.invokeMethod<bool>('network') ?? false;
  Future<bool> notificationsAllowed({bool request = false}) async =>
      await channel.invokeMethod<bool>(
        request ? 'requestPermission' : 'permission',
      ) ??
      false;
  Future<void> notify(int id, String body) =>
      channel.invokeMethod<void>('notify', {'id': id, 'body': body});
  Future<void> clear([int? id]) =>
      channel.invokeMethod<void>('clear', {'id': id});
}
