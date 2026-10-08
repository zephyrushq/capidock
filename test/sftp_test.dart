import 'package:capidock/core/security/security_controls.dart';
import 'package:capidock/features/sftp/sftp_documents.dart';

import 'dart:typed_data';

import 'package:capidock/features/sftp/sftp_browser.dart';
import 'package:capidock/features/sftp/sftp_panel.dart';
import 'package:capidock/features/connections/data/ssh_connection.dart';
import 'package:capidock/features/connections/data/host_key_store.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:capidock/l10n/localization.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

class FakeClient implements SftpClient {
  @override
  Future<void> close() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Browser extends SftpBrowser {
  Browser() : super(FakeClient());
  String? last;
  int deletes = 0;
  String? uploaded;
  Uint8List? received;
  @override
  Future<String> home() async => '/home/operator';
  @override
  Future<List<SftpName>> list(String path) async {
    last = path;
    return [
      SftpName(
        filename: 'folder',
        longname: '',
        attr: SftpFileAttrs(mode: SftpFileMode.value(0x4000)),
      ),
      SftpName(
        filename: 'hello.txt',
        longname: '',
        attr: SftpFileAttrs(mode: SftpFileMode.value(0x8000), size: 20),
      ),
    ];
  }

  @override
  Future<SftpFileAttrs?> stat(String path) async => null;
  @override
  Future<void> upload(
    String path,
    Uint8List bytes, {
    bool overwrite = false,
    Uint8List? original,
    void Function(int)? progress,
  }) async {
    uploaded = path;
    received = bytes;
  }

  @override
  Future<void> delete(String path) async {
    deletes++;
  }
}

class Connection extends SshConnection {
  Connection()
    : super(
        const ServerInstance(
          id: 'test',
          name: 'Test',
          type: InstanceType.ssh,
          host: 'localhost',
          port: 22,
          username: 'test',
        ),
        hostKeys: HostKeyStore(secrets: MemorySecretStore()),
      ) {
    status = ConnectionStatus.connected;
  }
}

class Documents implements SftpDocuments {
  Documents(this.connection);
  final Connection connection;
  final payload = Uint8List.fromList([97, 98, 99]);
  @override
  Future<SftpDocument?> open() async {
    connection.disconnect();
    return SftpDocument('upload.txt', payload);
  }

  @override
  Future<bool> save(String name, Uint8List bytes) async => true;
}

void main() {
  testWidgets(
    'Upload uses protected document picker, reconnects and clears payload',
    (tester) async {
      final ssh = Connection();
      addTearDown(ssh.dispose);
      final documents = Documents(ssh);
      final browsers = <Browser>[];
      var protectedCalls = 0, reconnects = 0;
      Future<T?> protected<T>(
        String reason,
        Future<T?> Function() action,
      ) async {
        protectedCalls++;
        return action();
      }

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'GB'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: SecurityControls(
            lock: () {},
            clearData: (_) async {},
            documentAction: protected,
            child: Scaffold(
              body: SftpPanel(
                connection: ssh,
                documents: documents,
                connect: () async {
                  reconnects++;
                  ssh.status = ConnectionStatus.connected;
                  ssh.notifyListeners();
                },
                createBrowser: () async {
                  final b = Browser();
                  browsers.add(b);
                  return b;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.upload_file));
      await tester.pumpAndSettle();
      expect(protectedCalls, 1);
      expect(reconnects, 1);
      expect(browsers.first.isClosed, true);
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(FilledButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(browsers.last.uploaded, '/home/operator/upload.txt');
      expect(documents.payload, [0, 0, 0]);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  test('SFTP paths cannot escape through entry names', () {
    for (final name in ['', '.', '..', '../x', 'a/b', 'a\n', 'x\u0000']) {
      expect(() => sftpName(name), throwsFormatException);
    }
    expect(sftpJoin('/', 'file'), ' /file'.trim());
    expect(sftpJoin('/home', 'x'), ' /home/x'.trim());
    expect(sftpParent('/home/operator'), '/home');
    expect(sftpParent('/home'), '/');
    expect(sftpParent('/'), '/');
    expect(sftpName('.env'), '.env');
  });
  test('Text editor rejects binary and malformed UTF-8', () {
    expect(
      () => sftpDecodeText(Uint8List.fromList([0])),
      throwsFormatException,
    );
    expect(
      () => sftpDecodeText(Uint8List.fromList([255])),
      throwsFormatException,
    );
    expect(
      () => sftpDecodeText(Uint8List(sftpEditorLimit + 1)),
      throwsFormatException,
    );
    expect(sftpDecodeText(Uint8List.fromList([97, 10])), 'a\n');
  });
  for (final locale in [
    const Locale('en', 'GB'),
    const Locale('en', 'US'),
    const Locale('pt', 'PT'),
    const Locale('pt', 'BR'),
    const Locale('es', 'ES'),
  ]) {
    testWidgets('SFTP mobile navigation and cancelled deletion in $locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final browser = Browser();
      final ssh = Connection();
      addTearDown(ssh.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SftpPanel(
              connection: ssh,
              connect: () async {},
              createBrowser: () async => browser,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('hello.txt'), findsOneWidget);
      await tester.tap(find.text('folder'));
      await tester.pumpAndSettle();
      expect(browser.last, '/home/operator/folder');
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();
      expect(browser.last, '/home/operator');
      await tester.tap(find.byType(PopupMenuButton<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PopupMenuItem<String>).last);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(
        find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(TextButton),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(browser.deletes, 0);
      await tester.enterText(find.byType(TextField), 'nothing');
      await tester.pumpAndSettle();
      expect(find.text('hello.txt'), findsNothing);
      expect(tester.takeException(), isNull);
      ssh.disconnect();
      await tester.pumpAndSettle();
      expect(browser.isClosed, true);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
