import 'dart:async';
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:xterm/xterm.dart';

/// An independent PTY on a shared SSH transport. Exiting it leaves the host shell intact.
class SshTerminalChannel extends ChangeNotifier {
  SshTerminalChannel(this._session) {
    terminal.onOutput = (data) {
      if (active) _session.write(utf8.encode(data));
    };
    terminal.onResize = (w, h, pw, ph) {
      if (active) _session.resizeTerminal(w, h, pw, ph);
    };
    for (final stream in [_session.stdout, _session.stderr]) {
      _streams.add(
        stream
            .cast<List<int>>()
            .transform(const Utf8Decoder(allowMalformed: true))
            .listen(
              (data) {
                if (active) terminal.write(data);
              },
              onError: (Object _) => close(),
              onDone: () {
                _remaining--;
                if (_remaining == 0 && _exited) _ended();
              },
            ),
      );
    }
    unawaited(
      _session.done.then((_) {
        _exited = true;
        if (_remaining == 0) _ended();
      }, onError: (Object _) => close()),
    );
  }
  final SSHSession _session;
  final terminal = Terminal(maxLines: 3000);
  final _streams = <StreamSubscription<String>>[];
  bool active = true;
  bool _disposed = false;
  bool _exited = false;
  int _remaining = 2;
  int? get exitCode => _session.exitCode;
  void _ended() {
    if (!active) return;
    active = false;
    terminal.onOutput = null;
    terminal.onResize = null;
    if (!_disposed) notifyListeners();
  }

  void close() {
    _session.close();
    _ended();
    for (final stream in _streams) {
      unawaited(stream.cancel());
    }
    _streams.clear();
    terminal.mainBuffer.clear();
    terminal.altBuffer.clear();
    terminal.mainBuffer.setCursor(0, 0);
    terminal.altBuffer.setCursor(0, 0);
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    close();
    super.dispose();
  }
}
