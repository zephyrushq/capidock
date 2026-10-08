import '../../../l10n/localization.dart';

import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

import '../../../core/app_theme.dart';
import '../../../core/widgets.dart';
import '../../instances/domain/server_instance.dart';
import '../../coolify/presentation/coolify_workspace_page.dart';
import '../data/ssh_connection.dart';

class InstanceConnectionPage extends StatefulWidget {
  const InstanceConnectionPage({
    super.key,
    required this.instance,
    required this.onEdit,
    this.onTerminal,
  });
  final ServerInstance instance;
  final VoidCallback onEdit;
  final VoidCallback? onTerminal;
  @override
  State<InstanceConnectionPage> createState() => _InstanceConnectionPageState();
}

class _InstanceConnectionPageState extends State<InstanceConnectionPage>
    with WidgetsBindingObserver {
  late final SshConnection _ssh = SshConnection(widget.instance);
  int _tab = 0;
  final _terminalFocus = FocusNode();

  bool get _isSsh => widget.instance.type == InstanceType.ssh;
  bool get _connected => _ssh.status == ConnectionStatus.connected;
  bool get _busy => _ssh.status == ConnectionStatus.connecting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _ssh.disconnect();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _ssh.dispose();
    _terminalFocus.dispose();
    super.dispose();
  }

  Future<bool> _confirmHostKey(
    String type,
    String fingerprint,
    String? previous,
  ) async {
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(
              previous == null
                  ? context.l10n.confirmSshServer
                  : context.l10n.serverKeyChanged,
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.instance.host}:${widget.instance.port}\n\n${previous == null ? context.l10n.compareFingerprint : context.l10n.changedKeyWarning}',
                  ),
                  const SizedBox(height: 16),
                  Text(type),
                  const SizedBox(height: 8),
                  SelectableText(fingerprint),
                  if (previous != null) ...[
                    const SizedBox(height: 16),
                    Text(context.l10n.savedKey),
                    SelectableText(previous),
                  ],
                  const SizedBox(height: 16),
                  Text(context.l10n.verifyKeyCommand),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  previous == null
                      ? context.l10n.trustAndConnect
                      : context.l10n.replaceKey,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) => !_isSsh
      ? CoolifyWorkspacePage(
          instance: widget.instance,
          onEdit: widget.onEdit,
          onTerminal: widget.onTerminal ?? widget.onEdit,
        )
      : ListenableBuilder(
          listenable: _ssh,
          builder: (context, _) => Column(
            children: [
              Expanded(child: _isSsh && _tab == 1 ? _terminal() : _overview()),
              if (_isSsh)
                NavigationBar(
                  selectedIndex: _tab,
                  onDestinationSelected: (value) =>
                      setState(() => _tab = value),
                  destinations: [
                    NavigationDestination(
                      icon: Icon(Icons.dns_outlined),
                      label: context.l10n.server,
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.terminal),
                      label: 'Terminal',
                    ),
                  ],
                ),
            ],
          ),
        );

  Widget _overview() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Row(
        children: [
          Icon(
            instanceIcon(widget.instance.type),
            color: DockColors.purple,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.instance.type == InstanceType.ssh
                  ? context.l10n.yourServer
                  : context.l10n.yourResources,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      SelectableText(
        widget.instance.address,
        style: const TextStyle(color: DockColors.muted),
      ),
      const SizedBox(height: 20),
      Align(
        alignment: Alignment.centerLeft,
        child: StatusPill(
          _busy
              ? context.l10n.connecting
              : _connected
              ? (_isSsh ? context.l10n.connected : context.l10n.receivedData)
              : context.l10n.notConnected,
          color: _connected ? DockColors.green : DockColors.muted,
        ),
      ),
      const SizedBox(height: 20),
      if (!widget.instance.hasCredentials) ...[
        Text(context.l10n.addCredentials),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: widget.onEdit,
          icon: const Icon(Icons.key),
          label: Text(context.l10n.configureAccess),
        ),
      ] else
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              key: const ValueKey('connect-instance'),
              onPressed: _busy
                  ? null
                  : () {
                      _connected
                          ? _ssh.refreshInformation()
                          : _ssh.connect(_confirmHostKey);
                    },
              icon: Icon(_connected ? Icons.refresh : Icons.power_settings_new),
              label: Text(
                _busy
                    ? context.l10n.connecting
                    : _connected
                    ? context.l10n.refresh
                    : context.l10n.connectInstance,
              ),
            ),
            if (_busy || (_isSsh && _connected))
              OutlinedButton(
                onPressed: _ssh.disconnect,
                child: Text(
                  _busy ? context.l10n.cancel : context.l10n.disconnect,
                ),
              ),
            TextButton.icon(
              onPressed: _busy ? null : widget.onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(context.l10n.editAccess),
            ),
          ],
        ),
      if (_busy)
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: LinearProgressIndicator(),
        ),
      if (_ssh.error case final String error)
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            localizedMessage(context, error),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      const SizedBox(height: 24),
      if (_isSsh) ...[
        if (_connected) ...[
          FilledButton.tonalIcon(
            onPressed: () => setState(() => _tab = 1),
            icon: const Icon(Icons.terminal),
            label: Text(context.l10n.openTerminal),
          ),
          const SizedBox(height: 24),
        ],
        if (_ssh.refreshing) const LinearProgressIndicator(),
        if (_ssh.informationError != null)
          Text(localizedMessage(context, _ssh.informationError!)),
        if (_ssh.information != null) ...[
          _timestamp(_ssh.updatedAt),
          const SizedBox(height: 12),
          SurfaceCard(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(
                _ssh.information!,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ),
        ] else if (!_busy && !_connected)
          SurfaceCard(child: Text(context.l10n.connectForInfo)),
      ],
      const SizedBox(height: 24),
      Text(
        context.l10n.connectionPrivacy,
        style: TextStyle(color: DockColors.muted, fontSize: 12),
      ),
    ],
  );

  Widget _timestamp(DateTime? time) => Text(
    time == null
        ? ''
        : context.l10n.lastRead(
            TimeOfDay.fromDateTime(time).format(context),
            !_connected ? context.l10n.previousData : '',
          ),
    style: const TextStyle(color: DockColors.muted, fontSize: 12),
  );

  Widget _terminal() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _connected
                    ? context.l10n.activeSshSession
                    : context.l10n.terminalDisconnected,
                style: const TextStyle(color: DockColors.muted),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _tab = 0),
              child: Text(context.l10n.connection),
            ),
          ],
        ),
      ),
      Expanded(
        child: TerminalView(
          _ssh.terminal,
          focusNode: _terminalFocus,
          readOnly: !_connected,
          autofocus: _connected,
          padding: const EdgeInsets.all(12),
        ),
      ),
      if (_connected)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final item in [
                ('Esc', TerminalKey.escape),
                ('Tab', TerminalKey.tab),
                ('↑', TerminalKey.arrowUp),
                ('↓', TerminalKey.arrowDown),
                ('←', TerminalKey.arrowLeft),
                ('→', TerminalKey.arrowRight),
              ])
                TextButton(
                  onPressed: () {
                    _ssh.terminal.keyInput(item.$2);
                    _terminalFocus.requestFocus();
                  },
                  child: Text(item.$1),
                ),
              TextButton(
                onPressed: () => _ssh.terminal.onOutput?.call('\x03'),
                child: Text('Ctrl+C'),
              ),
              TextButton(
                onPressed: () => _ssh.terminal.onOutput?.call('\x04'),
                child: Text('Ctrl+D'),
              ),
              IconButton(
                onPressed: _terminalFocus.requestFocus,
                tooltip: context.l10n.openKeyboard,
                icon: const Icon(Icons.keyboard),
              ),
            ],
          ),
        ),
    ],
  );
}
