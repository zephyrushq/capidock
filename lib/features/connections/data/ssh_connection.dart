import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:xterm/xterm.dart';

import '../../instances/domain/server_instance.dart';
import 'host_key_store.dart';
import 'ssh_identity.dart';
import 'ssh_security_policy.dart';

enum ConnectionStatus { disconnected, connecting, connected, failed }

class SshConnection extends ChangeNotifier {
  SshConnection(this.instance, {HostKeyStore? hostKeys})
    : _hostKeys = hostKeys ?? HostKeyStore();
  final ServerInstance instance;
  final HostKeyStore _hostKeys;
  final terminal = Terminal(maxLines: 3000);
  SSHClient? _client;
  SSHSession? _shell;
  final List<StreamSubscription<String>> _streams = [];
  int _generation = 0;
  bool _disposed = false;
  ConnectionStatus status = ConnectionStatus.disconnected;
  String? error;
  String? information;
  String? informationError;
  DateTime? updatedAt;
  bool refreshing = false;

  bool _active(int generation) => !_disposed && generation == _generation;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> connect(ConfirmHostKey confirm, {bool openShell = true}) async {
    disconnect();
    final generation = _generation;
    status = ConnectionStatus.connecting;
    error = null;
    information = null;
    informationError = null;
    updatedAt = null;
    terminal.buffer.clear();
    terminal.buffer.setCursor(0, 0);
    _notify();
    try {
      final identities = instance.privateKey.isEmpty
          ? null
          : await compute(decodeSshIdentity, (
              instance.privateKey,
              instance.passphrase,
            ));
      if (!_active(generation)) return;
      final host = instance.host.replaceAll(RegExp(r'^\[|\]$'), '');
      final socket = await SSHSocket.connect(
        host,
        instance.port,
        timeout: const Duration(seconds: 15),
      );
      if (!_active(generation)) {
        socket.destroy();
        return;
      }
      final client = SSHClient(
        socket,
        algorithms: secureSshAlgorithms,
        username: instance.username,
        identities: identities,
        onPasswordRequest: instance.password.isEmpty
            ? null
            : () => instance.password,
        onVerifyHostKey: (type, fingerprint) => _hostKeys.verify(
          instance,
          type,
          utf8.decode(fingerprint),
          confirm,
          isActive: () => _active(generation),
        ),
        handshakeTimeout: const Duration(seconds: 90),
        authTimeout: const Duration(seconds: 25),
      );
      _client = client;
      // Observe transport errors immediately, including errors before authentication.
      unawaited(
        client.done.then(
          (_) => _closed(generation),
          onError: (Object error, StackTrace stack) => _closed(generation),
        ),
      );
      await client.authenticated;
      if (!_active(generation)) return;
      if (!openShell) {
        status = ConnectionStatus.connected;
        _notify();
        return;
      }
      final shell = await client
          .shell(
            pty: SSHPtyConfig(
              type: 'xterm-256color',
              width: terminal.viewWidth,
              height: terminal.viewHeight,
            ),
          )
          .timeout(const Duration(seconds: 15));
      if (!_active(generation)) {
        shell.close();
        return;
      }
      _shell = shell;
      terminal.onOutput = (data) {
        if (_active(generation)) shell.write(utf8.encode(data));
      };
      terminal.onResize = (width, height, pixelWidth, pixelHeight) {
        if (_active(generation)) {
          shell.resizeTerminal(width, height, pixelWidth, pixelHeight);
        }
      };
      for (final stream in [shell.stdout, shell.stderr]) {
        _streams.add(
          stream
              .cast<List<int>>()
              .transform(const Utf8Decoder(allowMalformed: true))
              .listen((data) {
                if (_active(generation)) terminal.write(data);
              }, onError: (Object error) => _closed(generation)),
        );
      }
      unawaited(
        shell.done.then(
          (_) => _closed(generation),
          onError: (Object error, StackTrace stack) => _closed(generation),
        ),
      );
      status = ConnectionStatus.connected;
      _notify();
      unawaited(refreshInformation());
    } catch (exception) {
      if (!_active(generation)) return;
      disconnect();
      status = ConnectionStatus.failed;
      error = sshErrorMessage(exception);
      _notify();
    }
  }

