import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../l10n/localization.dart';
import '../../connections/data/ssh_connection.dart';
import '../data/docker_client.dart';
import '../data/docker_models.dart';
import 'docker_container_page.dart';
import 'docker_widgets.dart';

class DockerPanel extends StatefulWidget {
  const DockerPanel({
    super.key,
    required this.connection,
    required this.connect,
  });
  final SshConnection connection;
  final Future<void> Function() connect;
  @override
  State<DockerPanel> createState() => _DockerPanelState();
}

class _DockerPanelState extends State<DockerPanel> {
  late final _client = DockerClient(widget.connection);
  List<DockerContainer> _containers = [];
  bool _busy = false, _loaded = false;
  late bool _wasConnected = _connected;
  int _generation = 0;
  String _query = '';
  Object? _error;
  bool get _connected => widget.connection.status == ConnectionStatus.connected;
  @override
  void initState() {
    super.initState();
    _wasConnected = _connected;
    widget.connection.addListener(_changed);
    if (_connected) _load();
  }

  void _changed() {
    final previous = _wasConnected;
    _wasConnected = _connected;
    if (!_connected) {
      _generation++;
      _client.cancelPending();
      setState(() {
        _containers = [];
        _loaded = false;
        _error = null;
        _busy = false;
      });
    } else if (!previous && !_busy) {
      _load();
    }
    if (mounted) setState(() {});
  }

  Future<void> _connect() async {
    if (_busy || widget.connection.status == ConnectionStatus.connecting) {
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.connect();
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted && _connected) await _load();
  }

  Future<void> _load() async {
    if (!_connected || _busy) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final containers = await _client.containers();
      if (mounted && generation == _generation && _connected) {
        setState(() {
          _containers = containers;
          _loaded = true;
        });
      }
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = error;
          _containers = [];
          _loaded = false;
        });
      }
    } finally {
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _generation++;
    widget.connection.removeListener(_changed);
    _client.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: _load,
    child: ListView(
      key: const ValueKey('docker-panel'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Text('Docker', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          context.l10n.dockerDescription,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        if (!_connected) ...[
          Text(
            widget.connection.error == null
                ? context.l10n.dockerConnect
                : localizedMessage(context, widget.connection.error!),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed:
                _busy || widget.connection.status == ConnectionStatus.connecting
                ? null
                : _connect,
            icon: const Icon(Icons.link),
            label: Text(context.l10n.connectInstance),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.refresh),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => _query = value.toLowerCase()),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: context.l10n.dockerSearch,
            ),
          ),
        ],
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              dockerError(context, _error!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        if (_loaded && _containers.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.l10n.dockerEmpty),
          ),
        if (_loaded && _containers.isNotEmpty && !_containers.any(_matches))
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.l10n.noInstancesFound),
          ),
        for (final container in _containers.where(_matches))
          Card(
            child: ListTile(
              key: ValueKey('docker-container-${container.id}'),
              leading: Icon(
                Icons.inventory_2_outlined,
                color: container.running ? DockColors.green : DockColors.muted,
              ),
              title: Text(container.name),
              subtitle: Text('${container.image}\n${container.status}'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: _busy
                  ? null
                  : () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => DockerContainerPage(
                            connection: widget.connection,
                            container: container,
                          ),
                        ),
                      );
                      if (mounted && _connected) _load();
                    },
            ),
          ),
      ],
    ),
  );
  bool _matches(DockerContainer value) =>
      '${value.name} ${value.image} ${value.state}'.toLowerCase().contains(
        _query,
      );
}
