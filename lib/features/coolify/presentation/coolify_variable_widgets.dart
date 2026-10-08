import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/widgets.dart';
import '../../../l10n/localization.dart';
import '../../connections/data/coolify_client.dart';
import '../data/coolify_catalog.dart';
import '../data/coolify_session.dart';
import 'coolify_operation_page.dart';

bool coolifyIsPreview(Map<String, dynamic> item) =>
    item['is_preview'] == true ||
    item['is_preview'] == 1 ||
    item['is_preview'] == '1' ||
    item['is_preview'] == 'true';

class CoolifyVariableGroups extends StatelessWidget {
  const CoolifyVariableGroups({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onDelete,
    this.onCreate,
    this.supportsPreview = true,
  });
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic>) onEdit, onDelete;
  final void Function(bool)? onCreate;
  final bool supportsPreview;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final preview = supportsPreview || items.any(coolifyIsPreview);
      if (preview && constraints.maxWidth >= 780) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _category(context, false)),
            const SizedBox(width: 16),
            Expanded(child: _category(context, true)),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _category(context, false),
          if (preview) _category(context, true),
        ],
      );
    },
  );

  Widget _category(BuildContext context, bool preview) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 18),
      SectionTitle(
        preview
            ? context.l10n.coolifyPreviewVariables
            : context.l10n.coolifyNormalVariables,
        trailing: onCreate == null
            ? null
            : IconButton(
                onPressed: () => onCreate!(preview),
                icon: const Icon(Icons.add),
                tooltip: context.l10n.coolifyCreate,
              ),
      ),
      if (!items.any((item) => coolifyIsPreview(item) == preview))
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            context.l10n.coolifyEmpty,
            style: const TextStyle(color: DockColors.muted),
          ),
        ),
      for (final item in items.where(
        (item) => coolifyIsPreview(item) == preview,
      ))
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CoolifyVariableCard(
            key: ValueKey(
              '${item['key']}:${item['uuid'] ?? item['id']}:$preview',
            ),
            item: item,
            onEdit: () => onEdit(item),
            onDelete: item['uuid'] != null || item['id'] != null
                ? () => onDelete(item)
                : null,
          ),
        ),
    ],
  );
}

class CoolifyVariableCard extends StatefulWidget {
  const CoolifyVariableCard({
    super.key,
    required this.item,
    required this.onEdit,
    this.onDelete,
  });
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  @override
  State<CoolifyVariableCard> createState() => _CoolifyVariableCardState();
}

class _CoolifyVariableCardState extends State<CoolifyVariableCard> {
  bool _reveal = false;
  @override
  void didUpdateWidget(CoolifyVariableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reveal = false;
  }

  @override
  Widget build(BuildContext context) {
    final readable = widget.item['value'] is String;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.key_outlined,
                size: 18,
                color: DockColors.purple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.item['key'] ?? widget.item['name'] ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: context.l10n.coolifyEditValue,
              ),
              if (widget.onDelete != null)
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: context.l10n.remove,
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (!readable)
            Text(
              context.l10n.coolifyRestricted,
              style: const TextStyle(color: DockColors.muted),
            )
          else ...[
            SelectableText(
              _reveal ? widget.item['value'] as String : '••••••••',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _reveal = !_reveal),
                icon: Icon(
                  _reveal
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                label: Text(
                  _reveal
                      ? context.l10n.coolifyHideValue
                      : context.l10n.coolifyShowValue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The variable key/category is immutable here; only its value can change.
/// Existing schema-supported flags are preserved when identifying/updating it.
class CoolifyVariableValuePage extends StatefulWidget {
  const CoolifyVariableValuePage({
    super.key,
    required this.session,
    required this.operation,
    required this.paths,
    required this.item,
    required this.target,
  });
  final CoolifySession session;
  final CoolifyOperation operation;
  final Map<String, String> paths;
  final Map<String, dynamic> item;
  final String target;
  @override
  State<CoolifyVariableValuePage> createState() =>
      _CoolifyVariableValuePageState();
}

class _CoolifyVariableValuePageState extends State<CoolifyVariableValuePage> {
  late final TextEditingController _value = TextEditingController(
    text: widget.item['value'] is String ? widget.item['value'] as String : '',
  );
  bool _reveal = false, _changed = false, _busy = false, _confirming = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    widget.session.addListener(_clear);
  }

  void _clear() {
    if (mounted) {
      setState(() {
        _value.clear();
        _changed = false;
        _reveal = false;
        _busy = false;
        _error = null;
      });
    }
  }

  @override
  void dispose() {
    widget.session.removeListener(_clear);
    _value.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_changed || _busy || _confirming || !widget.session.active) return;
    final generation = widget.session.generation;
    final op = widget.operation;
    final body = <String, dynamic>{'value': _value.text};
    if (op.properties.containsKey('key')) body['key'] = widget.item['key'];
    for (final entry in op.properties.entries) {
      if (entry.value is Map &&
          (entry.value as Map)['type'] == 'boolean' &&
          widget.item[entry.key] != null) {
        body[entry.key] = entry.key == 'is_preview'
            ? coolifyIsPreview(widget.item)
            : widget.item[entry.key];
      }
    }
    if (op.properties.containsKey('is_preview')) {
      body['is_preview'] = coolifyIsPreview(widget.item);
    }
    final path = op.resolvePath(widget.paths);
    setState(() => _confirming = true);
    final accepted = await confirmCoolifyOperation(
      context,
      op,
      widget.target,
      path: path,
      preview: {'key': widget.item['key'], 'value': '••••••••'},
    );
    if (!mounted) return;
    setState(() => _confirming = false);
    if (!accepted || generation != widget.session.generation) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.session.request(op.method, path, body: body);
      if (mounted && generation == widget.session.generation) {
        Navigator.pop(context, true);
      }
    } on CoolifyException catch (e) {
      if (mounted && generation == widget.session.generation) {
        setState(() {
          _error = e.message;
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.coolifyEditValue)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${widget.item['key'] ?? widget.item['name'] ?? ''}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          coolifyIsPreview(widget.item)
              ? context.l10n.coolifyPreviewVariables
              : context.l10n.coolifyNormalVariables,
          style: const TextStyle(color: DockColors.muted),
        ),
        if (widget.item['value'] is! String) ...[
          const SizedBox(height: 16),
          Text(context.l10n.coolifyRestricted),
        ],
        const SizedBox(height: 20),
        TextField(
          key: const ValueKey('coolify-variable-value'),
          controller: _value,
          enabled: !_busy && !_confirming,
          obscureText: !_reveal,
          maxLines: _reveal ? 8 : 1,
          autocorrect: false,
          enableSuggestions: false,
          onChanged: (_) => setState(() => _changed = true),
          decoration: InputDecoration(
            labelText: context.l10n.coolifyValue,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _reveal = !_reveal),
              icon: Icon(_reveal ? Icons.visibility_off : Icons.visibility),
              tooltip: _reveal
                  ? context.l10n.coolifyHideValue
                  : context.l10n.coolifyShowValue,
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const ValueKey('coolify-save-variable-value'),
          onPressed: _changed && !_busy && !_confirming && widget.session.active
              ? _save
              : null,
          icon: const Icon(Icons.save_outlined),
          label: Text(context.l10n.coolifySaveValue),
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              localizedMessage(context, _error!),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    ),
  );
}
