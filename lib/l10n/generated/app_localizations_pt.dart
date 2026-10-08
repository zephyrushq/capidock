// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get emptyProjectTitle => 'Um espaço para\ncada projeto.';

  @override
  String get emptyServerTitle => 'O seu próximo servidor\ncomeça aqui.';

  @override
  String get emptyProjectBody =>
      'Crie um workspace para organizar as suas instâncias SSH e Coolify.';

  @override
  String get createWorkspace => 'Criar workspace';

  @override
  String get addInstance => 'Adicionar instância';

  @override
  String get aboutDescription =>
      'Um dock para todos os seus servidores.\n\nCada workspace reúne os seus próprios canais SSH e Coolify. As configurações e credenciais ficam cifradas neste dispositivo. Ligue-se diretamente por SSH ou consulte os recursos da API Coolify.';

  @override
  String get aboutLicence =>
      'Código aberto sob GPL-3.0-only. Pode redistribuir e modificar a app nos termos da licença. Sem garantia, nos limites da lei.\n\nOs textos da licença, créditos e política de marca estão disponíveis em Ver licenças, mesmo sem internet.';

  @override
  String get sourceCode =>
      'Código-fonte: https://github.com/zephyrushq/capidock-mobile';

  @override
  String get removeInstanceTitle => 'Remover instância?';

  @override
  String get removeInstanceError =>
      'Não foi possível remover a instância. Tente novamente.';

  @override
  String get preservedData => 'Os dados guardados foram preservados.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get openInstances => 'Abrir instâncias';

  @override
  String get firstWorkspace => 'Crie o seu primeiro workspace';

  @override
  String get instanceOptions => 'Opções da instância';

  @override
  String get editInstance => 'Editar instância';

  @override
  String get moveInstance => 'Mover para workspace';

  @override
  String get removeInstance => 'Remover instância';

  @override
  String get aboutCapidock => 'Sobre o Capidock';

  @override
  String get unnamedResource => 'Sem nome';

  @override
  String get unavailableStatus => 'Estado indisponível';

  @override
  String get coolifyHttpsError => 'O Coolify requer uma URL HTTPS válida.';

  @override
  String get apiTokenRequired => 'Configure o token da API.';

  @override
  String get invalidToken =>
      'Token inválido ou expirado. Edite a credencial da instância.';

  @override
  String get coolifyAccessDenied =>
      'Acesso recusado. Verifique as permissões do token, a API e a lista de IPs permitidos.';

  @override
  String get apiNotFound =>
      'API não encontrada. Verifique a URL base e se a API está ativa.';

  @override
  String get rateLimited =>
      'Limite de pedidos atingido. Aguarde e tente novamente.';

  @override
  String get redirectError =>
      'O servidor redirecionou o pedido. Configure diretamente a URL HTTPS final.';

  @override
  String get responseTooLarge =>
      'A resposta do Coolify excedeu o limite de 4 MiB.';

  @override
  String get coolifyTimeout =>
      'O Coolify excedeu o tempo limite. Verifique a rede/VPN.';

  @override
  String get invalidApiResponse =>
      'A API devolveu uma resposta inesperada. Verifique a URL e a versão do Coolify.';

  @override
  String get coolifyConnectionError =>
      'Não foi possível contactar o Coolify. Verifique a rede e o certificado HTTPS.';

  @override
  String get sshSessionEnded => 'A sessão SSH terminou. Pode voltar a ligar.';

  @override
  String get systemInfoError =>
      'Não foi possível obter a informação do sistema. O terminal continua disponível. Os comandos de resumo requerem Linux/POSIX.';

  @override
  String get sshAuthError =>
      'Autenticação recusada. Verifique o utilizador e a credencial SSH.';

  @override
  String get sshHostKeyError =>
      'A identidade do servidor não foi aceite. A ligação foi interrompida.';

  @override
  String get sshPrivateKeyError =>
      'Não foi possível ler a chave privada. Verifique a chave e a frase-passe.';

  @override
  String get sshTimeout =>
      'A ligação excedeu o tempo limite. Verifique a rede e a porta SSH.';

  @override
  String get serverUnreachable =>
      'Servidor inacessível. Verifique o endereço, a porta e a rede/VPN.';

  @override
  String get sshConnectionError =>
      'Não foi possível abrir a sessão SSH. Verifique o acesso ao servidor e tente novamente.';

  @override
  String get confirmSshServer => 'Confirmar servidor SSH';

  @override
  String get serverKeyChanged => 'A chave do servidor mudou';

  @override
  String get compareFingerprint =>
      'Compare esta impressão digital com a do seu servidor antes de confiar.';

  @override
  String get changedKeyWarning =>
      'Pode ser uma reinstalação ou uma ligação a outro servidor. Só substitua a chave depois de a verificar por outro meio.';

  @override
  String get savedKey => 'Chave guardada:';

  @override
  String get verifyKeyCommand =>
      'No servidor: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (ajuste ao tipo de chave apresentado).';

  @override
  String get trustAndConnect => 'Confiar e ligar';

  @override
  String get replaceKey => 'Substituir chave';

  @override
  String get yourServer => 'O seu servidor';

  @override
  String get yourResources => 'Os seus recursos';

  @override
  String get connecting => 'A ligar…';

  @override
  String get receivedData => 'Dados recebidos';

  @override
  String get notConnected => 'Por ligar';

  @override
  String get addCredentials =>
      'Adicione uma credencial para ligar esta instância. O endereço guardado foi preservado.';

  @override
  String get configureAccess => 'Configurar acesso';

  @override
  String get connectInstance => 'Ligar à instância';

  @override
  String get editAccess => 'Editar acesso';

  @override
  String get openTerminal => 'Abrir terminal';

  @override
  String get connectForInfo =>
      'Ligue-se para consultar o sistema, uptime, memória e disco, ou usar o terminal interativo.';

  @override
  String get noCoolifyResources =>
      'A API não devolveu recursos para a equipa deste token.';

  @override
  String get coolifyOverview =>
      'Consulte as aplicações, bases de dados e serviços da sua equipa. Os estados vêm diretamente da API Coolify.';

  @override
  String get connectionPrivacy =>
      'As ligações SSH encerram ao mudar de instância ou colocar a app em segundo plano. As credenciais ficam cifradas no dispositivo.';

  @override
  String get activeSshSession => 'Sessão SSH ativa';

  @override
  String get terminalDisconnected => 'Terminal desligado';

  @override
  String get connection => 'Ligação';

  @override
  String get openKeyboard => 'Abrir teclado';

  @override
  String get loadWorkspacesError =>
      'Não foi possível carregar os workspaces guardados.';

  @override
  String get secureSaveError =>
      'Não foi possível guardar no armazenamento seguro. Os campos foram preservados; tente novamente.';

  @override
  String get welcomeTitle => 'Os seus servidores.\nO seu dock.';

  @override
  String get firstServerTitle => 'Dê lugar ao seu\nprimeiro servidor.';

  @override
  String get connectionTitle => 'Como vamos\nligar-nos?';

  @override
  String get welcomeBody =>
      'Bem-vindo ao Capidock. Crie um workspace para reunir as instâncias dos seus projetos.';

  @override
  String get workspaceName => 'Nome do workspace';

  @override
  String get workspaceHint => 'ex.: Pessoal, Empresa ou Projeto';

  @override
  String get workspaceNameRequired => 'Dê um nome ao workspace.';

  @override
  String get saving => 'A guardar…';

  @override
  String get configureConnection => 'Configurar ligação';

  @override
  String get createAndOpen => 'Criar e abrir instância';

  @override
  String get localByChoice =>
      'Local por escolha. Sem conta, sem sincronização.';

  @override
  String get manageWorkspaces => 'Gerir workspaces';

  @override
  String get newWorkspace => 'Novo workspace';

  @override
  String get renameWorkspace => 'Renomear workspace';

  @override
  String get workspaceGrouping =>
      'Agrupe os servidores de um projeto, cliente ou ambiente.';

  @override
  String get workspaceEditorHint => 'ex.: Pessoal, Trabalho, Homelab';

  @override
  String get saveError => 'Não foi possível guardar. Tente novamente.';

  @override
  String get yourWorkspaces => 'Os seus workspaces';

  @override
  String get workspaceContexts => 'Um espaço para cada contexto.';

  @override
  String get removeWorkspace => 'Remover workspace';

  @override
  String get noWorkspaces => 'Ainda não existem workspaces.';

  @override
  String get removeWorkspaceTitle => 'Remover workspace?';

  @override
  String get removeWorkspaceError =>
      'Não foi possível remover o workspace. Tente novamente.';

  @override
  String get moveInstanceError =>
      'Não foi possível mover a instância. Tente novamente.';

  @override
  String get sshDescription => 'Acesso ao servidor por terminal';

  @override
  String get coolifyDescription => 'Descrição';

  @override
  String get hostRequired => 'Informe o endereço da instância.';

  @override
  String get hostNoSpaces => 'O endereço não pode ter espaços.';

  @override
  String get httpsRequired =>
      'Use uma URL HTTPS, como https://coolify.exemplo.pt.';

  @override
  String get hostOnly => 'Use apenas o hostname ou IP do servidor.';

  @override
  String get privateKeyEmpty => 'A chave privada está vazia.';

  @override
  String get privateKeyFormatError =>
      'Não foi possível ler a chave privada. Verifique o formato e a frase-passe.';

  @override
  String get instanceName => 'Nome da instância';

  @override
  String get instanceHint => 'ex.: produção-europa';

  @override
  String get instanceNameRequired => 'Dê um nome à instância.';

  @override
  String get hostname => 'Hostname ou IP';

  @override
  String get coolifyUrl => 'URL do Coolify';

  @override
  String get invalidUsername => 'Utilizador inválido.';

  @override
  String get authentication => 'Autenticação';

  @override
  String get privateKey => 'Chave privada';

  @override
  String get sshPassword => 'Palavra-passe SSH';

  @override
  String get privateKeyLabel => 'Chave privada PEM / OpenSSH';

  @override
  String get privateKeyHint =>
      'Cole a chave completa, incluindo as linhas BEGIN e END.';

  @override
  String get passphraseLabel => 'Frase-passe da chave (opcional)';

  @override
  String get coolifyToken => 'Token da API Coolify';

  @override
  String get coolifyTokenHint =>
      'No Coolify, ative a API e crie um token em Keys & Tokens → API tokens. Tokens de leitura permitem consultar recursos. Para editar, use write; deploys podem exigir deploy ou sensitive. Use a URL base, sem /api/v1.';

  @override
  String get localCredentials =>
      'Configuração e credenciais cifradas neste dispositivo. A ligação é feita diretamente ao seu servidor, sem conta Capidock.';

  @override
  String get showCredential => 'Mostrar credencial';

  @override
  String get hideCredential => 'Ocultar credencial';

  @override
  String get credentialRequired => 'Informe a credencial.';

  @override
  String get newInstanceTitle => 'Um novo lugar no seu dock.';

  @override
  String get saveConfiguration => 'Guardar configuração';

  @override
  String get findInstance => 'Encontrar instância';

  @override
  String get emptyInstances => 'Este workspace ainda não tem instâncias.';

  @override
  String get noInstancesFound => 'Nenhuma instância encontrada.';

  @override
  String get newInstance => 'Nova instância';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Remover';

  @override
  String get save => 'Guardar';

  @override
  String get rename => 'Renomear';

  @override
  String get back => 'Voltar';

  @override
  String get username => 'Utilizador';

  @override
  String get port => 'Porta';

  @override
  String get password => 'Palavra-passe';

  @override
  String get server => 'Servidor';

  @override
  String get connected => 'Ligado';

  @override
  String get refresh => 'Atualizar';

  @override
  String get disconnect => 'Desligar';

  @override
  String get workspaceStep => 'WORKSPACE';

  @override
  String get instanceStep => 'INSTÂNCIA';

  @override
  String get connectionStep => 'LIGAÇÃO';

  @override
  String get previousData => ' · dados anteriores';

  @override
  String get language => 'Idioma';

  @override
  String get languageSaveError =>
      'Não foi possível guardar o idioma. Tente novamente.';

  @override
  String emptyWorkspaceBody(String name) {
    return 'Adicione uma instância SSH ou Coolify ao workspace “$name”.';
  }

  @override
  String removeInstanceBody(String name) {
    return 'A configuração de “$name” será removida deste dispositivo. O servidor não será alterado.';
  }

  @override
  String firstInstanceBody(String name) {
    return 'Cada instância é um canal dentro de “$name”. Comece pela primeira.';
  }

  @override
  String configureInstanceBody(String name) {
    return 'Configure o acesso a “$name”. Pode editar estes dados mais tarde.';
  }

  @override
  String onboardingStep(int step, String name) {
    return 'PASSO $step DE 3 · $name';
  }

  @override
  String workspaceLabel(String name) {
    return 'Workspace $name';
  }

  @override
  String workspaceOptions(String name) {
    return 'Opções de $name';
  }

  @override
  String removeWorkspaceBody(String name, int count) {
    return '“$name” e as suas $count instâncias serão removidos deste dispositivo. Os servidores não serão alterados.';
  }

  @override
  String inWorkspace(String name) {
    return 'No workspace “$name”.';
  }

  @override
  String lastRead(String time, String suffix) {
    return 'Última leitura: $time$suffix';
  }

  @override
  String httpError(int code) {
    return 'O Coolify respondeu com erro HTTP $code. Tente novamente.';
  }

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instâncias',
      one: '1 instância',
      zero: '0 instâncias',
    );
    return '$_temp0';
  }

  @override
  String workspaceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count espaços locais',
      one: '1 espaço local',
      zero: '0 espaços locais',
    );
    return '$_temp0';
  }

  @override
  String resourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recursos',
      one: '1 recurso',
      zero: '0 recursos',
    );
    return '$_temp0';
  }

  @override
  String get coolifyOperations => 'Todas as operações';

  @override
  String get coolifyApplications => 'Aplicações';

  @override
  String get coolifyDatabases => 'Bases de dados';

  @override
  String get coolifyServices => 'Serviços';

  @override
  String get coolifyProjects => 'Projetos';

  @override
  String get coolifyServers => 'Servidores';

  @override
  String get coolifyPermissions =>
      'A leitura requer read. Para editar, use write; deploys e operações de servidor podem exigir deploy ou sensitive. A versão do Coolify determina as operações disponíveis.';

  @override
  String get coolifySearch => 'Pesquisar recursos ou operações';

  @override
  String get coolifyAll => 'Todas as categorias';

  @override
  String get coolifyCatalogHelp =>
      'Aceda às operações documentadas da API Coolify. Os nomes e descrições dos campos seguem a API oficial. Operações recentes podem não existir em instalações antigas.';

  @override
  String get coolifyDetails => 'Detalhes';

  @override
  String get coolifyEnvironment => 'Ambiente';

  @override
  String get coolifyLogs => 'Logs';

  @override
  String get coolifyBackups => 'Backups';

  @override
  String get coolifyStorages => 'Volumes e ficheiros';

  @override
  String get coolifyDeployments => 'Deployments';

  @override
  String get coolifyCreate => 'Criar';

  @override
  String get coolifyEdit => 'Editar configuração';

  @override
  String get coolifyStart => 'Iniciar';

  @override
  String get coolifyStop => 'Parar';

  @override
  String get coolifyRestart => 'Reiniciar';

  @override
  String get coolifyDeploy => 'Fazer deploy';

  @override
  String get coolifyExecutions => 'Histórico de execuções';

  @override
  String get coolifyScheduleBackup => 'Agendar backup';

  @override
  String get coolifyRunBackup => 'Executar backup';

  @override
  String get coolifyEmpty => 'A API não devolveu resultados.';

  @override
  String get coolifyConfirm => 'Confirmar operação';

  @override
  String get coolifyDestructive => 'Confirmar operação destrutiva';

  @override
  String get coolifyMutationWarning =>
      'Esta ação altera o servidor remoto. Parar, reiniciar, fazer deploy, restaurar e eliminar pode interromper serviços ou remover dados. Verifique o destino antes de continuar.';

  @override
  String coolifyTypeTarget(String target) {
    return 'Escreva $target para confirmar.';
  }

  @override
  String get coolifyExecute => 'Executar operação';

  @override
  String get coolifyRead => 'Consultar dados';

  @override
  String get coolifyReveal => 'Mostrar valores e logs (podem conter segredos)';

  @override
  String get coolifyChangedOnly =>
      'Só são enviados os campos alterados. Os campos opcionais não alterados mantêm os valores no servidor. Uma cadeia vazia editada limpa o valor. Listas e objetos usam JSON.';

  @override
  String get coolifyInvalidField => 'Verifique o valor e o tipo exigido.';

  @override
  String get coolifyInvalidJson => 'Introduza JSON válido.';

  @override
  String get coolifyRequiredPayload =>
      'Preencha pelo menos um campo, todos os campos obrigatórios e escolha um ficheiro para uploads.';

  @override
  String get coolifyChooseFile => 'Escolher ficheiro de backup';

  @override
  String get coolifySuccess =>
      'Pedido aceite pelo Coolify. As tarefas em fila podem ainda estar em execução; atualize o estado.';

  @override
  String get coolifyYes => 'Sim';

  @override
  String get coolifyNo => 'Não';

  @override
  String get coolifyConflict =>
      'Outra operação está em curso ou a alteração é incompatível com o estado atual. Atualize antes de tentar novamente.';

  @override
  String get coolifyValidationError =>
      'O Coolify rejeitou os campos. Verifique os valores obrigatórios, tipos e a versão da API instalada.';

  @override
  String get coolifyUploadSize =>
      'Escolha um ficheiro de backup não vazio até 10 GiB.';

  @override
  String get coolifyCancelled =>
      'Ligação encerrada. Atualize para verificar se a operação remota foi concluída.';

  @override
  String get coolifySshTerminal =>
      'O Coolify não expõe um terminal interativo pela API REST pública. Escolha uma ligação SSH guardada para aceder ao servidor.';

  @override
  String get coolifyNoSsh =>
      'Adicione primeiro uma instância SSH deste servidor a um workspace.';

  @override
  String get coolifyResources => 'Recursos';

  @override
  String get coolifyEnvironments => 'Ambientes';

  @override
  String get coolifySharedVariables => 'Variáveis partilhadas';

  @override
  String get coolifyName => 'Nome';

  @override
  String get coolifyStatus => 'Estado';

  @override
  String get coolifyDomains => 'Domínios';

  @override
  String get coolifyRepository => 'Repositório';

  @override
  String get coolifyBranch => 'Branch';

  @override
  String get coolifyBuildPack => 'Método de build';

  @override
  String get coolifyAddress => 'Endereço';

  @override
  String get coolifyPort => 'Porta';

  @override
  String get coolifyUser => 'Utilizador';

  @override
  String get coolifyFrequency => 'Agendamento';

  @override
  String get coolifyEnabled => 'Ativo';

  @override
  String get coolifyMountPath => 'Caminho de montagem';

  @override
  String get coolifyHostPath => 'Caminho no servidor';

  @override
  String get coolifyCreated => 'Criado';

  @override
  String get coolifyUpdated => 'Atualizado';

  @override
  String get coolifyValue => 'Valor';

  @override
  String get coolifyPreview => 'Preview';

  @override
  String get coolifySettings => 'Definições';

  @override
  String get coolifyType => 'Tipo';

  @override
  String get coolifyRunning => 'Em execução';

  @override
  String get coolifyStopped => 'Parado';

  @override
  String get coolifyConfiguration => 'Configuração';

  @override
  String get coolifyOverviewTitle => 'Visão geral';

  @override
  String get coolifyResourceSearch => 'Pesquisar recursos';

  @override
  String get coolifyOtherSettings => 'Mais definições';

  @override
  String get coolifyEnvironmentEmpty =>
      'Ainda não existem ambientes neste projeto.';

  @override
  String get coolifyLogsHidden =>
      'Revele os logs para ver o conteúdo. Podem conter segredos.';

  @override
  String get coolifyResourceEmpty =>
      'Ainda não existem recursos neste ambiente.';

  @override
  String get coolifyRestricted => 'Valor protegido pelas permissões do token.';

  @override
  String get coolifyVariables => 'Variáveis de ambiente';

  @override
  String get coolifyNormalVariables => 'Variáveis normais';

  @override
  String get coolifyPreviewVariables => 'Variáveis de preview';

  @override
  String get coolifyShowValue => 'Mostrar valor';

  @override
  String get coolifyHideValue => 'Ocultar valor';

  @override
  String get coolifyEditValue => 'Editar valor';

  @override
  String get coolifySaveValue => 'Guardar valor';

  @override
  String get deviceLocked => 'Capidock bloqueado';

  @override
  String get deviceUnlockReason => 'Desbloquear as credenciais do Capidock';

  @override
  String get deviceUnlock => 'Desbloquear';

  @override
  String get deviceLockHelp =>
      'Configure um PIN, palavra-passe ou biometria no dispositivo para continuar.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get emptyProjectTitle => 'Um espaço para\ncada projeto.';

  @override
  String get emptyServerTitle => 'O seu próximo servidor\ncomeça aqui.';

  @override
  String get emptyProjectBody =>
      'Crie um workspace para organizar as suas instâncias SSH e Coolify.';

  @override
  String get createWorkspace => 'Criar workspace';

  @override
  String get addInstance => 'Adicionar instância';

  @override
  String get aboutDescription =>
      'Um dock para todos os seus servidores.\n\nCada workspace reúne os seus próprios canais SSH e Coolify. As configurações e credenciais ficam criptografadas neste dispositivo. Conecte-se diretamente por SSH ou consulte os recursos da API Coolify.';

  @override
  String get aboutLicence =>
      'Código aberto sob GPL-3.0-only. Pode redistribuir e modificar a app nos termos da licença. Sem garantia, nos limites da lei.\n\nOs textos da licença, créditos e política de marca estão disponíveis em Ver licenças, mesmo sem internet.';

  @override
  String get sourceCode =>
      'Código-fonte: https://github.com/zephyrushq/capidock-mobile';

  @override
  String get removeInstanceTitle => 'Remover instância?';

  @override
  String get removeInstanceError =>
      'Não foi possível remover a instância. Tente novamente.';

  @override
  String get preservedData => 'Os dados salvos foram preservados.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get openInstances => 'Abrir instâncias';

  @override
  String get firstWorkspace => 'Crie o seu primeiro workspace';

  @override
  String get instanceOptions => 'Opções da instância';

  @override
  String get editInstance => 'Editar instância';

  @override
  String get moveInstance => 'Mover para workspace';

  @override
  String get removeInstance => 'Remover instância';

  @override
  String get aboutCapidock => 'Sobre o Capidock';

  @override
  String get unnamedResource => 'Sem nome';

  @override
  String get unavailableStatus => 'Estado indisponível';

  @override
  String get coolifyHttpsError => 'O Coolify requer uma URL HTTPS válida.';

  @override
  String get apiTokenRequired => 'Configure o token da API.';

  @override
  String get invalidToken =>
      'Token inválido ou expirado. Edite a credencial da instância.';

  @override
  String get coolifyAccessDenied =>
      'Acesso recusado. Verifique as permissões do token, a API e a lista de IPs permitidos.';

  @override
  String get apiNotFound =>
      'API não encontrada. Verifique a URL base e se a API está ativa.';

  @override
  String get rateLimited =>
      'Limite de pedidos atingido. Aguarde e tente novamente.';

  @override
  String get redirectError =>
      'O servidor redirecionou o pedido. Configure diretamente a URL HTTPS final.';

  @override
  String get responseTooLarge =>
      'A resposta do Coolify excedeu o limite de 4 MiB.';

  @override
  String get coolifyTimeout =>
      'O Coolify excedeu o tempo limite. Verifique a rede/VPN.';

  @override
  String get invalidApiResponse =>
      'A API devolveu uma resposta inesperada. Verifique a URL e a versão do Coolify.';

  @override
  String get coolifyConnectionError =>
      'Não foi possível contactar o Coolify. Verifique a rede e o certificado HTTPS.';

  @override
  String get sshSessionEnded => 'A sessão SSH terminou. Pode voltar a ligar.';

  @override
  String get systemInfoError =>
      'Não foi possível obter a informação do sistema. O terminal continua disponível. Os comandos de resumo requerem Linux/POSIX.';

  @override
  String get sshAuthError =>
      'Autenticação recusada. Verifique o usuário e a credencial SSH.';

  @override
  String get sshHostKeyError =>
      'A identidade do servidor não foi aceite. A conexão foi interrompida.';

  @override
  String get sshPrivateKeyError =>
      'Não foi possível ler a chave privada. Verifique a chave e a senha.';

  @override
  String get sshTimeout =>
      'A conexão excedeu o tempo limite. Verifique a rede e a porta SSH.';

  @override
  String get serverUnreachable =>
      'Servidor inacessível. Verifique o endereço, a porta e a rede/VPN.';

  @override
  String get sshConnectionError =>
      'Não foi possível abrir a sessão SSH. Verifique o acesso ao servidor e tente novamente.';

  @override
  String get confirmSshServer => 'Confirmar servidor SSH';

  @override
  String get serverKeyChanged => 'A chave do servidor mudou';

  @override
  String get compareFingerprint =>
      'Compare esta impressão digital com a do seu servidor antes de confiar.';

  @override
  String get changedKeyWarning =>
      'Pode ser uma reinstalação ou uma conexão a outro servidor. Só substitua a chave depois de a verificar por outro meio.';

  @override
  String get savedKey => 'Chave salva:';

  @override
  String get verifyKeyCommand =>
      'No servidor: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (ajuste ao tipo de chave apresentado).';

  @override
  String get trustAndConnect => 'Confiar e ligar';

  @override
  String get replaceKey => 'Substituir chave';

  @override
  String get yourServer => 'O seu servidor';

  @override
  String get yourResources => 'Os seus recursos';

  @override
  String get connecting => 'Conectando…';

  @override
  String get receivedData => 'Dados recebidos';

  @override
  String get notConnected => 'Por ligar';

  @override
  String get addCredentials =>
      'Adicione uma credencial para ligar esta instância. O endereço salvo foi preservado.';

  @override
  String get configureAccess => 'Configurar acesso';

  @override
  String get connectInstance => 'Conectar à instância';

  @override
  String get editAccess => 'Editar acesso';

  @override
  String get openTerminal => 'Abrir terminal';

  @override
  String get connectForInfo =>
      'Conecte-se para consultar o sistema, uptime, memória e disco, ou usar o terminal interativo.';

  @override
  String get noCoolifyResources =>
      'A API não devolveu recursos para a equipe deste token.';

  @override
  String get coolifyOverview =>
      'Consulte as aplicações, bancos de dados e serviços da sua equipe. Os estados vêm diretamente da API Coolify.';

  @override
  String get connectionPrivacy =>
      'As conexões SSH encerram ao mudar de instância ou colocar a app em segundo plano. As credenciais ficam criptografadas no dispositivo.';

  @override
  String get activeSshSession => 'Sessão SSH ativa';

  @override
  String get terminalDisconnected => 'Terminal desligado';

  @override
  String get connection => 'Conexão';

  @override
  String get openKeyboard => 'Abrir teclado';

  @override
  String get loadWorkspacesError =>
      'Não foi possível carregar os workspaces salvos.';

  @override
  String get secureSaveError =>
      'Não foi possível salvar no armazenamento seguro. Os campos foram preservados; tente novamente.';

  @override
  String get welcomeTitle => 'Os seus servidores.\nO seu dock.';

  @override
  String get firstServerTitle => 'Dê lugar ao seu\nprimeiro servidor.';

  @override
  String get connectionTitle => 'Como vamos\nnos conectar?';

  @override
  String get welcomeBody =>
      'Bem-vindo ao Capidock. Crie um workspace para reunir as instâncias dos seus projetos.';

  @override
  String get workspaceName => 'Nome do workspace';

  @override
  String get workspaceHint => 'ex.: Pessoal, Empresa ou Projeto';

  @override
  String get workspaceNameRequired => 'Dê um nome ao workspace.';

  @override
  String get saving => 'Salvando…';

  @override
  String get configureConnection => 'Configurar conexão';

  @override
  String get createAndOpen => 'Criar e abrir instância';

  @override
  String get localByChoice =>
      'Local por escolha. Sem conta, sem sincronização.';

  @override
  String get manageWorkspaces => 'Gerenciar workspaces';

  @override
  String get newWorkspace => 'Novo workspace';

  @override
  String get renameWorkspace => 'Renomear workspace';

  @override
  String get workspaceGrouping =>
      'Agrupe os servidores de um projeto, cliente ou ambiente.';

  @override
  String get workspaceEditorHint => 'ex.: Pessoal, Trabalho, Homelab';

  @override
  String get saveError => 'Não foi possível salvar. Tente novamente.';

  @override
  String get yourWorkspaces => 'Os seus workspaces';

  @override
  String get workspaceContexts => 'Um espaço para cada contexto.';

  @override
  String get removeWorkspace => 'Remover workspace';

  @override
  String get noWorkspaces => 'Ainda não existem workspaces.';

  @override
  String get removeWorkspaceTitle => 'Remover workspace?';

  @override
  String get removeWorkspaceError =>
      'Não foi possível remover o workspace. Tente novamente.';

  @override
  String get moveInstanceError =>
      'Não foi possível mover a instância. Tente novamente.';

  @override
  String get sshDescription => 'Acesso ao servidor por terminal';

  @override
  String get coolifyDescription => 'Descrição';

  @override
  String get hostRequired => 'Informe o endereço da instância.';

  @override
  String get hostNoSpaces => 'O endereço não pode ter espaços.';

  @override
  String get httpsRequired =>
      'Use uma URL HTTPS, como https://coolify.exemplo.pt.';

  @override
  String get hostOnly => 'Use apenas o hostname ou IP do servidor.';

  @override
  String get privateKeyEmpty => 'A chave privada está vazia.';

  @override
  String get privateKeyFormatError =>
      'Não foi possível ler a chave privada. Verifique o formato e a senha.';

  @override
  String get instanceName => 'Nome da instância';

  @override
  String get instanceHint => 'ex.: producao-brasil';

  @override
  String get instanceNameRequired => 'Dê um nome à instância.';

  @override
  String get hostname => 'Hostname ou IP';

  @override
  String get coolifyUrl => 'URL do Coolify';

  @override
  String get invalidUsername => 'Usuário inválido.';

  @override
  String get authentication => 'Autenticação';

  @override
  String get privateKey => 'Chave privada';

  @override
  String get sshPassword => 'Senha SSH';

  @override
  String get privateKeyLabel => 'Chave privada PEM / OpenSSH';

  @override
  String get privateKeyHint =>
      'Cole a chave completa, incluindo as linhas BEGIN e END.';

  @override
  String get passphraseLabel => 'Senha da chave (opcional)';

  @override
  String get coolifyToken => 'Token da API Coolify';

  @override
  String get coolifyTokenHint =>
      'No Coolify, ative a API e crie um token em Keys & Tokens → API tokens. Tokens de leitura permitem consultar recursos. Para editar, use write; deploys podem exigir deploy ou sensitive. Use a URL base, sem /api/v1.';

  @override
  String get localCredentials =>
      'Configuração e credenciais criptografadas neste dispositivo. A conexão é feita diretamente ao seu servidor, sem conta Capidock.';

  @override
  String get showCredential => 'Mostrar credencial';

  @override
  String get hideCredential => 'Ocultar credencial';

  @override
  String get credentialRequired => 'Informe a credencial.';

  @override
  String get newInstanceTitle => 'Um novo lugar no seu dock.';

  @override
  String get saveConfiguration => 'Salvar configuração';

  @override
  String get findInstance => 'Encontrar instância';

  @override
  String get emptyInstances => 'Este workspace ainda não tem instâncias.';

  @override
  String get noInstancesFound => 'Nenhuma instância encontrada.';

  @override
  String get newInstance => 'Nova instância';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Remover';

  @override
  String get save => 'Salvar';

  @override
  String get rename => 'Renomear';

  @override
  String get back => 'Voltar';

  @override
  String get username => 'Usuário';

  @override
  String get port => 'Porta';

  @override
  String get password => 'Senha';

  @override
  String get server => 'Servidor';

  @override
  String get connected => 'Ligado';

  @override
  String get refresh => 'Atualizar';

  @override
  String get disconnect => 'Desligar';

  @override
  String get workspaceStep => 'WORKSPACE';

  @override
  String get instanceStep => 'INSTÂNCIA';

  @override
  String get connectionStep => 'LIGAÇÃO';

  @override
  String get previousData => ' · dados anteriores';

  @override
  String get language => 'Idioma';

  @override
  String get languageSaveError =>
      'Não foi possível salvar o idioma. Tente novamente.';

  @override
  String emptyWorkspaceBody(String name) {
    return 'Adicione uma instância SSH ou Coolify ao workspace “$name”.';
  }

  @override
  String removeInstanceBody(String name) {
    return 'A configuração de “$name” será removida deste dispositivo. O servidor não será alterado.';
  }

  @override
  String firstInstanceBody(String name) {
    return 'Cada instância é um canal dentro de “$name”. Comece pela primeira.';
  }

  @override
  String configureInstanceBody(String name) {
    return 'Configure o acesso a “$name”. Pode editar estes dados mais tarde.';
  }

  @override
  String onboardingStep(int step, String name) {
    return 'PASSO $step DE 3 · $name';
  }

  @override
  String workspaceLabel(String name) {
    return 'Workspace $name';
  }

  @override
  String workspaceOptions(String name) {
    return 'Opções de $name';
  }

  @override
  String removeWorkspaceBody(String name, int count) {
    return '“$name” e as suas $count instâncias serão removidos deste dispositivo. Os servidores não serão alterados.';
  }

  @override
  String inWorkspace(String name) {
    return 'No workspace “$name”.';
  }

  @override
  String lastRead(String time, String suffix) {
    return 'Última leitura: $time$suffix';
  }

  @override
  String httpError(int code) {
    return 'O Coolify respondeu com erro HTTP $code. Tente novamente.';
  }

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instâncias',
      one: '1 instância',
      zero: '0 instâncias',
    );
    return '$_temp0';
  }

  @override
  String workspaceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count espaços locais',
      one: '1 espaço local',
      zero: '0 espaços locais',
    );
    return '$_temp0';
  }

  @override
  String resourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recursos',
      one: '1 recurso',
      zero: '0 recursos',
    );
    return '$_temp0';
  }

  @override
  String get coolifyOperations => 'Todas as operações';

  @override
  String get coolifyApplications => 'Aplicativos';

  @override
  String get coolifyDatabases => 'Bancos de dados';

  @override
  String get coolifyServices => 'Serviços';

  @override
  String get coolifyProjects => 'Projetos';

  @override
  String get coolifyServers => 'Servidores';

  @override
  String get coolifyPermissions =>
      'A leitura exige read. Para editar, use write; deploys e operações de servidor podem exigir deploy ou sensitive. A versão do Coolify determina as operações disponíveis.';

  @override
  String get coolifySearch => 'Pesquisar recursos ou operações';

  @override
  String get coolifyAll => 'Todas as categorias';

  @override
  String get coolifyCatalogHelp =>
      'Acesse as operações documentadas da API Coolify. Os nomes e descrições dos campos seguem a API oficial. Operações recentes podem não existir em instalações antigas.';

  @override
  String get coolifyDetails => 'Detalhes';

  @override
  String get coolifyEnvironment => 'Ambiente';

  @override
  String get coolifyLogs => 'Logs';

  @override
  String get coolifyBackups => 'Backups';

  @override
  String get coolifyStorages => 'Volumes e arquivos';

  @override
  String get coolifyDeployments => 'Deployments';

  @override
  String get coolifyCreate => 'Criar';

  @override
  String get coolifyEdit => 'Editar configuração';

  @override
  String get coolifyStart => 'Iniciar';

  @override
  String get coolifyStop => 'Parar';

  @override
  String get coolifyRestart => 'Reiniciar';

  @override
  String get coolifyDeploy => 'Fazer deploy';

  @override
  String get coolifyExecutions => 'Histórico de execuções';

  @override
  String get coolifyScheduleBackup => 'Agendar backup';

  @override
  String get coolifyRunBackup => 'Executar backup';

  @override
  String get coolifyEmpty => 'A API não retornou resultados.';

  @override
  String get coolifyConfirm => 'Confirmar operação';

  @override
  String get coolifyDestructive => 'Confirmar operação destrutiva';

  @override
  String get coolifyMutationWarning =>
      'Esta ação altera o servidor remoto. Parar, reiniciar, fazer deploy, restaurar e excluir pode interromper serviços ou remover dados. Verifique o destino antes de continuar.';

  @override
  String coolifyTypeTarget(String target) {
    return 'Digite $target para confirmar.';
  }

  @override
  String get coolifyExecute => 'Executar operação';

  @override
  String get coolifyRead => 'Consultar dados';

  @override
  String get coolifyReveal => 'Mostrar valores e logs (podem conter segredos)';

  @override
  String get coolifyChangedOnly =>
      'Só são enviados os campos alterados. Campos opcionais não alterados mantêm os valores no servidor. Uma string vazia editada limpa o valor. Listas e objetos usam JSON.';

  @override
  String get coolifyInvalidField => 'Verifique o valor e o tipo exigido.';

  @override
  String get coolifyInvalidJson => 'Insira JSON válido.';

  @override
  String get coolifyRequiredPayload =>
      'Preencha pelo menos um campo, todos os campos obrigatórios e escolha um arquivo para uploads.';

  @override
  String get coolifyChooseFile => 'Escolher arquivo de backup';

  @override
  String get coolifySuccess =>
      'Pedido aceito pelo Coolify. As tarefas na fila podem ainda estar em execução; atualize o status.';

  @override
  String get coolifyYes => 'Sim';

  @override
  String get coolifyNo => 'Não';

  @override
  String get coolifyConflict =>
      'Outra operação está em andamento ou a alteração é incompatível com o estado atual. Atualize antes de tentar novamente.';

  @override
  String get coolifyValidationError =>
      'O Coolify rejeitou os campos. Verifique os valores obrigatórios, tipos e a versão da API instalada.';

  @override
  String get coolifyUploadSize =>
      'Escolha um arquivo de backup não vazio de até 10 GiB.';

  @override
  String get coolifyCancelled =>
      'Conexão encerrada. Atualize para verificar se a operação remota foi concluída.';

  @override
  String get coolifySshTerminal =>
      'O Coolify não expõe um terminal interativo pela API REST pública. Escolha uma conexão SSH salva para acessar o servidor.';

  @override
  String get coolifyNoSsh =>
      'Adicione primeiro uma instância SSH deste servidor a um workspace.';

  @override
  String get coolifyResources => 'Recursos';

  @override
  String get coolifyEnvironments => 'Ambientes';

  @override
  String get coolifySharedVariables => 'Variáveis compartilhadas';

  @override
  String get coolifyName => 'Nome';

  @override
  String get coolifyStatus => 'Estado';

  @override
  String get coolifyDomains => 'Domínios';

  @override
  String get coolifyRepository => 'Repositório';

  @override
  String get coolifyBranch => 'Branch';

  @override
  String get coolifyBuildPack => 'Método de build';

  @override
  String get coolifyAddress => 'Endereço';

  @override
  String get coolifyPort => 'Porta';

  @override
  String get coolifyUser => 'Usuário';

  @override
  String get coolifyFrequency => 'Agendamento';

  @override
  String get coolifyEnabled => 'Ativo';

  @override
  String get coolifyMountPath => 'Caminho de montagem';

  @override
  String get coolifyHostPath => 'Caminho no servidor';

  @override
  String get coolifyCreated => 'Criado';

  @override
  String get coolifyUpdated => 'Atualizado';

  @override
  String get coolifyValue => 'Valor';

  @override
  String get coolifyPreview => 'Preview';

  @override
  String get coolifySettings => 'Configurações';

  @override
  String get coolifyType => 'Tipo';

  @override
  String get coolifyRunning => 'Em execução';

  @override
  String get coolifyStopped => 'Parado';

  @override
  String get coolifyConfiguration => 'Configuração';

  @override
  String get coolifyOverviewTitle => 'Visão geral';

  @override
  String get coolifyResourceSearch => 'Pesquisar recursos';

  @override
  String get coolifyOtherSettings => 'Mais configurações';

  @override
  String get coolifyEnvironmentEmpty =>
      'Ainda não existem ambientes neste projeto.';

  @override
  String get coolifyLogsHidden =>
      'Revele os logs para ver o conteúdo. Podem conter segredos.';

  @override
  String get coolifyResourceEmpty =>
      'Ainda não existem recursos neste ambiente.';

  @override
  String get coolifyRestricted => 'Valor protegido pelas permissões do token.';

  @override
  String get coolifyVariables => 'Variáveis de ambiente';

  @override
  String get coolifyNormalVariables => 'Variáveis normais';

  @override
  String get coolifyPreviewVariables => 'Variáveis de preview';

  @override
  String get coolifyShowValue => 'Mostrar valor';

  @override
  String get coolifyHideValue => 'Ocultar valor';

  @override
  String get coolifyEditValue => 'Editar valor';

  @override
  String get coolifySaveValue => 'Salvar valor';

  @override
  String get deviceLocked => 'Capidock bloqueado';

  @override
  String get deviceUnlockReason => 'Desbloquear as credenciais do Capidock';

  @override
  String get deviceUnlock => 'Desbloquear';

  @override
  String get deviceLockHelp =>
      'Configure um PIN, senha ou biometria no dispositivo para continuar.';
}

