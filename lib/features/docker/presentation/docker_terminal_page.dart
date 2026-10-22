import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

import '../../../l10n/localization.dart';
import '../../connections/data/ssh_connection.dart';
import '../../connections/data/ssh_terminal_channel.dart';
import '../../settings/app_preferences.dart';
import '../data/docker_client.dart';
import 'docker_widgets.dart';

class DockerTerminalPage extends StatefulWidget {
  const DockerTerminalPage({
    super.key,
    required this.connection,
    required this.id,
    required this.name,
    required this.shell,
  });
  final SshConnection connection;
  final String id, name, shell;
  @override
  State<DockerTerminalPage> createState() => _DockerTerminalPageState();
}

class _DockerTerminalPageState extends State<DockerTerminalPage>
    with WidgetsBindingObserver {
  late final _client = DockerClient(widget.connection);
  SshTerminalChannel? _channel;
  Object? _error;
  bool _opening = true;
  int _generation = 0;
  final _focus = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.connection.addListener(_connectionChanged);
    _open();
  }

  Future<void> _open() async {
    final generation = _generation;
    try {
      final channel = await _client.terminal(widget.id, widget.shell);
      if (!mounted || generation != _generation) {
        channel.dispose();
        return;
      }
      _channel = channel;
      channel.addListener(_changed);
    } catch (error) {
      if (mounted && generation == _generation) _error = error;
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _opening = false);
      }
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _connectionChanged() {
    if (widget.connection.status != ConnectionStatus.connected) _close();
  }

  void _close() {
    _generation++;
    _client.cancelPending();
    _channel?.close();
    if (mounted) setState(() => _opening = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _close();
    }
  }

  @override
  void dispose() {
    _generation++;
    widget.connection.removeListener(_connectionChanged);
    WidgetsBinding.instance.removeObserver(this);
    _channel?.removeListener(_changed);
    _client.dispose();
    _channel?.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channel = _channel;
    final active = channel?.active == true;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name} · ${widget.shell}'),
        actions: [
          IconButton(
            onPressed: active ? _close : null,
            tooltip: context.l10n.disconnect,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_opening) const LinearProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _error != null
                    ? dockerError(context, _error!)
                    : active
                    ? context.l10n.dockerContainerTerminal
                    : context.l10n.dockerTerminalEnded,
              ),
            ),
            if (channel != null)
              Expanded(
                child: TerminalView(
                  channel.terminal,
                  key: const ValueKey('docker-terminal'),
                  textStyle: TerminalStyle(
                    fontSize:
                        AppPreferencesScope.maybeOf(context)
                            ?.terminalFontSize ??
                        14,
                  ),
                  focusNode: _focus,
                  autofocus: active,
                  readOnly: !active,
                  padding: const EdgeInsets.all(12),
                ),
              )
            else
              const Spacer(),
            if (active)
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
                          channel!.terminal.keyInput(item.$2);
                          _focus.requestFocus();
                        },
                        child: Text(item.$1),
                      ),
                    TextButton(
                      onPressed: () => channel!.terminal.onOutput?.call('\x03'),
                      child: const Text('Ctrl+C'),
                    ),
                    TextButton(
                      onPressed: () => channel!.terminal.onOutput?.call('\x04'),
                      child: const Text('Ctrl+D'),
                    ),
                    IconButton(
                      onPressed: _focus.requestFocus,
                      tooltip: context.l10n.openKeyboard,
                      icon: const Icon(Icons.keyboard),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
