import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../workspaces/domain/dock_controller.dart';
import '../domain/server_instance.dart';

class InstanceSidebar extends StatefulWidget {
  const InstanceSidebar({
    super.key,
    required this.controller,
    required this.onSelect,
    required this.onAdd,
    required this.onAbout,
    required this.onManageWorkspaces,
  });
  final DockController controller;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;
  final VoidCallback onAbout;
  final VoidCallback onManageWorkspaces;

  @override
  State<InstanceSidebar> createState() => _InstanceSidebarState();
}

class _InstanceSidebarState extends State<InstanceSidebar> {
  String _query = '';

  @override
  Widget build(BuildContext context) => Material(
    color: DockColors.rail,
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            child: Material(
              color: DockColors.elevated,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: const ValueKey('workspace-switcher'),
                onTap: widget.onManageWorkspaces,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WORKSPACE',
                              style: TextStyle(
                                fontSize: 8,
                                letterSpacing: 1.4,
                                color: DockColors.muted,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.controller.activeWorkspace?.name ??
                                  'Os seus workspaces',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.controller.instances.length} instâncias',
                              style: const TextStyle(
                                fontSize: 10,
                                color: DockColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.unfold_more_rounded,
                        size: 18,
                        color: DockColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _query = value.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Encontrar instância',
                hintStyle: TextStyle(fontSize: 12, color: DockColors.muted),
                prefixIcon: Icon(Icons.search, size: 18),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (final type in InstanceType.values) _group(type),
                if (widget.controller.instances.where(_matches).isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.controller.instances.isEmpty
                          ? 'Este workspace ainda não tem instâncias.'
                          : 'Nenhuma instância encontrada.',
                      style: const TextStyle(
                        color: DockColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (widget.controller.activeWorkspace != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: widget.onAdd,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Nova instância',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            onTap: widget.onManageWorkspaces,
            title: const Text(
              'Gerir workspaces',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${widget.controller.workspaces.length} espaços locais',
              style: const TextStyle(fontSize: 10, color: DockColors.muted),
            ),
            trailing: IconButton(
              onPressed: widget.onAbout,
              tooltip: 'Sobre o Capidock',
              icon: const Icon(
                Icons.info_outline,
                size: 18,
                color: DockColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  bool _matches(ServerInstance instance) =>
      '${instance.name} ${instance.host} ${instance.type.label}'
          .toLowerCase()
          .contains(_query);

  Widget _group(InstanceType type) {
    final instances = widget.controller.instances
        .where((i) => i.type == type && _matches(i))
        .toList();
    if (instances.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Row(
            children: [
              const Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: DockColors.muted,
              ),
              const SizedBox(width: 5),
              Text(
                type.label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: DockColors.muted),
              ),
              const Spacer(),
              Text(
                '${instances.length}',
                style: const TextStyle(color: DockColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
        for (final instance in instances)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Semantics(
              selected: widget.controller.selected?.id == instance.id,
              child: Material(
                color: widget.controller.selected?.id == instance.id
                    ? const Color(0xFF2E2243)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  key: ValueKey('channel-${instance.id}'),
                  onTap: () => widget.onSelect(instance.id),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tag_rounded,
                          size: 21,
                          color: widget.controller.selected?.id == instance.id
                              ? DockColors.purple
                              : DockColors.muted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            instance.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  widget.controller.selected?.id == instance.id
                                  ? DockColors.text
                                  : DockColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