/// The translations for Portuguese, as used in Portugal (`pt_PT`).
class AppLocalizationsPtPt extends AppLocalizationsPt {
  AppLocalizationsPtPt() : super('pt_PT');

  @override
  String get emptyProjectTitle => 'Um espaço para\ncada projeto.';

  @override
  String get emptyServerTitle => 'O seu próximo servidor\ncomeça aqui.';

  @override
  String get emptyProjectBody =>
      'Crie um workspace para organizar as suas instâncias SSH e Coolify.';

  @override
  String get createWorkspace => 'Criar workspace';

  @override
  String get addInstance => 'Adicionar instância';

  @override
  String get aboutDescription =>
      'Um dock para todos os seus servidores.\n\nCada workspace reúne os seus próprios canais SSH e Coolify. As configurações e credenciais ficam cifradas neste dispositivo. Ligue-se diretamente por SSH ou consulte os recursos da API Coolify.';

  @override
  String get aboutLicence =>
      'Código aberto sob GPL-3.0-only. Pode redistribuir e modificar a app nos termos da licença. Sem garantia, nos limites da lei.\n\nOs textos da licença, créditos e política de marca estão disponíveis em Ver licenças, mesmo sem internet.';

  @override
  String get sourceCode =>
      'Código-fonte: https://github.com/zephyrushq/capidock-mobile';

