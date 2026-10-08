import 'package:flutter/material.dart';

import '../../../core/help_button.dart';
import '../../../core/security/security_controls.dart';
import '../../../l10n/localization.dart';
import '../../workspaces/domain/dock_controller.dart';
import '../data/backup_files.dart';
import '../data/encrypted_backup.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({
    super.key,
    required this.controller,
    this.files = const AndroidBackupFiles(),
  });
  final DockController controller;
  final BackupFiles files;
  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _busy = false;
  bool _processing = false;
  String? _error, _success;

  Future<String?> _password(bool exporting) => showDialog<String>(
    context: context,
    builder: (_) => _BackupPasswordDialog(exporting: exporting),
  );

  Future<void> _run(bool exporting) async {
    if (_busy || widget.controller.isSaving || widget.controller.isLoading) {
      return;
    }
    final controls = SecurityControls.maybeOf(context);
    if (controls?.reauthenticate == null || controls?.documentAction == null) {
      return;
    }
    final reason = context.l10n.backupAuthReason;
    setState(() {
      _busy = true;
      _error = null;
      _success = null;
    });
    try {
      if (exporting) {
        final password = await _password(true);
        if (!mounted ||
            password == null ||
            !await controls!.reauthenticate!(reason) ||
            !mounted) {
          return;
        }
        setState(() => _processing = true);
        final bytes = await EncryptedBackup.export(
          widget.controller.workspaces,
          password,
        );
        if (!mounted) return;
        final saved = await controls.documentAction!<bool>(
          reason,
          () => widget.files.save(bytes),
        );
        if (mounted && saved == true) {
          setState(() => _success = context.l10n.backupExported);
        }
      } else {
        final bytes = await controls!.documentAction!(
          reason,
          widget.files.open,
        );
        if (!mounted || bytes == null) return;
        final password = await _password(false);
        if (!mounted || password == null) return;
        setState(() => _processing = true);
        final imported = await EncryptedBackup.import(bytes, password);
        if (!mounted) return;
        setState(() => _processing = false);
        final count = imported.fold<int>(
          0,
          (sum, workspace) => sum + workspace.instances.length,
        );
        final accepted = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.backupImport),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.localCounts(imported.length, count)),
                    const SizedBox(height: 12),
                    for (final workspace in imported)
                      Text('• ${workspace.name}'),
                    const SizedBox(height: 16),
                    Text(context.l10n.backupImportWarning),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: imported.isEmpty
                    ? null
                    : () => Navigator.pop(context, true),
                child: Text(context.l10n.backupImport),
              ),
            ],
          ),
        );
        if (!mounted ||
            accepted != true ||
            !await controls.reauthenticate!(reason) ||
            !mounted) {
          return;
        }
        setState(() => _processing = true);
        await widget.controller.importWorkspaces(imported);
        if (mounted) setState(() => _success = context.l10n.backupImported);
      }
    } on BackupException catch (error) {
      if (mounted) {
        setState(() => _error = localizedMessage(context, error.code));
      }
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.backupFailed);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _processing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controls = SecurityControls.maybeOf(context);
    final available =
        controls?.reauthenticate != null &&
        controls?.documentAction != null &&
        !widget.controller.isLoading &&
        !widget.controller.isSaving &&
        widget.controller.loadError == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.backupTitle),
        actions: [HelpButton(message: context.l10n.backupHelp)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(context.l10n.backupEncrypted),
            subtitle: Text(context.l10n.backupContents),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const ValueKey('backup-export'),
            onPressed:
                available && !_busy && widget.controller.workspaces.isNotEmpty
                ? () => _run(true)
                : null,
            icon: const Icon(Icons.file_upload_outlined),
            label: Text(context.l10n.backupExport),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const ValueKey('backup-import'),
            onPressed: available && !_busy ? () => _run(false) : null,
            icon: const Icon(Icons.file_download_outlined),
            label: Text(context.l10n.backupImport),
          ),
          if (_processing)
            const Padding(
              padding: EdgeInsets.all(20),
              child: LinearProgressIndicator(),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_success != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(_success!),
            ),
        ],
      ),
    );
  }
}

class _BackupPasswordDialog extends StatefulWidget {
  const _BackupPasswordDialog({required this.exporting});
  final bool exporting;
  @override
  State<_BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<_BackupPasswordDialog> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController(), _confirm = TextEditingController();
  bool _visible = false;
  @override
  void dispose() {
    _password.clear();
    _confirm.clear();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.backupPassword),
    content: Form(
      key: _form,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _password,
              key: const ValueKey('backup-password'),
              obscureText: !_visible,
              autocorrect: false,
              enableSuggestions: false,
              maxLength: 1024,
              decoration: InputDecoration(
                labelText: context.l10n.backupPassword,
                counterText: '',
                suffixIcon: IconButton(
                  tooltip: context.l10n.coolifyReveal,
                  onPressed: () => setState(() => _visible = !_visible),
                  icon: Icon(
                    _visible ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) =>
                  (value?.isEmpty ?? true) ||
                      (widget.exporting && value!.runes.length < 12)
                  ? context.l10n.backupPasswordWeak
                  : null,
            ),
            if (widget.exporting)
              TextFormField(
                controller: _confirm,
                key: const ValueKey('backup-password-confirm'),
                obscureText: !_visible,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 1024,
                decoration: InputDecoration(
                  labelText: context.l10n.backupConfirmPassword,
                  counterText: '',
                ),
                validator: (value) => value != _password.text
                    ? context.l10n.backupPasswordMismatch
                    : null,
              ),
            if (widget.exporting)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(context.l10n.backupPasswordHelp),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) {
            Navigator.pop(context, _password.text);
          }
        },
        child: Text(
          widget.exporting
              ? context.l10n.backupExport
              : context.l10n.backupImport,
        ),
      ),
    ],
  );
}
