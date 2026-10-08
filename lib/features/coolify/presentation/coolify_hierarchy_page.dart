import '../terminal/container_target.dart';

import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/widgets.dart';
import '../../../core/request_states.dart';
import '../../../l10n/localization.dart';
import '../../connections/data/coolify_client.dart';
import '../data/coolify_catalog.dart';
import '../data/coolify_session.dart';
import 'coolify_cards.dart';
import 'coolify_operation_page.dart';
import 'coolify_workspace_page.dart';
import 'coolify_variables_page.dart';

/// Projects contain deployment environments, which contain typed resources.
/// `/envs` is shared configuration and is deliberately not used as the environment list.
class CoolifyHierarchyPage extends StatefulWidget {
  const CoolifyHierarchyPage({
    super.key,
    required this.session,
    required this.catalog,
    required this.kind,
    required this.uuid,
    required this.name,
    required this.onTerminal,
    this.onResourceTerminal,
    this.projectUuid,
    this.projectName,
  });
  final CoolifySession session;
  final CoolifyCatalog catalog;
  final String kind, uuid, name;
  final String? projectUuid, projectName;
  final VoidCallback onTerminal;
  final OpenResourceTerminal? onResourceTerminal;
  @override
  State<CoolifyHierarchyPage> createState() => _CoolifyHierarchyPageState();
}

class _CoolifyHierarchyPageState extends State<CoolifyHierarchyPage> {
  Map<String, dynamic>? _details;
  List<Map<String, dynamic>> _children = [];
  bool _busy = false;
  String? _error, _childrenError;
  String _search = '';
  int _request = 0;
  bool get environment => widget.kind == 'environments';
  bool get project => widget.kind == 'projects';
  String get base => environment
      ? '/projects/${Uri.encodeComponent(widget.projectUuid!)}/${Uri.encodeComponent(widget.uuid)}'
      : '/${widget.kind}/${Uri.encodeComponent(widget.uuid)}';
  String get template => environment
      ? '/projects/{uuid}/environments/{environment_name_or_uuid}'
      : '/${widget.kind}/{uuid}';
  Map<String, String> get paths => environment
      ? {'uuid': widget.projectUuid!, 'environment_name_or_uuid': widget.uuid}
      : {'uuid': widget.uuid};
  @override
  void initState() {
    super.initState();
    widget.session.addListener(_clear);
    widget.session.access.addListener(_accessChanged);
    _load();
  }

  void _accessChanged() {
    if (mounted) setState(() {});
  }

