import 'package:flutter/material.dart';

import '../../../l10n/localization.dart';
import '../../instances/domain/server_instance.dart';

Future<bool> confirmSshHostKey(
  BuildContext context,
  ServerInstance instance,
  String type,
  String fingerprint,
  String? previous,
) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            previous == null
                ? context.l10n.confirmSshServer
                : context.l10n.serverKeyChanged,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${instance.host}:${instance.port}\n\n${previous == null ? context.l10n.compareFingerprint : context.l10n.changedKeyWarning}',
                ),
                const SizedBox(height: 16),
                Text(type),
                const SizedBox(height: 8),
                SelectableText(fingerprint),
                if (previous != null) ...[
                  const SizedBox(height: 16),
                  Text(context.l10n.savedKey),
                  SelectableText(previous),
                ],
                const SizedBox(height: 16),
                Text(context.l10n.verifyKeyCommand),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                previous == null
                    ? context.l10n.trustAndConnect
                    : context.l10n.replaceKey,
              ),
            ),
          ],
        ),
      ) ??
      false;
}
