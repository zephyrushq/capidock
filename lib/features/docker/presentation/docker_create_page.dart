import 'package:flutter/material.dart';

import '../../../l10n/localization.dart';
import '../../connections/data/ssh_connection.dart';
import '../data/docker_client.dart';
import '../data/docker_command.dart';
import '../data/docker_create_spec.dart';
import 'docker_widgets.dart';

class _PortDraft {
  final address = TextEditingController(text: '127.0.0.1');
  final host = TextEditingController(), target = TextEditingController();
  String protocol = 'tcp';
  void dispose() {
    address.dispose();
    host.dispose();
    target.dispose();
  }
}

class _EnvironmentDraft {
  final name = TextEditingController(), value = TextEditingController();
  void dispose() {
    name.dispose();
    value.dispose();
  }
}

class _MountDraft {
  final source = TextEditingController(), target = TextEditingController();
  DockerMountType type = DockerMountType.volume;
  bool readOnly = false;
  void dispose() {
    source.dispose();
    target.dispose();
  }
}

class DockerCreatePage extends StatefulWidget {
  const DockerCreatePage({super.key, required this.connection});
  final SshConnection connection;
  @override
  State<DockerCreatePage> createState() => _DockerCreatePageState();
}

class _DockerCreatePageState extends State<DockerCreatePage>
    with WidgetsBindingObserver {
  late final _client = DockerClient(widget.connection);
  final _image = TextEditingController(), _name = TextEditingController();
  final _ports = <_PortDraft>[];
  final _environment = <_EnvironmentDraft>[];
  final _mounts = <_MountDraft>[];
  final _scroll = ScrollController();
  bool _busy = false, _expired = false, _uncertain = false, _sending = false;
  int _generation = 0;
  String? _error;
  DialogRoute<bool>? _review;
  bool get _connected => widget.connection.status == ConnectionStatus.connected;
  bool get _resumed =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  bool get _editable => !_busy && !_expired && !_uncertain && _connected;
  bool _active(int generation) =>
      mounted &&
      generation == _generation &&
      _connected &&
      _resumed &&
      !_expired;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.connection.addListener(_connectionChanged);
  }

  void _connectionChanged() {
    if (!_connected) _expire();
  }

  void _expire() {
    if (!mounted || _expired) return;
    _generation++;
    _client.cancelPending();
    _image.clear();
    _name.clear();
    for (final row in _environment) {
      row.name.clear();
      row.value.clear();
    }
    for (final row in _ports) {
      row.address.clear();
      row.host.clear();
      row.target.clear();
    }
    for (final row in _mounts) {
      row.source.clear();
      row.target.clear();
    }
    final route = _review;
    if (route != null && route.isActive) route.navigator?.removeRoute(route);
    setState(() {
      _expired = true;
      _busy = false;
      _sending = false;
      _error = null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _expire();
    }
  }

  @override
  void dispose() {
    _generation++;
    widget.connection.removeListener(_connectionChanged);
    WidgetsBinding.instance.removeObserver(this);
    _client.dispose();
    _image.dispose();
    _name.dispose();
    _scroll.dispose();
    for (final row in _ports) {
      row.dispose();
    }
    for (final row in _environment) {
      row.dispose();
    }
    for (final row in _mounts) {
      row.dispose();
    }
    super.dispose();
  }

  DockerCreateSpec _spec() => DockerCreateSpec(
    image: _image.text.trim(),
    name: _name.text.trim(),
    ports: [
      for (final row in _ports)
        DockerPortMapping(
          hostAddress: row.address.text.trim(),
          hostPort: int.tryParse(row.host.text) ?? 0,
          containerPort: int.tryParse(row.target.text) ?? 0,
          protocol: row.protocol,
        ),
    ],
    environment: [
      for (final row in _environment)
        DockerEnvironment(row.name.text.trim(), row.value.text),
    ],
    mounts: [
      for (final row in _mounts)
        DockerMount(
          type: row.type,
          source: row.source.text.trim(),
          target: row.target.text.trim(),
          readOnly: row.readOnly,
        ),
    ],
  );
  String _validation(DockerCreateField field) => switch (field) {
    DockerCreateField.image => context.l10n.dockerCreateInvalidImage,
    DockerCreateField.name => context.l10n.dockerCreateInvalidName,
    DockerCreateField.ports => context.l10n.dockerCreateInvalidPorts,
    DockerCreateField.environment =>
      context.l10n.dockerCreateInvalidEnvironment,
    DockerCreateField.mounts => context.l10n.dockerCreateInvalidMounts,
  };
  void _showError(String message) {
    setState(() => _error = message);
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _submit() async {
    if (!_editable || !_resumed) return;
    final DockerCreateSpec spec;
    try {
      spec = _spec();
    } on DockerCreateValidation catch (error) {
      _showError(_validation(error.field));
      return;
    }
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final route = DialogRoute<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.dockerCreateReview),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dockerField(context, context.l10n.dockerImage, spec.image),
                dockerField(context, context.l10n.dockerCreateName, spec.name),
                if (spec.ports.isNotEmpty)
                  dockerField(
                    context,
                    context.l10n.dockerPorts,
                    spec.ports.map((p) => p.binding).join('\n'),
                  ),
                if (spec.environment.isNotEmpty)
                  dockerField(
                    context,
                    context.l10n.dockerCreateEnvironment,
                    spec.environment.map((e) => '${e.name}=••••').join('\n'),
                  ),
                if (spec.mounts.isNotEmpty)
                  dockerField(
                    context,
                    context.l10n.dockerMounts,
                    spec.mounts
                        .map(
                          (m) =>
                              '${m.type == DockerMountType.volume ? context.l10n.dockerCreateNamedVolume : context.l10n.dockerCreateBindMount}: ${m.source} -> ${m.normalizedTarget} (${m.readOnly ? context.l10n.dockerCreateReadOnly : context.l10n.dockerCreateReadWrite})',
                        )
                        .join('\n'),
                  ),
                Text(context.l10n.dockerCreateStopped),
                const SizedBox(height: 12),
                Text(context.l10n.dockerCreatePullHelp),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              key: const ValueKey('docker-confirm-create'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.dockerCreate),
            ),
          ],
        ),
      );
      _review = route;
      final approved = await Navigator.of(context).push(route);
      _review = null;
      if (approved != true || !_active(generation)) return;
      setState(() => _sending = true);
      final id = await _client.create(spec);
      if (mounted && _active(generation)) Navigator.pop(context, id);
    } catch (error) {
      if (mounted && _active(generation)) {
        _uncertain =
            error is! DockerException ||
            !const {
              DockerFailure.notInstalled,
              DockerFailure.permission,
              DockerFailure.unavailable,
              DockerFailure.nameConflict,
              DockerFailure.imageUnavailable,
            }.contains(error.failure);
        _showError(dockerError(context, error));
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() {
          _busy = false;
          _sending = false;
        });
      }
    }
  }

  Widget _field(
    String key,
    String label,
    TextEditingController controller, {
    bool secret = false,
    bool numeric = false,
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      key: ValueKey(key),
      controller: controller,
      enabled: _editable,
      obscureText: secret,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, hintText: hint),
    ),
  );
  Widget _section(String title, String help, VoidCallback? add, String key) =>
      Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(help, style: Theme.of(context).textTheme.bodySmall),
            TextButton.icon(
              key: ValueKey(key),
              onPressed: _editable ? add : null,
              icon: const Icon(Icons.add),
              label: Text(title),
            ),
          ],
        ),
      );
  Widget _rowCard(Object row, int index, Widget child, VoidCallback remove) =>
      Card(
        key: ObjectKey(row),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: _editable ? remove : null,
                  tooltip: context.l10n.remove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
              child,
            ],
          ),
        ),
      );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.dockerCreate)),
    body: SafeArea(
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.all(20),
        children: [
          if (_expired)
            Text(
              context.l10n.dockerCreateExpired,
              key: const ValueKey('docker-create-expired'),
            ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_uncertain) Text(context.l10n.dockerCreateUncertain),
          Text(
            context.l10n.dockerCreateStopped,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          _field(
            'docker-create-image',
            context.l10n.dockerImage,
            _image,
            hint: 'nginx:alpine',
          ),
          _field(
            'docker-create-name',
            context.l10n.dockerCreateName,
            _name,
            hint: 'my-web',
          ),
          _section(
            context.l10n.dockerPorts,
            context.l10n.dockerCreatePortsHelp,
            _ports.length >= 32
                ? null
                : () => setState(() => _ports.add(_PortDraft())),
            'docker-add-port',
          ),
          for (var i = 0; i < _ports.length; i++)
            _rowCard(
              _ports[i],
              i,
              Column(
                children: [
                  _field(
                    'docker-port-address-$i',
                    context.l10n.dockerCreateHostAddress,
                    _ports[i].address,
                  ),
                  _field(
                    'docker-port-host-$i',
                    context.l10n.dockerCreateHostPort,
                    _ports[i].host,
                    numeric: true,
                  ),
                  _field(
                    'docker-port-target-$i',
                    context.l10n.dockerCreateContainerPort,
                    _ports[i].target,
                    numeric: true,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _ports[i].protocol,
                    decoration: InputDecoration(
                      labelText: context.l10n.dockerCreateProtocol,
                    ),
                    items: [
                      for (final p in ['tcp', 'udp'])
                        DropdownMenuItem(
                          value: p,
                          child: Text(p.toUpperCase()),
                        ),
                    ],
                    onChanged: _editable
                        ? (v) => setState(() => _ports[i].protocol = v!)
                        : null,
                  ),
                ],
              ),
              () {
                final row = _ports.removeAt(i);
                setState(() {});
                row.dispose();
              },
            ),
          _section(
            context.l10n.dockerCreateEnvironment,
            context.l10n.dockerCreateEnvironmentHelp,
            _environment.length >= 128
                ? null
                : () => setState(() => _environment.add(_EnvironmentDraft())),
            'docker-add-env',
          ),
          for (var i = 0; i < _environment.length; i++)
            _rowCard(
              _environment[i],
              i,
              Column(
                children: [
                  _field(
                    'docker-env-name-$i',
                    context.l10n.dockerCreateVariableName,
                    _environment[i].name,
                  ),
                  _field(
                    'docker-env-value-$i',
                    context.l10n.dockerCreateVariableValue,
                    _environment[i].value,
                    secret: true,
                  ),
                ],
              ),
              () {
                final row = _environment.removeAt(i);
                setState(() {});
                row.dispose();
              },
            ),
          _section(
            context.l10n.dockerMounts,
            context.l10n.dockerCreateMountsHelp,
            _mounts.length >= 32
                ? null
                : () => setState(() => _mounts.add(_MountDraft())),
            'docker-add-mount',
          ),
          for (var i = 0; i < _mounts.length; i++)
            _rowCard(
              _mounts[i],
              i,
              Column(
                children: [
                  DropdownButtonFormField<DockerMountType>(
                    key: ValueKey('docker-mount-type-$i'),
                    initialValue: _mounts[i].type,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.dockerCreateMountType,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: DockerMountType.volume,
                        child: Text(context.l10n.dockerCreateNamedVolume),
                      ),
                      DropdownMenuItem(
                        value: DockerMountType.bind,
                        child: Text(context.l10n.dockerCreateBindMount),
                      ),
                    ],
                    onChanged: _editable
                        ? (v) => setState(() => _mounts[i].type = v!)
                        : null,
                  ),
                  _field(
                    'docker-mount-source-$i',
                    context.l10n.dockerCreateMountSource,
                    _mounts[i].source,
                  ),
                  _field(
                    'docker-mount-target-$i',
                    context.l10n.dockerCreateMountTarget,
                    _mounts[i].target,
                    hint: '/data',
                  ),
                  SwitchListTile(
                    title: Text(context.l10n.dockerCreateReadOnly),
                    value: _mounts[i].readOnly,
                    onChanged: _editable
                        ? (v) => setState(() => _mounts[i].readOnly = v)
                        : null,
                  ),
                ],
              ),
              () {
                final row = _mounts.removeAt(i);
                setState(() {});
                row.dispose();
              },
            ),
          const SizedBox(height: 20),
          if (_sending) ...[
            const LinearProgressIndicator(),
            Text(context.l10n.dockerCreatePullHelp),
          ],
          if (_expired || _uncertain)
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.dockerCreateBackToList),
            )
          else
            FilledButton.icon(
              key: const ValueKey('docker-review-create'),
              onPressed: _editable ? _submit : null,
              icon: const Icon(Icons.add_box_outlined),
              label: Text(context.l10n.dockerCreateReview),
            ),
        ],
      ),
    ),
  );
}
