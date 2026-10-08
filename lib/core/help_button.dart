import 'package:flutter/material.dart';

import '../l10n/localization.dart';

class HelpButton extends StatelessWidget {
  const HelpButton({super.key, required this.message, this.title});
  final String message;
  final String? title;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: title ?? context.l10n.help,
    icon: const Icon(Icons.help_outline, size: 20),
    onPressed: () => showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title ?? context.l10n.help,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
            ),
          ],
        ),
      ),
    ),
  );
}
