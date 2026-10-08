import 'dart:async';

import 'package:flutter/widgets.dart';

import '../instances/domain/server_instance.dart';
import '../workspaces/domain/dock_controller.dart';
import 'monitor_cancellation.dart';
import 'monitor_service.dart';
import 'monitor_state.dart';

/// Runs one round at a time. Pausing revokes pending results and closes transports.
class ForegroundMonitorLoop {
  ForegroundMonitorLoop(this.service, {required this.locale});
  final MonitorService service;
  final String Function() locale;
  int interval = 10, _generation = 0;
  bool _active = false, _running = false;
  Timer? _timer;
  MonitorCancellation? _cancellation;
  void start(int seconds) {
    interval = seconds;
    if (_active) return;
    _active = true;
    _generation++;
    if (!_running) unawaited(_tick());
  }

  void stop() {
    _active = false;
    _generation++;
    _timer?.cancel();
    _cancellation?.cancel();
  }

  Future<void> _tick() async {
    if (!_active || _running) return;
    _running = true;
    final generation = _generation;
    final cancellation = MonitorCancellation();
    _cancellation = cancellation;
    var delay = interval;
    try {
      await service.run(
        fast: true,
        locale: locale(),
        cancellation: cancellation,
        isActive: () => _active && generation == _generation,
        onCheck: (check) {
          final minimum = switch (check.health) {
            Health.up => interval,
            Health.down || Health.offline => 30,
            _ => 60,
          };
          if (minimum > delay) delay = minimum;
        },
      );
    } catch (_) {
      delay = 60;
    } finally {
      _running = false;
      _cancellation = null;
      if (_active) {
        _timer = Timer(
          Duration(seconds: generation == _generation ? delay : 0),
          _tick,
        );
      }
    }
  }
}

class ForegroundMonitor extends StatefulWidget {
  const ForegroundMonitor({
    super.key,
    required this.controller,
    required this.child,
    this.service,
  });
  final DockController controller;
  final Widget child;
  final MonitorService? service;
  @override
  State<ForegroundMonitor> createState() => _ForegroundMonitorState();
}

class _ForegroundMonitorState extends State<ForegroundMonitor>
    with WidgetsBindingObserver {
  late final service = widget.service ?? MonitorService();
  late final loop = ForegroundMonitorLoop(
    service,
    locale: () => Localizations.localeOf(context).toLanguageTag(),
  );
  StreamSubscription<void>? _subscription;
  int _revision = 0;
  bool get _resumed =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_sync);
    _subscription = MonitorService.changes.listen((_) {
      loop.stop();
      _sync();
    });
    _sync();
  }

  Future<void> _sync() async {
    final revision = ++_revision;
    if (!_resumed || widget.controller.isLoading) {
      loop.stop();
      return;
    }
    try {
      final config = await service.bridge.transaction(service.config);
      if (!mounted || revision != _revision || !_resumed) return;
      final enabled =
          config.fastEnabled &&
          widget.controller.workspaces.any(
            (w) => w.instances.any(
              (i) =>
                  i.type == InstanceType.coolify &&
                  i.hasCredentials &&
                  config.ids.contains(i.id),
            ),
          );
      if (enabled) {
        loop.start(config.fastInterval);
      } else {
        loop.stop();
      }
    } catch (_) {
      if (mounted && revision == _revision) loop.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _revision++;
    loop.stop();
    if (state == AppLifecycleState.resumed) _sync();
  }

  @override
  void dispose() {
    _revision++;
    loop.stop();
    _subscription?.cancel();
    widget.controller.removeListener(_sync);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