  @override
  String get removeInstanceTitle => 'Remover instância?';

  @override
  String get removeInstanceError =>
      'Não foi possível remover a instância. Tente novamente.';

  @override
  String get preservedData => 'Os dados guardados foram preservados.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get openInstances => 'Abrir instâncias';

  @override
  String get firstWorkspace => 'Crie o seu primeiro workspace';

  @override
  String get instanceOptions => 'Opções da instância';

  @override
  String get editInstance => 'Editar instância';

  @override
  String get moveInstance => 'Mover para workspace';

  @override
  String get removeInstance => 'Remover instância';

  @override
  String get aboutCapidock => 'Sobre o Capidock';

  @override
  String get unnamedResource => 'Sem nome';

  @override
  String get unavailableStatus => 'Estado indisponível';

  @override
  String get coolifyHttpsError => 'O Coolify requer uma URL HTTPS válida.';

  @override
  String get apiTokenRequired => 'Configure o token da API.';

  @override
  String get invalidToken =>
      'Token inválido ou expirado. Edite a credencial da instância.';

  @override
  String get coolifyAccessDenied =>
      'Acesso recusado. Verifique as permissões do token, a API e a lista de IPs permitidos.';

  @override
  String get apiNotFound =>
      'API não encontrada. Verifique a URL base e se a API está ativa.';

