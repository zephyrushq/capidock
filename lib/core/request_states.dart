import 'package:flutter/material.dart';

import '../l10n/localization.dart';

/// Static placeholders respect reduced-motion preferences and do not announce
/// decorative bars as content to screen readers.
class LoadingCards extends StatelessWidget {
  const LoadingCards({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.connecting,
    liveRegion: true,
    child: ExcludeSemantics(
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 10,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class RequestFailure extends StatelessWidget {
  const RequestFailure({
    super.key,
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Icon(Icons.error_outline),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(localizedMessage(context, message)),
          ),
        ),
        IconButton(
          onPressed: onRetry,
          tooltip: context.l10n.retry,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
  );
}
