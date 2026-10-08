import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';

import '../../core/security/security_controls.dart';
import '../../l10n/localization.dart';
import '../connections/data/ssh_connection.dart';
import 'sftp_browser.dart';
import 'sftp_documents.dart';

class SftpPanel extends StatefulWidget {
  const SftpPanel({
    super.key,
    required this.connection,
    required this.connect,
    this.documents = const AndroidSftpDocuments(),
    this.createBrowser,
  });
  final SshConnection connection;
  final Future<void> Function() connect;
  final SftpDocuments documents;
  final Future<SftpBrowser> Function()? createBrowser;
  @override
  State<SftpPanel> createState() => _SftpPanelState();
}

class _SftpPanelState extends State<SftpPanel> {
  SftpBrowser? _browser;
  List<SftpName> _entries = [];
  String? _path, _error;
  String _search = '';
  bool _busy = false, _picking = false, _dialog = false;
  int _generation = 0, _page = 0;
  double? _progress;
  bool get _connected => widget.connection.status == ConnectionStatus.connected;
  bool _active(int generation) =>
      mounted && generation == _generation && _connected;
  @override
  void initState() {
    super.initState();
    widget.connection.addListener(_connectionChanged);
    if (_connected) _load();
  }

  void _connectionChanged() {
    if (!_connected &&
        widget.connection.status != ConnectionStatus.connecting) {
      _generation++;
      _browser?.close();
      _browser = null;
      if (mounted) {
        setState(() {
          _entries = [];

          _progress = null;
        });
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _generation++;
    widget.connection.removeListener(_connectionChanged);
    _browser?.close();
    super.dispose();
  }

  Future<SftpBrowser> _ready() async {
    if (!_connected) await widget.connect();
    if (!mounted || !_connected) throw StateError('Disconnected');
    if (_browser != null && !_browser!.isClosed) return _browser!;
    final generation = _generation;
    final browser =
        await (widget.createBrowser?.call() ??
            widget.connection.openSftp().then(SftpBrowser.new));
    if (!_active(generation)) {
      browser.close();
      throw StateError('Disconnected');
    }
    _browser = browser;
    return browser;
  }

  Future<void> _load([String? path]) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final browser = await _ready();
      final generation = _generation;
      final destination = path ?? _path ?? await browser.home();
      final entries = await browser.list(destination);
      if (_active(generation)) {
        setState(() {
          _path = destination;
          _entries = entries;
          _page = 0;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = sftpError(e));
    } finally {
      if (mounted && !_picking) setState(() => _busy = false);
    }
  }

  Future<T?> _modal<T>(WidgetBuilder builder) async {
    setState(() => _dialog = true);
    try {
      return await showDialog<T>(context: context, builder: builder);
    } finally {
      if (mounted) setState(() => _dialog = false);
    }
  }

  Future<bool> _confirm(String title, String path) async =>
      await _modal<bool>(
        (context) => AlertDialog(
          title: Text(title),
          content: Text(path),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.sftpConfirm),
            ),
          ],
        ),
      ) ??
      false;
  Future<String?> _name(String title, [String initial = '']) async {
    final value = TextEditingController(text: initial);
    final key = GlobalKey<FormState>();
    try {
      return await _modal<String>(
        (context) => AlertDialog(
          title: Text(title),
          content: Form(
            key: key,
            child: TextFormField(
              controller: value,
              autofocus: true,
              maxLength: 255,
              validator: (text) {
                try {
                  sftpName(text ?? '');
                  return null;
                } catch (_) {
                  return context.l10n.sftpInvalidName;
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => key.currentState!.validate()
                  ? Navigator.pop(context, value.text)
                  : null,
              child: Text(context.l10n.sftpConfirm),
            ),
          ],
        ),
      );
    } finally {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      value.dispose();
    }
  }

  Future<void> _operation(Future<void> Function(SftpBrowser) action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _progress = null;
    });
    final generation = _generation;
    try {
      final browser = await _ready();
      if (_active(generation)) {
        await action(browser);
        if (_active(generation)) await _load();
      }
    } catch (e) {
      if (mounted) setState(() => _error = sftpError(e));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  void _updateProgress(int count, int total) {
    if (mounted && _connected && !_picking) {
      setState(() => _progress = total == 0 ? 1 : (count / total).clamp(0, 1));
    }
  }

  Future<void> _upload() async {
    final controls = SecurityControls.maybeOf(context);
    if (_busy || controls?.documentAction == null || _path == null) return;
    final path = _path!;
    setState(() {
      _busy = true;
      _picking = true;
      _error = null;
    });
    SftpDocument? document;
    try {
      // The normal SSH lifecycle closes the transport while SAF is visible.
      // Fresh OS authentication is handled by the protected document action.
      document = await controls!.documentAction!(
        context.l10n.sftpFiles,
        widget.documents.open,
      );
      if (!mounted || document == null) return;
      _picking = false;
      final destination = sftpJoin(path, document.name);
      final browser = await _ready();
      final attrs = await browser.stat(destination);
      if (!mounted || !_connected) return;
      if (!await _confirm(
            attrs == null ? context.l10n.sftpUpload : context.l10n.sftpReplace,
            destination,
          ) ||
          !mounted ||
          !_connected) {
        return;
      }
      final generation = _generation;
      await browser.upload(
        destination,
        document.bytes,
        overwrite: attrs != null,
        progress: (n) => _updateProgress(n, document!.bytes.length),
      );
      if (_active(generation)) await _load(path);
    } catch (e) {
      if (mounted) setState(() => _error = sftpError(e));
    } finally {
      document?.bytes.fillRange(0, document.bytes.length, 0);
      if (mounted) {
        setState(() {
          _busy = false;
          _picking = false;
          _progress = null;
        });
      }
    }
  }

  Future<void> _download(SftpName entry) async {
    final controls = SecurityControls.maybeOf(context);
    if (controls?.documentAction == null) return;
    await _operation((browser) async {
      final bytes = await browser.read(
        sftpJoin(_path!, entry.filename),
        progress: (n) => _updateProgress(n, entry.attr.size ?? n),
      );
      try {
        if (!mounted || !_connected) return;
        _picking = true;
        await controls!.documentAction!<bool>(
          context.l10n.sftpFiles,
          () => widget.documents.save(entry.filename, bytes),
        );
      } finally {
        bytes.fillRange(0, bytes.length, 0);
        _picking = false;
      }
    });
  }

  Future<void> _edit(SftpName entry) async {
    await _operation((browser) async {
      final path = sftpJoin(_path!, entry.filename);
      final bytes = await browser.read(path, limit: sftpEditorLimit);
      final text = TextEditingController();
      Uint8List? edited;
      try {
        text.text = sftpDecodeText(bytes);
        if (!mounted || !_connected) return;
        edited = await _modal<Uint8List>(
          (context) => AlertDialog(
            title: Text(entry.filename),
            content: SizedBox(
              width: double.maxFinite,
              height:
                  ((MediaQuery.sizeOf(context).height -
                              MediaQuery.viewInsetsOf(context).vertical) *
                          .45)
                      .clamp(80, 350),
              child: TextField(
                controller: text,
                maxLines: null,
                expands: true,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                autocorrect: false,
                enableSuggestions: false,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  Uint8List.fromList(utf8.encode(text.text)),
                ),
                child: Text(context.l10n.save),
              ),
            ],
          ),
        );
        if (!mounted || !_connected || edited == null) return;
        if (edited.length > sftpEditorLimit) {
          throw const FormatException('sftpTooLarge');
        }
        if (!await _confirm(context.l10n.sftpReplace, path) ||
            !mounted ||
            !_connected) {
          return;
        }
        await browser.upload(path, edited, overwrite: true, original: bytes);
      } finally {
        bytes.fillRange(0, bytes.length, 0);
        edited?.fillRange(0, edited.length, 0);
        text.clear();
        await Future<void>.delayed(const Duration(milliseconds: 250));
        text.dispose();
      }
    });
  }

  Future<void> _entryAction(String action, SftpName entry) async {
    final path = sftpJoin(_path!, entry.filename);
    if (action == 'download') {
      await _download(entry);
      return;
    }
    if (action == 'edit') {
      await _edit(entry);
      return;
    }
    if (action == 'rename') {
      final name = await _name(context.l10n.sftpRename, entry.filename);
      if (!mounted || name == null || name == entry.filename) return;
      final destination = sftpJoin(_path!, name);
      if (!await _confirm(context.l10n.sftpRename, '$path → $destination') ||
          !mounted) {
        return;
      }
      await _operation((b) => b.rename(path, destination));
    } else if (await _confirm(context.l10n.remove, path) && mounted) {
      await _operation((b) => b.delete(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _entries
        .where((e) => e.filename.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    final pages = (filtered.length / 50).ceil();
    final page = _page.clamp(0, pages == 0 ? 0 : pages - 1);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _path ?? context.l10n.sftpFiles,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(context.l10n.sftpFiles),
                        content: Text(context.l10n.sftpHelp),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(context.l10n.cancel),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.help_outline),
                  ),
                ],
              ),
              if (_busy && !_dialog && !_picking)
                LinearProgressIndicator(value: _progress),
              if (_error != null)
                Text(
                  localizedMessage(context, _error!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed:
                        _busy || !_connected || _path == null || _path == '/'
                        ? null
                        : () => _load(sftpParent(_path!)),
                    tooltip: context.l10n.sftpParent,
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  IconButton(
                    onPressed: _busy ? null : _load,
                    tooltip: _connected
                        ? context.l10n.refresh
                        : context.l10n.connectInstance,
                    icon: Icon(_connected ? Icons.refresh : Icons.link),
                  ),
                  IconButton(
                    onPressed: _busy || !_connected
                        ? null
                        : () async {
                            final name = await _name(
                              context.l10n.sftpNewFolder,
                            );
                            if (mounted && name != null) {
                              await _operation(
                                (b) => b.createFolder(sftpJoin(_path!, name)),
                              );
                            }
                          },
                    tooltip: context.l10n.sftpNewFolder,
                    icon: const Icon(Icons.create_new_folder_outlined),
                  ),
                  IconButton(
                    onPressed:
                        _busy ||
                            !_connected ||
                            SecurityControls.maybeOf(context)?.documentAction ==
                                null
                        ? null
                        : _upload,
                    tooltip: context.l10n.sftpUpload,
                    icon: const Icon(Icons.upload_file),
                  ),
                  IconButton(
                    onPressed: _connected ? widget.connection.disconnect : null,
                    tooltip: context.l10n.disconnect,
                    icon: const Icon(Icons.link_off),
                  ),
                ],
              ),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: context.l10n.coolifySearch,
                ),
                onChanged: (value) => setState(() {
                  _search = value;
                  _page = 0;
                }),
              ),
              if (pages > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _busy || page == 0
                          ? null
                          : () => setState(() => _page = page - 1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('${page + 1} / $pages'),
                    IconButton(
                      onPressed: _busy || page >= pages - 1
                          ? null
                          : () => setState(() => _page = page + 1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
            ],
          ),
        ),
        Expanded(
          child: !_connected && !_busy
              ? Center(child: Text(context.l10n.notConnected))
              : filtered.isEmpty && !_busy
              ? Center(child: Text(context.l10n.sftpEmpty))
              : ListView.builder(
                  itemCount: filtered.skip(page * 50).take(50).length,
                  itemBuilder: (context, index) {
                    final entry = filtered[page * 50 + index];
                    final dir = entry.attr.isDirectory;
                    return ListTile(
                      leading: Icon(
                        dir
                            ? Icons.folder_outlined
                            : entry.attr.isSymbolicLink
                            ? Icons.link
                            : Icons.description_outlined,
                      ),
                      title: Text(
                        entry.filename,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(dir ? '' : '${entry.attr.size ?? '—'} B'),
                      onTap: _busy || !dir
                          ? null
                          : () => _load(sftpJoin(_path!, entry.filename)),
                      trailing: PopupMenuButton<String>(
                        enabled: !_busy && _connected,
                        onSelected: (a) => _entryAction(a, entry),
                        itemBuilder: (_) => [
                          if (entry.attr.isFile) ...[
                            PopupMenuItem(
                              value: 'download',
                              child: Text(context.l10n.sftpDownload),
                            ),
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(context.l10n.sftpEditText),
                            ),
                          ],
                          PopupMenuItem(
                            value: 'rename',
                            child: Text(context.l10n.sftpRename),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(context.l10n.remove),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
