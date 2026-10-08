import 'dart:convert';
import 'dart:math';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets.dart';
import '../../../core/help_button.dart';
import 'coolify_access_button.dart';
import '../../../l10n/localization.dart';
import '../../connections/data/coolify_client.dart';
import '../data/coolify_catalog.dart';
import '../data/coolify_session.dart';
import 'coolify_cards.dart';
import 'coolify_logs_panel.dart';
import 'coolify_activity_list.dart';

String coolifyOperationTitle(BuildContext context, CoolifyOperation op) {
  final strings = context.l10n;
  if (op.path.endsWith('/start')) return strings.coolifyStart;
  if (op.path.endsWith('/stop')) return strings.coolifyStop;
  if (op.path.endsWith('/restart')) return strings.coolifyRestart;
  if (op.path == '/deploy') return strings.coolifyDeploy;
  if (op.path.endsWith('/backups/run')) return strings.coolifyRunBackup;
  if (op.path.endsWith('/executions')) return strings.coolifyExecutions;
  if (op.path.endsWith('/logs')) return strings.coolifyLogs;
  if (op.method == 'DELETE') return strings.remove;
  if (op.method == 'PATCH') return strings.coolifyEdit;
  if (op.path.endsWith('/envs') && op.method == 'POST') {
    return strings.coolifyCreate;
  }
  return op.title;
}

String prettyCoolify(Object? value) =>
    value is String ? value : const JsonEncoder.withIndent('  ').convert(value);

class CoolifyPayload extends StatelessWidget {
  const CoolifyPayload({super.key, required this.data, this.sensitive = false});
  final Object? data;
  final bool sensitive;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: CoolifyInfoFields(data: data, sensitive: sensitive),
  );
}

Future<bool> confirmCoolifyOperation(
  BuildContext context,
  CoolifyOperation operation,
  String target, {
  Object? preview,
  String? path,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (_) => _CoolifyConfirmation(
        operation: operation,
        target: target,
        preview: preview,
        path: path,
      ),
    ) ??
    false;

class _CoolifyConfirmation extends StatefulWidget {
  const _CoolifyConfirmation({
    required this.operation,
    required this.target,
    this.preview,
    this.path,
  });
  final CoolifyOperation operation;
  final String target;
  final Object? preview;
  final String? path;
  @override
  State<_CoolifyConfirmation> createState() => _CoolifyConfirmationState();
}

class _CoolifyConfirmationState extends State<_CoolifyConfirmation> {
  final _confirmation = TextEditingController();
  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.operation.destructive
          ? context.l10n.coolifyDestructive
          : context.l10n.coolifyConfirm,
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${coolifyOperationTitle(context, widget.operation)}\n${widget.target}',
          ),
          if (widget.path != null)
            SelectableText('${widget.operation.method} ${widget.path}'),
          if (widget.preview != null)
            CoolifyInfoFields(data: redactCoolify(widget.preview)),
          const SizedBox(height: 16),
          Text(context.l10n.coolifyMutationWarning),
          if (widget.operation.destructive) ...[
            const SizedBox(height: 16),
            Text(context.l10n.coolifyTypeTarget(widget.target)),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('coolify-confirm-target'),
              controller: _confirmation,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        key: const ValueKey('coolify-confirm-action'),
        onPressed:
            !widget.operation.destructive || _confirmation.text == widget.target
            ? () => Navigator.pop(context, true)
            : null,
        child: Text(context.l10n.coolifyExecute),
      ),
    ],
  );
}

/// Schema-backed operation forms keep all documented API fields available.
/// PATCH requests contain only edited fields, preserving remote defaults/secrets.
class CoolifyOperationPage extends StatefulWidget {
  const CoolifyOperationPage({
    super.key,
    required this.session,
    required this.operation,
    this.pathValues = const {},
    this.initialValues = const {},
    this.target,
    this.catalog,
    this.autoRead = false,
  });
  final CoolifySession session;
  final CoolifyOperation operation;
  final Map<String, String> pathValues;
  final Map<String, dynamic> initialValues;
  final String? target;
  final CoolifyCatalog? catalog;
  final bool autoRead;
  @override
  State<CoolifyOperationPage> createState() => _CoolifyOperationPageState();
}

