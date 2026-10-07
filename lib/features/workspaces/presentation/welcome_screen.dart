import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../../../core/widgets.dart';
import '../../instances/presentation/instance_form.dart';
import '../domain/dock_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.controller,
    required this.onAbout,
  });
  final DockController controller;
  final VoidCallback onAbout;
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _form = GlobalKey<FormState>();
  final _workspace = TextEditingController();
  final _draft = InstanceDraft();
  final _scroll = ScrollController();
  int _step = 0;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _workspace.dispose();
    _draft.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _go(int step) {
    FocusScope.of(context).unfocus();
    setState(() {
      _step = step;
      _error = null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _next() async {
    if (!_form.currentState!.validate()) return;
    if (_step < 2) {
      _go(_step + 1);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await _draft.validateCredentials();
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _error = error;
        _saving = false;
      });
      return;
    }
    try {
      await widget.controller.createFirstWorkspace(
        _workspace.text,
        _draft.toInstance(),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Não foi possível guardar no armazenamento seguro. Os campos foram preservados; tente novamente.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving && _step == 0,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop && !_saving && _step > 0) _go(_step - 1);
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Capidock'),
        actions: [
          IconButton(
            onPressed: widget.onAbout,
            tooltip: 'Sobre o Capidock',
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: DockLogo(size: 72),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _step == 0
                        ? 'Os seus servidores.\nO seu dock.'
                        : _step == 1
                        ? 'Dê lugar ao seu\nprimeiro servidor.'
                        : 'Como vamos\nligar-nos?',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _step == 0
                        ? 'Bem-vindo ao Capidock. Crie um workspace para reunir as instâncias dos seus projetos.'
                        : _step == 1
                        ? 'Cada instância é um canal dentro de “${_workspace.text.trim()}”. Comece pela primeira.'
                        : 'Configure o acesso a “${_draft.name.text.trim()}”. Pode editar estes dados mais tarde.',
                    style: const TextStyle(color: DockColors.muted),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'PASSO ${_step + 1} DE 3 · ${['WORKSPACE', 'INSTÂNCIA', 'LIGAÇÃO'][_step]}',
                    style: const TextStyle(
                      color: DockColors.purple,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_step + 1) / 3,
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _form,
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: switch (_step) {
                        0 => TextFormField(
                          key: const ValueKey('onboarding-workspace'),
                          controller: _workspace,
                          enabled: !_saving,
                          maxLength: 40,
                          decoration: const InputDecoration(
                            labelText: 'Nome do workspace',
                            hintText: 'ex.: Pessoal, Empresa ou Projeto',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Dê um nome ao workspace.'
                              : null,
                        ),
                        1 => InstanceNameField(
                          controller: _draft.name,
                          enabled: !_saving,
                        ),
                        _ => InstanceConnectionFields(
                          draft: _draft,
                          enabled: !_saving,
                        ),
                      },
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const ValueKey('onboarding-next'),
                    onPressed: _saving ? null : _next,
                    icon: Icon(
                      _step == 2 ? Icons.lock_outline : Icons.arrow_forward,
                    ),
                    label: Text(
                      _saving
                          ? 'A guardar…'
                          : [
                              'Criar workspace',
                              'Configurar ligação',
                              'Criar e abrir instância',
                            ][_step],
                    ),
                  ),
                  if (_step > 0)
                    TextButton(
                      onPressed: _saving ? null : () => _go(_step - 1),
                      child: const Text('Voltar'),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    'Local por escolha. Sem conta, sem sincronização.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: DockColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
