import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';
export 'generated/app_localizations.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Resolve transport and validation messages using the current widget locale.
String localizedMessage(BuildContext context, String message) {
  final strings = context.l10n;
  final http = RegExp(
    r'^O Coolify respondeu com erro HTTP (\d+)\. Tente novamente\.$',
  ).firstMatch(message);
  if (http != null) return strings.httpError(int.parse(http.group(1)!));
  return switch (message) {
    'secureSaveError' => strings.secureSaveError,
    'saveError' => strings.saveError,
    "Sem nome" => strings.unnamedResource,
    "Estado indisponível" => strings.unavailableStatus,
    "O Coolify requer uma URL HTTPS válida." => strings.coolifyHttpsError,
    "Configure o token da API." => strings.apiTokenRequired,
    "Token inválido ou expirado. Edite a credencial da instância." =>
      strings.invalidToken,
    "Acesso recusado. Verifique as permissões do token, a API e a lista de IPs permitidos." =>
      strings.coolifyAccessDenied,
    "API não encontrada. Verifique a URL base e se a API está ativa." =>
      strings.apiNotFound,
    "Limite de pedidos atingido. Aguarde e tente novamente." =>
      strings.rateLimited,
    "O servidor redirecionou o pedido. Configure diretamente a URL HTTPS final." =>
      strings.redirectError,
    "A resposta do Coolify excedeu o limite de 4 MiB." =>
      strings.responseTooLarge,
    "O Coolify excedeu o tempo limite. Verifique a rede/VPN." =>
      strings.coolifyTimeout,
    "A API devolveu uma resposta inesperada. Verifique a URL e a versão do Coolify." =>
      strings.invalidApiResponse,
    "Não foi possível contactar o Coolify. Verifique a rede e o certificado HTTPS." =>
      strings.coolifyConnectionError,
    "A sessão SSH terminou. Pode voltar a ligar." => strings.sshSessionEnded,
    "Não foi possível obter a informação do sistema. O terminal continua disponível. Os comandos de resumo requerem Linux/POSIX." =>
      strings.systemInfoError,
    "Autenticação recusada. Verifique o utilizador e a credencial SSH." =>
      strings.sshAuthError,
    "A identidade do servidor não foi aceite. A ligação foi interrompida." =>
      strings.sshHostKeyError,
    "Não foi possível ler a chave privada. Verifique a chave e a frase-passe." =>
      strings.sshPrivateKeyError,
    "A ligação excedeu o tempo limite. Verifique a rede e a porta SSH." =>
      strings.sshTimeout,
    "Servidor inacessível. Verifique o endereço, a porta e a rede/VPN." =>
      strings.serverUnreachable,
    "Não foi possível abrir a sessão SSH. Verifique o acesso ao servidor e tente novamente." =>
      strings.sshConnectionError,
    "Não foi possível carregar os workspaces guardados." =>
      strings.loadWorkspacesError,
    "Não foi possível guardar no armazenamento seguro. Os campos foram preservados; tente novamente." =>
      strings.secureSaveError,
    "Não foi possível guardar. Tente novamente." => strings.saveError,
    "Acesso ao servidor por terminal" => strings.sshDescription,
    "Aplicações e deployments" => strings.coolifyDescription,
    "Informe o endereço da instância." => strings.hostRequired,
    "O endereço não pode ter espaços." => strings.hostNoSpaces,
    "Use uma URL HTTPS, como https://coolify.exemplo.pt." =>
      strings.httpsRequired,
    "Use apenas o hostname ou IP do servidor." => strings.hostOnly,
    "A chave privada está vazia." => strings.privateKeyEmpty,
    "Não foi possível ler a chave privada. Verifique o formato e a frase-passe." =>
      strings.privateKeyFormatError,
    _ => message,
  };
}
