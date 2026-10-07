import '../../../l10n/localization.dart';

import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/widgets.dart';
import '../domain/dock_controller.dart';
import '../domain/dock_workspace.dart';

class WorkspaceAvatar extends StatelessWidget {
  const WorkspaceAvatar({
    super.key,
    required this.workspace,
    this.selected = false,
    this.size = 44,
  });
  final DockWorkspace workspace;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: selected ? DockColors.primary : DockColors.elevated,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: selected ? DockColors.purple : DockColors.border,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          workspace.name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((word) => word.characters.first)
              .join()
              .toUpperCase(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : DockColors.purple,
          ),
        ),
      ),
    ),
  );
}

class WorkspaceRail extends StatelessWidget {
  const WorkspaceRail({
    super.key,
    required this.controller,
    required this.onCreate,
    required this.onManage,
  });
  final DockController controller;
  final VoidCallback onCreate;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) => Material(
    color: DockColors.background,
    child: SafeArea(
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Tooltip(
                message: context.l10n.manageWorkspaces,
                child: InkWell(
                  onTap: onManage,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: DockLogo(size: 40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  for (final workspace in controller.workspaces)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Semantics(
                        button: true,
                        selected:
                            controller.activeWorkspace?.id == workspace.id,
                        label: context.l10n.workspaceLabel(workspace.name),
                        child: Tooltip(
                          message: workspace.name,
                          excludeFromSemantics: true,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (controller.activeWorkspace?.id ==
                                  workspace.id)
                                Positioned(
                                  left: 0,
                                  child: Container(
                                    width: 3,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: DockColors.purple,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              InkWell(
                                key: ValueKey('workspace-${workspace.id}'),
                                onTap: () =>
                                    controller.selectWorkspace(workspace.id),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: WorkspaceAvatar(
                                    workspace: workspace,
                                    selected:
                                        controller.activeWorkspace?.id ==
                                        workspace.id,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: IconButton.filledTonal(
                key: const ValueKey('add-workspace'),
                onPressed: controller.isSaving ? null : onCreate,
                tooltip: context.l10n.createWorkspace,
                icon: const Icon(Icons.add_rounded, color: DockColors.purple),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool?> showWorkspaceEditor(
  BuildContext context,
  DockController controller, {
  DockWorkspace? workspace,
}) => showDialog<bool>(
  context: context,
  builder: (_) =>
      _WorkspaceNameDialog(controller: controller, workspace: workspace),
);

class _WorkspaceNameDialog extends StatefulWidget {
  const _WorkspaceNameDialog({required this.controller, this.workspace});
  final DockController controller;
  final DockWorkspace? workspace;
  @override
  State<_WorkspaceNameDialog> createState() => _WorkspaceNameDialogState();
}

class _WorkspaceNameDialogState extends State<_WorkspaceNameDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.workspace?.name);
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      scrollable: true,
      title: Text(
        widget.workspace == null
            ? context.l10n.newWorkspace
            : context.l10n.renameWorkspace,
      ),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.workspace == null) ...[
              Text(
                context.l10n.workspaceGrouping,
                style: TextStyle(color: DockColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 20),
            ],
            TextFormField(
              key: const ValueKey('workspace-name'),
              controller: _name,
              autofocus: true,
              enabled: !_saving,
              decoration: InputDecoration(
                labelText: context.l10n.workspaceName,
                hintText: context.l10n.workspaceEditorHint,
              ),
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!_saving) _save();
              },
              validator: (value) => value == null || value.trim().isEmpty
                  ? context.l10n.workspaceNameRequired
                  : null,
            ),
            if (_error != null)
              Text(
                localizedMessage(context, _error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('save-workspace'),
          onPressed: _saving ? null : _save,
          child: Text(
            _saving
                ? context.l10n.saving
                : widget.workspace == null
                ? context.l10n.createWorkspace
                : context.l10n.save,
          ),
        ),
      ],
    ),
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final workspace = widget.workspace;
      if (workspace == null) {
        await widget.controller.createWorkspace(_name.text);
      } else {
        await widget.controller.renameWorkspace(workspace.id, _name.text);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'saveError';
        });
      }
    }
  }
}

Future<void> showWorkspaceManager(
  BuildContext context,
  DockController controller,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => SizedBox(
      height: MediaQuery.sizeOf(context).height * .65,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              context.l10n.yourWorkspaces,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.workspaceContexts,
              style: TextStyle(color: DockColors.muted),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  for (final workspace in controller.workspaces)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: controller.activeWorkspace?.id == workspace.id
                            ? const Color(0xFF2E2243)
                            : DockColors.background,
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          key: ValueKey('manage-workspace-${workspace.id}'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          onTap: () {
                            controller.selectWorkspace(workspace.id);
                            Navigator.pop(context);
                          },
                          leading: WorkspaceAvatar(
                            workspace: workspace,
                            size: 38,
                          ),
                          title: Text(
                            workspace.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            context.l10n.instanceCount(
                              workspace.instances.length,
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              color: DockColors.muted,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            key: ValueKey('workspace-options-${workspace.id}'),
                            tooltip: context.l10n.workspaceOptions(
                              workspace.name,
                            ),
                            enabled: !controller.isSaving,
                            onSelected: (action) async {
                              if (action == 'rename') {
                                await showWorkspaceEditor(
                                  context,
                                  controller,
                                  workspace: workspace,
                                );
                              }
                              if (action == 'delete' && context.mounted) {
                                await _removeWorkspace(
                                  context,
                                  controller,
                                  workspace,
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text(context.l10n.rename),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(context.l10n.removeWorkspace),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (controller.workspaces.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        context.l10n.noWorkspaces,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: controller.isSaving
                  ? null
                  : () async {
                      final created = await showWorkspaceEditor(
                        context,
                        controller,
                      );
                      if (created == true && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.newWorkspace),
            ),
          ],
        ),
      ),
    ),
  ),
);

Future<void> _removeWorkspace(
  BuildContext context,
  DockController controller,
  DockWorkspace workspace,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.removeWorkspaceTitle),
      content: Text(
        context.l10n.removeWorkspaceBody(
          workspace.name,
          workspace.instances.length,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.remove),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await controller.removeWorkspace(workspace.id);
    if (controller.workspaces.isEmpty && context.mounted) {
      Navigator.pop(context);
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.removeWorkspaceError)),
      );
    }
  }
}

Future<void> showMoveInstance(
  BuildContext context,
  DockController controller,
) async {
  final instance = controller.selected;
  if (instance == null) return;
  final targets = controller.workspaces
      .where((w) => w.id != controller.activeWorkspace?.id)
      .toList();
  final destination = await showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(context.l10n.moveInstance),
      children: [
        for (final workspace in targets)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, workspace.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  WorkspaceAvatar(workspace: workspace, size: 36),
                  const SizedBox(width: 12),
                  Expanded(child: Text(workspace.name)),
                ],
              ),
            ),
          ),
      ],
    ),
  );
  if (destination == null) return;
  try {
    await controller.moveInstance(instance.id, destination);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.moveInstanceError)));
    }
  }
}