  @override
  String get rateLimited =>
      'Limite de pedidos atingido. Aguarde e tente novamente.';

  @override
  String get redirectError =>
      'O servidor redirecionou o pedido. Configure diretamente a URL HTTPS final.';

  @override
  String get responseTooLarge =>
      'A resposta do Coolify excedeu o limite de 4 MiB.';

  @override
  String get coolifyTimeout =>
      'O Coolify excedeu o tempo limite. Verifique a rede/VPN.';

  @override
  String get invalidApiResponse =>
      'A API devolveu uma resposta inesperada. Verifique a URL e a versão do Coolify.';

  @override
  String get coolifyConnectionError =>
      'Não foi possível contactar o Coolify. Verifique a rede e o certificado HTTPS.';

  @override
  String get sshSessionEnded => 'A sessão SSH terminou. Pode voltar a ligar.';

  @override
  String get systemInfoError =>
      'Não foi possível obter a informação do sistema. O terminal continua disponível. Os comandos de resumo requerem Linux/POSIX.';

  @override
  String get sshAuthError =>
      'Autenticação recusada. Verifique o utilizador e a credencial SSH.';

  @override
  String get sshHostKeyError =>
      'A identidade do servidor não foi aceite. A ligação foi interrompida.';

  @override
  String get sshPrivateKeyError =>
      'Não foi possível ler a chave privada. Verifique a chave e a frase-passe.';

