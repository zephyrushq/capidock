import 'dart:async';
import 'dart:collection';

import 'package:capidock_monitor_bridge/capidock_monitor_bridge.dart';
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../l10n/localization.dart';

/// Ephemeral, generic notices above every route in the unlocked app. No server
/// identifiers or values enter this queue, and background events are discarded.
class MonitorAlertOverlay extends StatefulWidget {
  const MonitorAlertOverlay({super.key, required this.child, this.events});
  final Widget child;
  final Stream<String>? events;
  @override
  State<MonitorAlertOverlay> createState() => _MonitorAlertOverlayState();
}

class _MonitorAlertOverlayState extends State<MonitorAlertOverlay>
    with WidgetsBindingObserver {
  final _pending = Queue<String>();
  StreamSubscription<String>? _subscription;
  Timer? _expiry;
  String? _current;
  bool get _resumed =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  static const _kinds = {
    'down',
    'recovery',
    'authentication',
    'identity',
    'unknown',
    'deployment',
    'deploymentStarted',
    'deploymentSucceeded',
    'deploymentCancelled',
    'resource',
    'resourceChanged',
  };
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listen();
  }

  Future<void> _listen() async {
    try {
      final stream = widget.events;
      if (stream == null &&
          await MonitorBridge.channel.invokeMethod<bool>('eventsAvailable') !=
              true) {
        return;
      }
      if (!mounted) return;
      _subscription = (stream ?? MonitorBridge.alerts).listen(
        _receive,
        onError: (Object _) {},
      );
    } catch (_) {
      // Unsupported platforms have no native monitoring event bus.
    }
  }

  void _receive(String kind) {
    if (!mounted) return;
    if (kind == 'clear') {
      _clear();
      return;
    }
    if (!_resumed ||
        !_kinds.contains(kind) ||
        kind == _current ||
        _pending.contains(kind)) {
      return;
    }
    if (_pending.length >= 3) _pending.removeFirst();
    _pending.add(kind);
    if (_current == null) _next();
  }

  void _next() {
    _expiry?.cancel();
    if (!mounted) return;
    setState(() => _current = _pending.isEmpty ? null : _pending.removeFirst());
    if (_current != null) _expiry = Timer(const Duration(seconds: 8), _next);
  }

  void _clear() {
    _expiry?.cancel();
    _pending.clear();
    setState(() => _current = null);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _clear();
  }

  @override
  void dispose() {
    _expiry?.cancel();
    _pending.clear();
    _subscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _message(String kind) => switch (kind) {
    'down' => context.l10n.monitorDown,
    'recovery' => context.l10n.monitorAlertRecovery,
    'authentication' => context.l10n.monitorAuthentication,
    'identity' => context.l10n.monitorIdentity,
    'deployment' => context.l10n.monitorDeploymentFailed,
    'resource' => context.l10n.monitorResourceUnhealthy,
    'deploymentStarted' => context.l10n.monitorDeploymentStarted,
    'deploymentSucceeded' => context.l10n.monitorDeploymentSucceeded,
    'deploymentCancelled' => context.l10n.monitorDeploymentCancelled,
    'resourceChanged' => context.l10n.monitorResourceChanged,
    _ => context.l10n.monitorUnknown,
  };
  @override
  Widget build(BuildContext context) {
    final success = {'recovery', 'deploymentSucceeded'}.contains(_current);
    final problem = {
      'down',
      'authentication',
      'identity',
      'deployment',
      'resource',
    }.contains(_current);
    final color = success
        ? DockColors.green
        : problem
        ? Theme.of(context).colorScheme.error
        : DockColors.purple;
    return Stack(
      children: [
        widget.child,
        if (_current != null)
          Positioned(
            top: 0,
            left: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Semantics(
                      liveRegion: true,
                      child: Material(
                        key: const ValueKey('monitor-floating-alert'),
                        elevation: 8,
                        color: DockColors.elevated,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: color.withValues(alpha: .5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 8,
                            bottom: 8,
                            right: 4,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                success
                                    ? Icons.check_circle_outline
                                    : problem
                                    ? Icons.error_outline
                                    : Icons.notifications_outlined,
                                color: color,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _message(_current!),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Semantics(
                                container: true,
                                label: MaterialLocalizations.of(context)
                                    .closeButtonTooltip,
                                button: true,
                                child: IconButton(
                                  onPressed: _next,
                                  icon: const Icon(Icons.close, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
