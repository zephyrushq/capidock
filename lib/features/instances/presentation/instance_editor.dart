import 'package:flutter/material.dart';

import '../../workspaces/domain/dock_controller.dart';
import '../domain/server_instance.dart';
import 'instance_form.dart';

Future<void> showInstanceEditor(
  BuildContext context,
  DockController controller, {
  ServerInstance? instance,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (_) => InstanceEditor(controller: controller, instance: instance),
);

class InstanceEditor extends StatefulWidget {
  const InstanceEditor({super.key, required this.controller, this.instance});
  final DockController controller;
  final ServerInstance? instance;
  @override
  State<InstanceEditor> createState() => _InstanceEditorState();
}

class _InstanceEditorState extends State<InstanceEditor> {
  final _form = GlobalKey<FormState>();
  late final _draft = InstanceDraft(widget.instance);
  late final _workspaceId = widget.controller.activeWorkspace!.id;
  late final _workspaceName = widget.controller.activeWorkspace!.name;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Capture the destination before the user can change workspace selection.
    _workspaceId;
    _workspaceName;
  }

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.instance == null
                  ? 'Um novo lugar no seu dock.'
                  : 'Editar instância',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text('No workspace “$_workspaceName”.'),
            const SizedBox(height: 24),
            InstanceNameField(controller: _draft.name, enabled: !_saving),
            const SizedBox(height: 12),
            InstanceConnectionFields(
              draft: _draft,
              enabled: !_saving,
              allowTypeChange: widget.instance == null,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const ValueKey('save-instance'),
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.lock_outline),
              label: Text(_saving ? 'A guardar…' : 'Guardar configuração'),
            ),
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await _draft.validateCredentials();
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _error = error;
        _saving = false;
      });
      return;
    }
    try {
      await widget.controller.upsert(
        _draft.toInstance(),
        workspaceId: _workspaceId,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Não foi possível guardar. Tente novamente.';
          _saving = false;
        });
      }
    }
  }
}
