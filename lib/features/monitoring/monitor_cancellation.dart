/// Each foreground cycle owns its transports. Pausing or locking cancels them
/// and prevents the cycle from starting requests or committing late results.
class MonitorCancellation {
  bool _cancelled = false;
  final _callbacks = <void Function()>{};
  bool get cancelled => _cancelled;
  void attach(void Function() close) {
    if (_cancelled) {
      close();
    } else {
      _callbacks.add(close);
    }
  }

  void detach(void Function() close) => _callbacks.remove(close);
  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final close in _callbacks.toList()) {
      close();
    }
    _callbacks.clear();
  }
}
