import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:file_selector/file_selector.dart';

import '../../instances/domain/server_instance.dart';

class CoolifyResource {
  const CoolifyResource({
    required this.name,
    required this.type,
    required this.status,
    required this.id,
  });
  final String name, type, status, id;
  factory CoolifyResource.fromJson(Map<String, dynamic> json) =>
      CoolifyResource(
        id: json['uuid'] as String? ?? '',
        name: json['name'] as String? ?? 'Sem nome',
        type: json['type'] as String? ?? 'Recurso',
        status: json['status'] as String? ?? 'Estado indisponível',
      );
}

class CoolifyException implements Exception {
  const CoolifyException(this.message);
  final String message;
}

class CoolifyClient {
  CoolifyClient({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<CoolifyResource>> resources(ServerInstance instance) async {
    final data = await request(instance, 'GET', '/resources');
    try {
      if (data is! List) throw const FormatException();
      return data
          .map((item) => CoolifyResource.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const CoolifyException(
        'A API devolveu uma resposta inesperada. Verifique a URL e a versão do Coolify.',
      );
    }
  }

  Future<Object?> request(
    ServerInstance instance,
    String method,
    String path, {
    Map<String, String> query = const {},
    Object? body,
    XFile? file,
  }) async {
    if (ServerInstance.validateHost(instance.host, InstanceType.coolify) !=
        null) {
      throw const CoolifyException('O Coolify requer uma URL HTTPS válida.');
    }
    if (instance.apiToken.trim().isEmpty) {
      throw const CoolifyException('Configure o token da API.');
    }
    // Only relative API paths are allowed. Never redirect an authenticated request.
    if (!path.startsWith('/') ||
        path.startsWith('//') ||
        path
            .split('/')
            .any(
              (segment) =>
                  Uri.decodeComponent(segment) == '..' ||
                  Uri.decodeComponent(segment) == '.',
            ) ||
        path.contains('?') ||
        path.contains('#') ||
        path.contains('://') ||
        !const ['GET', 'POST', 'PATCH', 'PUT', 'DELETE'].contains(method)) {
      throw ArgumentError('Invalid Coolify API operation');
    }
    final uri = Uri.parse(instance.host).replace(
      path: '/api/v1$path',
      queryParameters: query.isEmpty ? null : query,
    );
    try {
      final http.BaseRequest request;
      if (file != null) {
        final fields = (body as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, v.toString()),
        );
        final length = await file.length();
        if (length <= 0 || length > 10 * 1024 * 1024 * 1024) {
          throw const CoolifyException('coolifyUploadSize');
        }
        request = http.MultipartRequest(method, uri)
          ..fields.addAll(fields)
          ..files.add(
            http.MultipartFile(
              'file',
              file.openRead(),
              length,
              filename: file.name,
            ),
          );
      } else {
        final plain = http.Request(method, uri);
        if (body != null) {
          final encoded = jsonEncode(body);
          if (utf8.encode(encoded).length > 4 * 1024 * 1024) {
            throw const CoolifyException(
              'A resposta do Coolify excedeu o limite de 4 MiB.',
            );
          }
          plain.headers['Content-Type'] = 'application/json';
          plain.body = encoded;
        }
        request = plain;
      }
      request.followRedirects = false;
      request.headers.addAll({
        'Authorization': 'Bearer ${instance.apiToken}',
        'Accept': 'application/json',
      });
      final timeout = file == null
          ? const Duration(seconds: 20)
          : const Duration(minutes: 15);
      final response = await _client.send(request).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        // Error bodies can include environment values or credentials. Do not echo them.
        final message = switch (response.statusCode) {
          401 => 'Token inválido ou expirado. Edite a credencial da instância.',
          403 => 'Acesso recusado. Verifique as permissões do token, a API e a lista de IPs permitidos.',
          404 =>
            'API não encontrada. Verifique a URL base e se a API está ativa.',
          409 => 'coolifyConflict',
          422 => 'coolifyValidationError',
          429 => 'Limite de pedidos atingido. Aguarde e tente novamente.',
          >= 300 && < 400 => 'O servidor redirecionou o pedido. Configure diretamente a URL HTTPS final.',
          _ =>
            'O Coolify respondeu com erro HTTP ${response.statusCode}. Tente novamente.',
        };
        throw CoolifyException(message);
      }
      final bytes = <int>[];
      await response.stream
          .timeout(const Duration(seconds: 15))
          .forEach((chunk) {
            if (bytes.length + chunk.length > 4 * 1024 * 1024) {
              throw const CoolifyException(
                'A resposta do Coolify excedeu o limite de 4 MiB.',
              );
            }
            bytes.addAll(chunk);
          })
          .timeout(const Duration(seconds: 20));
      if (bytes.isEmpty) return null;
      final text = utf8.decode(bytes);
      try {
        return jsonDecode(text);
      } on FormatException {
        if (response.headers['content-type']?.startsWith('text/plain') ==
                true &&
            !text.trimLeft().startsWith('<')) {
          return text;
        }
        rethrow;
      }
    } on CoolifyException {
      rethrow;
    } on TimeoutException {
      throw const CoolifyException(
        'O Coolify excedeu o tempo limite. Verifique a rede/VPN.',
      );
    } on FormatException {
      throw const CoolifyException(
        'A API devolveu uma resposta inesperada. Verifique a URL e a versão do Coolify.',
      );
    } catch (_) {
      throw const CoolifyException(
        'Não foi possível contactar o Coolify. Verifique a rede e o certificado HTTPS.',
      );
    }
  }

  void close() => _client.close();
}