  void _clear() {
    _request++;
    if (mounted) {
      setState(() {
        _details = null;
        _children = [];
        _error = null;
        _childrenError = null;
        _busy = false;
      });
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_clear);
    widget.session.access.removeListener(_accessChanged);
    super.dispose();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _busy = true;
      _error = null;
      _childrenError = null;
    });
    try {
      final result = await widget.session.request('GET', base);
      if (!mounted || request != _request) return;
      if (result is! Map<String, dynamic>) {
        throw const CoolifyException('invalidApiResponse');
      }
      setState(() => _details = result);
      if (environment) {
        setState(() => _children = coolifyEnvironmentResources(result));
      } else {
        try {
          final children = await widget.session.request(
            'GET',
            project ? '$base/environments' : '$base/resources',
          );
          if (mounted && request == _request) {
            setState(() => _children = coolifyEntries(children));
          }
        } on CoolifyException catch (e) {
          if (mounted && request == _request) {
            setState(() => _childrenError = e.message);
          }
        }
      }
    } on CoolifyException catch (e) {
      if (mounted && request == _request) setState(() => _error = e.message);
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  Future<void> _operation(
    CoolifyOperation? op, {
    Map<String, dynamic> initial = const {},
  }) async {
    if (op == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CoolifyOperationPage(
          session: widget.session,
          catalog: widget.catalog,
          operation: op,
          pathValues: paths,
          initialValues: initial,
          target: widget.name,
          autoRead: !op.mutates,
        ),
      ),
    );
    if (mounted && widget.session.active) _load();
  }

  Future<void> _sharedVariables(String template) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CoolifyVariablesPage(
          session: widget.session,
          catalog: widget.catalog,
          template: template,
          paths: paths,
          name: widget.name,
        ),
      ),
    );
    if (mounted && widget.session.active) _load();
  }

  Future<void> _open(Map<String, dynamic> item) async {
    final id = '${item['uuid'] ?? (project ? item['name'] : '') ?? ''}';
    if (id.isEmpty) return;
    final kind = project ? 'environments' : coolifyKind(item);
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => project
            ? CoolifyHierarchyPage(
                session: widget.session,
                catalog: widget.catalog,
                kind: kind,
                uuid: id,
                name: '${item['name'] ?? id}',
                projectUuid: widget.uuid,
                projectName: widget.name,
                onTerminal: widget.onTerminal,
                onResourceTerminal: widget.onResourceTerminal,
              )
            : CoolifyResourcePage(
                session: widget.session,
                catalog: widget.catalog,
                collection: kind,
                uuid: id,
                name: '${item['name'] ?? id}',
                onTerminal: widget.onTerminal,
                onResourceTerminal: widget.onResourceTerminal,
              ),
      ),
    );
    if (mounted && widget.session.active) _load();
  }

  @override
  Widget build(BuildContext context) {
    final children = _children
        .where(
          (v) => '${v['name']} ${v['type']}'.toLowerCase().contains(
            _search.toLowerCase(),
          ),
        )
        .toList();
    final sharedTemplate = environment
        ? '/projects/{uuid}/environments/{environment_name_or_uuid}/envs'
        : '$template/envs';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          if (widget.kind == 'servers')
            IconButton(
              onPressed: _busy
                  ? null
                  : () {
                      if (widget.onResourceTerminal case final open?) {
                        open(
                          CoolifyTerminalTarget(
                            kind: 'servers',
                            uuid: widget.uuid,
                            name: widget.name,
                            details: _details ?? {},
                          ),
                        );
                      } else {
                        widget.onTerminal();
                      }
                    },
              icon: const Icon(Icons.terminal),
              tooltip: context.l10n.openTerminal,
            ),
          IconButton(
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.refresh,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Icon(
                coolifyIcon(widget.kind),
                color: DockColors.purple,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      environment
                          ? '${widget.projectName ?? ''} / ${context.l10n.coolifyEnvironments}'
                          : coolifyLabel(context, widget.kind),
                      style: const TextStyle(color: DockColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_details != null && coolifySummary(_details!).isNotEmpty) ...[
            const SizedBox(height: 16),
            SurfaceCard(
              child: CoolifyInfoFields(data: coolifySummary(_details!)),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.catalog.find('GET', sharedTemplate) != null)
                OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _sharedVariables(sharedTemplate),
                  icon: const Icon(Icons.tune),
                  label: Text(context.l10n.coolifySharedVariables),
                ),
              if (widget.catalog.find('PATCH', template) != null)
                OutlinedButton.icon(
                  onPressed:
                      _busy || !widget.session.access.allows('PATCH', template)
                      ? null
                      : () => _operation(
                          widget.catalog.find('PATCH', template),
                          initial: _details ?? {},
                        ),
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(context.l10n.coolifySettings),
                ),
              if (project)
                FilledButton.icon(
                  onPressed:
                      _busy ||
                          !widget.session.access.allows(
                            'POST',
                            '$template/environments',
                          )
                      ? null
                      : () => _operation(
                          widget.catalog.find('POST', '$template/environments'),
                        ),
                  icon: const Icon(Icons.add),
                  label: Text(
                    '${context.l10n.coolifyCreate} · ${context.l10n.coolifyEnvironment}',
                  ),
                ),
              if (environment)
                PopupMenuButton<CoolifyOperation>(
                  tooltip: context.l10n.coolifyCreate,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '${context.l10n.coolifyCreate} · ${context.l10n.coolifyResources}',
                      style: const TextStyle(color: DockColors.purple),
                    ),
                  ),
                  onSelected: (op) => _operation(
                    op,
                    initial: {
                      'project_uuid': widget.projectUuid,
                      'environment_name': widget.name,
                      if (widget.uuid != widget.name)
                        'environment_uuid': widget.uuid,
                    },
                  ),
                  itemBuilder: (_) => [
                    for (final op in widget.catalog.operations.where(
                      (o) =>
                          o.method == 'POST' &&
                          (o.path.startsWith('/applications/') &&
                                  o.path.split('/').length == 3 ||
                              o.path.startsWith('/databases/') &&
                                  o.path.split('/').length == 3 ||
                              o.path == '/services'),
                    ))
                      PopupMenuItem(
                        value: op,
                        enabled:
                            !_busy &&
                            widget.session.access.allows(op.method, op.path),
                        child: Text(op.title),
                      ),
                  ],
                ),
              if (widget.catalog.find('DELETE', template) != null)
                TextButton(
                  onPressed:
                      _busy || !widget.session.access.allows('DELETE', template)
                      ? null
                      : () =>
                            _operation(widget.catalog.find('DELETE', template)),
                  child: Text(context.l10n.remove),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SectionTitle(
            project
                ? context.l10n.coolifyEnvironments
                : context.l10n.coolifyResources,
            trailing: Text(
              '${_children.length}',
              style: const TextStyle(color: DockColors.muted),
            ),
          ),
          if (_busy && _details == null)
            const LoadingCards()
          else if (_busy)
            const LinearProgressIndicator(),
          if (_error != null || _childrenError != null)
            RequestFailure(
              message: _error ?? _childrenError!,
              onRetry: _busy ? null : _load,
            ),
          if (_details != null && _childrenError == null) ...[
            if (_children.isNotEmpty) ...[
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  labelText: context.l10n.coolifyResourceSearch,
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
              const SizedBox(height: 16),
            ],
            if (children.isEmpty)
              SurfaceCard(
                child: Text(
                  _search.isNotEmpty
                      ? context.l10n.coolifyEmpty
                      : project
                      ? context.l10n.coolifyEnvironmentEmpty
                      : context.l10n.coolifyResourceEmpty,
                ),
              ),
            CoolifyCardGrid(
              children: [
                for (final item in children)
                  CoolifyResourceCard(
                    item: item,
                    kind: project ? 'environments' : coolifyKind(item),
                    onTap: () => _open(item),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Coolify serializes resources by Eloquent relation, not as one `resources` list.
List<Map<String, dynamic>> coolifyEnvironmentResources(
  Map<String, dynamic> environment,
) {
  final result = <Map<String, dynamic>>[];
  final seen = <String>{};
  for (final entry in environment.entries) {
    final kind = switch (entry.key) {
      'applications' => 'applications',
      'services' => 'services',
      'postgresqls' ||
      'postgresql' ||
      'redis' ||
      'redis_databases' ||
      'mongodbs' ||
      'mysqls' ||
      'mariadbs' ||
      'clickhouses' ||
      'keydbs' ||
      'dragonflies' ||
      'databases' => 'databases',
      'resources' => 'resources',
      _ => null,
    };
    if (kind == null || entry.value is! List) continue;
    for (final raw in (entry.value as List).whereType<Map<String, dynamic>>()) {
      final resolved = kind == 'resources' ? coolifyKind(raw) : kind;
      final id = '${raw['uuid'] ?? ''}';
      if (id.isEmpty || !seen.add('$resolved:$id')) continue;
      result.add({
        ...raw,
        'type':
            raw['type'] ??
            (resolved == 'applications'
                ? 'application'
                : resolved == 'services'
                ? 'service'
                : 'database'),
      });
    }
  }
  return result;
}
