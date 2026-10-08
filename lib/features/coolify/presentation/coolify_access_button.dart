import 'package:flutter/material.dart';

import '../../../l10n/localization.dart';
import '../data/coolify_access.dart';

class CoolifyAccessButton extends StatelessWidget {
  const CoolifyAccessButton({super.key, required this.access});
  final CoolifyAccess access;
  @override
  Widget build(BuildContext context) => TextButton.icon(
    icon: const Icon(Icons.shield_outlined, size: 20),
    label: Text(context.l10n.tokenAccess),
    onPressed: () => showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => ListenableBuilder(
        listenable: access,
        builder: (context, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.tokenAccess,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(context.l10n.tokenAccessHelp),
              for (final scope in CoolifyAccess.scopes)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Text(scope),
                      Text(switch (access.evidence(scope)) {
                        AccessEvidence.unknown => context.l10n.accessUnknown,
                        AccessEvidence.available => context.l10n.accessObserved,
                        AccessEvidence.denied => context.l10n.accessDenied,
                      }),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
