import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/help_button.dart';
import '../../core/security/security_controls.dart';
import '../../l10n/localization.dart';
import '../workspaces/domain/dock_controller.dart';
import 'monitor_service.dart';
import 'monitor_state.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key, required this.controller, this.service});
  final DockController controller;
  final MonitorService? service;
  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> with WidgetsBindingObserver {
  late final MonitorService service = widget.service ?? MonitorService();
  MonitorConfig? config;
  Map<String, MonitorState> states = {};
  bool busy = false, permission = false, failed = false, prompting = false;
  Timer? refresh;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _startRefresh();
  }

  void _startRefresh() {
    refresh?.cancel();
    refresh = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!busy) _load();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    refresh?.cancel();
    if (state == AppLifecycleState.resumed) {
      _load();
      _startRefresh();
    }
  }

  @override
  void dispose() {
    refresh?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final snapshot = await service.bridge.transaction(
        () async => (await service.config(), await service.history()),
      );
      final allowed = await service.bridge.notificationsAllowed();
      if (mounted) {
        setState(() {
          config = snapshot.$1;
          states = snapshot.$2;
          permission = allowed;
          failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  Future<void> _action(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.saveError)));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _save({
    Set<String>? ids,
    int? interval,
    bool? fastEnabled,
    int? fastInterval,
    Set<String>? alerts,
  }) async {
    final current = config!;
    await service.save(
      MonitorConfig(
        fastEnabled: fastEnabled ?? current.fastEnabled,
        fastInterval: fastInterval ?? current.fastInterval,
        ids: ids ?? current.ids,
        interval: interval ?? current.interval,
        alerts: alerts ?? current.alerts,
        revision: MonitorService.nonce(),
        locale: Localizations.localeOf(context).toLanguageTag(),
      ),
    );
  }

  Future<void> _toggle(String id, bool enable) => _action(() async {
    if (enable) {
      if (config!.ids.length >= 20) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.monitorLimit)));
        return;
      }
      setState(() => prompting = true);
      bool? consent;
      try {
        consent = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.monitorEnable),
            content: Text(context.l10n.monitorConsent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.monitorEnable),
              ),
            ],
          ),
        );
      } finally {
        if (mounted) setState(() => prompting = false);
      }
      if (!mounted || consent != true) return;
      final authenticate = SecurityControls.maybeOf(context)?.reauthenticate;
      if (authenticate == null ||
          !await authenticate(context.l10n.monitorEnable) ||
          !mounted) {
        return;
      }
      if (!widget.controller.workspaces.any(
        (w) => w.instances.any((i) => i.id == id),
      )) {
        return;
      }
    }
    final ids = {...config!.ids};
    if (enable) {
      ids.add(id);
    } else {
      ids.remove(id);
    }
    await _save(ids: ids);
  });
  String _health(String? health) => switch (health) {
    'up' => context.l10n.monitorUp,
    'down' => context.l10n.monitorDown,
    'offline' => context.l10n.monitorOffline,
    'authentication' => context.l10n.monitorAuthentication,
    'identity' => context.l10n.monitorIdentity,
    _ => context.l10n.monitorUnknown,
  };
  String _event(String kind) => switch (kind) {
    'deployment' => context.l10n.monitorAlertDeployments,
    'deploymentStarted' => context.l10n.monitorDeploymentStarted,
    'deploymentSucceeded' => context.l10n.monitorDeploymentSucceeded,
    'deploymentCancelled' => context.l10n.monitorDeploymentCancelled,
    'resourceChanged' => context.l10n.monitorResourceChanged,
    'resource' => context.l10n.monitorAlertResources,
    'recovery' => context.l10n.monitorAlertRecovery,
    _ => _health(kind),
  };
  String _time(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${MaterialLocalizations.of(context).formatShortDate(date)} ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.monitorTitle),
      actions: [
        HelpButton(message: context.l10n.monitorHelp),
        IconButton(
          onPressed: busy ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: config == null
        ? Center(
            child: failed
                ? TextButton(onPressed: _load, child: Text(context.l10n.retry))
                : const CircularProgressIndicator(),
          )
        : ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              final instances = [
                for (final w in widget.controller.workspaces) ...w.instances,
              ];
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SwitchListTile(
                    title: Text(context.l10n.monitorFastTitle),
                    secondary: HelpButton(
                      message: context.l10n.monitorFastHelp,
                    ),
                    value: config!.fastEnabled,
                    onChanged: busy
                        ? null
                        : (v) => _action(() => _save(fastEnabled: v)),
                  ),
                  if (config!.fastEnabled)
                    ListTile(
                      title: Text(context.l10n.monitorFastInterval),
                      trailing: DropdownButton<int>(
                        value: config!.fastInterval,
                        items: [
                          for (final seconds in [10, 30, 60])
                            DropdownMenuItem(
                              value: seconds,
                              child: Text('$seconds s'),
                            ),
                        ],
                        onChanged: busy
                            ? null
                            : (v) => _action(() => _save(fastInterval: v)),
                      ),
                    ),
                  ListTile(
                    title: Text(context.l10n.monitorInterval),
                    trailing: DropdownButton<int>(
                      value: config!.interval,
                      items: [
                        for (final minutes in [15, 30, 60])
                          DropdownMenuItem(
                            value: minutes,
                            child: Text('$minutes min'),
                          ),
                      ],
                      onChanged: busy
                          ? null
                          : (v) => _action(() => _save(interval: v)),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      permission
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                    ),
                    title: Text(
                      permission
                          ? context.l10n.monitorPermission
                          : context.l10n.monitorPermissionOff,
                    ),
                    onTap: busy
                        ? null
                        : () => _action(() async {
                            await service.bridge.notificationsAllowed(
                              request: true,
                            );
                          }),
                  ),
                  if (!permission)
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => _action(() async {
                              await service.bridge.notificationsAllowed(
                                request: true,
                              );
                            }),
                      child: Text(context.l10n.monitorRequest),
                    ),
                  if (config!.ids.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: busy
                          ? null
                          : () => _action(() async {
                              await MonitorService.checkSoon();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.monitorScheduled,
                                    ),
                                  ),
                                );
                              }
                            }),
                      icon: const Icon(Icons.sync),
                      label: Text(context.l10n.monitorCheck),
                    ),
                  if (busy && !prompting) const LinearProgressIndicator(),
                  if (failed) Text(context.l10n.saveError),
                  const Divider(),
                  if (instances.isEmpty) Text(context.l10n.monitorEmpty),
                  for (final instance in instances)
                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            key: ValueKey('monitor-instance-${instance.id}'),
                            title: Text(instance.name),
                            subtitle: Text(instance.type.label),
                            value: config!.ids.contains(instance.id),
                            onChanged: busy || !instance.hasCredentials
                                ? null
                                : (v) => _toggle(instance.id, v),
                          ),
                          if (config!.ids.contains(instance.id))
                            Builder(
                              builder: (context) {
                                final state = states[instance.id];
                                final sample = state?.latest;
                                final stale =
                                    sample != null &&
                                    DateTime.now().millisecondsSinceEpoch -
                                            (sample['at'] as int) >
                                        Duration(minutes: config!.interval * 2)
                                            .inMilliseconds;
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        sample == null
                                            ? context.l10n.monitorNoChecks
                                            : stale
                                            ? context.l10n.monitorStale
                                            : _health(
                                                sample['health'] as String?,
                                              ),
                                      ),
                                      subtitle: sample == null
                                          ? null
                                          : Text(
                                              '${_time(sample['at'] as int)}${sample['latency'] == null ? '' : ' · ${sample['latency']} ms'}',
                                            ),
                                    ),
                                    ListTile(
                                      title: Text(context.l10n.monitorObserved),
                                      trailing: Text(
                                        state?.uptime == null
                                            ? '—'
                                            : '${state!.uptime!.toStringAsFixed(1)}%',
                                      ),
                                    ),
                                    if (state != null &&
                                        state.samples.isNotEmpty)
                                      ExpansionTile(
                                        title: Text(
                                          context.l10n.monitorHistory,
                                        ),
                                        children: [
                                          for (final event
                                              in state.events.reversed.take(10))
                                            ListTile(
                                              leading: const Icon(
                                                Icons.notifications_outlined,
                                              ),
                                              title: Text(
                                                _event(event['kind'] as String),
                                              ),
                                              subtitle: Text(
                                                _time(event['at'] as int),
                                              ),
                                            ),
                                          for (final s
                                              in state.samples.reversed.take(
                                                20,
                                              ))
                                            ListTile(
                                              dense: true,
                                              title: Text(
                                                _health(s['health'] as String?),
                                              ),
                                              subtitle: Text(
                                                _time(s['at'] as int),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  const Divider(),
                  Text(
                    context.l10n.monitorAlerts,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final group in [
                    (
                      {'down', 'authentication', 'identity', 'unknown'},
                      context.l10n.monitorAlertConnections,
                    ),
                    (
                      {
                        'deployment',
                        'deploymentStarted',
                        'deploymentSucceeded',
                        'deploymentCancelled',
                      },
                      context.l10n.monitorAlertDeployments,
                    ),
                    (
                      {'resource', 'resourceChanged'},
                      context.l10n.monitorAlertResources,
                    ),
                    ({'recovery'}, context.l10n.monitorAlertRecovery),
                  ])
                    SwitchListTile(
                      title: Text(group.$2),
                      value: group.$1.every(config!.alerts.contains),
                      onChanged: busy
                          ? null
                          : (value) => _action(() async {
                              final alerts = {...config!.alerts};
                              if (value) {
                                alerts.addAll(group.$1);
                              } else {
                                alerts.removeAll(group.$1);
                              }
                              await _save(alerts: alerts);
                            }),
                    ),
                ],
              );
            },
          ),
  );
}