  @override
  String get sshTimeout =>
      'A ligação excedeu o tempo limite. Verifique a rede e a porta SSH.';

  @override
  String get serverUnreachable =>
      'Servidor inacessível. Verifique o endereço, a porta e a rede/VPN.';

  @override
  String get sshConnectionError =>
      'Não foi possível abrir a sessão SSH. Verifique o acesso ao servidor e tente novamente.';

  @override
  String get confirmSshServer => 'Confirmar servidor SSH';

  @override
  String get serverKeyChanged => 'A chave do servidor mudou';

  @override
  String get compareFingerprint =>
      'Compare esta impressão digital com a do seu servidor antes de confiar.';

  @override
  String get changedKeyWarning =>
      'Pode ser uma reinstalação ou uma ligação a outro servidor. Só substitua a chave depois de a verificar por outro meio.';

  @override
  String get savedKey => 'Chave guardada:';

  @override
  String get verifyKeyCommand =>
      'No servidor: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (ajuste ao tipo de chave apresentado).';

  @override
  String get trustAndConnect => 'Confiar e ligar';

  @override
  String get replaceKey => 'Substituir chave';

  @override
  String get yourServer => 'O seu servidor';

  @override
  String get yourResources => 'Os seus recursos';

  @override
  String get connecting => 'A ligar…';

