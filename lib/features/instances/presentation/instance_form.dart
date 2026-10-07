import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets.dart';
import '../../connections/data/ssh_identity.dart';
import '../domain/server_instance.dart';

enum SshAuthentication { password, privateKey }

/// A form draft is kept in memory until one encrypted save succeeds.
class InstanceDraft {
  InstanceDraft([ServerInstance? instance])
    : id = instance?.id ?? 'instance-${DateTime.now().microsecondsSinceEpoch}',
      type = instance?.type ?? InstanceType.ssh,
      authentication = instance?.privateKey.isNotEmpty == true
          ? SshAuthentication.privateKey
          : SshAuthentication.password,
      name = TextEditingController(text: instance?.name),
      host = TextEditingController(text: instance?.host),
      port = TextEditingController(text: '${instance?.port ?? 22}'),
      username = TextEditingController(text: instance?.username),
      password = TextEditingController(text: instance?.password),
      privateKey = TextEditingController(text: instance?.privateKey),
      passphrase = TextEditingController(text: instance?.passphrase),
      apiToken = TextEditingController(text: instance?.apiToken);

  final String id;
  InstanceType type;
  SshAuthentication authentication;
  final TextEditingController name, host, port, username;
  final TextEditingController password, privateKey, passphrase, apiToken;

  Future<String?> validateCredentials() async {
    if (type == InstanceType.ssh &&
        authentication == SshAuthentication.privateKey) {
      try {
        final keys = await compute(decodeSshIdentity, (
          privateKey.text,
          passphrase.text,
        ));
        if (keys.isEmpty) return 'A chave privada está vazia.';
      } catch (_) {
        return 'Não foi possível ler a chave privada. Verifique o formato e a frase-passe.';
      }
    }
    return null;
  }

  ServerInstance toInstance() => ServerInstance(
    id: id,
    name: name.text.trim(),
    type: type,
    host: host.text.trim(),
    port: type == InstanceType.ssh
        ? int.parse(port.text.trim())
        : Uri.parse(host.text.trim()).port,
    username: type == InstanceType.ssh ? username.text.trim() : '',
    password:
        type == InstanceType.ssh && authentication == SshAuthentication.password
        ? password.text
        : '',
    privateKey:
        type == InstanceType.ssh &&
            authentication == SshAuthentication.privateKey
        ? privateKey.text.trim()
        : '',
    passphrase:
        type == InstanceType.ssh &&
            authentication == SshAuthentication.privateKey
        ? passphrase.text
        : '',
    apiToken: type == InstanceType.coolify ? apiToken.text.trim() : '',
  );

  void dispose() {
    for (final value in [
      name,
      host,
      port,
      username,
      password,
      privateKey,
      passphrase,
      apiToken,
    ]) {
      value.dispose();
    }
  }
}

class InstanceNameField extends StatelessWidget {
  const InstanceNameField({
    super.key,
    required this.controller,
    this.enabled = true,
  });
  final TextEditingController controller;
  final bool enabled;
  @override
  Widget build(BuildContext context) => TextFormField(
    key: const ValueKey('instance-name'),
    controller: controller,
    enabled: enabled,
    maxLength: 32,
    textInputAction: TextInputAction.next,
    decoration: const InputDecoration(
      labelText: 'Nome da instância',
      hintText: 'ex.: produção-europa',
      prefixIcon: Icon(Icons.tag),
    ),
    validator: (value) => value == null || value.trim().isEmpty
        ? 'Dê um nome à instância.'
        : null,
  );
}

class InstanceConnectionFields extends StatefulWidget {
  const InstanceConnectionFields({
    super.key,
    required this.draft,
    this.enabled = true,
    this.allowTypeChange = true,
  });
  final InstanceDraft draft;
  final bool enabled, allowTypeChange;
  @override
  State<InstanceConnectionFields> createState() =>
      _InstanceConnectionFieldsState();
}

