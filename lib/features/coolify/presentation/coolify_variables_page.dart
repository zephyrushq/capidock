import 'package:flutter/material.dart';

import '../../../l10n/localization.dart';
import '../../connections/data/coolify_client.dart';
import '../data/coolify_catalog.dart';
import '../data/coolify_session.dart';
import 'coolify_variable_widgets.dart';
import 'coolify_operation_page.dart';
import 'coolify_workspace_page.dart';

class CoolifyVariablesPage extends StatefulWidget {
  const CoolifyVariablesPage({
    super.key,
    required this.session,
    required this.catalog,
    required this.template,
    required this.paths,
    required this.name,
  });
  final CoolifySession session;
  final CoolifyCatalog catalog;
  final String template, name;
  final Map<String, String> paths;
  @override
  State<CoolifyVariablesPage> createState() => _CoolifyVariablesPageState();
}

class _CoolifyVariablesPageState extends State<CoolifyVariablesPage> {
  List<Map<String, dynamic>>? _data;
  bool _busy = false;
  String? _error;
  int _request = 0;
  @override
  void initState() {
    super.initState();
    widget.session.addListener(_clear);
    _load();
  }

  void _clear() {
    _request++;
    if (mounted) {
      setState(() {
        _data = null;
        _error = null;
        _busy = false;
      });
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_clear);
    super.dispose();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _data = null;
      _error = null;
      _busy = true;
    });
    try {
      final op = widget.catalog.find('GET', widget.template)!;
      final data = await widget.session.request(
        'GET',
        op.resolvePath(widget.paths),
      );
      if (mounted && request == _request) {
        setState(() => _data = coolifyEntries(data));
      }
    } on CoolifyException catch (e) {
      if (mounted && request == _request) setState(() => _error = e.message);
    } finally {
      if (mounted && request == _request) setState(() => _busy = false);
    }
  }

  Future<void> _edit(
    String method, [
    Map<String, dynamic> item = const {},
  ]) async {
    final withId = method == 'DELETE' || method == 'PATCH';
    final op = widget.catalog.find(
      method,
      withId ? '${widget.template}/{env_id}' : widget.template,
    );
    if (op == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => method == 'PATCH'
            ? CoolifyVariableValuePage(
                session: widget.session,
                operation: op,
                paths: {
                  ...widget.paths,
                  'env_id': '${item['id'] ?? item['uuid']}',
                },
                item: item,
                target: '${widget.name} / ${item['key']}',
              )
            : CoolifyOperationPage(
                session: widget.session,
                catalog: widget.catalog,
                operation: op,
                pathValues: {
                  ...widget.paths,
                  if (withId) 'env_id': '${item['id'] ?? item['uuid']}',
                },
                initialValues: item,
                target:
                    '${widget.name} / ${item['key'] ?? context.l10n.coolifySharedVariables}',
              ),
      ),
    );
    if (mounted && widget.session.active) _load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.coolifySharedVariables),
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
        Text(widget.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _busy ? null : () => _edit('POST'),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.coolifyCreate),
          ),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Text(localizedMessage(context, _error!)),
        if (_data != null && _data!.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.l10n.coolifyEmpty),
          ),
        if (_data != null)
          CoolifyVariableGroups(
            items: _data!,
            supportsPreview: false,
            onEdit: (item) => _edit('PATCH', item),
            onDelete: (item) => _edit('DELETE', item),
          ),
      ],
    ),
  );
}
