import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/widgets.dart';
import '../../../l10n/localization.dart';
import '../data/coolify_catalog.dart';

String coolifyKind(
  Map<String, dynamic> item, [
  String fallback = 'applications',
]) {
  final type = '${item['type'] ?? ''}'.toLowerCase();
  if (type.contains('application')) return 'applications';
  if (type.contains('service')) return 'services';
  if (type.contains('database') ||
      [
        'postgres',
        'redis',
        'mysql',
        'mariadb',
        'mongo',
        'clickhouse',
        'keydb',
        'dragonfly',
      ].any(type.contains)) {
    return 'databases';
  }
  return fallback;
}

String coolifyLabel(BuildContext context, String key) {
  final l = context.l10n;
  return switch (key) {
    'frequency' => l.listSchedule,
    'size' => l.activitySize,
    'finished_at' => l.activityFinished,
    'enabled' => l.activityEnabled,
    'commit_message' => l.activityCommit,
    'resources' => l.coolifyResources,
    'applications' => l.coolifyApplications,
    'databases' => l.coolifyDatabases,
    'services' => l.coolifyServices,
    'projects' => l.coolifyProjects,
    'servers' => l.coolifyServers,
    'environments' => l.coolifyEnvironments,
    'name' => l.coolifyName,
    'description' => l.coolifyDescription,
    'status' => l.coolifyStatus,
    'fqdn' => l.coolifyDomains,
    'git_repository' => l.coolifyRepository,
    'git_branch' => l.coolifyBranch,
    'build_pack' => l.coolifyBuildPack,
    'ip' => l.coolifyAddress,
    'port' => l.coolifyPort,
    'user' => l.coolifyUser,
    'mount_path' => l.coolifyMountPath,
    'host_path' => l.coolifyHostPath,
    'created_at' => l.coolifyCreated,
    'updated_at' => l.coolifyUpdated,
    'value' => l.coolifyValue,
    'is_preview' => l.coolifyPreview,
    'settings' => l.coolifySettings,
    'type' => l.coolifyType,
    _ =>
      key
          .replaceAll('_', ' ')
          .split(' ')
          .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
          .join(' '),
  };
}

IconData coolifyIcon(String kind) => switch (kind) {
  'projects' => Icons.folder_outlined,
  'environments' => Icons.layers_outlined,
  'servers' => Icons.dns_outlined,
  'databases' => Icons.storage_outlined,
  'services' => Icons.widgets_outlined,
  _ => Icons.code,
};

/// The API's status remains authoritative; no optimistic running status is invented.
Widget coolifyStatus(BuildContext context, String status) {
  final state = status.split(':').first;
  final label = switch (state) {
    'running' => context.l10n.coolifyRunning,
    'stopped' => context.l10n.coolifyStopped,
    'exited' => context.l10n.coolifyStopped,
    _ => status,
  };
  return StatusPill(
    label,
    color: status.contains('unhealthy') || ['failed', 'error'].contains(state)
        ? Theme.of(context).colorScheme.error
        : ['running', 'finished', 'success', 'completed'].contains(state)
        ? DockColors.green
        : ['queued', 'pending', 'in_progress'].contains(state)
        ? DockColors.purple
        : DockColors.muted,
  );
}

class CoolifyResourceCard extends StatelessWidget {
  const CoolifyResourceCard({
    super.key,
    required this.item,
    required this.kind,
    this.onTap,
  });
  final Map<String, dynamic> item;
  final String kind;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: DockColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: DockColors.border),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: DockColors.elevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    coolifyIcon(kind),
                    color: DockColors.purple,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['name'] ?? item['key'] ?? context.l10n.unnamedResource}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        coolifyLabel(context, kind),
                        style: const TextStyle(color: DockColors.muted),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: DockColors.muted,
                  ),
              ],
            ),
            if ('${item['description'] ?? ''}'.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${item['description']}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if ('${item['fqdn'] ?? ''}'.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${item['fqdn']}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: DockColors.muted),
              ),
            ],
            if ('${item['status'] ?? ''}'.isNotEmpty) ...[
              const SizedBox(height: 12),
              coolifyStatus(context, '${item['status']}'),
            ],
          ],
        ),
      ),
    ),
  );
}

class CoolifyCardGrid extends StatelessWidget {
  const CoolifyCardGrid({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1050
          ? 3
          : constraints.maxWidth >= 650
          ? 2
          : 1;
      final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

/// Human-readable response fields, including nested settings, without JSON syntax.
/// Reveal is local to this widget and never persisted.
class CoolifyInfoFields extends StatefulWidget {
  const CoolifyInfoFields({
    super.key,
    required this.data,
    this.sensitive = false,
  });
  final Object? data;
  final bool sensitive;
  @override
  State<CoolifyInfoFields> createState() => _CoolifyInfoFieldsState();
}

class _CoolifyInfoFieldsState extends State<CoolifyInfoFields> {
  bool _reveal = false;
  @override
  void didUpdateWidget(CoolifyInfoFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reveal = false;
  }

  Widget _value(Object? data, {String? key}) {
    if (data is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in data.entries)
            if (entry.value != null && '${entry.value}'.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coolifyLabel(context, '${entry.key}'),
                      style: const TextStyle(
                        color: DockColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _value(entry.value, key: '${entry.key}'),
                  ],
                ),
              ),
        ],
      );
    }
    if (data is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in data)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _value(item),
            ),
        ],
      );
    }
    if (data is bool) {
      return Icon(
        data ? Icons.check_circle_outline : Icons.cancel_outlined,
        size: 20,
        color: data ? DockColors.green : DockColors.muted,
      );
    }
    if (key == 'status') return coolifyStatus(context, '$data');
    return SelectableText(
      data == null ? '—' : '$data',
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (widget.sensitive || _containsSecrets(widget.data))
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _reveal = !_reveal),
            icon: Icon(_reveal ? Icons.visibility_off : Icons.visibility),
            label: Text(
              _reveal
                  ? context.l10n.hideCredential
                  : context.l10n.coolifyReveal,
            ),
          ),
        ),
      _value(
        !_reveal && widget.sensitive
            ? '••••••••'
            : _reveal
            ? widget.data
            : redactCoolify(widget.data),
      ),
    ],
  );
}

bool _containsSecrets(Object? data) => '$data' != '${redactCoolify(data)}';

Map<String, dynamic> coolifySummary(Map<String, dynamic> data) => {
  for (final key in [
    'description',
    'status',
    'fqdn',
    'git_repository',
    'git_branch',
    'build_pack',
    'docker_registry_image_name',
    'docker_registry_image_tag',
    'ip',
    'port',
    'user',
    'database_type',
    'image',
    'ports_exposes',
    'limits_memory',
    'limits_cpus',
  ])
    if (data[key] != null && '${data[key]}'.isNotEmpty) key: data[key],
};
