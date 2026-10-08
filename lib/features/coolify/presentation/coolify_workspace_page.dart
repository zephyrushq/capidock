import 'package:flutter/material.dart';

import '../../../core/widgets.dart';
import '../../../core/request_states.dart';
import 'coolify_access_button.dart';
import '../../../core/app_theme.dart';
import '../../../l10n/localization.dart';
import '../../connections/data/coolify_client.dart';
import '../../instances/domain/server_instance.dart';
import '../data/coolify_catalog.dart';
import '../data/coolify_session.dart';
import 'coolify_operation_page.dart';
import 'coolify_cards.dart';
import 'coolify_variable_widgets.dart';
import 'coolify_hierarchy_page.dart';

class CoolifyWorkspacePage extends StatefulWidget {
  const CoolifyWorkspacePage({
    super.key,
    required this.instance,
    required this.onEdit,
    required this.onTerminal,
    this.createClient,
  });
  final ServerInstance instance;
  final VoidCallback onEdit, onTerminal;
  final CoolifyClient Function()? createClient;
  @override
  State<CoolifyWorkspacePage> createState() => _CoolifyWorkspacePageState();
}

class _CoolifyWorkspacePageState extends State<CoolifyWorkspacePage> {
  late final CoolifySession _session = CoolifySession(
    widget.instance,
    createClient: widget.createClient,
  );
  CoolifyCatalog? _catalog;
  Object? _data;
  String? _error;
  bool _busy = false;
  String _collection = 'resources';
  String _search = '';
  int _request = 0;
  @override
  void initState() {
    super.initState();
    _session.addListener(_clear);
    _session.access.addListener(_accessChanged);
    CoolifyCatalog.load()
        .then((catalog) {
          if (mounted) setState(() => _catalog = catalog);
        })
        .catchError((Object error) {
          if (mounted) setState(() => _error = 'invalidApiResponse');
        });
  }

  void _accessChanged() {
    if (mounted) setState(() {});
  }

  void _clear() {
    _request++;
    if (mounted) {
      setState(() {
        _data = null;
        _busy = false;
        _error = null;
      });
    }
  }

  @override
  void dispose() {
    _session.removeListener(_clear);
    _session.access.removeListener(_accessChanged);
    _session.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final data = await _session.request('GET', '/$_collection');
      if (mounted && request == _request) setState(() => _data = data);
    } on CoolifyException catch (error) {
      if (mounted && request == _request) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  String _label(String collection) => switch (collection) {
    'resources' => context.l10n.coolifyResources,
    'applications' => context.l10n.coolifyApplications,
    'databases' => context.l10n.coolifyDatabases,
    'services' => context.l10n.coolifyServices,
    'projects' => context.l10n.coolifyProjects,
    'servers' => context.l10n.coolifyServers,
    _ => collection,
  };
  String? _kind(Map<String, dynamic> item) {
    if (_collection != 'resources') return _collection;
    final type = '${item['type'] ?? ''}'.toLowerCase();
    if (type == 'application') return 'applications';
    if (type == 'service') return 'services';
    if (type.contains('database') ||
        [
          'postgresql',
          'mysql',
          'mariadb',
          'redis',
          'mongodb',
          'clickhouse',
          'keydb',
          'dragonfly',
          'sqlite',
        ].any(type.contains)) {
      return 'databases';
    }
    return null;
  }

  Future<void> _details(Map<String, dynamic> item) async {
    final collection = _kind(item);
    if (_catalog == null || collection == null || item['uuid'] == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ['projects', 'servers'].contains(collection)
            ? CoolifyHierarchyPage(
                session: _session,
                catalog: _catalog!,
                kind: collection,
                uuid: '${item['uuid']}',
                name: '${item['name'] ?? item['uuid']}',
                onTerminal: widget.onTerminal,
              )
            : CoolifyResourcePage(
                session: _session,
                catalog: _catalog!,
                collection: collection,
                uuid: '${item['uuid']}',
                name: '${item['name'] ?? item['uuid']}',
                onTerminal: widget.onTerminal,
              ),
      ),
    );
    // Refresh cards when returning from remote changes.
    if (mounted && _session.active) _load();
  }