  void _closed(int generation) {
    if (!_active(generation)) return;
    // The connect future reports precise authentication/host-key errors itself.
    if (status == ConnectionStatus.connecting) return;
    disconnect();
    error = 'A sessão SSH terminou. Pode voltar a ligar.';
    _notify();
  }

  Future<void> refreshInformation() async {
    final client = _client;
    if (client == null || status != ConnectionStatus.connected || refreshing) {
      return;
    }
    final generation = _generation;
    refreshing = true;
    informationError = null;
    _notify();
    SSHSession? probe;
    var acceptingProbe = true;
    try {
      // Static, read-only POSIX commands. Never interpolate configuration into a shell command.
      final opening = client.execute(
        "export LC_ALL=C; printf 'SYSTEM\\n'; uname -snr; printf '\\nUPTIME\\n'; uptime; printf '\\nMEMORY (MiB)\\n'; free -m; printf '\\nDISK /\\n'; df -h /",
      );
      unawaited(
        opening.then((session) {
          if (!_active(generation) || !acceptingProbe) session.close();
        }, onError: (Object e, StackTrace s) {}),
      );
      probe = await opening.timeout(const Duration(seconds: 10));
      final chunks = <int>[];
      await probe.stdout
          .timeout(const Duration(seconds: 10))
          .forEach((chunk) {
            if (chunks.length + chunk.length > 65536) {
              throw const FormatException('Response too large');
            }
            chunks.addAll(chunk);
          })
          .timeout(const Duration(seconds: 12));
      if (!_active(generation)) return;
      information = utf8.decode(chunks, allowMalformed: true).trim();
      if (information!.isEmpty) throw const FormatException('Empty response');
      updatedAt = DateTime.now();
    } catch (_) {
      if (_active(generation)) informationError = 'Não foi possível obter a informação do sistema. O terminal continua disponível. Os comandos de resumo requerem Linux/POSIX.';
    } finally {
      acceptingProbe = false;
      probe?.close();
      if (_active(generation)) {
        refreshing = false;
        _notify();
      }
    }
  }

  void disconnect() {
    _generation++;
    terminal.onOutput = null;
    terminal.onResize = null;
    for (final stream in _streams) {
      unawaited(stream.cancel());
    }
    _streams.clear();
    _shell?.close();
    _shell = null;
    _client?.close();
    _client = null;
    terminal.mainBuffer.clear();
    terminal.altBuffer.clear();
    terminal.mainBuffer.setCursor(0, 0);
    terminal.altBuffer.setCursor(0, 0);
    information = null;
    informationError = null;
    updatedAt = null;
    error = null;
    refreshing = false;
    status = ConnectionStatus.disconnected;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    disconnect();
    super.dispose();
  }
}

String sshErrorMessage(Object error) {
  if (error is SSHAuthError) {
    return 'Autenticação recusada. Verifique o utilizador e a credencial SSH.';
  }
  if (error is SSHHostkeyError) {
    return 'A identidade do servidor não foi aceite. A ligação foi interrompida.';
  }
  if (error is SSHKeyDecodeError) {
    return 'Não foi possível ler a chave privada. Verifique a chave e a frase-passe.';
  }
  if (error is TimeoutException) {
    return 'A ligação excedeu o tempo limite. Verifique a rede e a porta SSH.';
  }
  if (error is SocketException || error is SSHSocketError) {
    return 'Servidor inacessível. Verifique o endereço, a porta e a rede/VPN.';
  }
  return 'Não foi possível abrir a sessão SSH. Verifique o acesso ao servidor e tente novamente.';
}