class _CoolifyOperationPageState extends State<CoolifyOperationPage> {
  final _form = GlobalKey<FormState>();
  final Map<String, TextEditingController> _fields = {};
  final Set<String> _changed = {};
  final Map<String, bool?> _booleans = {};
  final Map<String, bool> _reveal = {};
  Object? _result;
  String? _resultPath;
  Map<String, String> _resultQuery = {};
  bool _completed = false, _busy = false, _confirming = false;
  String? _error;
  XFile? _file;
  int _request = 0;
  CoolifyOperation get op => widget.operation;
  @override
  void initState() {
    super.initState();
    for (final parameter in op.parameters) {
      final name = parameter['name'] as String;
      final location = parameter['in'] as String;
      _fields['$location:$name'] = TextEditingController(
        text: location == 'path'
            ? widget.pathValues[name]
            : widget.initialValues['query:$name'] as String?,
      );
    }
    for (final entry in op.properties.entries) {
      final schema = entry.value as Map<String, dynamic>;
      final value = widget.initialValues[entry.key];
      if (schema['type'] == 'boolean') {
        _booleans[entry.key] = value is bool ? value : null;
      } else {
        _fields['body:${entry.key}'] = TextEditingController(
          text: value == null
              ? null
              : value is Map || value is List
              ? jsonEncode(value)
              : '$value',
        );
      }
    }
    if (op.schema.isNotEmpty && op.properties.isEmpty) {
      _fields['body:json'] = TextEditingController();
    }
    if (op.upload) {
      final random = Random.secure();
      final bytes = List<int>.generate(16, (_) => random.nextInt(256));
      bytes[6] = (bytes[6] & 15) | 64;
      bytes[8] = (bytes[8] & 63) | 128;
      final hex = bytes.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
      _fields['body:upload_id']!.text =
          '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
    }
    if (op.method == 'POST') {
      for (final entry in widget.initialValues.entries) {
        if (op.properties.containsKey(entry.key) && entry.value != null) {
          _changed.add('body:${entry.key}');
        }
      }
    }
    if (op.method == 'PATCH') {
      final identifier =
          op.properties.containsKey('uuid') &&
              widget.initialValues['uuid'] != null
          ? 'uuid'
          : op.properties.containsKey('id') &&
                widget.initialValues['id'] != null
          ? 'id'
          : null;
      if (identifier != null) _changed.add('body:$identifier');
    }
    widget.session.addListener(_clear);
    widget.session.access.addListener(_accessChanged);
    if (widget.autoRead && !op.mutates) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _execute();
      });
    }
  }

  void _accessChanged() {
    if (mounted) setState(() {});
  }

  void _clear() {
    if (!mounted) return;
    _request++;
    for (final entry in _fields.entries) {
      entry.value.text = entry.key.startsWith('path:')
          ? widget.pathValues[entry.key.substring(5)] ?? ''
          : '';
    }
    _changed.clear();
    _booleans.updateAll((_, _) => null);
    _reveal.clear();
    setState(() {
      _result = null;
      _completed = false;
      _busy = false;
      _error = null;
      _file = null;
    });
  }

  @override
  void dispose() {
    widget.session.removeListener(_clear);
    widget.session.access.removeListener(_accessChanged);
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  bool _sensitive(String key) =>
      RegExp(r'value|password|secret|token|key|content|compose|dockerfile')
          .hasMatch(key);
  Object? _parse(String raw, Map<String, dynamic> schema) {
    if (raw == 'null' && schema['nullable'] == true) return null;
    final type = schema['type'];
    final Object? value = switch (type) {
      'boolean' =>
        raw == 'true'
            ? true
            : raw == 'false'
            ? false
            : throw const FormatException(),
      'integer' => int.parse(raw),
      'number' => num.parse(raw),
      'array' || 'object' => jsonDecode(raw),
      _ => raw,
    };
    if (type == 'array' && value is! List ||
        type == 'object' && value is! Map) {
      throw const FormatException();
    }
    if (schema['enum'] case final List options) {
      if (!options.contains(value)) throw const FormatException();
    }
    if (value is num &&
        (schema['minimum'] is num && value < (schema['minimum'] as num) ||
            schema['maximum'] is num && value > (schema['maximum'] as num))) {
      throw const FormatException();
    }
    return value;
  }

  Widget _field(
    String key,
    String name,
    Map<String, dynamic> schema, {
    bool required = false,
    bool readOnly = false,
  }) {
    final secret = _sensitive(name);
    final complex = schema['type'] == 'array' || schema['type'] == 'object';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey('coolify-field-$key'),
        controller: _fields[key],
        readOnly: readOnly,
        enabled: !_busy,
        obscureText: secret && !(_reveal[key] ?? false),
        maxLines: secret
            ? (_reveal[key] == true ? 5 : 1)
            : complex || name.contains('compose')
            ? 5
            : 1,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: '${coolifyLabel(context, name)}${required ? ' *' : ''}',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (secret)
                IconButton(
                  onPressed: () =>
                      setState(() => _reveal[key] = !(_reveal[key] ?? false)),
                  tooltip: context.l10n.showCredential,
                  icon: const Icon(Icons.visibility_outlined),
                ),
              if (schema['description'] != null || schema['enum'] is List)
                HelpButton(
                  message: [
                    if (schema['description'] != null) schema['description'],
                    if (schema['enum'] is List)
                      (schema['enum'] as List).join(' | '),
                  ].join('\n'),
                ),
            ],
          ),
        ),
        onChanged: (_) => _changed.add(key),
        validator: (text) {
          if (readOnly) return null;
          if (text == null || text.isEmpty) {
            return required && name != 'value'
                ? context.l10n.credentialRequired
                : _changed.contains(key) && schema['type'] != 'string'
                ? context.l10n.coolifyInvalidField
                : null;
          }
          try {
            _parse(text, schema);
            return null;
          } catch (_) {
            return context.l10n.coolifyInvalidField;
          }
        },
      ),
    );
  }

  bool _requiredField(String name) {
    // Upstream marks both alternatives as required although its contract needs one.
    if (op.properties.containsKey('environment_name') &&
        op.properties.containsKey('environment_uuid') &&
        (name == 'environment_name' || name == 'environment_uuid')) {
      final alternative = name == 'environment_name'
          ? 'environment_uuid'
          : 'environment_name';
      if (_fields['body:$alternative']!.text.trim().isNotEmpty) return false;
    }
    return op.requiredFields.contains(name);
  }

  Future<void> _execute() async {
    if (_busy ||
        _confirming ||
        !widget.session.access.allows(op.method, op.path) ||
        !_form.currentState!.validate()) {
      return;
    }
    try {
      final generation = widget.session.generation;
      final paths = Map<String, String>.of(widget.pathValues);
      final query = <String, String>{};
      for (final p in op.parameters) {
        final name = p['name'] as String, location = p['in'] as String;
        final value = _fields['$location:$name']!.text;
        if (p['required'] == true && value.trim().isEmpty) {
          throw const FormatException();
        }
        if (value.isNotEmpty) {
          _parse(value, p['schema'] as Map<String, dynamic>);
        }
        if (location == 'path') {
          paths[name] = value;
        }
        if (location == 'query' && value.isNotEmpty) {
          query[name] = value;
        }
      }
      final body = <String, dynamic>{};
      for (final entry in op.properties.entries) {
        final key = 'body:${entry.key}';
        if (!_changed.contains(key) && !_requiredField(entry.key)) {
          continue;
        }
        final schema = entry.value as Map<String, dynamic>;
        if (_requiredField(entry.key) &&
            schema['type'] == 'boolean' &&
            _booleans[entry.key] == null) {
          throw const FormatException();
        }
        if (schema['type'] == 'boolean') {
          if (_booleans[entry.key] != null) {
            body[entry.key] = _booleans[entry.key];
          }
        } else {
          final raw = _fields[key]!.text;
          if (['environment_name', 'environment_uuid'].contains(entry.key) &&
              raw.trim().isEmpty &&
              !_requiredField(entry.key)) {
            continue;
          }
          if (_requiredField(entry.key) &&
              raw.isEmpty &&
              entry.key != 'value') {
            throw const FormatException();
          }
          // A changed empty string is an intentional empty env value, not omission.
          body[entry.key] = _parse(raw, schema);
        }
      }
      Object? payload = body.isEmpty ? null : body;
      if (_fields['body:json'] case final TextEditingController field) {
        if (field.text.isNotEmpty) {
          try {
            payload = jsonDecode(field.text);
          } catch (_) {
            setState(() => _error = 'coolifyInvalidJson');
            return;
          }
        }
      }
      if (op.bodyRequired && payload == null || op.upload && _file == null) {
        setState(() => _error = 'coolifyRequiredPayload');
        return;
      }
      String path;
      try {
        path = op.resolvePath(paths);
      } catch (_) {
        setState(() => _error = 'coolifyInvalidField');
        return;
      }
      final target =
          widget.target ?? paths['uuid'] ?? widget.session.instance.name;
      if (op.mutates) {
        setState(() => _confirming = true);
        final accepted = await confirmCoolifyOperation(
          context,
          op,
          target,
          path: path,
          preview: {'fields': payload, 'options': query},
        );
        if (mounted) setState(() => _confirming = false);
        if (!accepted) return;
      }
      if (!mounted || generation != widget.session.generation) return;
      final request = ++_request;
      setState(() {
        _busy = true;
        _error = null;
        if (op.mutates ||
            path != _resultPath ||
            op.path.endsWith('/logs') ||
            op.path == '/deployments/{uuid}') {
          _result = null;
          _completed = false;
        }
      });
      try {
        final result = await widget.session.request(
          op.method,
          path,
          query: query,
          body: payload,
          file: _file,
        );
        if (!mounted || request != _request) return;
        setState(() {
          _result = result;
          _resultPath = path;
          _resultQuery = Map.of(query);
          _completed = true;
        });
      } on CoolifyException catch (error) {
        if (mounted && request == _request) {
          setState(() => _error = error.message);
        }
      } finally {
        if (mounted && request == _request) setState(() => _busy = false);
      }
    } on FormatException {
      if (mounted) setState(() => _error = 'coolifyInvalidField');
    }
  }

  Future<void> _deleteExecution(String id) async {
    final operation = widget.catalog?.find(
      'DELETE',
      '${op.path}/{execution_uuid}',
    );
    if (_busy || _confirming || operation == null) return;
    final generation = widget.session.generation;
    final values = {
      for (final p in op.parameters.where((p) => p['in'] == 'path'))
        p['name'] as String: _fields['path:${p['name']}']!.text,
      'execution_uuid': id,
    };
    final path = operation.resolvePath(values);
    setState(() => _confirming = true);
    final accepted = await confirmCoolifyOperation(
      context,
      operation,
      id,
      path: path,
    );
    if (mounted) setState(() => _confirming = false);
    if (!accepted || !mounted || generation != widget.session.generation) {
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.session.request('DELETE', path);
      if (!mounted || generation != widget.session.generation) return;
      setState(() => _busy = false);
      _execute();
    } on CoolifyException catch (error) {
      if (mounted && generation == widget.session.generation) {
        setState(() {
          _error = error.message;
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(coolifyOperationTitle(context, op))),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: CoolifyAccessButton(access: widget.session.access),
              ),
              HelpButton(
                message: '${op.description}\n\n${op.method} ${op.path}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final p in op.parameters)
            _field(
              '${p['in']}:${p['name']}',
              p['name'] as String,
              {
                ...(p['schema'] as Map<String, dynamic>),
                'description': p['description'],
              },
              required: p['required'] == true,
              readOnly:
                  p['in'] == 'path' && widget.pathValues.containsKey(p['name']),
            ),
          if (op.properties.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: HelpButton(message: context.l10n.coolifyChangedOnly),
            ),
            const SizedBox(height: 16),
          ],
          for (final entry in op.properties.entries)
            if ((entry.value as Map<String, dynamic>)['type'] == 'boolean')
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField<bool>(
                  initialValue: _booleans[entry.key],
                  isExpanded: true,
                  validator: (value) =>
                      _requiredField(entry.key) && value == null
                      ? context.l10n.credentialRequired
                      : null,
                  decoration: InputDecoration(
                    labelText: entry.key,
                    suffixIcon: entry.value['description'] == null
                        ? null
                        : HelpButton(
                            message: entry.value['description'] as String,
                          ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: true,
                      child: Text(context.l10n.coolifyYes),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Text(context.l10n.coolifyNo),
                    ),
                  ],
                  onChanged: _busy
                      ? null
                      : (value) {
                          _booleans[entry.key] = value;
                          _changed.add('body:${entry.key}');
                        },
                ),
              )
            else
              _field(
                'body:${entry.key}',
                entry.key,
                entry.value as Map<String, dynamic>,
                required: _requiredField(entry.key),
              ),
          if (_fields.containsKey('body:json'))
            _field('body:json', 'JSON', const {
              'type': 'object',
            }, required: op.bodyRequired),
          if (op.upload) ...[
            OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () async {
                      final generation = widget.session.generation;
                      final selected = await openFile();
                      if (mounted && generation == widget.session.generation) {
                        setState(() => _file = selected);
                      }
                    },
              icon: const Icon(Icons.upload_file),
              label: Text(context.l10n.coolifyChooseFile),
            ),
            if (_file != null) Text(_file!.name),
            const SizedBox(height: 16),
          ],
          FilledButton.icon(
            key: const ValueKey('coolify-execute'),
            onPressed:
                _busy ||
                    _confirming ||
                    !widget.session.access.allows(op.method, op.path)
                ? null
                : _execute,
            icon: Icon(op.mutates ? Icons.check : Icons.refresh),
            label: Text(
              op.mutates
                  ? context.l10n.coolifyExecute
                  : context.l10n.coolifyRead,
            ),
          ),
          if (!widget.session.access.allows(op.method, op.path))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(context.l10n.coolifyPermissionDenied),
            ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                localizedMessage(context, _error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_completed) ...[
            const SizedBox(height: 16),
            Text(context.l10n.coolifySuccess),
            if (_result != null) ...[
              if (op.method == 'GET' &&
                  _resultPath != null &&
                  (op.path.endsWith('/logs') ||
                      op.path == '/deployments/{uuid}')) ...[
                if (!op.path.endsWith('/logs') && _result is Map)
                  CoolifyActivityCard(
                    item: Map<String, dynamic>.from(_result as Map),
                    kind: 'deployments',
                  ),
                CoolifyLogsPanel(
                  key: ValueKey('$_resultPath:$_request'),
                  session: widget.session,
                  path: _resultPath!,
                  query: _resultQuery,
                  data: _result,
                  onData: op.path == '/deployments/{uuid}'
                      ? (data) {
                          if (mounted) setState(() => _result = data);
                        }
                      : null,
                ),
              ] else if (op.method == 'GET' &&
                  op.path.contains('/backups/') &&
                  op.path.endsWith('/executions')) ...[
                CoolifyActivityList(
                  items: coolifyActivityEntries(_result),
                  busy: _busy || _confirming,
                  itemBuilder: (entry) => CoolifyActivityCard(
                    item: entry,
                    kind: 'executions',
                    actions: [
                      if (entry['uuid'] != null &&
                          widget.catalog?.find(
                                'DELETE',
                                '${op.path}/{execution_uuid}',
                              ) !=
                              null)
                        TextButton.icon(
                          onPressed:
                              _busy ||
                                  _confirming ||
                                  !widget.session.access.allows(
                                    'DELETE',
                                    '${op.path}/{execution_uuid}',
                                  )
                              ? null
                              : () =>
                                    _deleteExecution(entry['uuid'].toString()),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: Text(context.l10n.remove),
                        ),
                    ],
                  ),
                ),
              ] else
                CoolifyPayload(
                  data: _result,
                  sensitive: op.path.endsWith('/logs'),
                ),
              if (!op.path.contains('/backups/') &&
                  op.path.endsWith('/executions') &&
                  _result is List)
                for (final entry
                    in (_result as List).whereType<Map<String, dynamic>>())
                  if (entry['uuid'] != null &&
                      widget.catalog?.find(
                            'DELETE',
                            '${op.path}/{execution_uuid}',
                          ) !=
                          null)
                    OutlinedButton.icon(
                      onPressed: _busy || _confirming
                          ? null
                          : () => _deleteExecution(entry['uuid'].toString()),
                      icon: const Icon(Icons.delete_outline),
                      label: Text('${context.l10n.remove} · ${entry['uuid']}'),
                    ),
            ],
          ],
        ],
      ),
    ),
  );
}
