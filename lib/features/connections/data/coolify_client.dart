import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

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
    if (ServerInstance.validateHost(instance.host, InstanceType.coolify) !=
        null) {
      throw const CoolifyException('O Coolify requer uma URL HTTPS válida.');
    }
    if (instance.apiToken.trim().isEmpty) {
      throw const CoolifyException('Configure o token da API.');
    }
    try {
      // Never forward a bearer token to a redirected host or downgraded URL.
      final request =
          http.Request(
              'GET',
              Uri.parse(instance.host).replace(path: '/api/v1/resources'),
            )
            ..followRedirects = false
            ..headers.addAll({
              'Authorization': 'Bearer ${instance.apiToken}',
              'Accept': 'application/json',
            });
      final response = await _client
          .send(request)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        final message = switch (response.statusCode) {
          401 => 'Token inválido ou expirado. Edite a credencial da instância.',
          403 => 'Acesso recusado. Verifique as permissões do token, a API e a lista de IPs permitidos.',
          404 =>
            'API não encontrada. Verifique a URL base e se a API está ativa.',
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
      final data = jsonDecode(utf8.decode(bytes));
      if (data is! List) {
        throw const FormatException('Expected a resource list');
      }
      return data
          .map((item) => CoolifyResource.fromJson(item as Map<String, dynamic>))
          .toList();
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
