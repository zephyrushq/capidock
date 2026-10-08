import 'dart:io';

import 'package:capidock/features/connections/data/coolify_client.dart';
import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Default transport rejects an untrusted TLS certificate before sending a token', () async {
    final directory = await Directory.systemTemp.createTemp('capidock-tls-');
    HttpServer? server;
    final client = CoolifyClient();
    try {
      final generated = await Process.run('openssl', [
        'req',
        '-x509',
        '-newkey',
        'rsa:2048',
        '-nodes',
        '-days',
        '1',
        '-subj',
        '/CN=localhost',
        '-addext',
        'subjectAltName=DNS:localhost,IP:127.0.0.1',
        '-keyout',
        '${directory.path}/key.pem',
        '-out',
        '${directory.path}/cert.pem',
      ]);
      expect(generated.exitCode, 0);
      final context = SecurityContext()
        ..useCertificateChain('${directory.path}/cert.pem')
        ..usePrivateKey('${directory.path}/key.pem');
      server = await HttpServer.bindSecure(
        InternetAddress.loopbackIPv4,
        0,
        context,
      );
      var requests = 0;
      server.listen((request) {
        requests++;
        request.response.close();
      }, onError: (Object _) {});
      final instance = ServerInstance(
        id: 'tls-test',
        name: 'TLS test',
        type: InstanceType.coolify,
        host: 'https://127.0.0.1:${server.port}',
        port: server.port,
        apiToken: 'synthetic-test-token',
      );
      await expectLater(
        client.request(instance, 'GET', '/projects'),
        throwsA(isA<CoolifyException>()),
      );
      expect(
        requests,
        0,
        reason: 'Bearer headers must never reach an untrusted endpoint',
      );
    } finally {
      client.close();
      await server?.close(force: true);
      await directory.delete(recursive: true);
    }
  });
}