class _InstanceConnectionFieldsState extends State<InstanceConnectionFields> {
  InstanceDraft get draft => widget.draft;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SegmentedButton<InstanceType>(
        segments: [
          for (final type in InstanceType.values)
            ButtonSegment(
              value: type,
              icon: Icon(instanceIcon(type)),
              label: Text(type.label),
            ),
        ],
        selected: {draft.type},
        onSelectionChanged: widget.enabled && widget.allowTypeChange
            ? (types) => setState(() {
                draft.type = types.single;
                draft.host.clear();
                draft.port.text = '${draft.type.defaultPort}';
              })
            : null,
      ),
      const SizedBox(height: 20),
      TextFormField(
        key: const ValueKey('instance-host'),
        controller: draft.host,
        enabled: widget.enabled,
        autocorrect: false,
        enableSuggestions: false,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: draft.type == InstanceType.ssh
              ? 'Hostname ou IP'
              : 'URL do Coolify',
          hintText: draft.type == InstanceType.ssh
              ? 'servidor.exemplo.pt'
              : 'https://coolify.exemplo.pt',
          prefixIcon: const Icon(Icons.language),
        ),
        validator: (value) => ServerInstance.validateHost(value, draft.type),
      ),
      const SizedBox(height: 20),
      if (draft.type == InstanceType.ssh) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                key: const ValueKey('instance-user'),
                controller: draft.username,
                enabled: widget.enabled,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Utilizador'),
                validator: (value) =>
                    !RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(value?.trim() ?? '')
                    ? 'Utilizador inválido.'
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                key: const ValueKey('instance-port'),
                controller: draft.port,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Porta'),
                validator: (value) {
                  final port = int.tryParse(value?.trim() ?? '');
                  return port == null || port < 1 || port > 65535
                      ? '1–65535'
                      : null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<SshAuthentication>(
          key: ValueKey(draft.authentication),
          initialValue: draft.authentication,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Autenticação'),
          items: const [
            DropdownMenuItem(
              value: SshAuthentication.password,
              child: Text('Palavra-passe'),
            ),
            DropdownMenuItem(
              value: SshAuthentication.privateKey,
              child: Text('Chave privada'),
            ),
          ],
          onChanged: widget.enabled
              ? (value) => setState(() => draft.authentication = value!)
              : null,
        ),
        const SizedBox(height: 20),
        if (draft.authentication == SshAuthentication.password)
          SecretField(
            fieldKey: 'instance-password',
            controller: draft.password,
            label: 'Palavra-passe SSH',
            enabled: widget.enabled,
          )
        else ...[
          SecretField(
            fieldKey: 'instance-private-key',
            controller: draft.privateKey,
            label: 'Chave privada PEM / OpenSSH',
            enabled: widget.enabled,
          ),
          const SizedBox(height: 8),
          const Text('Cole a chave completa, incluindo as linhas BEGIN e END.'),
          const SizedBox(height: 16),
          SecretField(
            fieldKey: 'instance-passphrase',
            controller: draft.passphrase,
            label: 'Frase-passe da chave (opcional)',
            enabled: widget.enabled,
            requiredValue: false,
          ),
        ],
      ] else ...[
        SecretField(
          fieldKey: 'instance-token',
          controller: draft.apiToken,
          label: 'Token da API Coolify',
          enabled: widget.enabled,
        ),
        const SizedBox(height: 12),
        const Text(
          'No Coolify, ative a API e crie um token com permissão de leitura em Keys & Tokens → API tokens. Use a URL base, sem /api/v1.',
        ),
      ],
      const SizedBox(height: 20),
      const SurfaceCard(
        padding: EdgeInsets.all(14),
        child: Text(
          'Configuração e credenciais cifradas neste dispositivo. A ligação é feita diretamente ao seu servidor, sem conta Capidock.',
        ),
      ),
    ],
  );
}

class SecretField extends StatefulWidget {
  const SecretField({
    super.key,
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.enabled,
    this.requiredValue = true,
  });
  final String fieldKey, label;
  final TextEditingController controller;
  final bool enabled, requiredValue;
  @override
  State<SecretField> createState() => _SecretFieldState();
}

class _SecretFieldState extends State<SecretField> {
  bool _hidden = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    key: ValueKey(widget.fieldKey),
    controller: widget.controller,
    enabled: widget.enabled,
    obscureText: _hidden,
    autocorrect: false,
    enableSuggestions: false,
    keyboardType: TextInputType.multiline,
    decoration: InputDecoration(
      labelText: widget.label,
      suffixIcon: IconButton(
        tooltip: _hidden ? 'Mostrar credencial' : 'Ocultar credencial',
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
    ),
    validator: (value) =>
        widget.requiredValue && (value == null || value.trim().isEmpty)
        ? 'Informe a credencial.'
        : null,
  );
}
