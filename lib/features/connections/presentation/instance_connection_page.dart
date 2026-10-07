import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

import '../../../core/app_theme.dart';
import '../../../core/widgets.dart';
import '../../instances/domain/server_instance.dart';
import '../data/coolify_client.dart';
import '../data/ssh_connection.dart';

class InstanceConnectionPage extends StatefulWidget {
  const InstanceConnectionPage({
    super.key,
    required this.instance,
    required this.onEdit,
  });
  final ServerInstance instance;
  final VoidCallback onEdit;
  @override
  State<InstanceConnectionPage> createState() => _InstanceConnectionPageState();
}

class _InstanceConnectionPageState extends State<InstanceConnectionPage>
    with WidgetsBindingObserver {
  late final SshConnection _ssh = SshConnection(widget.instance);
  CoolifyClient? _coolify;
  List<CoolifyResource>? _resources;
  String? _coolifyError;
  DateTime? _updatedAt;
  bool _loading = false;
  int _request = 0;
  int _tab = 0;
  final _terminalFocus = FocusNode();

  bool get _isSsh => widget.instance.type == InstanceType.ssh;
  bool get _connected =>
      _isSsh ? _ssh.status == ConnectionStatus.connected : _resources != null;
  bool get _busy =>
      _isSsh ? _ssh.status == ConnectionStatus.connecting : _loading;

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
      _cancelCoolify();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _request++;
    _coolify?.close();
    _ssh.dispose();
    _terminalFocus.dispose();
    super.dispose();
  }

  void _cancelCoolify() {
    _request++;
    _coolify?.close();
    _coolify = null;
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadResources() async {
    _cancelCoolify();
    final request = _request;
    final client = CoolifyClient();
    _coolify = client;
    setState(() {
      _loading = true;
      _coolifyError = null;
    });
    try {
      final resources = await client.resources(widget.instance);
      if (!mounted || request != _request) return;
      setState(() {
        _resources = resources;
        _updatedAt = DateTime.now();
      });
    } on CoolifyException catch (error) {
      if (mounted && request == _request) {
        setState(() => _coolifyError = error.message);
      }
    } finally {
      client.close();
      if (mounted && request == _request) {
        setState(() {
          _loading = false;
          _coolify = null;
        });
      }
    }
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
                  ? 'Confirmar servidor SSH'
                  : 'A chave do servidor mudou',
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.instance.host}:${widget.instance.port}\n\n${previous == null ? 'Compare esta impressão digital com a do seu servidor antes de confiar.' : 'Pode ser uma reinstalação ou uma ligação a outro servidor. Só substitua a chave depois de a verificar por outro meio.'}',
                  ),
                  const SizedBox(height: 16),
                  Text(type),
                  const SizedBox(height: 8),
                  SelectableText(fingerprint),
                  if (previous != null) ...[
                    const SizedBox(height: 16),
                    const Text('Chave guardada:'),
                    SelectableText(previous),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'No servidor: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (ajuste ao tipo de chave apresentado).',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  previous == null ? 'Confiar e ligar' : 'Substituir chave',
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _ssh,
    builder: (context, _) => Column(
      children: [
        Expanded(child: _isSsh && _tab == 1 ? _terminal() : _overview()),
        if (_isSsh)
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (value) => setState(() => _tab = value),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dns_outlined),
                label: 'Servidor',
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
                  ? 'O seu servidor'
                  : 'Os seus recursos',
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
              ? 'A ligar…'
              : _connected
              ? (_isSsh ? 'Ligado' : 'Dados recebidos')
              : 'Por ligar',
          color: _connected ? DockColors.green : DockColors.muted,
        ),
      ),
      const SizedBox(height: 20),
      if (!widget.instance.hasCredentials) ...[
        const Text(
          'Adicione uma credencial para ligar esta instância. O endereço guardado foi preservado.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: widget.onEdit,
          icon: const Icon(Icons.key),
          label: const Text('Configurar acesso'),
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
                      if (_isSsh) {
                        _connected
                            ? _ssh.refreshInformation()
                            : _ssh.connect(_confirmHostKey);
                      } else {
                        _loadResources();
                      }
                    },
              icon: Icon(_connected ? Icons.refresh : Icons.power_settings_new),
              label: Text(
                _busy
                    ? 'A ligar…'
                    : _connected
                    ? 'Atualizar'
                    : 'Ligar à instância',
              ),
            ),
            if (_busy || (_isSsh && _connected))
              OutlinedButton(
                onPressed: _isSsh ? _ssh.disconnect : _cancelCoolify,
                child: Text(_busy ? 'Cancelar' : 'Desligar'),
              ),
            TextButton.icon(
              onPressed: _busy ? null : widget.onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar acesso'),
            ),
          ],
        ),
      if (_busy)
        const Padding(
          padding: EdgeInsets.only(top: 20),
          child: LinearProgressIndicator(),
        ),
      if ((_isSsh ? _ssh.error : _coolifyError) case final String error)
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            error,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      const SizedBox(height: 24),
      if (_isSsh) ...[
        if (_connected) ...[
          FilledButton.tonalIcon(
            onPressed: () => setState(() => _tab = 1),
            icon: const Icon(Icons.terminal),
            label: const Text('Abrir terminal'),
          ),
          const SizedBox(height: 24),
        ],
        if (_ssh.refreshing) const LinearProgressIndicator(),
        if (_ssh.informationError != null) Text(_ssh.informationError!),
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
          const SurfaceCard(
            child: Text(
              'Ligue-se para consultar o sistema, uptime, memória e disco, ou usar o terminal interativo.',
            ),
          ),
      ] else ...[
        if (_resources != null) ...[
          SectionTitle('${_resources!.length} recursos'),
          _timestamp(_updatedAt),
          const SizedBox(height: 16),
          if (_resources!.isEmpty)
            const SurfaceCard(
              child: Text(
                'A API não devolveu recursos para a equipa deste token.',
              ),
            ),
          for (final resource in _resources!)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resource.type,
                      style: const TextStyle(color: DockColors.muted),
                    ),
                    const SizedBox(height: 8),
                    Text(resource.status),
                  ],
                ),
              ),
            ),
        ] else if (!_busy)
          const SurfaceCard(
            child: Text(
              'Consulte as aplicações, bases de dados e serviços da sua equipa. Os estados vêm diretamente da API Coolify.',
            ),
          ),
      ],
      const SizedBox(height: 24),
      const Text(
        'As ligações SSH encerram ao mudar de instância ou colocar a app em segundo plano. As credenciais ficam cifradas no dispositivo.',
        style: TextStyle(color: DockColors.muted, fontSize: 12),
      ),
    ],
  );

  Widget _timestamp(DateTime? time) => Text(
    time == null
        ? ''
        : 'Última leitura: ${TimeOfDay.fromDateTime(time).format(context)}${!_connected || _coolifyError != null ? ' · dados anteriores' : ''}',
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
                _connected ? 'Sessão SSH ativa' : 'Terminal desligado',
                style: const TextStyle(color: DockColors.muted),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _tab = 0),
              child: const Text('Ligação'),
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
                child: const Text('Ctrl+C'),
              ),
              TextButton(
                onPressed: () => _ssh.terminal.onOutput?.call('\x04'),
                child: const Text('Ctrl+D'),
              ),
              IconButton(
                onPressed: _terminalFocus.requestFocus,
                tooltip: 'Abrir teclado',
                icon: const Icon(Icons.keyboard),
              ),
            ],
          ),
        ),
    ],
  );
}