  @override
  String get receivedData => 'Dados recebidos';

  @override
  String get notConnected => 'Por ligar';

  @override
  String get addCredentials =>
      'Adicione uma credencial para ligar esta instância. O endereço guardado foi preservado.';

  @override
  String get configureAccess => 'Configurar acesso';

  @override
  String get connectInstance => 'Ligar à instância';

  @override
  String get editAccess => 'Editar acesso';

  @override
  String get openTerminal => 'Abrir terminal';

  @override
  String get connectForInfo =>
      'Ligue-se para consultar o sistema, uptime, memória e disco, ou usar o terminal interativo.';

  @override
  String get noCoolifyResources =>
      'A API não devolveu recursos para a equipa deste token.';

  @override
  String get coolifyOverview =>
      'Consulte as aplicações, bases de dados e serviços da sua equipa. Os estados vêm diretamente da API Coolify.';

  @override
  String get connectionPrivacy =>
      'As ligações SSH encerram ao mudar de instância ou colocar a app em segundo plano. As credenciais ficam cifradas no dispositivo.';

  @override
  String get activeSshSession => 'Sessão SSH ativa';

  @override
  String get terminalDisconnected => 'Terminal desligado';

  @override
  String get connection => 'Ligação';

  @override
  String get openKeyboard => 'Abrir teclado';

