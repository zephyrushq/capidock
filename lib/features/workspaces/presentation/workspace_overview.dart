import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/app_theme.dart';
import '../../../core/widgets.dart';
import '../../../l10n/localization.dart';
import '../../instances/domain/server_instance.dart';
import '../../monitoring/monitor_service.dart';
import '../../monitoring/monitor_state.dart';
import '../domain/dock_controller.dart';

class WorkspaceOverview extends StatefulWidget {
  const WorkspaceOverview({
    super.key,
    required this.controller,
    required this.onSelect,
    required this.onMonitoring,
    this.service,
  });
  final DockController controller;
  final ValueChanged<String> onSelect;
  final VoidCallback onMonitoring;
  final MonitorService? service;

  @override
  State<WorkspaceOverview> createState() => _WorkspaceOverviewState();
}

class _WorkspaceOverviewState extends State<WorkspaceOverview>
    with WidgetsBindingObserver {
  late final _service = widget.service ?? MonitorService();
  MonitorConfig? _config;
  Map<String, MonitorState> _states = {};
  StreamSubscription<void>? _changes;
  Timer? _timer;
  int _generation = 0;
  bool _failed = false;
  bool _loading = false;
  bool get _resumed =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.addListener(_invalidate);
    _changes = MonitorService.changes.listen((_) => _invalidate());
    _start();
  }

  void _start() {
    _timer?.cancel();
    if (!_resumed) return;
    _load();
    // Re-read encrypted history, including results from the headless worker.
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!_loading) _load();
    });
  }

  @override
  void didUpdateWidget(covariant WorkspaceOverview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_invalidate);
      widget.controller.addListener(_invalidate);
      _invalidate();
    }
  }

  void _invalidate() {
    _generation++;
    if (!mounted) return;
    setState(() {
      _config = null;
      _states = {};
    });
    if (_resumed) _load();
  }

  Future<void> _load() async {
    if (!_resumed) return;
    final generation = ++_generation;
    setState(() => _loading = true);
    try {
      final snapshot = await _service.workspaceSnapshot(
        List.of(widget.controller.instances),
      );
      if (!mounted || generation != _generation || !_resumed) return;
      setState(() {
        _config = snapshot.$1;
        _states = snapshot.$2;
        _failed = false;
      });
    } catch (_) {
      if (!mounted || generation != _generation || !_resumed) return;
      setState(() {
        _config = null;
        _states = {};
        _failed = true;
      });
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _timer?.cancel();
    _generation++;
    _loading = false;
    if (state == AppLifecycleState.resumed) {
      _start();
    } else {
      setState(() {
        _states = {};
        _config = null;
      });
    }
  }

  @override
  void dispose() {
    _generation++;
    _timer?.cancel();
    _changes?.cancel();
    widget.controller.removeListener(_invalidate);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _stale(MonitorState? state, DateTime now) =>
      state?.latest != null &&
      now.millisecondsSinceEpoch - (state!.latest!['at'] as int) >
          Duration(minutes: (_config?.interval ?? 15) * 2).inMilliseconds;

  String _health(String? health) => switch (health) {
    'up' => context.l10n.monitorUp,
    'down' => context.l10n.monitorDown,
    'offline' => context.l10n.monitorOffline,
    'authentication' => context.l10n.monitorAuthentication,
    'identity' => context.l10n.monitorIdentity,
    _ => context.l10n.monitorUnknown,
  };

  String _event(String kind) => switch (kind) {
    'deployment' => context.l10n.monitorDeploymentFailed,
    'deploymentStarted' => context.l10n.monitorDeploymentStarted,
    'deploymentSucceeded' => context.l10n.monitorDeploymentSucceeded,
    'deploymentCancelled' => context.l10n.monitorDeploymentCancelled,
    'resource' => context.l10n.monitorResourceUnhealthy,
    'resourceChanged' => context.l10n.monitorResourceChanged,
    'recovery' => context.l10n.monitorAlertRecovery,
    _ => _health(kind),
  };

  String _time(int timestamp) =>
      DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag())
          .add_Hm()
          .format(DateTime.fromMillisecondsSinceEpoch(timestamp));

  @override
  Widget build(BuildContext context) {
    final instances = widget.controller.instances;
    final now = DateTime.now();
    final monitored = instances
        .where((i) => _config?.ids.contains(i.id) == true)
        .length;
    final attention = instances.where((i) {
      final state = _states[i.id];
      return state?.latest != null &&
          !_stale(state, now) &&
          state!.latest!['health'] != 'up';
    }).length;
    final stale = instances.where((i) => _stale(_states[i.id], now)).length;
    final cutoff = now
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;
    final events = <({ServerInstance instance, int at, String kind})>[
      for (final instance in instances)
        for (final event
            in _states[instance.id]?.events ?? <Map<String, dynamic>>[])
          if ((event['at'] as int) >= cutoff)
            (
              instance: instance,
              at: event['at'] as int,
              kind: event['kind'] as String,
            ),
    ]..sort((a, b) => b.at.compareTo(a.at));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        key: const ValueKey('workspace-overview'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.workspaceOverview,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.overviewDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(context.l10n.instanceCount(instances.length))),
              if (_config != null) ...[
                Chip(label: Text(context.l10n.overviewMonitored(monitored))),
                Chip(label: Text(context.l10n.overviewAttention(attention))),
                if (stale > 0)
                  Chip(label: Text(context.l10n.overviewStale(stale))),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: widget.onMonitoring,
                icon: const Icon(Icons.monitor_heart_outlined),
                label: Text(context.l10n.monitorTitle),
              ),
              TextButton.icon(
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.refresh),
              ),
            ],
          ),
          if (_loading) const LinearProgressIndicator(),
          if (_failed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.l10n.overviewLoadError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 600 ? 2 : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 12) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final instance in instances)
                    SizedBox(width: width, child: _instanceCard(instance, now)),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            context.l10n.overviewRecentEvents,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.overviewEventsDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (events.isEmpty && !_loading && !_failed)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(context.l10n.overviewNoEvents),
              ),
            ),
          for (final event in events.take(20))
            Card(
              child: ListTile(
                onTap: () => widget.onSelect(event.instance.id),
                leading: Icon(
                  {'recovery', 'deploymentSucceeded'}.contains(event.kind)
                      ? Icons.check_circle_outline
                      : Icons.notifications_outlined,
                  color: DockColors.purple,
                ),
                title: Text(_event(event.kind)),
                subtitle: Text('${event.instance.name}\n${_time(event.at)}'),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _instanceCard(ServerInstance instance, DateTime now) {
    final state = _states[instance.id];
    final sample = state?.latest;
    final enabled = _config?.ids.contains(instance.id) == true;
    final stale = _stale(state, now);
    final health = sample?['health'] as String?;
    final color = sample == null || stale
        ? DockColors.muted
        : health == 'up'
        ? DockColors.green
        : Theme.of(context).colorScheme.error;
    final status = _config == null
        ? context.l10n.monitorUnknown
        : !enabled
        ? context.l10n.overviewNotMonitored
        : sample == null
        ? context.l10n.monitorNoChecks
        : _health(health);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('overview-instance-${instance.id}'),
        onTap: () => widget.onSelect(instance.id),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(instanceIcon(instance.type), color: DockColors.purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      instance.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: DockColors.muted),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                instance.type.label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                instance.host,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(Icons.circle, size: 10, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(status, style: TextStyle(color: color)),
                  ),
                ],
              ),
              if (stale) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.monitorStale,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (sample != null) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.overviewLastCheck(_time(sample['at'] as int)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
