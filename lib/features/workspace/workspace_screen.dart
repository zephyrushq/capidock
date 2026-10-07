import '../../l10n/language_selector.dart';
import '../../l10n/localization.dart';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/app_theme.dart';
import '../../core/widgets.dart';
import '../workspaces/domain/dock_controller.dart';
import '../instances/domain/server_instance.dart';
import '../instances/presentation/instance_editor.dart';
import '../instances/presentation/instance_sidebar.dart';
import '../workspaces/presentation/workspace_controls.dart';
import '../connections/presentation/instance_connection_page.dart';
import '../workspaces/presentation/welcome_screen.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key, required this.controller});
  final DockController controller;
  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final _scaffold = GlobalKey<ScaffoldState>();
  DockController get controller => widget.controller;
  void _add() {
    if (controller.activeWorkspace == null) {
      _createWorkspace();
    } else {
      showInstanceEditor(context, controller);
    }
  }

  void _createWorkspace() => showWorkspaceEditor(context, controller);
  void _manageWorkspaces() => showWorkspaceManager(context, controller);
  void _edit() =>
      showInstanceEditor(context, controller, instance: controller.selected);

  Future<void> _about() async {
    String? version;
    try {
      final info = await PackageInfo.fromPlatform();
      version = '${info.version}+${info.buildNumber}';
    } catch (_) {
      // The about dialog remains available if platform metadata cannot be read.
    }
    if (!mounted) return;
    showAboutDialog(
      context: context,
      applicationName: 'Capidock',
      applicationVersion: version,
      applicationIcon: const DockLogo(size: 54),
      applicationLegalese: '© 2026 ZEPHYRUS PROSPERITY - UNIPESSOAL LDA',
      children: [
        Text(context.l10n.aboutDescription),
        SizedBox(height: 16),
        Text(context.l10n.aboutLicence),
        SizedBox(height: 12),
        SelectableText(context.l10n.sourceCode),
      ],
    );
  }

  Future<void> _remove() async {
    final instance = controller.selected!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.removeInstanceTitle),
        content: Text(context.l10n.removeInstanceBody(instance.name)),
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
    if (confirmed != true || !mounted) return;
    try {
      await controller.remove(instance.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.removeInstanceError)),
        );
      }
    }
  }

  Widget _sidebar({bool drawer = false}) => Row(
    children: [
      WorkspaceRail(
        controller: controller,
        onCreate: _createWorkspace,
        onManage: _manageWorkspaces,
      ),
      const VerticalDivider(width: 1, thickness: 1),
      Expanded(
        child: InstanceSidebar(
          key: ValueKey(controller.activeWorkspace?.id),
          controller: controller,
          onAdd: () {
            if (drawer) Navigator.pop(context);
            _add();
          },
          onAbout: _about,
          onManageWorkspaces: _manageWorkspaces,
          onSelect: (id) {
            controller.select(id);
            if (drawer) Navigator.pop(context);
          },
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      if (controller.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (controller.loadError != null) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 48,
                      color: DockColors.purple,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      localizedMessage(context, controller.loadError!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.preservedData,
                      style: TextStyle(color: DockColors.muted),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: controller.initialize,
                      child: Text(context.l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      if (controller.workspaces.isEmpty) {
        return WelcomeScreen(controller: controller, onAbout: _about);
      }
      final wide = MediaQuery.sizeOf(context).width >= 900;
      final instance = controller.selected;
      return Scaffold(
        key: _scaffold,
        drawer: wide
            ? null
            : Drawer(
                width: (MediaQuery.sizeOf(context).width - 16).clamp(
                  0.0,
                  360.0,
                ),
                shape: const RoundedRectangleBorder(),
                child: _sidebar(drawer: true),
              ),
        body: Row(
          children: [
            if (wide) ...[
              SizedBox(width: 340, child: _sidebar()),
              const VerticalDivider(width: 1, thickness: 1),
            ],
            Expanded(
              child: SafeArea(
                child: Column(
                  children: [
                    _header(wide, instance),
                    if (instance != null) _channelBar(instance, wide),
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1040),
                          child: instance == null
                              ? EmptyWorkspace(
                                  onAdd: _add,
                                  workspaceName:
                                      controller.activeWorkspace?.name,
                                )
                              : _content(instance),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _header(bool wide, ServerInstance? instance) => Container(
    padding: EdgeInsets.fromLTRB(wide ? 22 : 8, 8, 12, 8),
    child: Row(
      children: [
        if (!wide)
          IconButton(
            onPressed: () => _scaffold.currentState!.openDrawer(),
            tooltip: context.l10n.openInstances,
            icon: const Icon(Icons.menu_rounded, color: DockColors.muted),
          ),
        if (!wide) ...[const DockLogo(size: 29), const SizedBox(width: 9)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wide
                    ? (controller.activeWorkspace?.name ?? 'Workspaces')
                    : 'Capidock',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: wide ? 13 : 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.4,
                  color: wide ? DockColors.muted : DockColors.text,
                ),
              ),
              if (!wide)
                Text(
                  controller.activeWorkspace?.name ??
                      context.l10n.firstWorkspace,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: DockColors.muted),
                ),
            ],
          ),
        ),
        const LanguageSelector(compact: true),
        IconButton(
          onPressed: _add,
          tooltip: controller.activeWorkspace == null
              ? context.l10n.createWorkspace
              : context.l10n.addInstance,
          icon: const Icon(Icons.add_rounded, color: DockColors.muted),
        ),
        if (instance != null)
          PopupMenuButton<String>(
            tooltip: context.l10n.instanceOptions,
            enabled: !controller.isSaving,
            icon: const Icon(Icons.more_horiz_rounded, color: DockColors.muted),
            onSelected: (value) {
              if (value == 'edit') _edit();
              if (value == 'delete') _remove();
              if (value == 'move') showMoveInstance(context, controller);
              if (value == 'about') _about();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(context.l10n.editInstance),
              ),
              if (controller.workspaces.length > 1)
                PopupMenuItem(
                  value: 'move',
                  child: Text(context.l10n.moveInstance),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Text(context.l10n.removeInstance),
              ),
              PopupMenuItem(
                value: 'about',
                child: Text(context.l10n.aboutCapidock),
              ),
            ],
          ),
      ],
    ),
  );

  Widget _channelBar(ServerInstance instance, bool wide) => Container(
    decoration: const BoxDecoration(
      border: Border(
        top: BorderSide(color: DockColors.border),
        bottom: BorderSide(color: DockColors.border),
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: wide ? null : () => _scaffold.currentState!.openDrawer(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          child: Row(
            children: [
              const Icon(Icons.tag_rounded, size: 23, color: DockColors.purple),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  instance.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!wide)
                Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.expand_more,
                    size: 17,
                    color: DockColors.muted,
                  ),
                ),
              const SizedBox(width: 12),
              Container(width: 1, height: 17, color: DockColors.border),
              const SizedBox(width: 12),
              Text(
                instance.type.label,
                style: const TextStyle(fontSize: 11, color: DockColors.muted),
              ),
              const Spacer(),
              Icon(
                instanceIcon(instance.type),
                size: 18,
                color: DockColors.muted,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _content(ServerInstance instance) => InstanceConnectionPage(
    key: ObjectKey(instance),
    instance: instance,
    onEdit: _edit,
  );
}