  @override
  String get loadWorkspacesError =>
      'Não foi possível carregar os workspaces guardados.';

  @override
  String get secureSaveError =>
      'Não foi possível guardar no armazenamento seguro. Os campos foram preservados; tente novamente.';

  @override
  String get welcomeTitle => 'Os seus servidores.\nO seu dock.';

  @override
  String get firstServerTitle => 'Dê lugar ao seu\nprimeiro servidor.';

  @override
  String get connectionTitle => 'Como vamos\nligar-nos?';

  @override
  String get welcomeBody =>
      'Bem-vindo ao Capidock. Crie um workspace para reunir as instâncias dos seus projetos.';

  @override
  String get workspaceName => 'Nome do workspace';

  @override
  String get workspaceHint => 'ex.: Pessoal, Empresa ou Projeto';

  @override
  String get workspaceNameRequired => 'Dê um nome ao workspace.';

  @override
  String get saving => 'A guardar…';

  @override
  String get configureConnection => 'Configurar ligação';

  @override
  String get createAndOpen => 'Criar e abrir instância';

  @override
  String get localByChoice =>
      'Local por escolha. Sem conta, sem sincronização.';

  @override
  String get manageWorkspaces => 'Gerir workspaces';

  @override
  String get newWorkspace => 'Novo workspace';

  @override
  String get renameWorkspace => 'Renomear workspace';

  @override
  String get workspaceGrouping =>
      'Agrupe os servidores de um projeto, cliente ou ambiente.';

  @override
  String get workspaceEditorHint => 'ex.: Pessoal, Trabalho, Homelab';

  @override
  String get saveError => 'Não foi possível guardar. Tente novamente.';

  @override
  String get yourWorkspaces => 'Os seus workspaces';

  @override
  String get workspaceContexts => 'Um espaço para cada contexto.';

  @override
  String get removeWorkspace => 'Remover workspace';

  @override
  String get noWorkspaces => 'Ainda não existem workspaces.';

  @override
  String get removeWorkspaceTitle => 'Remover workspace?';

  @override
  String get removeWorkspaceError =>
      'Não foi possível remover o workspace. Tente novamente.';

  @override
  String get moveInstanceError =>
      'Não foi possível mover a instância. Tente novamente.';

  @override
  String get sshDescription => 'Acesso ao servidor por terminal';

  @override
  String get coolifyDescription => 'Descrição';

  @override
  String get hostRequired => 'Informe o endereço da instância.';

  @override
  String get hostNoSpaces => 'O endereço não pode ter espaços.';

  @override
  String get httpsRequired =>
      'Use uma URL HTTPS, como https://coolify.exemplo.pt.';

  @override
  String get hostOnly => 'Use apenas o hostname ou IP do servidor.';

  @override
  String get privateKeyEmpty => 'A chave privada está vazia.';

  @override
  String get privateKeyFormatError =>
      'Não foi possível ler a chave privada. Verifique o formato e a frase-passe.';

  @override
  String get instanceName => 'Nome da instância';

  @override
  String get instanceHint => 'ex.: produção-europa';

  @override
  String get instanceNameRequired => 'Dê um nome à instância.';

  @override
  String get hostname => 'Hostname ou IP';

  @override
  String get coolifyUrl => 'URL do Coolify';

  @override
  String get invalidUsername => 'Utilizador inválido.';

  @override
  String get authentication => 'Autenticação';

  @override
  String get privateKey => 'Chave privada';

  @override
  String get sshPassword => 'Palavra-passe SSH';

  @override
  String get privateKeyLabel => 'Chave privada PEM / OpenSSH';

  @override
  String get privateKeyHint =>
      'Cole a chave completa, incluindo as linhas BEGIN e END.';

  @override
  String get passphraseLabel => 'Frase-passe da chave (opcional)';

  @override
  String get coolifyToken => 'Token da API Coolify';

  @override
  String get coolifyTokenHint =>
      'No Coolify, ative a API e crie um token em Keys & Tokens → API tokens. Tokens de leitura permitem consultar recursos. Para editar, use write; deploys podem exigir deploy ou sensitive. Use a URL base, sem /api/v1.';

  @override
  String get localCredentials =>
      'Configuração e credenciais cifradas neste dispositivo. A ligação é feita diretamente ao seu servidor, sem conta Capidock.';

  @override
  String get showCredential => 'Mostrar credencial';

  @override
  String get hideCredential => 'Ocultar credencial';

  @override
  String get credentialRequired => 'Informe a credencial.';

  @override
  String get newInstanceTitle => 'Um novo lugar no seu dock.';

  @override
  String get saveConfiguration => 'Guardar configuração';

  @override
  String get findInstance => 'Encontrar instância';

  @override
  String get emptyInstances => 'Este workspace ainda não tem instâncias.';

  @override
  String get noInstancesFound => 'Nenhuma instância encontrada.';

  @override
  String get newInstance => 'Nova instância';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Remover';

  @override
  String get save => 'Guardar';

  @override
  String get rename => 'Renomear';

  @override
  String get back => 'Voltar';

  @override
  String get username => 'Utilizador';

  @override
  String get port => 'Porta';

  @override
  String get password => 'Palavra-passe';

  @override
  String get server => 'Servidor';

  @override
  String get connected => 'Ligado';

  @override
  String get refresh => 'Atualizar';

  @override
  String get disconnect => 'Desligar';

  @override
  String get workspaceStep => 'WORKSPACE';

  @override
  String get instanceStep => 'INSTÂNCIA';

  @override
  String get connectionStep => 'LIGAÇÃO';

  @override
  String get previousData => ' · dados anteriores';

  @override
  String get language => 'Idioma';

  @override
  String get languageSaveError =>
      'Não foi possível guardar o idioma. Tente novamente.';

  @override
  String emptyWorkspaceBody(String name) {
    return 'Adicione uma instância SSH ou Coolify ao workspace “$name”.';
  }

  @override
  String removeInstanceBody(String name) {
    return 'A configuração de “$name” será removida deste dispositivo. O servidor não será alterado.';
  }

  @override
  String firstInstanceBody(String name) {
    return 'Cada instância é um canal dentro de “$name”. Comece pela primeira.';
  }

  @override
  String configureInstanceBody(String name) {
    return 'Configure o acesso a “$name”. Pode editar estes dados mais tarde.';
  }

  @override
  String onboardingStep(int step, String name) {
    return 'PASSO $step DE 3 · $name';
  }

  @override
  String workspaceLabel(String name) {
    return 'Workspace $name';
  }

  @override
  String workspaceOptions(String name) {
    return 'Opções de $name';
  }

  @override
  String removeWorkspaceBody(String name, int count) {
    return '“$name” e as suas $count instâncias serão removidos deste dispositivo. Os servidores não serão alterados.';
  }

  @override
  String inWorkspace(String name) {
    return 'No workspace “$name”.';
  }

