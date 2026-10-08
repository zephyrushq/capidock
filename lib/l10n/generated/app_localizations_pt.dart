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

  @override
  String get termsOfUse => 'Termos de Uso';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String legalUpdated(String date) {
    return 'Atualizado: $date';
  }

  @override
  String get legalLoadError =>
      'Não foi possível carregar este documento. Volte a abri-lo.';

  @override
  String get help => 'Ajuda';

  @override
  String get appSettings => 'Definições da app';

  @override
  String get terminalFontSize => 'Tamanho do texto do terminal';

  @override
  String get lockNow => 'Bloquear agora';

  @override
  String get trustedSshKeys => 'Identidades SSH de confiança';

  @override
  String get trustedSshHelp =>
      'Compara as fingerprints com o teu servidor antes de confiar. Esquecer uma identidade pede confirmação na próxima ligação; uma sessão existente mantém-se ligada.';

  @override
  String get localStorage => 'Armazenamento local';

  @override
  String localCounts(int workspaces, int instances) {
    return '$workspaces workspaces · $instances instâncias';
  }

  @override
  String get eraseLocalData => 'Apagar dados de servidores guardados';

  @override
  String get eraseLocalWarning =>
      'Remove permanentemente todos os workspaces, credenciais e identidades SSH deste dispositivo. Os teus servidores não são alterados. Requer autenticação do dispositivo.';

  @override
  String get eraseAuthReason =>
      'Autentica-te para apagar os dados de servidores do Capidock';

  @override
  String get localEraseFailed =>
      'Não foi possível verificar a eliminação de todos os dados locais de servidores. Desbloqueia e verifica os dados guardados antes de tentar novamente.';

  @override
  String get noTrustedKeys => 'Sem identidades de confiança';

  @override
  String get forgetSshWarning =>
      'Esquecer esta identidade SSH? Terás de verificar a fingerprint na próxima ligação.';

  @override
  String get tokenAccess => 'Acesso do token';

  @override
  String get tokenAccessHelp =>
      'Estas são observações dos pedidos nesta sessão, não as permissões exatas do token. A API pública não indica se um token é readonly ou root. Permissões não verificadas ficam desconhecidas. Só erros explícitos de permissão desativam ações; falhas genéricas também podem vir de regras de IP ou proxies. O servidor valida cada pedido.';

  @override
  String get accessUnknown => 'Desconhecido';

  @override
  String get accessObserved => 'Observado';

  @override
  String get accessDenied => 'Recusado';

  @override
  String get coolifyPermissionDenied =>
      'O servidor indicou falta de permissão para esta ação. Edita o token e volta a ligar para verificar novamente.';

  @override
  String get testConnection => 'Testar ligação';

  @override
  String get connectionVerified => 'Ligação verificada';

  @override
  String get connectionTestHelp =>
      'Testa a autenticação sem guardar o formulário. O SSH não abre terminal nem executa comandos; a confiança confirmada aqui é temporária. O Coolify usa um pedido de leitura da API, sem testes de escrita ou deploy.';

  @override
  String get noSearchResults => 'Nenhum recurso corresponde à pesquisa.';

  @override
  String get logsPause => 'Pausar logs em direto';

  @override
  String get logsResume => 'Retomar logs em direto';

  @override
  String get logsFollow => 'Acompanhar últimas linhas';

  @override
  String get backupTitle => 'Backup cifrado';

  @override
  String get backupEncrypted => 'Ficheiro protegido por palavra-passe';

  @override
  String get backupContents => 'Workspaces e credenciais de ligação';

  @override
  String get backupExport => 'Exportar backup';

  @override
  String get backupImport => 'Importar backup';

  @override
  String get backupPassword => 'Palavra-passe do backup';

  @override
  String get backupConfirmPassword => 'Confirmar palavra-passe';

  @override
  String get backupPasswordWeak => 'Use pelo menos 12 caracteres.';

  @override
  String get backupPasswordMismatch => 'As palavras-passe não coincidem.';

  @override
  String get backupPasswordHelp =>
      'Guarde esta palavra-passe. O Capidock não a pode recuperar.';

  @override
  String get backupHelp =>
      'Os backups incluem workspaces e credenciais guardados. A cifra AES-256-GCM usa uma chave derivada da palavra-passe, que não é guardada. Não incluem identidades SSH de confiança, preferências ou dados dos servidores. O fornecedor de ficheiros escolhido pode sincronizar o ficheiro cifrado. A importação adiciona cópias e exige confirmar novamente as identidades SSH.';

  @override
  String get backupImportWarning =>
      'Estes workspaces serão adicionados como novas cópias. Os dados existentes são mantidos. Confirme as impressões digitais SSH antes de ligar.';

  @override
  String get backupAuthReason => 'Autentique-se para gerir backups cifrados.';

  @override
  String get backupExported => 'Backup cifrado guardado.';

  @override
  String get backupImported => 'Workspaces importados.';

  @override
  String get backupFailed =>
      'Não foi possível concluir a operação. Os dados guardados não foram substituídos.';

  @override
  String get backupInvalid => 'Backup inválido ou não suportado.';

  @override
  String get backupUnlockFailed =>
      'Palavra-passe incorreta ou backup alterado.';

  @override
  String get backupTooLarge => 'O backup excede o limite de tamanho.';

  @override
  String get backupFileFailed =>
      'Não foi possível aceder ao ficheiro do backup.';

  @override
  String get listSearch => 'Pesquisar';

  @override
  String get listAllStatuses => 'Todos os estados';

  @override
  String get listPrevious => 'Anterior';

  @override
  String get listNext => 'Seguinte';

  @override
  String get listNoMatches => 'Nenhum resultado corresponde aos filtros.';

  @override
  String listPage(int page) {
    return 'Página $page';
  }

  @override
  String get logsLevelAll => 'Todos os níveis';

  @override
  String get logsLevelErrors => 'Erros';

  @override
  String get logsLevelWarnings => 'Avisos';

  @override
  String get logsLineLimit => 'Linhas de logs';

  @override
  String get listHistory => 'Histórico';

  @override
  String get listSchedule => 'Agendamento';

  @override
  String get listDetails => 'Detalhes';

  @override
  String get listPageFilterHelp =>
      'A pesquisa e os filtros aplicam-se à página atual do servidor. Use as setas para consultar deployments anteriores.';

  @override
  String get activitySize => 'Tamanho do ficheiro';

  @override
  String get activityCommit => 'Mensagem do commit';

  @override
  String get activityFinished => 'Concluído';

  @override
  String get activityEnabled => 'Ativo';

  @override
  String get logsShow => 'Mostrar logs';

  @override
  String get logsHide => 'Ocultar logs';

  @override
  String get coolifyTerminalServer => 'Servidor Coolify';

  @override
  String get coolifyTerminalContainer => 'Terminal do container';

  @override
  String get coolifyTerminalHost => 'Terminal do servidor';

  @override
  String get coolifyTerminalNoContainers =>
      'Não foram encontrados containers em execução para este recurso.';

  @override
  String get coolifyTerminalServersFailed =>
      'Não foi possível carregar os servidores. Verifica as permissões da API e a ligação.';

  @override
  String get coolifyTerminalLinkFailed =>
      'Não foi possível ler a associação SSH guardada.';

  @override
  String get coolifyTerminalConnectFailed =>
      'Não foi possível ligar ou guardar a associação SSH. Verifica as credenciais e o armazenamento seguro.';

  @override
  String get coolifyTerminalDockerFailed =>
      'Não foi possível listar os containers. Verifica o acesso ao Docker deste utilizador SSH.';

  @override
  String get coolifyTerminalContainerGone =>
      'O container já não está em execução ou já não pertence a este recurso. Atualiza a lista.';

  @override
  String get coolifyTerminalShellFailed =>
      'Não foi possível abrir o terminal. Verifica se a shell escolhida está instalada. Volta a ligar para tentar novamente.';

  @override
  String get coolifyTerminalHelp =>
      'Associa a ligação SSH correta ao servidor Coolify selecionado. As credenciais permanecem cifradas no dispositivo. O token da API não é uma credencial SSH. As permissões SSH e Docker são independentes do token: o acesso ao Docker pode dar controlo total sobre o servidor. A lista mostra apenas containers em execução deste recurso. Fecha a sessão ao terminar; as sessões também fecham em segundo plano.';

  @override
  String get sftpFiles => 'Ficheiros';

  @override
  String get sftpUpload => 'Enviar ficheiro';

  @override
  String get sftpDownload => 'Descarregar';

  @override
  String get sftpReplace => 'Substituir o ficheiro remoto?';

  @override
  String get sftpNewFolder => 'Nova pasta';

  @override
  String get sftpRename => 'Renomear';

  @override
  String get sftpEditText => 'Editar texto';

  @override
  String get sftpParent => 'Pasta superior';

  @override
  String get sftpEmpty => 'Esta pasta está vazia.';

  @override
  String get sftpInvalidName =>
      'Usa um nome sem barras ou caracteres de controlo.';

  @override
  String get sftpPermissionDenied => 'O servidor recusou a permissão.';

  @override
  String get sftpFailed =>
      'O SFTP falhou. Verifica o acesso, as permissões e o suporte do subsistema; volta a ligar para tentar novamente.';

  @override
  String get sftpDirectoryLimit =>
      'Esta pasta excede o limite de 5 000 entradas.';

  @override
  String get sftpRegularOnly =>
      'Esta ação aceita apenas ficheiros regulares, não ligações simbólicas.';

  @override
  String get sftpTooLarge =>
      'Limite de transferência: 16 MiB. Limite do editor: 256 KiB.';

  @override
  String get sftpTextOnly => 'O editor aceita texto UTF-8 sem bytes nulos.';

  @override
  String get sftpExists => 'O destino já existe ou não é um ficheiro regular.';

  @override
  String get sftpChanged =>
      'O ficheiro remoto mudou. Volta a carregá-lo antes de guardar.';

  @override
  String get sftpLocalFailed =>
      'Não foi possível aceder ao documento local selecionado.';

  @override
  String get sftpHelp =>
      'O SFTP usa esta ligação SSH verificada e as permissões do servidor. Transferências até 16 MiB; edição UTF-8 até 256 KiB. Os ficheiros não são guardados em cache no telemóvel. Os downloads ficam no local escolhido, que o fornecedor pode sincronizar. O SSH fecha enquanto o seletor está aberto; os uploads voltam a ligar após autenticação no dispositivo. Só são apagados ficheiros, ligações ou pastas vazias. Uma transferência interrompida pode deixar um ficheiro remoto parcial. A substituição requer suporte para renomear sobre o destino; se falhar, o original é preservado.';

  @override
  String get sftpConfirm => 'Confirmar';

  @override
  String get monitorTitle => 'Monitorização';

  @override
  String get monitorHelp =>
      'As verificações são locais, neste telemóvel. O Android pode adiá-las em repouso ou após uma paragem forçada. Uma falha pode dever-se à rede ou VPN; não prova que o servidor caiu. Duas falhas consecutivas geram um alerta. A disponibilidade é a percentagem de verificações acessíveis nos últimos 30 dias, não um uptime contínuo. Verificações offline ou desconhecidas não contam. No Coolify são analisados os últimos 20 deployments e a saúde dos recursos; falhas existentes servem de referência inicial. O SSH requer uma chave de servidor já confiada.';

  @override
  String get monitorEnable => 'Ativar monitorização';

  @override
  String get monitorConsent =>
      'Permitir que o Capidock utilize as credenciais cifradas desta instância para verificações de leitura em segundo plano, mesmo com a app bloqueada? O histórico fica cifrado localmente.';

  @override
  String get monitorInterval => 'Intervalo em segundo plano';

  @override
  String get monitorPermission => 'Notificações permitidas';

  @override
  String get monitorPermissionOff => 'As notificações estão desativadas';

  @override
  String get monitorRequest => 'Permitir notificações';

  @override
  String get monitorCheck => 'Verificar em breve';

  @override
  String get monitorScheduled =>
      'Verificação agendada. O Android decide quando a executa.';

  @override
  String get monitorEmpty => 'Crie uma instância para iniciar a monitorização.';

  @override
  String get monitorNoChecks => 'Ainda sem verificações';

  @override
  String get monitorObserved => 'Disponibilidade observada';

  @override
  String get monitorHistory => 'Histórico · últimos 30 dias';

  @override
  String get monitorAlerts => 'Alertas';

  @override
  String get monitorAlertConnections => 'Problemas de ligação e acesso';

  @override
  String get monitorAlertDeployments => 'Eventos de deployments';

  @override
  String get monitorAlertResources => 'Alterações de estado dos recursos';

  @override
  String get monitorAlertRecovery => 'Recuperação';

  @override
  String get monitorUp => 'Acessível';

  @override
  String get monitorDown => 'Falha de ligação';

  @override
  String get monitorOffline => 'Telemóvel offline';

  @override
  String get monitorAuthentication => 'Verifique credenciais ou permissões';

  @override
  String get monitorIdentity => 'Identidade SSH não verificada';

  @override
  String get monitorUnknown => 'Verificação incompleta';

  @override
  String get monitorStale => 'À espera de nova verificação';

  @override
  String get monitorLatency => 'Latência';

  @override
  String get monitorLimit => 'Pode monitorizar até 20 instâncias.';

  @override
  String get monitorFastTitle => 'Monitorização rápida do Coolify';

  @override
  String get monitorFastHelp =>
      'Verifica as instâncias Coolify ativadas enquanto a app está aberta e desbloqueada. Pausa em segundo plano. Ligações lentas podem atrasar as verificações; eventos breves podem passar despercebidos.';

  @override
  String get monitorFastInterval => 'Intervalo com a app aberta';

  @override
  String get monitorDeploymentStarted => 'Deployment iniciado';

  @override
  String get monitorDeploymentSucceeded => 'Deployment concluído';

  @override
  String get monitorDeploymentCancelled => 'Deployment cancelado';

  @override
  String get monitorResourceChanged => 'Estado do recurso alterado';

  @override
  String get monitorDeploymentFailed => 'Deployment falhou';

  @override
  String get monitorResourceUnhealthy => 'Recurso com problemas';
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

  @override
  String get termsOfUse => 'Termos de Uso';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String legalUpdated(String date) {
    return 'Atualizado: $date';
  }

  @override
  String get legalLoadError =>
      'Não foi possível carregar este documento. Volte a abri-lo.';

  @override
  String get help => 'Ajuda';

  @override
  String get appSettings => 'Configurações do app';

  @override
  String get terminalFontSize => 'Tamanho do texto do terminal';

  @override
  String get lockNow => 'Bloquear agora';

  @override
  String get trustedSshKeys => 'Identidades SSH confiáveis';

  @override
  String get trustedSshHelp =>
      'Compare as fingerprints com seu servidor antes de confiar. Esquecer uma identidade pede confirmação na próxima conexão; uma sessão existente continua conectada.';

  @override
  String get localStorage => 'Armazenamento local';

  @override
  String localCounts(int workspaces, int instances) {
    return '$workspaces workspaces · $instances instâncias';
  }

  @override
  String get eraseLocalData => 'Apagar dados de servidores salvos';

  @override
  String get eraseLocalWarning =>
      'Remove permanentemente todos os workspaces, credenciais e identidades SSH deste dispositivo. Seus servidores não são alterados. Requer autenticação do dispositivo.';

  @override
  String get eraseAuthReason =>
      'Autentique-se para apagar os dados de servidores do Capidock';

  @override
  String get localEraseFailed =>
      'Não foi possível verificar a exclusão de todos os dados locais de servidores. Desbloqueie e confira os dados salvos antes de tentar novamente.';

  @override
  String get noTrustedKeys => 'Sem identidades confiáveis';

  @override
  String get forgetSshWarning =>
      'Esquecer esta identidade SSH? Você precisará verificar a fingerprint na próxima conexão.';

  @override
  String get tokenAccess => 'Acesso do token';

  @override
  String get tokenAccessHelp =>
      'Estas são observações dos pedidos nesta sessão, não as permissões exatas do token. A API pública não informa se um token é readonly ou root. Permissões não verificadas ficam desconhecidas. Só erros explícitos de permissão desativam ações; falhas genéricas também podem vir de regras de IP ou proxies. O servidor valida cada pedido.';

  @override
  String get accessUnknown => 'Desconhecido';

  @override
  String get accessObserved => 'Observado';

  @override
  String get accessDenied => 'Recusado';

  @override
  String get coolifyPermissionDenied =>
      'O servidor informou falta de permissão para esta ação. Edite o token e conecte novamente para verificar.';

  @override
  String get testConnection => 'Testar conexão';

  @override
  String get connectionVerified => 'Conexão verificada';

  @override
  String get connectionTestHelp =>
      'Testa a autenticação sem salvar o formulário. O SSH não abre terminal nem executa comandos; a confiança confirmada aqui é temporária. O Coolify usa um pedido de leitura da API, sem testes de escrita ou deploy.';

  @override
  String get noSearchResults => 'Nenhum recurso corresponde à pesquisa.';

  @override
  String get logsPause => 'Pausar logs ao vivo';

  @override
  String get logsResume => 'Retomar logs ao vivo';

  @override
  String get logsFollow => 'Acompanhar últimas linhas';

  @override
  String get backupTitle => 'Backup criptografado';

  @override
  String get backupEncrypted => 'Arquivo protegido por senha';

  @override
  String get backupContents => 'Workspaces e credenciais de conexão';

  @override
  String get backupExport => 'Exportar backup';

  @override
  String get backupImport => 'Importar backup';

  @override
  String get backupPassword => 'Senha do backup';

  @override
  String get backupConfirmPassword => 'Confirmar senha';

  @override
  String get backupPasswordWeak => 'Use pelo menos 12 caracteres.';

  @override
  String get backupPasswordMismatch => 'As senhas não coincidem.';

  @override
  String get backupPasswordHelp =>
      'Guarde esta senha. O Capidock não pode recuperá-la.';

  @override
  String get backupHelp =>
      'Os backups incluem workspaces e credenciais salvos. A criptografia AES-256-GCM usa uma chave derivada da senha, que não é salva. Não incluem identidades SSH confiáveis, preferências ou dados dos servidores. O provedor de arquivos escolhido pode sincronizar o arquivo criptografado. A importação adiciona cópias e exige confirmar novamente as identidades SSH.';

  @override
  String get backupImportWarning =>
      'Estes workspaces serão adicionados como novas cópias. Os dados existentes serão mantidos. Verifique as impressões digitais SSH antes de conectar.';

  @override
  String get backupAuthReason =>
      'Autentique-se para gerenciar backups criptografados.';

  @override
  String get backupExported => 'Backup criptografado salvo.';

  @override
  String get backupImported => 'Workspaces importados.';

  @override
  String get backupFailed =>
      'Não foi possível concluir a operação. Os dados salvos não foram substituídos.';

  @override
  String get backupInvalid => 'Backup inválido ou não suportado.';

  @override
  String get backupUnlockFailed => 'Senha incorreta ou backup alterado.';

  @override
  String get backupTooLarge => 'O backup excede o limite de tamanho.';

  @override
  String get backupFileFailed =>
      'Não foi possível acessar o arquivo do backup.';

  @override
  String get listSearch => 'Pesquisar';

  @override
  String get listAllStatuses => 'Todos os estados';

  @override
  String get listPrevious => 'Anterior';

  @override
  String get listNext => 'Próxima';

  @override
  String get listNoMatches => 'Nenhum resultado corresponde aos filtros.';

  @override
  String listPage(int page) {
    return 'Página $page';
  }

  @override
  String get logsLevelAll => 'Todos os níveis';

  @override
  String get logsLevelErrors => 'Erros';

  @override
  String get logsLevelWarnings => 'Avisos';

  @override
  String get logsLineLimit => 'Linhas de logs';

  @override
  String get listHistory => 'Histórico';

  @override
  String get listSchedule => 'Agendamento';

  @override
  String get listDetails => 'Detalhes';

  @override
  String get listPageFilterHelp =>
      'A pesquisa e os filtros se aplicam à página atual do servidor. Use as setas para consultar deployments anteriores.';

  @override
  String get activitySize => 'Tamanho do arquivo';

  @override
  String get activityCommit => 'Mensagem do commit';

  @override
  String get activityFinished => 'Concluído';

  @override
  String get activityEnabled => 'Ativo';

  @override
  String get logsShow => 'Mostrar logs';

  @override
  String get logsHide => 'Ocultar logs';

  @override
  String get coolifyTerminalServer => 'Servidor Coolify';

  @override
  String get coolifyTerminalContainer => 'Terminal do container';

  @override
  String get coolifyTerminalHost => 'Terminal do servidor';

  @override
  String get coolifyTerminalNoContainers =>
      'Nenhum container em execução encontrado para este recurso.';

  @override
  String get coolifyTerminalServersFailed =>
      'Não foi possível carregar os servidores. Verifique as permissões da API e a conexão.';

  @override
  String get coolifyTerminalLinkFailed =>
      'Não foi possível ler a associação SSH salva.';

  @override
  String get coolifyTerminalConnectFailed =>
      'Não foi possível conectar ou salvar a associação SSH. Verifique as credenciais e o armazenamento seguro.';

  @override
  String get coolifyTerminalDockerFailed =>
      'Não foi possível listar os containers. Verifique o acesso ao Docker deste usuário SSH.';

  @override
  String get coolifyTerminalContainerGone =>
      'O container não está mais em execução ou não pertence mais a este recurso. Atualize a lista.';

  @override
  String get coolifyTerminalShellFailed =>
      'Não foi possível abrir o terminal. Verifique se o shell escolhido está instalado. Conecte novamente para tentar.';

  @override
  String get coolifyTerminalHelp =>
      'Associe a conexão SSH correta ao servidor Coolify selecionado. As credenciais permanecem criptografadas no dispositivo. O token da API não é uma credencial SSH. As permissões SSH e Docker são independentes do token: o acesso ao Docker pode dar controle total sobre o servidor. A lista mostra apenas containers em execução deste recurso. Feche a sessão ao terminar; as sessões também fecham em segundo plano.';

  @override
  String get sftpFiles => 'Arquivos';

  @override
  String get sftpUpload => 'Enviar arquivo';

  @override
  String get sftpDownload => 'Baixar';

  @override
  String get sftpReplace => 'Substituir o arquivo remoto?';

  @override
  String get sftpNewFolder => 'Nova pasta';

  @override
  String get sftpRename => 'Renomear';

  @override
  String get sftpEditText => 'Editar texto';

  @override
  String get sftpParent => 'Pasta superior';

  @override
  String get sftpEmpty => 'Esta pasta está vazia.';

  @override
  String get sftpInvalidName =>
      'Use um nome sem barras ou caracteres de controle.';

  @override
  String get sftpPermissionDenied => 'O servidor negou a permissão.';

  @override
  String get sftpFailed =>
      'O SFTP falhou. Verifique o acesso, as permissões e o suporte do subsistema; conecte novamente para tentar.';

  @override
  String get sftpDirectoryLimit =>
      'Esta pasta excede o limite de 5.000 entradas.';

  @override
  String get sftpRegularOnly =>
      'Esta ação aceita apenas arquivos regulares, não links simbólicos.';

  @override
  String get sftpTooLarge =>
      'Limite de transferência: 16 MiB. Limite do editor: 256 KiB.';

  @override
  String get sftpTextOnly => 'O editor aceita texto UTF-8 sem bytes nulos.';

  @override
  String get sftpExists => 'O destino já existe ou não é um arquivo regular.';

  @override
  String get sftpChanged =>
      'O arquivo remoto mudou. Carregue novamente antes de salvar.';

  @override
  String get sftpLocalFailed =>
      'Não foi possível acessar o documento local selecionado.';

  @override
  String get sftpHelp =>
      'O SFTP usa esta conexão SSH verificada e as permissões do servidor. Transferências até 16 MiB; edição UTF-8 até 256 KiB. Os arquivos não são guardados em cache no celular. Os downloads ficam no local escolhido, que o provedor pode sincronizar. O SSH fecha enquanto o seletor está aberto; os uploads reconectam após autenticação no dispositivo. Só são apagados arquivos, links ou pastas vazias. Uma transferência interrompida pode deixar um arquivo remoto parcial. A substituição requer suporte para renomear sobre o destino; se falhar, o original é preservado.';

  @override
  String get sftpConfirm => 'Confirmar';

  @override
  String get monitorTitle => 'Monitoramento';

  @override
  String get monitorHelp =>
      'As verificações são locais, neste celular. O Android pode adiá-las em repouso ou após uma paragem forçada. Uma falha pode dever-se à rede ou VPN; não prova que o servidor caiu. Duas falhas consecutivas geram um alerta. A disponibilidade é a percentagem de verificações acessíveis nos últimos 30 dias, não um uptime contínuo. Verificações offline ou desconhecidas não contam. No Coolify são analisados os últimos 20 deployments e a saúde dos recursos; falhas existentes servem de referência inicial. O SSH requer uma chave de servidor já confiada.';

  @override
  String get monitorEnable => 'Ativar monitoramento';

  @override
  String get monitorConsent =>
      'Permitir que o Capidock utilize as credenciais criptografadas desta instância para verificações de leitura em segundo plano, mesmo com a app bloqueada? O histórico fica criptografado localmente.';

  @override
  String get monitorInterval => 'Intervalo em segundo plano';

  @override
  String get monitorPermission => 'Notificações permitidas';

  @override
  String get monitorPermissionOff => 'As notificações estão desativadas';

  @override
  String get monitorRequest => 'Permitir notificações';

  @override
  String get monitorCheck => 'Verificar em breve';

  @override
  String get monitorScheduled =>
      'Verificação agendada. O Android decide quando a executa.';

  @override
  String get monitorEmpty => 'Crie uma instância para iniciar a monitoramento.';

  @override
  String get monitorNoChecks => 'Ainda sem verificações';

  @override
  String get monitorObserved => 'Disponibilidade observada';

  @override
  String get monitorHistory => 'Histórico · últimos 30 dias';

  @override
  String get monitorAlerts => 'Alertas';

  @override
  String get monitorAlertConnections => 'Problemas de conexão e acesso';

  @override
  String get monitorAlertDeployments => 'Eventos de deployments';

  @override
  String get monitorAlertResources => 'Alterações de estado dos recursos';

  @override
  String get monitorAlertRecovery => 'Recuperação';

  @override
  String get monitorUp => 'Acessível';

  @override
  String get monitorDown => 'Falha de conexão';

  @override
  String get monitorOffline => 'Celular offline';

  @override
  String get monitorAuthentication => 'Verifique credenciais ou permissões';

  @override
  String get monitorIdentity => 'Identidade SSH não verificada';

  @override
  String get monitorUnknown => 'Verificação incompleta';

  @override
  String get monitorStale => 'À espera de nova verificação';

  @override
  String get monitorLatency => 'Latência';

  @override
  String get monitorLimit => 'Pode monitorizar até 20 instâncias.';

  @override
  String get monitorFastTitle => 'Monitorização rápida do Coolify';

  @override
  String get monitorFastHelp =>
      'Verifica as instâncias Coolify ativadas enquanto a app está aberta e desbloqueada. Pausa em segundo plano. Ligações lentas podem atrasar as verificações; eventos breves podem passar despercebidos.';

  @override
  String get monitorFastInterval => 'Intervalo com a app aberta';

  @override
  String get monitorDeploymentStarted => 'Deployment iniciado';

  @override
  String get monitorDeploymentSucceeded => 'Deployment concluído';

  @override
  String get monitorDeploymentCancelled => 'Deployment cancelado';

  @override
  String get monitorResourceChanged => 'Estado do recurso alterado';

  @override
  String get monitorDeploymentFailed => 'Deployment falhou';

  @override
  String get monitorResourceUnhealthy => 'Recurso com problemas';
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

  @override
  String get termsOfUse => 'Termos de Uso';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String legalUpdated(String date) {
    return 'Atualizado: $date';
  }

  @override
  String get legalLoadError =>
      'Não foi possível carregar este documento. Volte a abri-lo.';

  @override
  String get help => 'Ajuda';

  @override
  String get appSettings => 'Definições da app';

  @override
  String get terminalFontSize => 'Tamanho do texto do terminal';

  @override
  String get lockNow => 'Bloquear agora';

  @override
  String get trustedSshKeys => 'Identidades SSH de confiança';

  @override
  String get trustedSshHelp =>
      'Compara as fingerprints com o teu servidor antes de confiar. Esquecer uma identidade pede confirmação na próxima ligação; uma sessão existente mantém-se ligada.';

  @override
  String get localStorage => 'Armazenamento local';

  @override
  String localCounts(int workspaces, int instances) {
    return '$workspaces workspaces · $instances instâncias';
  }

  @override
  String get eraseLocalData => 'Apagar dados de servidores guardados';

  @override
  String get eraseLocalWarning =>
      'Remove permanentemente todos os workspaces, credenciais e identidades SSH deste dispositivo. Os teus servidores não são alterados. Requer autenticação do dispositivo.';

  @override
  String get eraseAuthReason =>
      'Autentica-te para apagar os dados de servidores do Capidock';

  @override
  String get localEraseFailed =>
      'Não foi possível verificar a eliminação de todos os dados locais de servidores. Desbloqueia e verifica os dados guardados antes de tentar novamente.';

  @override
  String get noTrustedKeys => 'Sem identidades de confiança';

  @override
  String get forgetSshWarning =>
      'Esquecer esta identidade SSH? Terás de verificar a fingerprint na próxima ligação.';

  @override
  String get tokenAccess => 'Acesso do token';

  @override
  String get tokenAccessHelp =>
      'Estas são observações dos pedidos nesta sessão, não as permissões exatas do token. A API pública não indica se um token é readonly ou root. Permissões não verificadas ficam desconhecidas. Só erros explícitos de permissão desativam ações; falhas genéricas também podem vir de regras de IP ou proxies. O servidor valida cada pedido.';

  @override
  String get accessUnknown => 'Desconhecido';

  @override
  String get accessObserved => 'Observado';

  @override
  String get accessDenied => 'Recusado';

  @override
  String get coolifyPermissionDenied =>
      'O servidor indicou falta de permissão para esta ação. Edita o token e volta a ligar para verificar novamente.';

  @override
  String get testConnection => 'Testar ligação';

  @override
  String get connectionVerified => 'Ligação verificada';

  @override
  String get connectionTestHelp =>
      'Testa a autenticação sem guardar o formulário. O SSH não abre terminal nem executa comandos; a confiança confirmada aqui é temporária. O Coolify usa um pedido de leitura da API, sem testes de escrita ou deploy.';

  @override
  String get noSearchResults => 'Nenhum recurso corresponde à pesquisa.';

  @override
  String get logsPause => 'Pausar logs em direto';

  @override
  String get logsResume => 'Retomar logs em direto';

  @override
  String get logsFollow => 'Acompanhar últimas linhas';

  @override
  String get backupTitle => 'Backup cifrado';

  @override
  String get backupEncrypted => 'Ficheiro protegido por palavra-passe';

  @override
  String get backupContents => 'Workspaces e credenciais de ligação';

  @override
  String get backupExport => 'Exportar backup';

  @override
  String get backupImport => 'Importar backup';

  @override
  String get backupPassword => 'Palavra-passe do backup';

  @override
  String get backupConfirmPassword => 'Confirmar palavra-passe';

  @override
  String get backupPasswordWeak => 'Use pelo menos 12 caracteres.';

  @override
  String get backupPasswordMismatch => 'As palavras-passe não coincidem.';

  @override
  String get backupPasswordHelp =>
      'Guarde esta palavra-passe. O Capidock não a pode recuperar.';

  @override
  String get backupHelp =>
      'Os backups incluem workspaces e credenciais guardados. A cifra AES-256-GCM usa uma chave derivada da palavra-passe, que não é guardada. Não incluem identidades SSH de confiança, preferências ou dados dos servidores. O fornecedor de ficheiros escolhido pode sincronizar o ficheiro cifrado. A importação adiciona cópias e exige confirmar novamente as identidades SSH.';

  @override
  String get backupImportWarning =>
      'Estes workspaces serão adicionados como novas cópias. Os dados existentes são mantidos. Confirme as impressões digitais SSH antes de ligar.';

  @override
  String get backupAuthReason => 'Autentique-se para gerir backups cifrados.';

  @override
  String get backupExported => 'Backup cifrado guardado.';

  @override
  String get backupImported => 'Workspaces importados.';

  @override
  String get backupFailed =>
      'Não foi possível concluir a operação. Os dados guardados não foram substituídos.';

  @override
  String get backupInvalid => 'Backup inválido ou não suportado.';

  @override
  String get backupUnlockFailed =>
      'Palavra-passe incorreta ou backup alterado.';

  @override
  String get backupTooLarge => 'O backup excede o limite de tamanho.';

  @override
  String get backupFileFailed =>
      'Não foi possível aceder ao ficheiro do backup.';

  @override
  String get listSearch => 'Pesquisar';

  @override
  String get listAllStatuses => 'Todos os estados';

  @override
  String get listPrevious => 'Anterior';

  @override
  String get listNext => 'Seguinte';

  @override
  String get listNoMatches => 'Nenhum resultado corresponde aos filtros.';

  @override
  String listPage(int page) {
    return 'Página $page';
  }

  @override
  String get logsLevelAll => 'Todos os níveis';

  @override
  String get logsLevelErrors => 'Erros';

  @override
  String get logsLevelWarnings => 'Avisos';

  @override
  String get logsLineLimit => 'Linhas de logs';

  @override
  String get listHistory => 'Histórico';

  @override
  String get listSchedule => 'Agendamento';

  @override
  String get listDetails => 'Detalhes';

  @override
  String get listPageFilterHelp =>
      'A pesquisa e os filtros aplicam-se à página atual do servidor. Use as setas para consultar deployments anteriores.';

  @override
  String get activitySize => 'Tamanho do ficheiro';

  @override
  String get activityCommit => 'Mensagem do commit';

  @override
  String get activityFinished => 'Concluído';

  @override
  String get activityEnabled => 'Ativo';

  @override
  String get logsShow => 'Mostrar logs';

  @override
  String get logsHide => 'Ocultar logs';

  @override
  String get coolifyTerminalServer => 'Servidor Coolify';

  @override
  String get coolifyTerminalContainer => 'Terminal do container';

  @override
  String get coolifyTerminalHost => 'Terminal do servidor';

  @override
  String get coolifyTerminalNoContainers =>
      'Não foram encontrados containers em execução para este recurso.';

  @override
  String get coolifyTerminalServersFailed =>
      'Não foi possível carregar os servidores. Verifica as permissões da API e a ligação.';

  @override
  String get coolifyTerminalLinkFailed =>
      'Não foi possível ler a associação SSH guardada.';

  @override
  String get coolifyTerminalConnectFailed =>
      'Não foi possível ligar ou guardar a associação SSH. Verifica as credenciais e o armazenamento seguro.';

  @override
  String get coolifyTerminalDockerFailed =>
      'Não foi possível listar os containers. Verifica o acesso ao Docker deste utilizador SSH.';

  @override
  String get coolifyTerminalContainerGone =>
      'O container já não está em execução ou já não pertence a este recurso. Atualiza a lista.';

  @override
  String get coolifyTerminalShellFailed =>
      'Não foi possível abrir o terminal. Verifica se a shell escolhida está instalada. Volta a ligar para tentar novamente.';

  @override
  String get coolifyTerminalHelp =>
      'Associa a ligação SSH correta ao servidor Coolify selecionado. As credenciais permanecem cifradas no dispositivo. O token da API não é uma credencial SSH. As permissões SSH e Docker são independentes do token: o acesso ao Docker pode dar controlo total sobre o servidor. A lista mostra apenas containers em execução deste recurso. Fecha a sessão ao terminar; as sessões também fecham em segundo plano.';

  @override
  String get sftpFiles => 'Ficheiros';

  @override
  String get sftpUpload => 'Enviar ficheiro';

  @override
  String get sftpDownload => 'Descarregar';

  @override
  String get sftpReplace => 'Substituir o ficheiro remoto?';

  @override
  String get sftpNewFolder => 'Nova pasta';

  @override
  String get sftpRename => 'Renomear';

  @override
  String get sftpEditText => 'Editar texto';

  @override
  String get sftpParent => 'Pasta superior';

  @override
  String get sftpEmpty => 'Esta pasta está vazia.';

  @override
  String get sftpInvalidName =>
      'Usa um nome sem barras ou caracteres de controlo.';

  @override
  String get sftpPermissionDenied => 'O servidor recusou a permissão.';

  @override
  String get sftpFailed =>
      'O SFTP falhou. Verifica o acesso, as permissões e o suporte do subsistema; volta a ligar para tentar novamente.';

  @override
  String get sftpDirectoryLimit =>
      'Esta pasta excede o limite de 5 000 entradas.';

  @override
  String get sftpRegularOnly =>
      'Esta ação aceita apenas ficheiros regulares, não ligações simbólicas.';

  @override
  String get sftpTooLarge =>
      'Limite de transferência: 16 MiB. Limite do editor: 256 KiB.';

  @override
  String get sftpTextOnly => 'O editor aceita texto UTF-8 sem bytes nulos.';

  @override
  String get sftpExists => 'O destino já existe ou não é um ficheiro regular.';

  @override
  String get sftpChanged =>
      'O ficheiro remoto mudou. Volta a carregá-lo antes de guardar.';

  @override
  String get sftpLocalFailed =>
      'Não foi possível aceder ao documento local selecionado.';

  @override
  String get sftpHelp =>
      'O SFTP usa esta ligação SSH verificada e as permissões do servidor. Transferências até 16 MiB; edição UTF-8 até 256 KiB. Os ficheiros não são guardados em cache no telemóvel. Os downloads ficam no local escolhido, que o fornecedor pode sincronizar. O SSH fecha enquanto o seletor está aberto; os uploads voltam a ligar após autenticação no dispositivo. Só são apagados ficheiros, ligações ou pastas vazias. Uma transferência interrompida pode deixar um ficheiro remoto parcial. A substituição requer suporte para renomear sobre o destino; se falhar, o original é preservado.';

  @override
  String get sftpConfirm => 'Confirmar';

  @override
  String get monitorTitle => 'Monitorização';

  @override
  String get monitorHelp =>
      'As verificações são locais, neste telemóvel. O Android pode adiá-las em repouso ou após uma paragem forçada. Uma falha pode dever-se à rede ou VPN; não prova que o servidor caiu. Duas falhas consecutivas geram um alerta. A disponibilidade é a percentagem de verificações acessíveis nos últimos 30 dias, não um uptime contínuo. Verificações offline ou desconhecidas não contam. No Coolify são analisados os últimos 20 deployments e a saúde dos recursos; falhas existentes servem de referência inicial. O SSH requer uma chave de servidor já confiada.';

  @override
  String get monitorEnable => 'Ativar monitorização';

  @override
  String get monitorConsent =>
      'Permitir que o Capidock utilize as credenciais cifradas desta instância para verificações de leitura em segundo plano, mesmo com a app bloqueada? O histórico fica cifrado localmente.';

  @override
  String get monitorInterval => 'Intervalo em segundo plano';

  @override
  String get monitorPermission => 'Notificações permitidas';

  @override
  String get monitorPermissionOff => 'As notificações estão desativadas';

  @override
  String get monitorRequest => 'Permitir notificações';

  @override
  String get monitorCheck => 'Verificar em breve';

  @override
  String get monitorScheduled =>
      'Verificação agendada. O Android decide quando a executa.';

  @override
  String get monitorEmpty => 'Crie uma instância para iniciar a monitorização.';

  @override
  String get monitorNoChecks => 'Ainda sem verificações';

  @override
  String get monitorObserved => 'Disponibilidade observada';

  @override
  String get monitorHistory => 'Histórico · últimos 30 dias';

  @override
  String get monitorAlerts => 'Alertas';

  @override
  String get monitorAlertConnections => 'Problemas de ligação e acesso';

  @override
  String get monitorAlertDeployments => 'Eventos de deployments';

  @override
  String get monitorAlertResources => 'Alterações de estado dos recursos';

  @override
  String get monitorAlertRecovery => 'Recuperação';

  @override
  String get monitorUp => 'Acessível';

  @override
  String get monitorDown => 'Falha de ligação';

  @override
  String get monitorOffline => 'Telemóvel offline';

  @override
  String get monitorAuthentication => 'Verifique credenciais ou permissões';

  @override
  String get monitorIdentity => 'Identidade SSH não verificada';

  @override
  String get monitorUnknown => 'Verificação incompleta';

  @override
  String get monitorStale => 'À espera de nova verificação';

  @override
  String get monitorLatency => 'Latência';

  @override
  String get monitorLimit => 'Pode monitorizar até 20 instâncias.';

  @override
  String get monitorFastTitle => 'Monitorização rápida do Coolify';

  @override
  String get monitorFastHelp =>
      'Verifica as instâncias Coolify ativadas enquanto a app está aberta e desbloqueada. Pausa em segundo plano. Ligações lentas podem atrasar as verificações; eventos breves podem passar despercebidos.';

  @override
  String get monitorFastInterval => 'Intervalo com a app aberta';

  @override
  String get monitorDeploymentStarted => 'Deployment iniciado';

  @override
  String get monitorDeploymentSucceeded => 'Deployment concluído';

  @override
  String get monitorDeploymentCancelled => 'Deployment cancelado';

  @override
  String get monitorResourceChanged => 'Estado do recurso alterado';

  @override
  String get monitorDeploymentFailed => 'Deployment falhou';

  @override
  String get monitorResourceUnhealthy => 'Recurso com problemas';
}