  @override
  Widget build(BuildContext context) {
    final entries = coolifyEntries(_data)
        .where(
          (v) => '${v['name']} ${v['uuid']} ${v['type']}'
              .toLowerCase()
              .contains(_search.toLowerCase()),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          context.l10n.yourResources,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        SelectableText(widget.instance.address),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: StatusPill(
            _busy
                ? context.l10n.connecting
                : _data != null
                ? context.l10n.receivedData
                : context.l10n.notConnected,
            color: _data != null ? DockColors.green : DockColors.muted,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              key: const ValueKey('connect-instance'),
              onPressed: _busy || !widget.instance.hasCredentials
                  ? null
                  : _load,
              icon: const Icon(Icons.refresh),
              label: Text(
                _data == null
                    ? context.l10n.connectInstance
                    : context.l10n.refresh,
              ),
            ),
            TextButton.icon(
              onPressed: widget.onEdit,
              icon: const Icon(Icons.key),
              label: Text(
                widget.instance.hasCredentials
                    ? context.l10n.editAccess
                    : context.l10n.configureAccess,
              ),
            ),
            OutlinedButton.icon(
              key: const ValueKey('coolify-all-operations'),
              onPressed: _catalog == null
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => CoolifyOperationsPage(
                          session: _session,
                          catalog: _catalog!,
                        ),
                      ),
                    ),
              icon: const Icon(Icons.tune),
              label: Text(context.l10n.coolifyOperations),
            ),
            OutlinedButton.icon(
              onPressed: widget.onTerminal,
              icon: const Icon(Icons.terminal),
              label: Text(context.l10n.openTerminal),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: CoolifyAccessButton(access: _session.access),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _collection,
          isExpanded: true,
          items: [
            for (final collection in [
              'resources',
              'applications',
              'databases',
              'services',
              'projects',
              'servers',
            ])
              DropdownMenuItem(
                value: collection,
                child: Text(_label(collection)),
              ),
          ],
          onChanged: _busy
              ? null
              : (value) {
                  setState(() {
                    _collection = value!;
                    _data = null;
                  });
                  _load();
                },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: context.l10n.coolifySearch,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (text) => setState(() => _search = text),
        ),
        if (_busy && _data == null)
          const LoadingCards()
        else if (_busy)
          const LinearProgressIndicator(),
        if (_error != null)
          RequestFailure(message: _error!, onRetry: _busy ? null : _load),
        if (_data == null && !_busy && _error == null) ...[
          const SizedBox(height: 16),
          SurfaceCard(child: Text(context.l10n.coolifyOverview)),
        ],
        if (_data != null) ...[
          const SizedBox(height: 16),
          SectionTitle(context.l10n.resourceCount(entries.length)),
          if (entries.isEmpty)
            SurfaceCard(
              child: Text(
                _search.trim().isNotEmpty
                    ? context.l10n.noSearchResults
                    : context.l10n.noCoolifyResources,
              ),
            ),
          CoolifyCardGrid(
            children: [
              for (final item in entries)
                CoolifyResourceCard(
                  item: item,
                  kind: _kind(item) ?? _collection,
                  onTap: _kind(item) != null && item['uuid'] != null
                      ? () => _details(item)
                      : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

List<Map<String, dynamic>> coolifyEntries(Object? data) {
  if (data is List) return data.whereType<Map<String, dynamic>>().toList();
  if (data is Map<String, dynamic>) {
    for (final key in [
      'data',
      'backups',
      'envs',
      'storages',
      'deployments',
      'executions',
      'resources',
    ]) {
      if (data[key] is List) {
        return (data[key] as List).whereType<Map<String, dynamic>>().toList();
      }
    }
  }
  return [];
}

class CoolifyOperationsPage extends StatefulWidget {
  const CoolifyOperationsPage({
    super.key,
    required this.session,
    required this.catalog,
    this.operations,
    this.pathValues = const {},
    this.target,
  });
  final CoolifySession session;
  final CoolifyCatalog catalog;
  final List<CoolifyOperation>? operations;
  final Map<String, String> pathValues;
  final String? target;
  @override
  State<CoolifyOperationsPage> createState() => _CoolifyOperationsPageState();
}

class _CoolifyOperationsPageState extends State<CoolifyOperationsPage> {
  @override
  void initState() {
    super.initState();
    widget.session.access.addListener(_accessChanged);
  }

  void _accessChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.session.access.removeListener(_accessChanged);
    super.dispose();
  }

  String _search = '', _group = '';
  @override
  Widget build(BuildContext context) {
    final all = widget.operations ?? widget.catalog.operations;
    final groups = all.map((o) => o.group).toSet().toList()..sort();
    final filtered = all
        .where(
          (o) =>
              (_group.isEmpty || o.group == _group) &&
              '${o.title} ${o.description} ${o.path} ${o.method}'
                  .toLowerCase()
                  .contains(_search.toLowerCase()),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.coolifyOperations)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(context.l10n.coolifyCatalogHelp),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: context.l10n.coolifySearch,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _group,
            isExpanded: true,
            items: [
              DropdownMenuItem(value: '', child: Text(context.l10n.coolifyAll)),
              for (final group in groups)
                DropdownMenuItem(value: group, child: Text(group)),
            ],
            onChanged: (value) => setState(() => _group = value!),
          ),
          const SizedBox(height: 16),
          Text('${filtered.length} / ${all.length}'),
          for (final op in filtered)
            ListTile(
              enabled: widget.session.access.allows(op.method, op.path),
              title: Text('${op.group} · ${op.title}'),
              subtitle: Text('${op.method} ${op.path}'),
              trailing: Icon(
                op.destructive ? Icons.delete_outline : Icons.chevron_right,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => CoolifyOperationPage(
                    session: widget.session,
                    operation: op,
                    pathValues: widget.pathValues,
                    target: widget.target,
                    catalog: widget.catalog,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CoolifyResourcePage extends StatefulWidget {
  const CoolifyResourcePage({
    super.key,
    required this.session,
    required this.catalog,
    required this.collection,
    required this.uuid,
    required this.name,
    required this.onTerminal,
    this.parentServiceUuid,
  });
  final CoolifySession session;
  final CoolifyCatalog catalog;
  final String collection, uuid, name;
  final VoidCallback onTerminal;
  final String? parentServiceUuid;
  @override
  State<CoolifyResourcePage> createState() => _CoolifyResourcePageState();
}

class _CoolifyResourcePageState extends State<CoolifyResourcePage> {
  int _tab = 0, _request = 0;
  String? _loadedSection;
  Object? _data;
  Map<String, dynamic>? _overview;
  List<Map<String, dynamic>> _components = [];
  String? _componentsError;
  String? _error;
  bool _busy = false, _confirming = false;
  String get componentParameter =>
      widget.collection == 'applications' ? 'app_uuid' : 'database_uuid';
  String get template => widget.parentServiceUuid == null
      ? '/${widget.collection}/{uuid}'
      : '/services/{uuid}/${widget.collection}/{$componentParameter}';
  Map<String, String> get paths => widget.parentServiceUuid == null
      ? {'uuid': widget.uuid}
      : {'uuid': widget.parentServiceUuid!, componentParameter: widget.uuid};
  String get base => widget.catalog.find('GET', template)!.resolvePath(paths);

  List<String> get sections => [
    'details',
    if (widget.catalog.find('GET', '$template/envs') != null) 'envs',
    if (widget.catalog.find('GET', '$template/logs') != null) 'logs',
    if (widget.catalog.find('GET', '$template/backups') != null) 'backups',
    if (widget.catalog.find('GET', '$template/storages') != null) 'storages',
    if (widget.collection == 'applications' && widget.parentServiceUuid == null)
      'deployments',
  ];
  String get section => sections[_tab];
  String _sectionLabel(String section) => switch (section) {
    'details' => context.l10n.coolifyConfiguration,
    'envs' => context.l10n.coolifyVariables,
    'logs' => context.l10n.coolifyLogs,
    'backups' => context.l10n.coolifyBackups,
    'storages' => context.l10n.coolifyStorages,
    'deployments' => context.l10n.coolifyDeployments,
    _ => section,
  };
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
        _data = null;
        _overview = null;
        _components = [];
        _componentsError = null;
        _error = null;
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
      if (_loadedSection != section) _data = null;
      _componentsError = null;
    });
    final path = switch (section) {
      'details' => base,
      'deployments' =>
        '/deployments/applications/${Uri.encodeComponent(widget.uuid)}',
      _ => '$base/$section',
    };
    try {
      if (section != 'details') {
        final details = await widget.session.request('GET', base);
        if (!mounted || request != _request) return;
        if (details is Map<String, dynamic>) {
          setState(() => _overview = details);
        }
      }
      final result = await widget.session.request(
        'GET',
        path,
        query: section == 'logs' ? {'lines': '200'} : {},
      );
      if (mounted && request == _request) {
        setState(() {
          _data = result;
          _loadedSection = section;
          if (section == 'details' && result is Map<String, dynamic>) {
            _overview = result;
          }
        });
      }
      if (section == 'details' && widget.collection == 'services') {
        final components = <Map<String, dynamic>>[];
        for (final collection in ['applications', 'databases']) {
          try {
            final children = await widget.session.request(
              'GET',
              '$base/$collection',
            );
            if (!mounted || request != _request) return;
            components.addAll(
              coolifyEntries(children)
                  .map((item) => {...item, '_collection': collection}),
            );
            setState(() => _components = List.of(components));
          } on CoolifyException catch (error) {
            if (mounted && request == _request) {
              setState(() => _componentsError = error.message);
            }
          }
        }
      }
    } on CoolifyException catch (error) {
      if (mounted && request == _request) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  Future<void> _perform(
    CoolifyOperation? operation, {
    Map<String, String>? values,
    Map<String, String> query = const {},
    Object? body,
  }) async {
    if (_busy || _confirming || operation == null) return;
    final generation = widget.session.generation;
    final path = operation.resolvePath(values ?? paths);
    if (!widget.session.access.allows(operation.method, path)) {
      setState(() => _error = 'coolifyPermissionDenied');
      return;
    }
    setState(() => _confirming = true);
    final accepted = await confirmCoolifyOperation(
      context,
      operation,
      widget.name,
      path: path,
      preview: {'fields': body, 'options': query},
    );
    if (mounted) setState(() => _confirming = false);
    if (!mounted || generation != widget.session.generation || !accepted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.session.request(
        operation.method,
        path,
        query: query,
        body: body,
      );
      if (!mounted || generation != widget.session.generation) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.coolifySuccess)));
      _load();
    } on CoolifyException catch (error) {
      if (mounted && generation == widget.session.generation) {
        setState(() {
          _error = error.message;
          _busy = false;
        });
      }
    }
  }

  Future<void> _operation(
    CoolifyOperation? op, {
    Map<String, String>? values,
    Map<String, dynamic> initial = const {},
  }) async {
    if (op == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CoolifyOperationPage(
          session: widget.session,
          operation: op,
          pathValues: values ?? paths,
          initialValues: initial,
          target: widget.name,
          catalog: widget.catalog,
          autoRead: !op.mutates,
        ),
      ),
    );
    if (mounted && widget.session.active) _load();
  }

  Future<void> _advanced() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CoolifyOperationsPage(
          session: widget.session,
          catalog: widget.catalog,
          operations: widget.catalog.operations
              .where((op) => op.path.startsWith(template))
              .toList(),
          pathValues: paths,
          target: widget.name,
        ),
      ),
    );
    if (mounted && widget.session.active) _load();
  }

