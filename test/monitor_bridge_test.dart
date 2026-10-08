import 'dart:async';

import 'package:capidock_monitor_bridge/capidock_monitor_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Transactions queue within an engine and always release ownership',
    () async {
      var owned = false, acquires = 0, releases = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MonitorBridge.channel, (call) async {
            if (call.method == 'acquire') {
              expect(owned, false);
              owned = true;
              acquires++;
              return 'token';
            }
            if (call.method == 'release') {
              expect(owned, true);
              expect(call.arguments, {'token': 'token'});
              owned = false;
              releases++;
              return null;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(MonitorBridge.channel, null),
      );
      final gate = Completer<void>(), started = Completer<void>();
      final first = MonitorBridge().transaction(() async {
        started.complete();
        await gate.future;
      });
      await started.future;
      final second = MonitorBridge().transaction(() async => 2);
      expect(acquires, 1);
      gate.complete();
      await first;
      expect(await second, 2);
      await expectLater(
        MonitorBridge().transaction(() async => throw StateError('test')),
        throwsStateError,
      );
      expect(await MonitorBridge().transaction(() async => 4), 4);
      expect(acquires, 4);
      expect(releases, 4);
      expect(owned, false);
    },
  );
}
