import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

import '../../../l10n/localization.dart';
import '../../connections/data/ssh_connection.dart';
import '../../connections/presentation/host_key_dialog.dart';
import '../../instances/domain/server_instance.dart';
import '../../instances/presentation/instance_editor.dart';
import '../../settings/app_preferences.dart';
import '../../workspaces/domain/dock_controller.dart';
import '../data/coolify_session.dart';
import 'container_target.dart';
import 'terminal_link_store.dart';

class CoolifyTerminalPage extends StatefulWidget {
  const CoolifyTerminalPage({
    super.key,
    required this.session,
    required this.controller,
    this.target,
    this.links,
    this.createConnection,
  });
  final CoolifySession session;
  final DockController controller;
  final CoolifyTerminalTarget? target;
  final TerminalLinkStore? links;
  final SshConnection Function(ServerInstance)? createConnection;
  @override
  State<CoolifyTerminalPage> createState() => _CoolifyTerminalPageState();
}

class _CoolifyTerminalPageState extends State<CoolifyTerminalPage>
    with WidgetsBindingObserver {
  late final _links = widget.links ?? TerminalLinkStore();
  List<Map<String, dynamic>> _servers = [];
  List<RunningContainer> _containers = [];
  String? _server, _sshId, _error, _container;
  String _shell = 'sh';
  bool _busy = false, _terminal = false;
  int _generation = 0;
  SshConnection? _ssh;
  final _focus = FocusNode();
  List<ServerInstance> get _choices => [
    for (final w in widget.controller.workspaces)
      for (final i in w.instances)
        if (i.type == InstanceType.ssh && !i.isDemo) i,
  ];
  ServerInstance? get _selected =>
      _choices.where((i) => i.id == _sshId).firstOrNull;
  bool get _connected => _ssh?.status == ConnectionStatus.connected;
  bool _active(int generation) =>
      mounted && generation == _generation && widget.session.active;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.session.addListener(_sessionChanged);
    widget.controller.addListener(_credentialsChanged);
    _loadServers();
  }

  void _credentialsChanged() {
    final coolifyExists = widget.controller.workspaces.any(
      (w) => w.instances.any((i) => identical(i, widget.session.instance)),
    );
    if (!coolifyExists ||
        (_ssh != null && !identical(_selected, _ssh!.instance))) {
      _disconnect();
      if (!coolifyExists) {
        _servers = [];
        _server = null;
        _sshId = null;
      }
    }
    if (mounted) setState(() {});
  }

  void _sessionChanged() {
    if (!widget.session.active) _disconnect();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _disconnect();
    }
  }

  void _disconnect() {
    _generation++;
    _ssh?.removeListener(_changed);
    _ssh?.dispose();
    _ssh = null;
    if (mounted) {
      setState(() {
        _busy = false;
        _terminal = false;
        _containers = [];
        _container = null;
      });
    }
  }

  void _changed() {
    if (!mounted) return;
    if (!_connected && _ssh?.status != ConnectionStatus.connecting) {
      setState(() {
        _terminal = false;
        _containers = [];
        _container = null;
        _error = _ssh?.error ?? _error;
      });
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _generation++;
    widget.session.removeListener(_sessionChanged);
    widget.controller.removeListener(_credentialsChanged);
    WidgetsBinding.instance.removeObserver(this);
    _ssh?.removeListener(_changed);
    _ssh?.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadServers() async {
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await widget.session.request('GET', '/servers');
      if (!_active(generation)) return;
      final raw = result is List
          ? result
          : result is Map
          ? result['data']
          : null;
      if (raw is! List) throw const FormatException('Invalid servers');
      _servers = raw
          .whereType<Map<String, dynamic>>()
          .where((s) => s['uuid'] is String)
          .toList();
      final target = widget.target;
      final details = target?.details ?? {};
      final destination = details['destination'];
      final nested =
          details['server'] ??
          (destination is Map ? destination['server'] : null);
      final uuid = target?.kind == 'servers'
          ? target!.uuid
          : details['server_uuid'] ?? (nested is Map ? nested['uuid'] : null);
      final id =
          details['server_id'] ??
          (destination is Map ? destination['server_id'] : null) ??
          (nested is Map ? nested['id'] : null);
      final match = _servers
          .where(
            (s) => uuid != null
                ? s['uuid'] == uuid
                : id != null && '${s['id']}' == '$id',
          )
          .firstOrNull;
      _server = match?['uuid'] as String?;
      if (_server != null) {
        _sshId = await _links.read(widget.session.instance, _server!, _choices);
      }
    } catch (_) {
      if (_active(generation)) _error = 'coolifyTerminalServersFailed';
    } finally {
      if (_active(generation)) setState(() => _busy = false);
    }
  }

  Future<void> _selectServer(String? value) async {
    _disconnect();
    final generation = _generation;
    setState(() {
      _server = value;
      _sshId = null;
      _error = null;
      _busy = true;
    });
    try {
      final saved = value == null
          ? null
          : await _links.read(widget.session.instance, value, _choices);
      if (_active(generation)) setState(() => _sshId = saved);
    } catch (_) {
      if (_active(generation)) {
        setState(() => _error = 'coolifyTerminalLinkFailed');
      }
    } finally {
      if (_active(generation)) setState(() => _busy = false);
    }
  }

  Future<void> _addSsh() async {
    final workspace = widget.controller.activeWorkspace;
    if (workspace == null) return;
    final previous = _choices.map((i) => i.id).toSet();
    await showInstanceEditor(
      context,
      widget.controller,
      workspaceId: workspace.id,
    );
    if (!mounted) return;
    final added = _choices.where((i) => !previous.contains(i.id)).firstOrNull;
    if (added != null) setState(() => _sshId = added.id);
  }

  Future<void> _connect() async {
    final selected = _selected;
    if (selected == null || _server == null) return;
    _disconnect();
    final generation = _generation;
    final ssh = _ssh =
        widget.createConnection?.call(selected) ?? SshConnection(selected);
    ssh.addListener(_changed);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ssh.connect((type, fingerprint, previous) async {
        if (!_active(generation)) return false;
        return confirmSshHostKey(
          context,
          selected,
          type,
          fingerprint,
          previous,
        );
      }, openShell: false);
      if (!_active(generation) || !identical(ssh, _ssh)) return;
      if (ssh.status != ConnectionStatus.connected) {
        setState(() => _error = ssh.error ?? 'coolifyCancelled');
        return;
      }
      await _links.write(widget.session.instance, _server!, selected);
      if (!_active(generation)) return;
      if (widget.target?.kind == 'servers') {
        await _openShell(null);
      } else {
        await _discover();
      }
    } catch (_) {
      if (_active(generation)) {
        setState(() => _error = 'coolifyTerminalConnectFailed');
      }
    } finally {
      if (_active(generation)) setState(() => _busy = false);
    }
  }

  Future<void> _discover() async {
    final generation = _generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final raw = await _ssh!.discoverContainers();
      if (!_active(generation)) return;
      final containers = resourceContainers(raw, widget.target);
      setState(() {
        _containers = containers;
        _container = null;
      });
    } catch (_) {
      if (_active(generation)) {
        setState(() => _error = 'coolifyTerminalDockerFailed');
      }
    } finally {
      if (_active(generation)) setState(() => _busy = false);
    }
  }

  Future<void> _openShell(String? id) async {
    final generation = _generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Recheck ownership and liveness immediately before selecting the ID.
      if (id != null) {
        final raw = await _ssh!.discoverContainers();
        if (!_active(generation)) return;
        if (!resourceContainers(raw, widget.target).any((c) => c.id == id)) {
          setState(() {
            _container = null;
            _error = 'coolifyTerminalContainerGone';
          });
          return;
        }
      }
      await _ssh!.openTerminal(containerId: id, shell: _shell);
      if (_active(generation) && _connected) setState(() => _terminal = true);
    } catch (_) {
      if (_active(generation)) {
        setState(() => _error = 'coolifyTerminalShellFailed');
      }
    } finally {
      if (_active(generation)) setState(() => _busy = false);
    }
  }

  void _help() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.openTerminal),
      content: Text(context.l10n.coolifyTerminalHelp),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.target?.name ?? context.l10n.openTerminal),
      actions: [
        IconButton(
          onPressed: _help,
          tooltip: context.l10n.openTerminal,
          icon: const Icon(Icons.help_outline),
        ),
        if (_connected)
          IconButton(
            onPressed: _disconnect,
            tooltip: context.l10n.disconnect,
            icon: const Icon(Icons.link_off),
          ),
      ],
    ),
    body: SafeArea(
      child: _terminal
          ? _terminalView()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_busy) const LinearProgressIndicator(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(localizedMessage(context, _error!)),
                  ),
                if (_servers.isEmpty && !_busy)
                  TextButton(
                    onPressed: _loadServers,
                    child: Text(context.l10n.retry),
                  ),
                DropdownButtonFormField<String>(
                  key: ValueKey('server-$_server'),
                  initialValue: _server,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.coolifyTerminalServer,
                  ),
                  items: [
                    for (final s in _servers)
                      DropdownMenuItem(
                        value: '${s['uuid']}',
                        child: Text(
                          '${s['name'] ?? s['uuid']} · ${s['ip'] ?? ''}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: _busy || _connected ? null : _selectServer,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('ssh-$_sshId'),
                  initialValue: _choices.any((i) => i.id == _sshId)
                      ? _sshId
                      : null,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.coolifySshTerminal,
                  ),
                  items: [
                    for (final i in _choices)
                      DropdownMenuItem(
                        value: i.id,
                        child: Text(
                          '${i.name} · ${i.address}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: _busy || _connected
                      ? null
                      : (value) => setState(() => _sshId = value),
                ),
                if (!_connected)
                  TextButton.icon(
                    onPressed:
                        _busy || widget.controller.activeWorkspace == null
                        ? null
                        : _addSsh,
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.addInstance),
                  ),
                if (_choices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(context.l10n.coolifyNoSsh),
                  ),
                const SizedBox(height: 16),
                if (!_connected)
                  FilledButton.icon(
                    onPressed: _busy || _selected == null || _server == null
                        ? null
                        : _connect,
                    icon: const Icon(Icons.link),
                    label: Text(context.l10n.connectInstance),
                  ),
                if (_connected) ...[
                  Text(
                    _selected?.address ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey('container-$_container'),
                    initialValue: _container,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.coolifyTerminalContainer,
                    ),
                    items: [
                      for (final c in _containers)
                        DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: _busy
                        ? null
                        : (value) => setState(() => _container = value),
                  ),
                  if (_containers.isEmpty && !_busy)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(context.l10n.coolifyTerminalNoContainers),
                    ),
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
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _busy || _container == null
                        ? null
                        : () => _openShell(_container),
                    icon: const Icon(Icons.terminal),
                    label: Text(context.l10n.coolifyTerminalContainer),
                  ),
                  TextButton.icon(
                    onPressed: _busy ? null : _discover,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.refresh),
                  ),
                  // Server access is explicit and separate from the resource container.
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _openShell(null),
                    icon: const Icon(Icons.dns_outlined),
                    label: Text(context.l10n.coolifyTerminalHost),
                  ),
                ],
              ],
            ),
    ),
  );
  Widget _terminalView() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${_selected?.address ?? ''}\n${_container == null ? context.l10n.coolifyTerminalHost : _containers.where((c) => c.id == _container).firstOrNull?.name ?? _container}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: _focus.requestFocus,
              tooltip: context.l10n.openKeyboard,
              icon: const Icon(Icons.keyboard),
            ),
          ],
        ),
      ),
      Expanded(
        child: TerminalView(
          _ssh!.terminal,
          focusNode: _focus,
          autofocus: true,
          textStyle: TerminalStyle(
            fontSize:
                AppPreferencesScope.maybeOf(context)?.terminalFontSize ?? 14,
          ),
          padding: const EdgeInsets.all(12),
        ),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final key in [
              ('Esc', TerminalKey.escape),
              ('Tab', TerminalKey.tab),
              ('↑', TerminalKey.arrowUp),
              ('↓', TerminalKey.arrowDown),
              ('←', TerminalKey.arrowLeft),
              ('→', TerminalKey.arrowRight),
            ])
              TextButton(
                onPressed: () {
                  _ssh!.terminal.keyInput(key.$2);
                  _focus.requestFocus();
                },
                child: Text(key.$1),
              ),
            for (final key in [('Ctrl+C', '\x03'), ('Ctrl+D', '\x04')])
              TextButton(
                onPressed: () => _ssh!.terminal.onOutput?.call(key.$2),
                child: Text(key.$1),
              ),
          ],
        ),
      ),
    ],
  );
}