  Widget _actions() {
    final stopped =
        '${_overview?['status'] ?? ''}'.startsWith('stopped') ||
        '${_overview?['status'] ?? ''}'.startsWith('exited');
    final primary = stopped ? 'start' : 'restart';
    final primaryOp = widget.catalog.find('POST', '$template/$primary');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (widget.parentServiceUuid == null &&
            ['applications', 'services'].contains(widget.collection))
          FilledButton.icon(
            onPressed:
                _busy ||
                    _confirming ||
                    !widget.session.access.allows('POST', '/deploy')
                ? null
                : () => _perform(
                    widget.catalog.find('POST', '/deploy'),
                    values: {},
                    query: {'uuid': widget.uuid},
                  ),
            icon: const Icon(Icons.rocket_launch_outlined),
            label: Text(context.l10n.coolifyDeploy),
          ),
        if (primaryOp != null)
          OutlinedButton.icon(
            onPressed:
                _busy ||
                    _confirming ||
                    !widget.session.access.allows(
                      primaryOp.method,
                      primaryOp.path,
                    )
                ? null
                : () => _perform(primaryOp),
            icon: Icon(stopped ? Icons.play_arrow : Icons.restart_alt),
            label: Text(
              stopped ? context.l10n.coolifyStart : context.l10n.coolifyRestart,
            ),
          ),
        if (widget.catalog.find('PATCH', template) != null)
          OutlinedButton.icon(
            onPressed: _busy || !widget.session.access.allows('PATCH', template)
                ? null
                : () => _operation(
                    widget.catalog.find('PATCH', template),
                    initial: _overview ?? {},
                  ),
            icon: const Icon(Icons.settings_outlined),
            label: Text(context.l10n.coolifySettings),
          ),
        PopupMenuButton<String>(
          enabled: !_busy && !_confirming,
          tooltip: context.l10n.coolifyOtherSettings,
          onSelected: (value) {
            switch (value) {
              case 'start':
              case 'stop':
                _perform(widget.catalog.find('POST', '$template/$value'));
              case 'remove':
                _operation(widget.catalog.find('DELETE', template));
              case 'operations':
                _advanced();
              case 'terminal':
                widget.onTerminal();
            }
          },
          itemBuilder: (_) => [
            if (primary != 'start' &&
                widget.catalog.find('POST', '$template/start') != null)
              PopupMenuItem(
                value: 'start',
                child: Text(context.l10n.coolifyStart),
              ),
            if (widget.catalog.find('POST', '$template/stop') != null)
              PopupMenuItem(
                value: 'stop',
                child: Text(context.l10n.coolifyStop),
              ),
            PopupMenuItem(
              value: 'terminal',
              child: Text(context.l10n.openTerminal),
            ),
            PopupMenuItem(
              value: 'operations',
              child: Text(context.l10n.coolifyOperations),
            ),
            if (widget.catalog.find('DELETE', template) != null)
              PopupMenuItem(value: 'remove', child: Text(context.l10n.remove)),
          ],
        ),
      ],
    );
  }

  Future<void> _editVariableValue(Map<String, dynamic> item) async {
    final op = widget.catalog.find('PATCH', '$template/envs');
    if (op == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CoolifyVariableValuePage(
          session: widget.session,
          operation: op,
          paths: paths,
          item: item,
          target: '${widget.name} / ${item['key']}',
        ),
      ),
    );
    if (mounted && widget.session.active) _load();
  }

  Widget _entry(Map<String, dynamic> item) {
    final id = '${item['uuid'] ?? item['id'] ?? ''}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${item['key'] ?? item['name'] ?? item['status'] ?? id}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...[
              CoolifyInfoFields(data: item, sensitive: section == 'logs'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (section == 'backups' && id.isNotEmpty) ...[
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => _perform(
                              widget.catalog.find(
                                'PATCH',
                                '$template/backups/{scheduled_backup_uuid}',
                              ),
                              values: {...paths, 'scheduled_backup_uuid': id},
                              body: {'backup_now': true},
                            ),
                      child: Text(context.l10n.coolifyRunBackup),
                    ),
                    TextButton(
                      onPressed: () => _operation(
                        widget.catalog.find(
                          'PATCH',
                          '$template/backups/{scheduled_backup_uuid}',
                        ),
                        values: {...paths, 'scheduled_backup_uuid': id},
                        initial: item,
                      ),
                      child: Text(context.l10n.coolifyEdit),
                    ),
                    TextButton(
                      onPressed: () => _operation(
                        widget.catalog.find(
                          'GET',
                          '$template/backups/{scheduled_backup_uuid}/executions',
                        ),
                        values: {...paths, 'scheduled_backup_uuid': id},
                      ),
                      child: Text(context.l10n.coolifyExecutions),
                    ),
                    TextButton(
                      onPressed: () => _operation(
                        widget.catalog.find(
                          'DELETE',
                          '$template/backups/{scheduled_backup_uuid}',
                        ),
                        values: {...paths, 'scheduled_backup_uuid': id},
                      ),
                      child: Text(context.l10n.remove),
                    ),
                  ],
                  if (section == 'storages' && id.isNotEmpty) ...[
                    TextButton(
                      onPressed: () => _operation(
                        widget.catalog.find('PATCH', '$template/storages'),
                        initial: item,
                      ),
                      child: Text(context.l10n.coolifyEdit),
                    ),
                    TextButton(
                      onPressed: () => _operation(
                        widget.catalog.find(
                          'PUT',
                          '$template/storages/{storage_uuid}/backups',
                        ),
                        values: {...paths, 'storage_uuid': id},
                        initial: item['backup'] is Map<String, dynamic>
                            ? item['backup'] as Map<String, dynamic>
                            : {},
                      ),
                      child: Text(context.l10n.coolifyScheduleBackup),
                    ),
                    TextButton(
                      onPressed: () => _operation(
                        widget.catalog.find(
                          'POST',
                          '$template/storages/{storage_uuid}/backups/run',
                        ),
                        values: {...paths, 'storage_uuid': id},
                      ),
                      child: Text(context.l10n.coolifyRunBackup),
                    ),
                    TextButton(
                      onPressed: () => _operation(
                        widget.catalog.find(
                          'DELETE',
                          '$template/storages/{storage_uuid}',
                        ),
                        values: {...paths, 'storage_uuid': id},
                      ),
                      child: Text(context.l10n.remove),
                    ),
                  ],
                  if (section == 'deployments' && id.isNotEmpty) ...[
                    TextButton(
                      onPressed: () => _operation(
                        widget.catalog.find('GET', '/deployments/{uuid}'),
                        values: {'uuid': id},
                      ),
                      child: Text(context.l10n.coolifyLogs),
                    ),
                    TextButton(
                      onPressed: () => _operation(
                        widget.catalog.find(
                          'POST',
                          '/deployments/{uuid}/cancel',
                        ),
                        values: {'uuid': id},
                      ),
                      child: Text(context.l10n.cancel),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = coolifyEntries(_data);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
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
          if (_overview != null) ...[
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        coolifyIcon(widget.collection),
                        color: DockColors.purple,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_overview!['name'] ?? widget.name}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CoolifyInfoFields(data: coolifySummary(_overview!)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _actions(),
          if (section == 'details' && widget.collection == 'services') ...[
            const SizedBox(height: 24),
            SectionTitle(context.l10n.coolifyResources),
            if (_componentsError != null)
              Text(localizedMessage(context, _componentsError!)),
            CoolifyCardGrid(
              children: [
                for (final item in _components)
                  CoolifyResourceCard(
                    item: item,
                    kind: '${item['_collection']}',
                    onTap: item['uuid'] == null
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => CoolifyResourcePage(
                                session: widget.session,
                                catalog: widget.catalog,
                                collection: '${item['_collection']}',
                                uuid: '${item['uuid']}',
                                name: '${item['name'] ?? ''}',
                                onTerminal: widget.onTerminal,
                                parentServiceUuid: widget.uuid,
                              ),
                            ),
                          ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 1; i < sections.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_sectionLabel(sections[i])),
                      selected: _tab == i,
                      onSelected:
                          _busy ||
                              !widget.session.access.allows(
                                'GET',
                                '$template/${sections[i]}',
                              )
                          ? null
                          : (_) {
                              setState(() => _tab = _tab == i ? 0 : i);
                              _load();
                            },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (section == 'backups' || section == 'storages')
            FilledButton.icon(
              onPressed:
                  _busy ||
                      !widget.session.access.allows(
                        'POST',
                        '$template/$section',
                      )
                  ? null
                  : () => _operation(
                      widget.catalog.find('POST', '$template/$section'),
                    ),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.coolifyCreate),
            ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                localizedMessage(context, _error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_data != null) ...[
            const SizedBox(height: 16),
            if (section == 'logs')
              SurfaceCard(
                child: CoolifyInfoFields(data: _data, sensitive: true),
              )
            else if (section == 'envs')
              CoolifyVariableGroups(
                canWrite: widget.session.access.allows(
                  'PATCH',
                  '$template/envs',
                ),
                items: entries,
                supportsPreview:
                    widget.catalog
                        .find('PATCH', '$template/envs')
                        ?.properties
                        .containsKey('is_preview') ??
                    false,
                onEdit: _editVariableValue,
                onDelete: (item) => _operation(
                  widget.catalog.find('DELETE', '$template/envs/{env_uuid}'),
                  values: {
                    ...paths,
                    'env_uuid': '${item['uuid'] ?? item['id']}',
                  },
                ),
                onCreate: widget.catalog.find('POST', '$template/envs') == null
                    ? null
                    : (preview) => _operation(
                        widget.catalog.find('POST', '$template/envs'),
                        initial: {
                          if (widget.catalog
                              .find('POST', '$template/envs')!
                              .properties
                              .containsKey('is_preview'))
                            'is_preview': preview,
                        },
                      ),
              )
            else if (entries.isNotEmpty)
              for (final item in entries) _entry(item)
            else if (_data is List)
              Text(context.l10n.coolifyEmpty)
            else if (section == 'logs')
              CoolifyInfoFields(data: _data, sensitive: true)
            else if (section == 'details')
              ExpansionTile(
                title: Text(context.l10n.coolifyConfiguration),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: CoolifyInfoFields(data: _data),
                  ),
                ],
              )
            else
              SurfaceCard(child: CoolifyInfoFields(data: _data)),
          ],
        ],
      ),
    );
  }
}