  @override
  String lastRead(String time, String suffix) {
    return 'Última leitura: $time$suffix';
  }

  @override
  String httpError(int code) {
    return 'O Coolify respondeu com erro HTTP $code. Tente novamente.';
  }

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instâncias',
      one: '1 instância',
      zero: '0 instâncias',
    );
    return '$_temp0';
  }

  @override
  String workspaceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count espaços locais',
      one: '1 espaço local',
      zero: '0 espaços locais',
    );
    return '$_temp0';
  }

  @override
  String resourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recursos',
      one: '1 recurso',
      zero: '0 recursos',
    );
    return '$_temp0';
  }

  @override
  String get coolifyOperations => 'Todas as operações';

  @override
  String get coolifyApplications => 'Aplicações';

  @override
  String get coolifyDatabases => 'Bases de dados';

  @override
  String get coolifyServices => 'Serviços';

  @override
  String get coolifyProjects => 'Projetos';

  @override
  String get coolifyServers => 'Servidores';

  @override
  String get coolifyPermissions =>
      'A leitura requer read. Para editar, use write; deploys e operações de servidor podem exigir deploy ou sensitive. A versão do Coolify determina as operações disponíveis.';

  @override
  String get coolifySearch => 'Pesquisar recursos ou operações';

  @override
  String get coolifyAll => 'Todas as categorias';

  @override
  String get coolifyCatalogHelp =>
      'Aceda às operações documentadas da API Coolify. Os nomes e descrições dos campos seguem a API oficial. Operações recentes podem não existir em instalações antigas.';

  @override
  String get coolifyDetails => 'Detalhes';

  @override
  String get coolifyEnvironment => 'Ambiente';

  @override
  String get coolifyLogs => 'Logs';

  @override
  String get coolifyBackups => 'Backups';

  @override
  String get coolifyStorages => 'Volumes e ficheiros';

  @override
  String get coolifyDeployments => 'Deployments';

  @override
  String get coolifyCreate => 'Criar';

  @override
  String get coolifyEdit => 'Editar configuração';

  @override
  String get coolifyStart => 'Iniciar';

  @override
  String get coolifyStop => 'Parar';

  @override
  String get coolifyRestart => 'Reiniciar';

  @override
  String get coolifyDeploy => 'Fazer deploy';

  @override
  String get coolifyExecutions => 'Histórico de execuções';

  @override
  String get coolifyScheduleBackup => 'Agendar backup';

  @override
  String get coolifyRunBackup => 'Executar backup';

  @override
  String get coolifyEmpty => 'A API não devolveu resultados.';

  @override
  String get coolifyConfirm => 'Confirmar operação';

  @override
  String get coolifyDestructive => 'Confirmar operação destrutiva';

  @override
  String get coolifyMutationWarning =>
      'Esta ação altera o servidor remoto. Parar, reiniciar, fazer deploy, restaurar e eliminar pode interromper serviços ou remover dados. Verifique o destino antes de continuar.';

  @override
  String coolifyTypeTarget(String target) {
    return 'Escreva $target para confirmar.';
  }

  @override
  String get coolifyExecute => 'Executar operação';

  @override
  String get coolifyRead => 'Consultar dados';

  @override
  String get coolifyReveal => 'Mostrar valores e logs (podem conter segredos)';

  @override
  String get coolifyChangedOnly =>
      'Só são enviados os campos alterados. Os campos opcionais não alterados mantêm os valores no servidor. Uma cadeia vazia editada limpa o valor. Listas e objetos usam JSON.';

  @override
  String get coolifyInvalidField => 'Verifique o valor e o tipo exigido.';

  @override
  String get coolifyInvalidJson => 'Introduza JSON válido.';

  @override
  String get coolifyRequiredPayload =>
      'Preencha pelo menos um campo, todos os campos obrigatórios e escolha um ficheiro para uploads.';

  @override
  String get coolifyChooseFile => 'Escolher ficheiro de backup';

  @override
  String get coolifySuccess =>
      'Pedido aceite pelo Coolify. As tarefas em fila podem ainda estar em execução; atualize o estado.';

  @override
  String get coolifyYes => 'Sim';

  @override
  String get coolifyNo => 'Não';

  @override
  String get coolifyConflict =>
      'Outra operação está em curso ou a alteração é incompatível com o estado atual. Atualize antes de tentar novamente.';

  @override
  String get coolifyValidationError =>
      'O Coolify rejeitou os campos. Verifique os valores obrigatórios, tipos e a versão da API instalada.';

  @override
  String get coolifyUploadSize =>
      'Escolha um ficheiro de backup não vazio até 10 GiB.';

  @override
  String get coolifyCancelled =>
      'Ligação encerrada. Atualize para verificar se a operação remota foi concluída.';

  @override
  String get coolifySshTerminal =>
      'O Coolify não expõe um terminal interativo pela API REST pública. Escolha uma ligação SSH guardada para aceder ao servidor.';

  @override
  String get coolifyNoSsh =>
      'Adicione primeiro uma instância SSH deste servidor a um workspace.';

  @override
  String get coolifyResources => 'Recursos';

  @override
  String get coolifyEnvironments => 'Ambientes';

  @override
  String get coolifySharedVariables => 'Variáveis partilhadas';

  @override
  String get coolifyName => 'Nome';

  @override
  String get coolifyStatus => 'Estado';

  @override
  String get coolifyDomains => 'Domínios';

  @override
  String get coolifyRepository => 'Repositório';

  @override
  String get coolifyBranch => 'Branch';

  @override
  String get coolifyBuildPack => 'Método de build';

  @override
  String get coolifyAddress => 'Endereço';

  @override
  String get coolifyPort => 'Porta';

  @override
  String get coolifyUser => 'Utilizador';

  @override
  String get coolifyFrequency => 'Agendamento';

  @override
  String get coolifyEnabled => 'Ativo';

  @override
  String get coolifyMountPath => 'Caminho de montagem';

  @override
  String get coolifyHostPath => 'Caminho no servidor';

  @override
  String get coolifyCreated => 'Criado';

  @override
  String get coolifyUpdated => 'Atualizado';

  @override
  String get coolifyValue => 'Valor';

  @override
  String get coolifyPreview => 'Preview';

  @override
  String get coolifySettings => 'Definições';

  @override
  String get coolifyType => 'Tipo';

  @override
  String get coolifyRunning => 'Em execução';

  @override
  String get coolifyStopped => 'Parado';

  @override
  String get coolifyConfiguration => 'Configuração';

  @override
  String get coolifyOverviewTitle => 'Visão geral';

  @override
  String get coolifyResourceSearch => 'Pesquisar recursos';

  @override
  String get coolifyOtherSettings => 'Mais definições';

  @override
  String get coolifyEnvironmentEmpty =>
      'Ainda não existem ambientes neste projeto.';

  @override
  String get coolifyLogsHidden =>
      'Revele os logs para ver o conteúdo. Podem conter segredos.';

  @override
  String get coolifyResourceEmpty =>
      'Ainda não existem recursos neste ambiente.';

  @override
  String get coolifyRestricted => 'Valor protegido pelas permissões do token.';

  @override
  String get coolifyVariables => 'Variáveis de ambiente';

  @override
  String get coolifyNormalVariables => 'Variáveis normais';

  @override
  String get coolifyPreviewVariables => 'Variáveis de preview';

  @override
  String get coolifyShowValue => 'Mostrar valor';

  @override
  String get coolifyHideValue => 'Ocultar valor';

  @override
  String get coolifyEditValue => 'Editar valor';

  @override
  String get coolifySaveValue => 'Guardar valor';

  @override
  String get deviceLocked => 'Capidock bloqueado';

  @override
  String get deviceUnlockReason => 'Desbloquear as credenciais do Capidock';

  @override
  String get deviceUnlock => 'Desbloquear';

  @override
  String get deviceLockHelp =>
      'Configure um PIN, palavra-passe ou biometria no dispositivo para continuar.';
}
