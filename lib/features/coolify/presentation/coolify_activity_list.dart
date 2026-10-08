import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/help_button.dart';
import '../../../core/widgets.dart';
import '../../../l10n/localization.dart';
import 'coolify_cards.dart';

List<Map<String, dynamic>> coolifyActivityEntries(Object? data) {
  if (data is List) return data.whereType<Map<String, dynamic>>().toList();
  if (data is Map) {
    for (final key in ['deployments', 'executions', 'backups', 'data']) {
      if (data[key] is List) return coolifyActivityEntries(data[key]);
    }
  }
  return [];
}

String coolifyActivityId(Map<String, dynamic> item) =>
    '${item['deployment_uuid'] ?? item['uuid'] ?? item['id'] ?? ''}';

String formatCoolifyBytes(num bytes, String locale) {
  if (!bytes.isFinite || bytes < 0) return '—';
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < 4) {
    value /= 1024;
    unit++;
  }
  return '${NumberFormat('#,##0.#', locale).format(value)} ${['B', 'KiB', 'MiB', 'GiB', 'TiB'][unit]}';
}

List<Map<String, dynamic>> filterCoolifyActivity(
  List<Map<String, dynamic>> items,
  String search,
  String? status,
) {
  final query = search.trim().toLowerCase();
  return items.where((item) {
    if (status != null && '${item['status'] ?? ''}' != status) return false;
    // Search display metadata only; never stringify secrets or full log bodies.
    return query.isEmpty ||
        [
          'deployment_uuid',
          'uuid',
          'name',
          'application_name',
          'filename',
          'status',
          'commit',
          'commit_message',
          'frequency',
          'created_at',
        ].any((key) => '${item[key] ?? ''}'.toLowerCase().contains(query));
  }).toList();
}

class ActivityPager extends StatelessWidget {
  const ActivityPager({
    super.key,
    required this.page,
    this.onPrevious,
    this.onNext,
  });
  final int page;
  final VoidCallback? onPrevious, onNext;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        key: const ValueKey('activity-previous'),
        tooltip: context.l10n.listPrevious,
        onPressed: onPrevious,
        icon: const Icon(Icons.chevron_left),
      ),
      Expanded(
        child: Text(
          context.l10n.listPage(page + 1),
          textAlign: TextAlign.center,
        ),
      ),
      IconButton(
        key: const ValueKey('activity-next'),
        tooltip: context.l10n.listNext,
        onPressed: onNext,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}

/// Lists without API pagination are paginated on device. Deployment pages use
/// skip/take from the API and explicitly scope filters to the current page.
class CoolifyActivityList extends StatefulWidget {
  const CoolifyActivityList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.remotePage,
    this.onPrevious,
    this.onNext,
    this.busy = false,
  });
  final List<Map<String, dynamic>> items;
  final Widget Function(Map<String, dynamic>) itemBuilder;
  final int? remotePage;
  final VoidCallback? onPrevious, onNext;
  final bool busy;
  @override
  State<CoolifyActivityList> createState() => _CoolifyActivityListState();
}

class _CoolifyActivityListState extends State<CoolifyActivityList> {
  String _search = '';
  String? _status;
  int _page = 0;
  static const pageSize = 10;
  @override
  Widget build(BuildContext context) {
    final statuses =
        widget.items
            .map((item) => '${item['status'] ?? ''}')
            .where((status) => status.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final status = statuses.contains(_status) ? _status : null;
    final filtered = filterCoolifyActivity(widget.items, _search, status);
    final maxPage = filtered.isEmpty ? 0 : (filtered.length - 1) ~/ pageSize;
    final page = _page.clamp(0, maxPage);
    final visible = widget.remotePage != null
        ? filtered
        : filtered.skip(page * pageSize).take(pageSize);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('activity-search'),
          decoration: InputDecoration(
            labelText: context.l10n.listSearch,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: widget.remotePage == null
                ? null
                : HelpButton(message: context.l10n.listPageFilterHelp),
          ),
          onChanged: (value) => setState(() {
            _search = value;
            _page = 0;
          }),
        ),
        const SizedBox(height: 12),
        if (statuses.isNotEmpty)
          DropdownButtonFormField<String>(
            key: ValueKey('activity-status-$status'),
            initialValue: status ?? '',
            isExpanded: true,
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(context.l10n.listAllStatuses),
              ),
              for (final value in statuses)
                DropdownMenuItem(value: value, child: Text(value)),
            ],
            onChanged: (value) => setState(() {
              _status = value == '' ? null : value;
              _page = 0;
            }),
          ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.items.isEmpty
                  ? context.l10n.coolifyEmpty
                  : context.l10n.listNoMatches,
            ),
          ),
        ActivityPager(
          page: widget.remotePage ?? page,
          onPrevious: widget.busy
              ? null
              : widget.remotePage != null
              ? widget.onPrevious
              : page > 0
              ? () => setState(() => _page = page - 1)
              : null,
          onNext: widget.busy
              ? null
              : widget.remotePage != null
              ? widget.onNext
              : page < maxPage
              ? () => setState(() => _page = page + 1)
              : null,
        ),
        for (final item in visible) widget.itemBuilder(item),
      ],
    );
  }
}

class CoolifyActivityCard extends StatelessWidget {
  const CoolifyActivityCard({
    super.key,
    required this.item,
    required this.kind,
    this.actions = const [],
  });
  final Map<String, dynamic> item;
  final String kind;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) {
    final id = coolifyActivityId(item);
    final title =
        item['name'] ??
        item['application_name'] ??
        item['filename'] ??
        (kind == 'deployments'
            ? (id.length > 12 ? id.substring(0, 12) : id)
            : context.l10n.listSchedule);
    final fields = {
      for (final key in [
        'created_at',
        'finished_at',
        'frequency',
        'enabled',
        'size',
        'commit_message',
      ])
        if (item[key] != null)
          key: key == 'size' && item[key] is num
              ? formatCoolifyBytes(
                  item[key] as num,
                  Localizations.localeOf(context).toString(),
                )
              : item[key],
      if (item['commit'] is String && (item['commit'] as String).isNotEmpty)
        'commit': (item['commit'] as String).substring(
          0,
          (item['commit'] as String).length.clamp(0, 8),
        ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$title',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (item['status'] != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: coolifyStatus(context, '${item['status']}'),
                ),
              ),
            CoolifyInfoFields(data: fields),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...actions,
                TextButton.icon(
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: Text(context.l10n.listDetails),
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => SafeArea(
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * .7,
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Text(
                              '$title',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            CoolifyInfoFields(
                              data: {
                                for (final entry in item.entries)
                                  if (![
                                    'logs',
                                    'configuration_snapshot',
                                    'configuration_diff',
                                  ].contains(entry.key))
                                    entry.key: entry.value,
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
