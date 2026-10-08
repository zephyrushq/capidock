import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../l10n/localization.dart';
import '../../connections/data/coolify_client.dart';
import '../../settings/app_preferences.dart';
import '../data/coolify_session.dart';
import 'coolify_activity_list.dart';

List<String> filterCoolifyLogLines(String text, String query, String level) {
  final search = query.trim().toLowerCase();
  final lines = text.split('\n');
  while (lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }
  return lines.where((line) {
    if (search.isNotEmpty && !line.toLowerCase().contains(search)) return false;
    return switch (level) {
      'error' => RegExp(
        r'\b(error|fatal|panic|exception|failed)\b',
        caseSensitive: false,
      ).hasMatch(line),
      'warning' => RegExp(
        r'\b(warn|warning)\b',
        caseSensitive: false,
      ).hasMatch(line),
      _ => true,
    };
  }).toList();
}

/// Decode Coolify's envelope and deployment records, never the application's
/// own JSON log messages. Keep the visible tail bounded and discard terminal
/// control sequences rather than executing output from a remote server.
String coolifyLogText(Object? payload) {
  final lines = <String>[];
  void read(Object? value, [int depth = 0]) {
    if (depth > 8 || value == null) return;
    if (value is String) {
      if (value.trimLeft().startsWith('[')) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List &&
              decoded.every((row) => row is Map && row.containsKey('output'))) {
            read(decoded, depth + 1);
            return;
          }
        } on FormatException {
          // Plain log output may start with a bracket.
        }
      }
      lines.add(value);
    } else if (value is List) {
      for (final row in value) {
        read(row, depth + 1);
      }
    } else if (value is Map) {
      if (value.containsKey('logs')) {
        read(value['logs'], depth + 1);
      } else if (value.containsKey('output') || value.containsKey('message')) {
        final output = value['output'] ?? value['message'];
        final time = value['timestamp'];
        if (output is String) {
          lines.add('${time == null ? '' : '[$time] '}$output');
        }
      } else {
        for (final key in ['data', 'stdout', 'stderr']) {
          if (value.containsKey(key)) read(value[key], depth + 1);
        }
      }
    }
  }

  read(payload);
  var text = lines
      .join('\n')
      .replaceAll(RegExp(r'\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)'), '')
      .replaceAll(RegExp(r'\x1b\[[0-?]*[ -/]*[@-~]'), '')
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(RegExp(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]'), '');
  if (text.length > 65536) text = text.substring(text.length - 65536);
  final tail = text.split('\n');
  return tail.skip(tail.length > 2000 ? tail.length - 2000 : 0).join('\n');
}

class CoolifyLogsPanel extends StatefulWidget {
  const CoolifyLogsPanel({
    super.key,
    required this.session,
    required this.path,
    required this.data,
    this.query = const {},
    this.onData,
  });
  final CoolifySession session;
  final String path;
  final Object? data;
  final Map<String, String> query;
  final ValueChanged<Object?>? onData;
  @override
  State<CoolifyLogsPanel> createState() => _CoolifyLogsPanelState();
}

