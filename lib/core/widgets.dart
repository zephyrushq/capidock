import 'package:flutter/material.dart';

import '../features/instances/domain/server_instance.dart';
import 'app_theme.dart';

class DockLogo extends StatelessWidget {
  const DockLogo({super.key, this.size = 42});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: DockColors.primary,
      borderRadius: BorderRadius.circular(size * .3),
      boxShadow: const [
        BoxShadow(
          color: Color(0x228B5CF6),
          blurRadius: 18,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Image.asset(
      'assets/branding/capidock-mark.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).ceil(),
      semanticLabel: 'Capidock',
    ),
  );
}

IconData instanceIcon(InstanceType type) =>
    type == InstanceType.ssh ? Icons.terminal_rounded : Icons.layers_rounded;

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: DockColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: DockColors.border),
    ),
    child: child,
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(
    this.label, {
    super.key,
    this.color = DockColors.green,
    this.dot = true,
  });
  final String label;
  final Color color;
  final bool dot;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: .18)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dot) ...[
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        ?trailing,
      ],
    ),
  );
}

class EmptyWorkspace extends StatelessWidget {
  const EmptyWorkspace({super.key, required this.onAdd, this.workspaceName});
  final String? workspaceName;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DockLogo(size: 72),
          const SizedBox(height: 28),
          Text(
            workspaceName == null
                ? 'Um espaço para\ncada projeto.'
                : 'O seu próximo servidor\ncomeça aqui.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            workspaceName == null
                ? 'Crie um workspace para organizar as suas instâncias SSH e Coolify.'
                : 'Adicione uma instância SSH ou Coolify ao workspace “$workspaceName”.',
            textAlign: TextAlign.center,
            style: TextStyle(color: DockColors.muted),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(
              workspaceName == null ? 'Criar workspace' : 'Adicionar instância',
            ),
          ),
        ],
      ),
    ),
  );
}
