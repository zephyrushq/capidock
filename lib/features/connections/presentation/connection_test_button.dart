import 'package:flutter/material.dart';

import '../../../core/help_button.dart';
import '../../../l10n/localization.dart';
import '../../instances/domain/server_instance.dart';
import '../../instances/presentation/instance_form.dart';
import '../data/coolify_client.dart';
import '../data/host_key_store.dart';
import '../data/ssh_connection.dart';
import 'host_key_dialog.dart';

class ConnectionTestButton extends StatefulWidget {
  const ConnectionTestButton({
    super.key,
    required this.draft,
    required this.enabled,
  });
  final InstanceDraft draft;
  final bool enabled;
  @override
  State<ConnectionTestButton> createState() => _ConnectionTestButtonState();
}

class _ConnectionTestButtonState extends State<ConnectionTestButton>
    with WidgetsBindingObserver {
  bool _busy = false;
  String? _result;
  SshConnection? _ssh;
  CoolifyClient? _api;
  int _generation = 0;
  List<TextEditingController> get _fields => [
    widget.draft.host,
    widget.draft.port,
    widget.draft.username,
    widget.draft.password,
    widget.draft.privateKey,
    widget.draft.passphrase,
    widget.draft.apiToken,
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    for (final field in _fields) {
      field.addListener(_cancel);
    }
  }

  void _cancel() {
    _generation++;
    _ssh?.dispose();
    _ssh = null;
    _api?.close();
    _api = null;
    if (mounted) {
      setState(() {
        _busy = false;
        _result = null;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ([
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.detached,
    ].contains(state)) {
      _cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final field in _fields) {
      field.removeListener(_cancel);
    }
    _generation++;
    _ssh?.dispose();
    _api?.close();
    super.dispose();
  }

  Future<void> _test() async {
    if (_busy || !widget.enabled || Form.of(context).validate() != true) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _result = null;
    });
    try {
      final error = await widget.draft.validateCredentials();
      if (!mounted || generation != _generation) return;
      if (error != null) {
        setState(() => _result = error);
        return;
      }
      final instance = widget.draft.toInstance();
      if (instance.type == InstanceType.coolify) {
        final api = _api = CoolifyClient();
        // /resources requires read, and actually validates API token authentication.
        await api.resources(instance);
      } else {
        final ssh = _ssh = SshConnection(
          instance,
          hostKeys: HostKeyStore(persist: false),
        );
        await ssh.connect((type, fingerprint, previous) async {
          if (!mounted || generation != _generation) return false;
          return confirmSshHostKey(
            context,
            instance,
            type,
            fingerprint,
            previous,
          );
        }, openShell: false);
        if (!mounted || generation != _generation) return;
        if (ssh.status != ConnectionStatus.connected) {
          setState(() => _result = ssh.error ?? 'coolifyCancelled');
          return;
        }
      }
      if (mounted && generation == _generation) {
        setState(() => _result = 'connectionVerified');
      }
    } on CoolifyException catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _result = error.message);
      }
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _result = 'invalidApiResponse');
      }
    } finally {
      if (generation == _generation) {
        _api?.close();
        _api = null;
        _ssh?.dispose();
        _ssh = null;
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              key: const ValueKey('test-connection'),
              onPressed: _busy || !widget.enabled ? null : _test,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.network_check),
              label: Text(context.l10n.testConnection),
            ),
          ),
          HelpButton(message: context.l10n.connectionTestHelp),
        ],
      ),
      if (_result != null)
        Text(
          _result == 'connectionVerified'
              ? context.l10n.connectionVerified
              : localizedMessage(context, _result!),
          style: TextStyle(
            color: _result == 'connectionVerified'
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        ),
    ],
  );
}
