import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/help_button.dart';
import '../../core/security/security_controls.dart';
import '../../l10n/language_selector.dart';
import '../../l10n/localization.dart';
import '../legal/legal_page.dart';
import '../workspaces/data/secret_store.dart';
import '../workspaces/domain/dock_controller.dart';
import 'app_preferences.dart';
import '../monitoring/monitor_page.dart';
import '../backups/presentation/backup_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.controller,
    this.secrets = const AndroidSecretStore(),
  });
  final DockController controller;
  final SecretStore secrets;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _version;
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform()
        .then((info) {
          if (mounted) {
            setState(() => _version = '${info.version}+${info.buildNumber}');
          }
        })
        .catchError((Object _) {});
  }

  Future<void> _erase() async {
    final controls = SecurityControls.maybeOf(context);
    if (controls == null) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.eraseLocalData),
        content: Text(context.l10n.eraseLocalWarning),
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
    if (accepted == true && mounted) {
      await controls.clearData(context.l10n.eraseAuthReason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = AppPreferencesScope.maybeOf(context);
    final controls = SecurityControls.maybeOf(context);
    final count = widget.controller.workspaces.fold<int>(
      0,
      (sum, workspace) => sum + workspace.instances.length,
    );
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appSettings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(context.l10n.language),
            trailing: const LanguageSelector(compact: true),
          ),
          if (preferences != null)
            ListTile(
              title: Text(context.l10n.terminalFontSize),
              trailing: DropdownButton<double>(
                value: preferences.terminalFontSize,
                items: [
                  for (final size in AppPreferences.sizes)
                    DropdownMenuItem(
                      value: size,
                      child: Text('${size.toInt()}'),
                    ),
                ],
                onChanged: preferences.saving
                    ? null
                    : (value) async {
                        try {
                          await preferences.setTerminalFontSize(value!);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.l10n.saveError)),
                            );
                          }
                        }
                      },
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.monitor_heart_outlined),
            title: Text(context.l10n.monitorTitle),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => MonitorPage(controller: widget.controller),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(context.l10n.lockNow),
            onTap: controls?.lock,
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: Text(context.l10n.trustedSshKeys),
            trailing: HelpButton(message: context.l10n.trustedSshHelp),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => TrustedKeysPage(secrets: widget.secrets),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(context.l10n.localStorage),
            subtitle: Text(
              context.l10n.localCounts(
                widget.controller.workspaces.length,
                count,
              ),
            ),
            trailing: HelpButton(message: context.l10n.localCredentials),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(context.l10n.eraseLocalData),
            onTap: controls == null ? null : _erase,
          ),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(context.l10n.backupTitle),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => BackupPage(controller: widget.controller),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Capidock'),
            subtitle: Text(_version ?? '—'),
            trailing: const Icon(Icons.info_outline),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Capidock',
              applicationVersion: _version,
              applicationLegalese:
                  '© 2026 ZEPHYRUS PROSPERITY - UNIPESSOAL LDA',
              children: [
                Text(context.l10n.aboutLicence),
                const SizedBox(height: 12),
                SelectableText(context.l10n.sourceCode),
              ],
            ),
          ),
          const LegalLinks(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: SelectableText(
              'legal@zephyrushq.com',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class TrustedKeysPage extends StatefulWidget {
  const TrustedKeysPage({super.key, required this.secrets});
  final SecretStore secrets;
  @override
  State<TrustedKeysPage> createState() => _TrustedKeysPageState();
}

class _TrustedKeysPageState extends State<TrustedKeysPage> {
  Map<String, Map<String, dynamic>>? _keys;
  bool _busy = false, _failed = false;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final all = await widget.secrets.readAll();
      final keys = <String, Map<String, dynamic>>{};
      for (final entry in all.entries.where(
        (entry) => entry.key.startsWith('capidock.host-key.'),
      )) {
        final data = jsonDecode(entry.value);
        if (data is! Map<String, dynamic> ||
            data['host'] is! String ||
            data['fingerprint'] is! String ||
            data['type'] is! String ||
            data['port'] is! int) {
          throw const FormatException();
        }
        keys[entry.key] = data;
      }
      if (mounted && generation == _generation) setState(() => _keys = keys);
    } catch (_) {
      if (mounted && generation == _generation) setState(() => _failed = true);
    } finally {
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
  }

  Future<void> _remove(String key) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.remove),
        content: Text(context.l10n.forgetSshWarning),
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
    if (accepted != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.secrets.delete(key);
      if (await widget.secrets.read(key) != null) {
        throw StateError('Deletion failed');
      }
      if (mounted) await _load();
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _failed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.trustedSshKeys),
      actions: [HelpButton(message: context.l10n.trustedSshHelp)],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_busy) const LinearProgressIndicator(),
        if (_failed)
          ListTile(
            title: Text(context.l10n.loadWorkspacesError),
            trailing: IconButton(
              onPressed: _busy ? null : _load,
              tooltip: context.l10n.retry,
              icon: const Icon(Icons.refresh),
            ),
          ),
        if (!_busy && !_failed && _keys?.isEmpty == true)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(context.l10n.noTrustedKeys),
            ),
          ),
        for (final entry
            in _keys?.entries ?? <MapEntry<String, Map<String, dynamic>>>[])
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${entry.value['host']}:${entry.value['port']}',
                        ),
                      ),
                      IconButton(
                        onPressed: _busy ? null : () => _remove(entry.key),
                        tooltip: context.l10n.remove,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  Text('${entry.value['type']}'),
                  const SizedBox(height: 8),
                  SelectableText(
                    '${entry.value['fingerprint']}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