class _CoolifyLogsPanelState extends State<CoolifyLogsPanel>
    with WidgetsBindingObserver {
  final _scroll = ScrollController();
  Timer? _timer;
  String _text = '';
  String? _error;
  bool _revealed = false, _live = true, _follow = true, _busy = false;
  bool _foreground = true;
  bool _fetching = false;
  int _generation = 0;
  String _search = '', _level = 'all';
  int _lineLimit = 200;
  int? _page;

  @override
  void initState() {
    super.initState();
    _text = coolifyLogText(widget.data);
    WidgetsBinding.instance.addObserver(this);
    widget.session.addListener(_clear);
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_revealed && _live) _refresh();
    });
  }

  @override
  void didUpdateWidget(CoolifyLogsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _text = coolifyLogText(widget.data);
      _toBottom();
    }
  }

  void _clear() {
    _generation++;
    if (mounted) {
      setState(() {
        _text = '';
        _error = null;
        _revealed = false;
        _busy = false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground) _clear();
  }

  Future<void> _refresh() async {
    if (_fetching ||
        !_foreground ||
        !widget.session.active ||
        ModalRoute.of(context)?.isCurrent == false) {
      return;
    }
    final generation = _generation;
    _fetching = true;
    setState(() => _busy = true);
    try {
      final result = await widget.session.request(
        'GET',
        widget.path,
        query: {
          ...widget.query,
          if (widget.path.endsWith('/logs')) 'lines': '$_lineLimit',
        },
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _text = coolifyLogText(result);
        _error = null;
      });
      _toBottom();
      widget.onData?.call(result);
    } on CoolifyException catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = error.message;
          _live = false;
        });
      }
    } finally {
      _fetching = false;
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
  }

  void _toBottom() {
    if (!_follow) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _follow && _scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _generation++;
    _timer?.cancel();
    widget.session.removeListener(_clear);
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = _text.isEmpty
        ? <String>[]
        : filterCoolifyLogLines(_text, _search, _level);
    final maxPage = lines.isEmpty ? 0 : (lines.length - 1) ~/ 200;
    final page = _follow || _page == null ? maxPage : _page!.clamp(0, maxPage);
    final output = lines.skip(page * 200).take(200).join('\n');
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xff0b0b12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff353044)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                key: const ValueKey('logs-reveal'),
                onPressed: () {
                  setState(() => _revealed = !_revealed);
                  if (_revealed) {
                    _toBottom();
                    _refresh();
                  } else {
                    _generation++;
                    _busy = false;
                  }
                },
                icon: Icon(_revealed ? Icons.visibility_off : Icons.visibility),
                label: Text(
                  _revealed
                      ? context.l10n.hideCredential
                      : context.l10n.coolifyReveal,
                ),
              ),
              if (_revealed) ...[
                IconButton(
                  key: const ValueKey('logs-live'),
                  tooltip: _live
                      ? context.l10n.logsPause
                      : context.l10n.logsResume,
                  onPressed: () {
                    setState(() => _live = !_live);
                    if (_live) _refresh();
                  },
                  icon: Icon(_live ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  key: const ValueKey('logs-follow'),
                  tooltip: context.l10n.logsFollow,
                  isSelected: _follow,
                  onPressed: () {
                    setState(() => _follow = !_follow);
                    _toBottom();
                  },
                  icon: const Icon(Icons.vertical_align_bottom),
                ),
                IconButton(
                  tooltip: context.l10n.refresh,
                  onPressed: _busy ? null : _refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ],
          ),
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          if (_revealed) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    key: const ValueKey('logs-search'),
                    decoration: InputDecoration(
                      labelText: context.l10n.listSearch,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() {
                      _search = value;
                      _page = null;
                    }),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      DropdownButton<String>(
                        value: _level,
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text(context.l10n.logsLevelAll),
                          ),
                          DropdownMenuItem(
                            value: 'error',
                            child: Text(context.l10n.logsLevelErrors),
                          ),
                          DropdownMenuItem(
                            value: 'warning',
                            child: Text(context.l10n.logsLevelWarnings),
                          ),
                        ],
                        onChanged: (value) => setState(() {
                          _level = value!;
                          _page = null;
                        }),
                      ),
                      if (widget.path.endsWith('/logs'))
                        DropdownButton<int>(
                          value: _lineLimit,
                          hint: Text(context.l10n.logsLineLimit),
                          items: [
                            for (final limit in [200, 500, 1000])
                              DropdownMenuItem(
                                value: limit,
                                child: Text(
                                  '$limit ${context.l10n.logsLineLimit.toLowerCase()}',
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _lineLimit = value!;
                              _page = null;
                            });
                            _refresh();
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (maxPage > 0)
              ActivityPager(
                page: page,
                onPrevious: page > 0
                    ? () => setState(() {
                        _follow = false;
                        _page = page - 1;
                      })
                    : null,
                onNext: page < maxPage
                    ? () => setState(() {
                        _follow = false;
                        _page = page + 1;
                      })
                    : null,
              ),
          ],
          if (_error != null && _revealed)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                localizedMessage(context, _error!),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_revealed)
            SizedBox(
              height: 360,
              child: NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  if (notification.dragDetails != null && _follow) {
                    setState(() => _follow = false);
                  }
                  return false;
                },
                child: Scrollbar(
                  controller: _scroll,
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SelectableText(
                        output.isEmpty
                            ? (_text.isEmpty
                                  ? context.l10n.coolifyEmpty
                                  : context.l10n.listNoMatches)
                            : output,
                        key: const ValueKey('logs-output'),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize:
                              AppPreferencesScope.maybeOf(context)
                                  ?.terminalFontSize ??
                              14,
                          height: 1.45,
                          color: const Color(0xffd8d4e5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
