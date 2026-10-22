import 'package:flutter/material.dart';

import '../../../l10n/localization.dart';
import '../data/docker_command.dart';

String dockerError(BuildContext context, Object error) {
  final strings = context.l10n;
  return switch (error is DockerException
      ? error.failure
      : DockerFailure.failed) {
    DockerFailure.notInstalled => strings.dockerNotInstalled,
    DockerFailure.permission => strings.dockerPermission,
    DockerFailure.unavailable => strings.dockerUnavailable,
    DockerFailure.notFound => strings.dockerGone,
    DockerFailure.invalidResponse => strings.dockerInvalidResponse,
    DockerFailure.tooLarge => strings.dockerTooLarge,
    DockerFailure.timeout => strings.dockerTimeout,
    DockerFailure.disconnected ||
    DockerFailure.cancelled => strings.terminalDisconnected,
    DockerFailure.failed => strings.dockerFailed,
  };
}

String dockerAction(BuildContext context, DockerOperation operation) =>
    switch (operation) {
      DockerOperation.start => context.l10n.coolifyStart,
      DockerOperation.stop => context.l10n.coolifyStop,
      _ => context.l10n.coolifyRestart,
    };

Widget dockerField(BuildContext context, String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      SelectableText(value.isEmpty ? '—' : value),
    ],
  ),
);
