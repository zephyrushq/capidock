import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../l10n/localization.dart';
import '../../connections/data/ssh_connection.dart';
import '../data/docker_client.dart';
import '../data/docker_command.dart';
import '../data/docker_models.dart';
import 'docker_terminal_page.dart';
import 'docker_widgets.dart';

class DockerContainerPage extends StatefulWidget {
  const DockerContainerPage({
    super.key,
    required this.connection,
    required this.container,
  });
  final SshConnection connection;
  final DockerContainer container;
  @override
  State<DockerContainerPage> createState() => _DockerContainerPageState();
}

class _DockerContainerPageState extends State<DockerContainerPage>
    with WidgetsBindingObserver {
  late final _client = DockerClient(widget.connection);
  DockerDetails? _details;
  DockerStats? _stats;
  String? _logs;
  Object? _error, _statsError;
  DateTime? _updatedAt;
  bool _busy = false, _uncertain = false;
  String _shell = 'sh';
  int _generation = 0, _tab = 0;
  Timer? _timer;
  bool get _connected => widget.connection.status == ConnectionStatus.connected;
  bool get _resumed =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  bool _active(int generation) =>
      mounted && generation == _generation && _connected && _resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.connection.addListener(_connectionChanged);
    _load();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_resumed &&
          _connected &&
          !_busy &&
          !_uncertain &&
          _tab == 0 &&
          ModalRoute.of(context)?.isCurrent == true) {
        _load();
      }
    });
  }

  void _connectionChanged() {
    if (!_connected) _clear();
  }

  void _clear() {
    _generation++;
    _client.cancelPending();
    if (mounted) {
      setState(() {
        _details = null;
        _stats = null;
        _logs = null;
        _updatedAt = null;
        _error = null;
        _statsError = null;
        _busy = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _clear();
    } else if (_connected) {
      _load();
    }
  }

  @override
  void dispose() {
    _generation++;
    _timer?.cancel();
    _client.dispose();
    widget.connection.removeListener(_connectionChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _load() async {
    if (_busy || !_connected || !_resumed) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
      _uncertain = false;
    });
    try {
      if (_tab == 1) {
        final logs = await _client.logs(widget.container.id);
        if (_active(generation)) {
          setState(() {
            _logs = logs;
            _updatedAt = DateTime.now();
          });
        }
      } else {
        final details = await _client.details(widget.container.id);
        DockerStats? stats;
        Object? statsError;
        if (!_active(generation)) return;
        if (details.running) {
          try {
            stats = await _client.stats(details.id);
          } catch (error) {
            statsError = error;
          }
        }
        if (_active(generation)) {
          setState(() {
            _details = details;
            _stats = stats;
            _statsError = statsError;
            _updatedAt = DateTime.now();
          });
        }
      }
    } catch (error) {
      if (_active(generation)) {
        setState(() {
          _error = error;
          if (_tab == 1) {
            _logs = null;
          } else {
            _details = null;
            _stats = null;
          }
        });
      }
    } finally {
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
  }

  Future<void> _act(DockerOperation operation) async {
    if (_busy || !_connected || !_resumed || _details == null) return;
    final generation = ++_generation;
    var succeeded = false;
    setState(() {
      _busy = true;
      _error = null;
      _uncertain = false;
    });
    try {
      final approved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            '${dockerAction(context, operation)} · ${widget.container.name}',
          ),
          content: Text(context.l10n.dockerConfirmAction),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              key: const ValueKey('docker-confirm-action'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(dockerAction(context, operation)),
            ),
          ],
        ),
      );
      if (approved != true || !_active(generation)) return;
      await _client.act(operation, widget.container.id);
      succeeded = true;
    } catch (error) {
      if (mounted && _active(generation)) {
        setState(() {
          _error = error;
          _uncertain =
              error is DockerException &&
              const {
                DockerFailure.timeout,
                DockerFailure.disconnected,
                DockerFailure.cancelled,
              }.contains(error.failure);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _uncertain
                  ? context.l10n.dockerActionUncertain
                  : dockerError(context, error),
            ),
            action: SnackBarAction(
              label: context.l10n.refresh,
              onPressed: _load,
            ),
          ),
        );
      }
    } finally {
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
    if (succeeded && _active(generation)) await _load();
  }

  Future<void> _openTerminal() async {
    if (_busy || !_connected || !_resumed) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DockerTerminalPage(
          connection: widget.connection,
          id: widget.container.id,
          name: widget.container.name,
          shell: _shell,
        ),
      ),
    );
    if (mounted && _connected) _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.container.name),
      actions: [
        IconButton(
          onPressed: _busy || !_connected ? null : _load,
          tooltip: context.l10n.refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: _busy
          ? null
          : (value) {
              setState(() {
                _tab = value;
                _error = null;
                _updatedAt = null;
              });
              _load();
            },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.info_outline),
          label: context.l10n.coolifyDetails,
        ),
        NavigationDestination(
          icon: const Icon(Icons.subject),
          label: context.l10n.coolifyLogs,
        ),
      ],
    ),
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (_busy) const LinearProgressIndicator(),
            if (!_connected) Text(context.l10n.terminalDisconnected),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  dockerError(context, _error!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_uncertain) Text(context.l10n.dockerActionUncertain),
            if (_updatedAt != null)
              Text(
                context.l10n.lastRead(
                  TimeOfDay.fromDateTime(_updatedAt!).format(context),
                  '',
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (_tab == 1) ...[
              Text(
                context.l10n.dockerLogsHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              if (_logs != null)
                SelectableText(
                  _logs!.isEmpty ? context.l10n.dockerNoLogs : _logs!,
                  key: const ValueKey('docker-logs'),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
            ] else if (_details case final details?) ...[
              const SizedBox(height: 12),
              Text(
                details.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              dockerField(context, context.l10n.dockerImage, details.image),
              dockerField(context, context.l10n.dockerState, details.state),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _metric('CPU', _stats?.cpu ?? '—'),
                  _metric(
                    'RAM',
                    _stats == null
                        ? '—'
                        : '${_stats!.memory}\n${_stats!.memoryPercent}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.dockerMetricsHelp,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (_statsError != null) Text(dockerError(context, _statsError!)),
              if (!details.running) Text(context.l10n.dockerStoppedMetrics),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final action in [
                    DockerOperation.start,
                    DockerOperation.stop,
                    DockerOperation.restart,
                  ])
                    OutlinedButton(
                      key: ValueKey('docker-action-${action.name}'),
                      onPressed:
                          _busy ||
                              !_connected ||
                              _uncertain ||
                              (action == DockerOperation.start
                                  ? !const {
                                      'exited',
                                      'created',
                                    }.contains(details.state)
                                  : !details.running)
                          ? null
                          : () => _act(action),
                      child: Text(dockerAction(context, action)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _shell,
                decoration: const InputDecoration(labelText: 'Shell'),
                items: [
                  for (final shell in ['sh', 'bash'])
                    DropdownMenuItem(value: shell, child: Text(shell)),
                ],
                onChanged: _busy
                    ? null
                    : (value) => setState(() => _shell = value!),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const ValueKey('docker-open-terminal'),
                onPressed: _busy || !details.running || !_connected
                    ? null
                    : _openTerminal,
                icon: const Icon(Icons.terminal),
                label: Text(context.l10n.dockerContainerTerminal),
              ),
              dockerField(context, 'ID', details.id),
              dockerField(
                context,
                context.l10n.dockerStartedAt,
                details.startedAt,
              ),
              dockerField(
                context,
                context.l10n.dockerExitCode,
                '${details.exitCode}',
              ),
              dockerField(
                context,
                context.l10n.dockerRestartPolicy,
                '${details.restartPolicy} · ${details.restartCount}',
              ),
              dockerField(
                context,
                context.l10n.dockerPorts,
                [
                  for (final entry in details.ports.entries)
                    '${entry.key} -> ${entry.value == null ? '—' : (entry.value as List).map((b) => '${b['HostIp']}:${b['HostPort']}').join(', ')}',
                ].join('\n'),
              ),
              dockerField(
                context,
                context.l10n.dockerMounts,
                [
                  for (final mount in details.mounts)
                    '${mount['type']} · ${mount['source']} -> ${mount['destination']} (${mount['rw'] == true ? 'rw' : 'ro'})',
                ].join('\n'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
  Widget _metric(String label, String value) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 100),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: DockColors.purple)),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    ),
  );
}
