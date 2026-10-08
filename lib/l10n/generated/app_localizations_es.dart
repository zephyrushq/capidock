// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get emptyProjectTitle => 'Un espacio para\ncada proyecto.';

  @override
  String get emptyServerTitle => 'Tu próximo servidor\nempieza aquí.';

  @override
  String get emptyProjectBody =>
      'Crea un espacio de trabajo para organizar tus instancias SSH y Coolify.';

  @override
  String get createWorkspace => 'Crear espacio de trabajo';

  @override
  String get addInstance => 'Añadir instancia';

  @override
  String get aboutDescription =>
      'Un dock para todos tus servidores.\n\nCada espacio de trabajo reúne tus canales SSH y Coolify. La configuración y las credenciales se guardan cifradas en este dispositivo. Conéctate por SSH o consulta los recursos de la API de Coolify.';

  @override
  String get aboutLicence =>
      'Código abierto bajo GPL-3.0-only. Puedes redistribuir y modificar la app según la licencia. Sin garantía, dentro de los límites legales.\n\nLas licencias, los créditos y la política de marca están disponibles en Ver licencias, incluso sin conexión.';

  @override
  String get sourceCode =>
      'Código fuente: https://github.com/zephyrushq/capidock-mobile';

  @override
  String get removeInstanceTitle => '¿Eliminar instancia?';

  @override
  String get removeInstanceError =>
      'No se pudo eliminar la instancia. Inténtalo de nuevo.';

  @override
  String get preservedData => 'Los datos guardados se han conservado.';

  @override
  String get retry => 'Reintentar';

  @override
  String get openInstances => 'Abrir instancias';

  @override
  String get firstWorkspace => 'Crea tu primer espacio de trabajo';

  @override
  String get instanceOptions => 'Opciones de la instancia';

  @override
  String get editInstance => 'Editar instancia';

  @override
  String get moveInstance => 'Mover a otro espacio de trabajo';

  @override
  String get removeInstance => 'Eliminar instancia';

  @override
  String get aboutCapidock => 'Acerca de Capidock';

  @override
  String get unnamedResource => 'Sin nombre';

  @override
  String get unavailableStatus => 'Estado no disponible';

  @override
  String get coolifyHttpsError => 'Coolify requiere una URL HTTPS válida.';

  @override
  String get apiTokenRequired => 'Configura el token de la API.';

  @override
  String get invalidToken =>
      'Token no válido o caducado. Edita la credencial de la instancia.';

  @override
  String get coolifyAccessDenied =>
      'Acceso denegado. Comprueba los permisos del token, la API y la lista de IP permitidas.';

  @override
  String get apiNotFound =>
      'API no encontrada. Comprueba la URL base y si la API está habilitada.';

  @override
  String get rateLimited =>
      'Límite de solicitudes alcanzado. Espera e inténtalo de nuevo.';

  @override
  String get redirectError =>
      'El servidor redirigió la solicitud. Configura directamente la URL HTTPS final.';

  @override
  String get responseTooLarge =>
      'La respuesta de Coolify superó el límite de 4 MiB.';

  @override
  String get coolifyTimeout =>
      'Coolify agotó el tiempo de espera. Comprueba la red/VPN.';

  @override
  String get invalidApiResponse =>
      'La API devolvió una respuesta inesperada. Comprueba la URL y la versión de Coolify.';

  @override
  String get coolifyConnectionError =>
      'No se pudo contactar con Coolify. Comprueba la red y el certificado HTTPS.';

  @override
  String get sshSessionEnded =>
      'La sesión SSH ha terminado. Puedes volver a conectarte.';

  @override
  String get systemInfoError =>
      'No se pudo obtener la información del sistema. El terminal sigue disponible. Los comandos de resumen requieren Linux/POSIX.';

  @override
  String get sshAuthError =>
      'Autenticación rechazada. Comprueba el usuario y la credencial SSH.';

  @override
  String get sshHostKeyError =>
      'No se aceptó la identidad del servidor. Se interrumpió la conexión.';

  @override
  String get sshPrivateKeyError =>
      'No se pudo leer la clave privada. Comprueba la clave y su contraseña.';

  @override
  String get sshTimeout =>
      'La conexión agotó el tiempo de espera. Comprueba la red y el puerto SSH.';

  @override
  String get serverUnreachable =>
      'Servidor inaccesible. Comprueba la dirección, el puerto y la red/VPN.';

  @override
  String get sshConnectionError =>
      'No se pudo abrir la sesión SSH. Comprueba el acceso al servidor e inténtalo de nuevo.';

  @override
  String get confirmSshServer => 'Confirmar servidor SSH';

  @override
  String get serverKeyChanged => 'La clave del servidor ha cambiado';

  @override
  String get compareFingerprint =>
      'Compara esta huella con la de tu servidor antes de confiar.';

  @override
  String get changedKeyWarning =>
      'Puede ser una reinstalación o una conexión a otro servidor. Sustituye la clave solo después de verificarla por otro medio.';

  @override
  String get savedKey => 'Clave guardada:';

  @override
  String get verifyKeyCommand =>
      'En el servidor: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (ajusta el comando al tipo de clave mostrado).';

  @override
  String get trustAndConnect => 'Confiar y conectar';

  @override
  String get replaceKey => 'Sustituir clave';

  @override
  String get yourServer => 'Tu servidor';

  @override
  String get yourResources => 'Tus recursos';

  @override
  String get connecting => 'Conectando…';

  @override
  String get receivedData => 'Datos recibidos';

  @override
  String get notConnected => 'Sin conectar';

  @override
  String get addCredentials =>
      'Añade una credencial para conectar esta instancia. Se ha conservado la dirección guardada.';

  @override
  String get configureAccess => 'Configurar acceso';

  @override
  String get connectInstance => 'Conectar a la instancia';

  @override
  String get editAccess => 'Editar acceso';

  @override
  String get openTerminal => 'Abrir terminal';

  @override
  String get connectForInfo =>
      'Conéctate para consultar el sistema, el tiempo de actividad, la memoria y el disco, o usar el terminal interactivo.';

  @override
  String get noCoolifyResources =>
      'La API no devolvió recursos para el equipo de este token.';

  @override
  String get coolifyOverview =>
      'Consulta las aplicaciones, bases de datos y servicios de tu equipo. Los estados proceden directamente de la API de Coolify.';

  @override
  String get connectionPrivacy =>
      'Las conexiones SSH se cierran al cambiar de instancia o poner la app en segundo plano. Las credenciales se guardan cifradas en el dispositivo.';

  @override
  String get activeSshSession => 'Sesión SSH activa';

  @override
  String get terminalDisconnected => 'Terminal desconectado';

  @override
  String get connection => 'Conexión';

  @override
  String get openKeyboard => 'Abrir teclado';

  @override
  String get loadWorkspacesError =>
      'No se pudieron cargar los espacios de trabajo guardados.';

  @override
  String get secureSaveError =>
      'No se pudo guardar en el almacenamiento seguro. Se han conservado los campos; inténtalo de nuevo.';

  @override
  String get welcomeTitle => 'Tus servidores.\nTu dock.';

  @override
  String get firstServerTitle => 'Haz sitio para\ntu primer servidor.';

  @override
  String get connectionTitle => '¿Cómo vamos\na conectarnos?';

  @override
  String get welcomeBody =>
      'Bienvenido a Capidock. Crea un espacio de trabajo para reunir las instancias de tus proyectos.';

  @override
  String get workspaceName => 'Nombre del espacio de trabajo';

  @override
  String get workspaceHint => 'p. ej.: Personal, Empresa o Proyecto';

  @override
  String get workspaceNameRequired => 'Pon un nombre al espacio de trabajo.';

  @override
  String get saving => 'Guardando…';

  @override
  String get configureConnection => 'Configurar conexión';

  @override
  String get createAndOpen => 'Crear y abrir instancia';

  @override
  String get localByChoice =>
      'Local por elección. Sin cuenta ni sincronización.';

  @override
  String get manageWorkspaces => 'Gestionar espacios de trabajo';

  @override
  String get newWorkspace => 'Nuevo espacio de trabajo';

  @override
  String get renameWorkspace => 'Renombrar espacio de trabajo';

  @override
  String get workspaceGrouping =>
      'Agrupa los servidores por proyecto, cliente o entorno.';

  @override
  String get workspaceEditorHint => 'p. ej.: Personal, Trabajo, Homelab';

  @override
  String get saveError => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get yourWorkspaces => 'Tus espacios de trabajo';

  @override
  String get workspaceContexts => 'Un espacio para cada contexto.';

  @override
  String get removeWorkspace => 'Eliminar espacio de trabajo';

  @override
  String get noWorkspaces => 'Todavía no hay espacios de trabajo.';

  @override
  String get removeWorkspaceTitle => '¿Eliminar espacio de trabajo?';

  @override
  String get removeWorkspaceError =>
      'No se pudo eliminar el espacio de trabajo. Inténtalo de nuevo.';

  @override
  String get moveInstanceError =>
      'No se pudo mover la instancia. Inténtalo de nuevo.';

  @override
  String get sshDescription => 'Acceso al servidor mediante terminal';

  @override
  String get coolifyDescription => 'Descripción';

  @override
  String get hostRequired => 'Introduce la dirección de la instancia.';

  @override
  String get hostNoSpaces => 'La dirección no puede contener espacios.';

  @override
  String get httpsRequired =>
      'Usa una URL HTTPS, como https://coolify.example.com.';

  @override
  String get hostOnly => 'Usa solo el nombre de host o la IP del servidor.';

  @override
  String get privateKeyEmpty => 'La clave privada está vacía.';

  @override
  String get privateKeyFormatError =>
      'No se pudo leer la clave privada. Comprueba el formato y su contraseña.';

  @override
  String get instanceName => 'Nombre de la instancia';

  @override
  String get instanceHint => 'p. ej.: produccion-europa';

  @override
  String get instanceNameRequired => 'Pon un nombre a la instancia.';

  @override
  String get hostname => 'Nombre de host o IP';

  @override
  String get coolifyUrl => 'URL de Coolify';

  @override
  String get invalidUsername => 'Usuario no válido.';

  @override
  String get authentication => 'Autenticación';

  @override
  String get privateKey => 'Clave privada';

  @override
  String get sshPassword => 'Contraseña SSH';

  @override
  String get privateKeyLabel => 'Clave privada PEM / OpenSSH';

  @override
  String get privateKeyHint =>
      'Pega la clave completa, incluidas las líneas BEGIN y END.';

  @override
  String get passphraseLabel => 'Contraseña de la clave (opcional)';

  @override
  String get coolifyToken => 'Token de la API de Coolify';

  @override
  String get coolifyTokenHint =>
      'En Coolify, habilita la API y crea un token en Keys & Tokens → API tokens. Los tokens de lectura permiten consultar recursos. Para editar, usa write; los despliegues pueden requerir deploy o sensitive. Usa la URL base sin /api/v1.';

  @override
  String get localCredentials =>
      'La configuración y las credenciales se cifran en este dispositivo. La conexión es directa con tu servidor, sin cuenta de Capidock.';

  @override
  String get showCredential => 'Mostrar credencial';

  @override
  String get hideCredential => 'Ocultar credencial';

  @override
  String get credentialRequired => 'Introduce la credencial.';

  @override
  String get newInstanceTitle => 'Un nuevo lugar en tu dock.';

  @override
  String get saveConfiguration => 'Guardar configuración';

  @override
  String get findInstance => 'Buscar instancia';

  @override
  String get emptyInstances =>
      'Este espacio de trabajo todavía no tiene instancias.';

  @override
  String get noInstancesFound => 'No se encontraron instancias.';

  @override
  String get newInstance => 'Nueva instancia';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get rename => 'Renombrar';

  @override
  String get back => 'Volver';

  @override
  String get username => 'Usuario';

  @override
  String get port => 'Puerto';

  @override
  String get password => 'Contraseña';

  @override
  String get server => 'Servidor';

  @override
  String get connected => 'Conectado';

  @override
  String get refresh => 'Actualizar';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get workspaceStep => 'ESPACIO DE TRABAJO';

  @override
  String get instanceStep => 'INSTANCIA';

  @override
  String get connectionStep => 'CONEXIÓN';

  @override
  String get previousData => ' · datos anteriores';

  @override
  String get language => 'Idioma';

  @override
  String get languageSaveError =>
      'No se pudo guardar el idioma. Inténtalo de nuevo.';

  @override
  String emptyWorkspaceBody(String name) {
    return 'Añade una instancia SSH o Coolify al espacio de trabajo «$name».';
  }

  @override
  String removeInstanceBody(String name) {
    return 'La configuración de «$name» se eliminará de este dispositivo. El servidor no se modificará.';
  }

  @override
  String firstInstanceBody(String name) {
    return 'Cada instancia es un canal dentro de «$name». Empieza por la primera.';
  }

  @override
  String configureInstanceBody(String name) {
    return 'Configura el acceso a «$name». Puedes editar estos datos más adelante.';
  }

  @override
  String onboardingStep(int step, String name) {
    return 'PASO $step DE 3 · $name';
  }

  @override
  String workspaceLabel(String name) {
    return 'Espacio de trabajo $name';
  }

  @override
  String workspaceOptions(String name) {
    return 'Opciones de $name';
  }

  @override
  String removeWorkspaceBody(String name, int count) {
    return '«$name» y sus instancias ($count) se eliminarán de este dispositivo. Los servidores no se modificarán.';
  }

  @override
  String inWorkspace(String name) {
    return 'En el espacio de trabajo «$name».';
  }

  @override
  String lastRead(String time, String suffix) {
    return 'Última lectura: $time$suffix';
  }

  @override
  String httpError(int code) {
    return 'Coolify respondió con el error HTTP $code. Inténtalo de nuevo.';
  }

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instancias',
      one: '1 instancia',
      zero: '0 instancias',
    );
    return '$_temp0';
  }

  @override
  String workspaceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count espacios locales',
      one: '1 espacio local',
      zero: '0 espacios locales',
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
  String get coolifyOperations => 'Todas las operaciones';

  @override
  String get coolifyApplications => 'Aplicaciones';

  @override
  String get coolifyDatabases => 'Bases de datos';

  @override
  String get coolifyServices => 'Servicios';

  @override
  String get coolifyProjects => 'Proyectos';

  @override
  String get coolifyServers => 'Servidores';

  @override
  String get coolifyPermissions =>
      'La lectura requiere read. Para editar, usa write; los despliegues y las operaciones de servidor pueden requerir deploy o sensitive. La versión de Coolify determina las operaciones disponibles.';

  @override
  String get coolifySearch => 'Buscar recursos u operaciones';

  @override
  String get coolifyAll => 'Todas las categorías';

  @override
  String get coolifyCatalogHelp =>
      'Accede a las operaciones documentadas de la API de Coolify. Los nombres y las descripciones de los campos siguen la API oficial. Las operaciones recientes pueden no existir en instalaciones antiguas.';

  @override
  String get coolifyDetails => 'Detalles';

  @override
  String get coolifyEnvironment => 'Entorno';

  @override
  String get coolifyLogs => 'Registros';

  @override
  String get coolifyBackups => 'Copias de seguridad';

  @override
  String get coolifyStorages => 'Volúmenes y archivos';

  @override
  String get coolifyDeployments => 'Despliegues';

  @override
  String get coolifyCreate => 'Crear';

  @override
  String get coolifyEdit => 'Editar configuración';

  @override
  String get coolifyStart => 'Iniciar';

  @override
  String get coolifyStop => 'Detener';

  @override
  String get coolifyRestart => 'Reiniciar';

  @override
  String get coolifyDeploy => 'Desplegar';

  @override
  String get coolifyExecutions => 'Historial de ejecuciones';

  @override
  String get coolifyScheduleBackup => 'Programar copia';

  @override
  String get coolifyRunBackup => 'Ejecutar copia';

  @override
  String get coolifyEmpty => 'La API no devolvió resultados.';

  @override
  String get coolifyConfirm => 'Confirmar operación';

  @override
  String get coolifyDestructive => 'Confirmar operación destructiva';

  @override
  String get coolifyMutationWarning =>
      'Esta acción modifica el servidor remoto. Detener, reiniciar, desplegar, restaurar y eliminar puede interrumpir servicios o borrar datos. Comprueba el destino antes de continuar.';

  @override
  String coolifyTypeTarget(String target) {
    return 'Escribe $target para confirmar.';
  }

  @override
  String get coolifyExecute => 'Ejecutar operación';

  @override
  String get coolifyRead => 'Consultar datos';

  @override
  String get coolifyReveal =>
      'Mostrar valores y registros (pueden contener secretos)';

  @override
  String get coolifyChangedOnly =>
      'Solo se envían los campos editados. Los campos opcionales sin editar mantienen sus valores en el servidor. Una cadena vacía editada borra el valor. Las listas y los objetos usan JSON.';

  @override
  String get coolifyInvalidField => 'Comprueba el valor y el tipo requerido.';

  @override
  String get coolifyInvalidJson => 'Introduce JSON válido.';

  @override
  String get coolifyRequiredPayload =>
      'Rellena al menos un campo, todos los campos obligatorios y elige un archivo para subir.';

  @override
  String get coolifyChooseFile => 'Elegir archivo de copia de seguridad';

  @override
  String get coolifySuccess =>
      'Solicitud aceptada por Coolify. Las tareas en cola pueden seguir ejecutándose; actualiza su estado.';

  @override
  String get coolifyYes => 'Sí';

  @override
  String get coolifyNo => 'No';

  @override
  String get coolifyConflict =>
      'Hay otra operación en curso o el cambio entra en conflicto con el estado actual. Actualiza antes de volver a intentarlo.';

  @override
  String get coolifyValidationError =>
      'Coolify rechazó los campos. Comprueba los valores obligatorios, los tipos y la versión instalada de la API.';

  @override
  String get coolifyUploadSize =>
      'Elige un archivo de copia de seguridad no vacío de hasta 10 GiB.';

  @override
  String get coolifyCancelled =>
      'Conexión cerrada. Actualiza para comprobar si la operación remota se completó.';

  @override
  String get coolifySshTerminal =>
      'Coolify no ofrece un terminal interactivo mediante su API REST pública. Elige una conexión SSH guardada para acceder al servidor.';

  @override
  String get coolifyNoSsh =>
      'Añade primero una instancia SSH de este servidor a un workspace.';

  @override
  String get coolifyResources => 'Recursos';

  @override
  String get coolifyEnvironments => 'Entornos';

  @override
  String get coolifySharedVariables => 'Variables compartidas';

  @override
  String get coolifyName => 'Nombre';

  @override
  String get coolifyStatus => 'Estado';

  @override
  String get coolifyDomains => 'Dominios';

  @override
  String get coolifyRepository => 'Repositorio';

  @override
  String get coolifyBranch => 'Rama';

  @override
  String get coolifyBuildPack => 'Método de compilación';

  @override
  String get coolifyAddress => 'Dirección';

  @override
  String get coolifyPort => 'Puerto';

  @override
  String get coolifyUser => 'Usuario';

  @override
  String get coolifyFrequency => 'Programación';

  @override
  String get coolifyEnabled => 'Activo';

  @override
  String get coolifyMountPath => 'Ruta de montaje';

  @override
  String get coolifyHostPath => 'Ruta en el servidor';

  @override
  String get coolifyCreated => 'Creado';

  @override
  String get coolifyUpdated => 'Actualizado';

  @override
  String get coolifyValue => 'Valor';

  @override
  String get coolifyPreview => 'Vista previa';

  @override
  String get coolifySettings => 'Ajustes';

  @override
  String get coolifyType => 'Tipo';

  @override
  String get coolifyRunning => 'En ejecución';

  @override
  String get coolifyStopped => 'Detenido';

  @override
  String get coolifyConfiguration => 'Configuración';

  @override
  String get coolifyOverviewTitle => 'Resumen';

  @override
  String get coolifyResourceSearch => 'Buscar recursos';

  @override
  String get coolifyOtherSettings => 'Más ajustes';

  @override
  String get coolifyEnvironmentEmpty =>
      'Todavía no hay entornos en este proyecto.';

  @override
  String get coolifyLogsHidden =>
      'Muestra los registros para ver su contenido. Pueden contener secretos.';

  @override
  String get coolifyResourceEmpty => 'Todavía no hay recursos en este entorno.';

  @override
  String get coolifyRestricted => 'Valor protegido por los permisos del token.';

  @override
  String get coolifyVariables => 'Variables de entorno';

  @override
  String get coolifyNormalVariables => 'Variables normales';

  @override
  String get coolifyPreviewVariables => 'Variables de vista previa';

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
  String get deviceUnlockReason => 'Desbloquear las credenciales de Capidock';

  @override
  String get deviceUnlock => 'Desbloquear';

  @override
  String get deviceLockHelp =>
      'Configura un PIN, contraseña o biometría en el dispositivo para continuar.';

  @override
  String get termsOfUse => 'Términos de Uso';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String legalUpdated(String date) {
    return 'Actualizado: $date';
  }

  @override
  String get legalLoadError =>
      'No se pudo cargar este documento. Vuelve a abrirlo.';

  @override
  String get help => 'Ayuda';

  @override
  String get appSettings => 'Ajustes de la app';

  @override
  String get terminalFontSize => 'Tamaño del texto del terminal';

  @override
  String get lockNow => 'Bloquear ahora';

  @override
  String get trustedSshKeys => 'Identidades SSH de confianza';

  @override
  String get trustedSshHelp =>
      'Compara las fingerprints con tu servidor antes de confiar. Olvidar una identidad pide confirmación en la próxima conexión; una sesión existente sigue conectada.';

  @override
  String get localStorage => 'Almacenamiento local';

  @override
  String localCounts(int workspaces, int instances) {
    return '$workspaces workspaces · $instances instancias';
  }

  @override
  String get eraseLocalData => 'Borrar datos de servidores guardados';

  @override
  String get eraseLocalWarning =>
      'Elimina permanentemente todos los workspaces, credenciales e identidades SSH de este dispositivo. Tus servidores no cambian. Requiere autenticación del dispositivo.';

  @override
  String get eraseAuthReason =>
      'Autentícate para borrar los datos de servidores de Capidock';

  @override
  String get localEraseFailed =>
      'No se pudo verificar la eliminación de todos los datos locales de servidores. Desbloquea y comprueba los datos guardados antes de intentarlo de nuevo.';

  @override
  String get noTrustedKeys => 'Sin identidades de confianza';

  @override
  String get forgetSshWarning =>
      '¿Olvidar esta identidad SSH? Tendrás que verificar la fingerprint en la próxima conexión.';

  @override
  String get tokenAccess => 'Acceso del token';

  @override
  String get tokenAccessHelp =>
      'Son observaciones de las solicitudes de esta sesión, no los permisos exactos del token. La API pública no indica si un token es readonly o root. Los permisos no comprobados quedan desconocidos. Solo los errores explícitos de permisos desactivan acciones; los errores genéricos también pueden venir de reglas IP o proxies. El servidor valida cada solicitud.';

  @override
  String get accessUnknown => 'Desconocido';

  @override
  String get accessObserved => 'Observado';

  @override
  String get accessDenied => 'Denegado';

  @override
  String get coolifyPermissionDenied =>
      'El servidor indicó que falta un permiso para esta acción. Edita el token y vuelve a conectar para comprobarlo.';

  @override
  String get testConnection => 'Probar conexión';

  @override
  String get connectionVerified => 'Conexión verificada';

  @override
  String get connectionTestHelp =>
      'Prueba la autenticación sin guardar el formulario. SSH no abre terminal ni ejecuta comandos; la confianza confirmada aquí es temporal. Coolify usa una solicitud de lectura de la API, sin pruebas de escritura ni deploy.';

  @override
  String get noSearchResults => 'Ningún recurso coincide con la búsqueda.';

  @override
  String get logsPause => 'Pausar registros en directo';

  @override
  String get logsResume => 'Reanudar registros en directo';

  @override
  String get logsFollow => 'Seguir los últimos registros';

  @override
  String get backupTitle => 'Copia cifrada';

  @override
  String get backupEncrypted => 'Archivo protegido con contraseña';

  @override
  String get backupContents => 'Workspaces y credenciales de conexión';

  @override
  String get backupExport => 'Exportar copia';

  @override
  String get backupImport => 'Importar copia';

  @override
  String get backupPassword => 'Contraseña de la copia';

  @override
  String get backupConfirmPassword => 'Confirmar contraseña';

  @override
  String get backupPasswordWeak => 'Usa al menos 12 caracteres.';

  @override
  String get backupPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get backupPasswordHelp =>
      'Guarda esta contraseña. Capidock no puede recuperarla.';

  @override
  String get backupHelp =>
      'Las copias incluyen workspaces y credenciales guardados. El cifrado AES-256-GCM usa una clave derivada de la contraseña, que no se guarda. No incluyen identidades SSH de confianza, preferencias ni datos de los servidores. El proveedor de archivos elegido puede sincronizar el archivo cifrado. La importación añade copias y requiere verificar de nuevo las identidades SSH.';

  @override
  String get backupImportWarning =>
      'Estos workspaces se añadirán como nuevas copias. Se conservarán los datos existentes. Verifica las huellas SSH antes de conectarte.';

  @override
  String get backupAuthReason => 'Autentícate para gestionar copias cifradas.';

  @override
  String get backupExported => 'Copia cifrada guardada.';

  @override
  String get backupImported => 'Workspaces importados.';

  @override
  String get backupFailed =>
      'No se pudo completar la operación. Los datos guardados no se han sustituido.';

  @override
  String get backupInvalid => 'Copia inválida o no compatible.';

  @override
  String get backupUnlockFailed => 'Contraseña incorrecta o copia alterada.';

  @override
  String get backupTooLarge => 'La copia supera el límite de tamaño.';

  @override
  String get backupFileFailed => 'No se pudo acceder al archivo de la copia.';

  @override
  String get listSearch => 'Buscar';

  @override
  String get listAllStatuses => 'Todos los estados';

  @override
  String get listPrevious => 'Anterior';

  @override
  String get listNext => 'Siguiente';

  @override
  String get listNoMatches =>
      'No hay resultados que coincidan con los filtros.';

  @override
  String listPage(int page) {
    return 'Página $page';
  }

  @override
  String get logsLevelAll => 'Todos los niveles';

  @override
  String get logsLevelErrors => 'Errores';

  @override
  String get logsLevelWarnings => 'Avisos';

  @override
  String get logsLineLimit => 'Líneas de registros';

  @override
  String get listHistory => 'Historial';

  @override
  String get listSchedule => 'Programación';

  @override
  String get listDetails => 'Detalles';

  @override
  String get listPageFilterHelp =>
      'La búsqueda y los filtros se aplican a la página actual del servidor. Usa las flechas para consultar despliegues anteriores.';

  @override
  String get activitySize => 'Tamaño del archivo';

  @override
  String get activityCommit => 'Mensaje del commit';

  @override
  String get activityFinished => 'Finalizado';

  @override
  String get activityEnabled => 'Activo';

  @override
  String get logsShow => 'Mostrar registros';

  @override
  String get logsHide => 'Ocultar registros';

  @override
  String get coolifyTerminalServer => 'Servidor Coolify';

  @override
  String get coolifyTerminalContainer => 'Terminal del contenedor';

  @override
  String get coolifyTerminalHost => 'Terminal del servidor';

  @override
  String get coolifyTerminalNoContainers =>
      'No se encontraron contenedores en ejecución para este recurso.';

  @override
  String get coolifyTerminalServersFailed =>
      'No se pudieron cargar los servidores. Comprueba los permisos de la API y la conexión.';

  @override
  String get coolifyTerminalLinkFailed =>
      'No se pudo leer la asociación SSH guardada.';

  @override
  String get coolifyTerminalConnectFailed =>
      'No se pudo conectar o guardar la asociación SSH. Comprueba las credenciales y el almacenamiento seguro.';

  @override
  String get coolifyTerminalDockerFailed =>
      'No se pudieron listar los contenedores. Comprueba el acceso a Docker de este usuario SSH.';

  @override
  String get coolifyTerminalContainerGone =>
      'El contenedor ya no está en ejecución o ya no pertenece a este recurso. Actualiza la lista.';

  @override
  String get coolifyTerminalShellFailed =>
      'No se pudo abrir el terminal. Comprueba si la shell seleccionada está instalada. Vuelve a conectar para intentarlo.';

  @override
  String get coolifyTerminalHelp =>
      'Asocia la conexión SSH correcta al servidor Coolify seleccionado. Las credenciales permanecen cifradas en el dispositivo. El token de la API no es una credencial SSH. Los permisos SSH y Docker son independientes del token: el acceso a Docker puede dar control total del servidor. La lista muestra solo contenedores en ejecución de este recurso. Cierra la sesión al terminar; las sesiones también se cierran en segundo plano.';

  @override
  String get sftpFiles => 'Archivos';

  @override
  String get sftpUpload => 'Subir archivo';

  @override
  String get sftpDownload => 'Descargar';

  @override
  String get sftpReplace => '¿Reemplazar el archivo remoto?';

  @override
  String get sftpNewFolder => 'Nueva carpeta';

  @override
  String get sftpRename => 'Renombrar';

  @override
  String get sftpEditText => 'Editar texto';

  @override
  String get sftpParent => 'Carpeta superior';

  @override
  String get sftpEmpty => 'Esta carpeta está vacía.';

  @override
  String get sftpInvalidName =>
      'Usa un nombre sin barras ni caracteres de control.';

  @override
  String get sftpPermissionDenied => 'El servidor denegó el permiso.';

  @override
  String get sftpFailed =>
      'SFTP falló. Comprueba el acceso, los permisos y el soporte del subsistema; vuelve a conectar.';

  @override
  String get sftpDirectoryLimit =>
      'Esta carpeta supera el límite de 5.000 entradas.';

  @override
  String get sftpRegularOnly =>
      'Esta acción admite archivos regulares, no enlaces simbólicos.';

  @override
  String get sftpTooLarge =>
      'Límite de transferencia: 16 MiB. Límite del editor: 256 KiB.';

  @override
  String get sftpTextOnly => 'El editor admite texto UTF-8 sin bytes nulos.';

  @override
  String get sftpExists => 'El destino ya existe o no es un archivo regular.';

  @override
  String get sftpChanged =>
      'El archivo remoto ha cambiado. Vuelve a cargarlo antes de guardar.';

  @override
  String get sftpLocalFailed =>
      'No se pudo acceder al documento local seleccionado.';

  @override
  String get sftpHelp =>
      'SFTP usa esta conexión SSH verificada y los permisos del servidor. Transferencias de hasta 16 MiB; edición UTF-8 de hasta 256 KiB. No se guardan archivos en caché. Las descargas se guardan donde elijas y el proveedor puede sincronizarlas. SSH se cierra mientras el selector está abierto; las subidas reconectan tras autenticar el dispositivo. Solo se eliminan archivos, enlaces o carpetas vacías. Una transferencia interrumpida puede dejar un archivo remoto parcial. Reemplazar requiere soporte para renombrar sobre el destino; si falla, se conserva el original.';

  @override
  String get sftpConfirm => 'Confirmar';

  @override
  String get monitorTitle => 'Supervisión';

  @override
  String get monitorHelp =>
      'Las comprobaciones se realizan en este teléfono. Android puede retrasarlas en reposo o tras un cierre forzado. Una conexión fallida puede deberse a la red o VPN; no demuestra que el servidor esté caído. Dos fallos consecutivos generan una alerta. La disponibilidad es el porcentaje de comprobaciones accesibles de los últimos 30 días, no un uptime continuo. Se excluyen comprobaciones sin red o desconocidas. Coolify analiza los últimos 20 despliegues y la salud de los recursos; los fallos existentes son la referencia inicial. SSH requiere una clave de servidor ya verificada.';

  @override
  String get monitorEnable => 'Activar supervisión';

  @override
  String get monitorConsent =>
      '¿Permitir que Capidock utilice las credenciales cifradas de esta instancia para comprobaciones de solo lectura en segundo plano, incluso con la app bloqueada? El historial permanece cifrado localmente.';

  @override
  String get monitorInterval => 'Intervalo en segundo plano';

  @override
  String get monitorPermission => 'Notificaciones permitidas';

  @override
  String get monitorPermissionOff => 'Las notificaciones están desactivadas';

  @override
  String get monitorRequest => 'Permitir notificaciones';

  @override
  String get monitorCheck => 'Comprobar pronto';

  @override
  String get monitorScheduled =>
      'Comprobación programada. Android decide cuándo ejecutarla.';

  @override
  String get monitorEmpty => 'Crea una instancia para iniciar la supervisión.';

  @override
  String get monitorNoChecks => 'Sin comprobaciones todavía';

  @override
  String get monitorObserved => 'Disponibilidad observada';

  @override
  String get monitorHistory => 'Historial · últimos 30 días';

  @override
  String get monitorAlerts => 'Alertas';

  @override
  String get monitorAlertConnections => 'Problemas de conexión y acceso';

  @override
  String get monitorAlertDeployments => 'Eventos de deployments';

  @override
  String get monitorAlertResources => 'Cambios de estado de los recursos';

  @override
  String get monitorAlertRecovery => 'Recuperación';

  @override
  String get monitorUp => 'Accesible';

  @override
  String get monitorDown => 'Conexión fallida';

  @override
  String get monitorOffline => 'Teléfono sin red';

  @override
  String get monitorAuthentication => 'Revisa credenciales o permisos';

  @override
  String get monitorIdentity => 'Identidad SSH no verificada';

  @override
  String get monitorUnknown => 'Comprobación incompleta';

  @override
  String get monitorStale => 'Esperando una nueva comprobación';

  @override
  String get monitorLatency => 'Latencia';

  @override
  String get monitorLimit => 'Puedes supervisar hasta 20 instancias.';

  @override
  String get monitorFastTitle => 'Supervisión rápida de Coolify';

  @override
  String get monitorFastHelp =>
      'Comprueba las instancias Coolify activadas mientras la app está abierta y desbloqueada. Se pausa en segundo plano. Las conexiones lentas pueden retrasar las comprobaciones; los eventos breves pueden pasar desapercibidos.';

  @override
  String get monitorFastInterval => 'Intervalo con la app abierta';

  @override
  String get monitorDeploymentStarted => 'Deployment iniciado';

  @override
  String get monitorDeploymentSucceeded => 'Deployment completado';

  @override
  String get monitorDeploymentCancelled => 'Deployment cancelado';

  @override
  String get monitorResourceChanged => 'Estado del recurso modificado';

  @override
  String get monitorDeploymentFailed => 'El despliegue ha fallado';

  @override
  String get monitorResourceUnhealthy => 'Recurso con problemas';
}

/// The translations for Spanish Castilian, as used in Spain (`es_ES`).
class AppLocalizationsEsEs extends AppLocalizationsEs {
  AppLocalizationsEsEs() : super('es_ES');

  @override
  String get emptyProjectTitle => 'Un espacio para\ncada proyecto.';

  @override
  String get emptyServerTitle => 'Tu próximo servidor\nempieza aquí.';

  @override
  String get emptyProjectBody =>
      'Crea un espacio de trabajo para organizar tus instancias SSH y Coolify.';

  @override
  String get createWorkspace => 'Crear espacio de trabajo';

  @override
  String get addInstance => 'Añadir instancia';

  @override
  String get aboutDescription =>
      'Un dock para todos tus servidores.\n\nCada espacio de trabajo reúne tus canales SSH y Coolify. La configuración y las credenciales se guardan cifradas en este dispositivo. Conéctate por SSH o consulta los recursos de la API de Coolify.';

  @override
  String get aboutLicence =>
      'Código abierto bajo GPL-3.0-only. Puedes redistribuir y modificar la app según la licencia. Sin garantía, dentro de los límites legales.\n\nLas licencias, los créditos y la política de marca están disponibles en Ver licencias, incluso sin conexión.';

  @override
  String get sourceCode =>
      'Código fuente: https://github.com/zephyrushq/capidock-mobile';

  @override
  String get removeInstanceTitle => '¿Eliminar instancia?';

  @override
  String get removeInstanceError =>
      'No se pudo eliminar la instancia. Inténtalo de nuevo.';

  @override
  String get preservedData => 'Los datos guardados se han conservado.';

  @override
  String get retry => 'Reintentar';

  @override
  String get openInstances => 'Abrir instancias';

  @override
  String get firstWorkspace => 'Crea tu primer espacio de trabajo';

  @override
  String get instanceOptions => 'Opciones de la instancia';

  @override
  String get editInstance => 'Editar instancia';

  @override
  String get moveInstance => 'Mover a otro espacio de trabajo';

  @override
  String get removeInstance => 'Eliminar instancia';

  @override
  String get aboutCapidock => 'Acerca de Capidock';

  @override
  String get unnamedResource => 'Sin nombre';

  @override
  String get unavailableStatus => 'Estado no disponible';

  @override
  String get coolifyHttpsError => 'Coolify requiere una URL HTTPS válida.';

  @override
  String get apiTokenRequired => 'Configura el token de la API.';

  @override
  String get invalidToken =>
      'Token no válido o caducado. Edita la credencial de la instancia.';

  @override
  String get coolifyAccessDenied =>
      'Acceso denegado. Comprueba los permisos del token, la API y la lista de IP permitidas.';

  @override
  String get apiNotFound =>
      'API no encontrada. Comprueba la URL base y si la API está habilitada.';

  @override
  String get rateLimited =>
      'Límite de solicitudes alcanzado. Espera e inténtalo de nuevo.';

  @override
  String get redirectError =>
      'El servidor redirigió la solicitud. Configura directamente la URL HTTPS final.';

  @override
  String get responseTooLarge =>
      'La respuesta de Coolify superó el límite de 4 MiB.';

  @override
  String get coolifyTimeout =>
      'Coolify agotó el tiempo de espera. Comprueba la red/VPN.';

  @override
  String get invalidApiResponse =>
      'La API devolvió una respuesta inesperada. Comprueba la URL y la versión de Coolify.';

  @override
  String get coolifyConnectionError =>
      'No se pudo contactar con Coolify. Comprueba la red y el certificado HTTPS.';

  @override
  String get sshSessionEnded =>
      'La sesión SSH ha terminado. Puedes volver a conectarte.';

  @override
  String get systemInfoError =>
      'No se pudo obtener la información del sistema. El terminal sigue disponible. Los comandos de resumen requieren Linux/POSIX.';

  @override
  String get sshAuthError =>
      'Autenticación rechazada. Comprueba el usuario y la credencial SSH.';

  @override
  String get sshHostKeyError =>
      'No se aceptó la identidad del servidor. Se interrumpió la conexión.';

  @override
  String get sshPrivateKeyError =>
      'No se pudo leer la clave privada. Comprueba la clave y su contraseña.';

  @override
  String get sshTimeout =>
      'La conexión agotó el tiempo de espera. Comprueba la red y el puerto SSH.';

  @override
  String get serverUnreachable =>
      'Servidor inaccesible. Comprueba la dirección, el puerto y la red/VPN.';

  @override
  String get sshConnectionError =>
      'No se pudo abrir la sesión SSH. Comprueba el acceso al servidor e inténtalo de nuevo.';

  @override
  String get confirmSshServer => 'Confirmar servidor SSH';

  @override
  String get serverKeyChanged => 'La clave del servidor ha cambiado';

  @override
  String get compareFingerprint =>
      'Compara esta huella con la de tu servidor antes de confiar.';

  @override
  String get changedKeyWarning =>
      'Puede ser una reinstalación o una conexión a otro servidor. Sustituye la clave solo después de verificarla por otro medio.';

  @override
  String get savedKey => 'Clave guardada:';

  @override
  String get verifyKeyCommand =>
      'En el servidor: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (ajusta el comando al tipo de clave mostrado).';

  @override
  String get trustAndConnect => 'Confiar y conectar';

  @override
  String get replaceKey => 'Sustituir clave';

  @override
  String get yourServer => 'Tu servidor';

  @override
  String get yourResources => 'Tus recursos';

  @override
  String get connecting => 'Conectando…';

  @override
  String get receivedData => 'Datos recibidos';

  @override
  String get notConnected => 'Sin conectar';

  @override
  String get addCredentials =>
      'Añade una credencial para conectar esta instancia. Se ha conservado la dirección guardada.';

  @override
  String get configureAccess => 'Configurar acceso';

  @override
  String get connectInstance => 'Conectar a la instancia';

  @override
  String get editAccess => 'Editar acceso';

  @override
  String get openTerminal => 'Abrir terminal';

  @override
  String get connectForInfo =>
      'Conéctate para consultar el sistema, el tiempo de actividad, la memoria y el disco, o usar el terminal interactivo.';

  @override
  String get noCoolifyResources =>
      'La API no devolvió recursos para el equipo de este token.';

  @override
  String get coolifyOverview =>
      'Consulta las aplicaciones, bases de datos y servicios de tu equipo. Los estados proceden directamente de la API de Coolify.';

  @override
  String get connectionPrivacy =>
      'Las conexiones SSH se cierran al cambiar de instancia o poner la app en segundo plano. Las credenciales se guardan cifradas en el dispositivo.';

  @override
  String get activeSshSession => 'Sesión SSH activa';

  @override
  String get terminalDisconnected => 'Terminal desconectado';

  @override
  String get connection => 'Conexión';

  @override
  String get openKeyboard => 'Abrir teclado';

  @override
  String get loadWorkspacesError =>
      'No se pudieron cargar los espacios de trabajo guardados.';

  @override
  String get secureSaveError =>
      'No se pudo guardar en el almacenamiento seguro. Se han conservado los campos; inténtalo de nuevo.';

  @override
  String get welcomeTitle => 'Tus servidores.\nTu dock.';

  @override
  String get firstServerTitle => 'Haz sitio para\ntu primer servidor.';

  @override
  String get connectionTitle => '¿Cómo vamos\na conectarnos?';

  @override
  String get welcomeBody =>
      'Bienvenido a Capidock. Crea un espacio de trabajo para reunir las instancias de tus proyectos.';

  @override
  String get workspaceName => 'Nombre del espacio de trabajo';

  @override
  String get workspaceHint => 'p. ej.: Personal, Empresa o Proyecto';

  @override
  String get workspaceNameRequired => 'Pon un nombre al espacio de trabajo.';

  @override
  String get saving => 'Guardando…';

  @override
  String get configureConnection => 'Configurar conexión';

  @override
  String get createAndOpen => 'Crear y abrir instancia';

  @override
  String get localByChoice =>
      'Local por elección. Sin cuenta ni sincronización.';

  @override
  String get manageWorkspaces => 'Gestionar espacios de trabajo';

  @override
  String get newWorkspace => 'Nuevo espacio de trabajo';

  @override
  String get renameWorkspace => 'Renombrar espacio de trabajo';

  @override
  String get workspaceGrouping =>
      'Agrupa los servidores por proyecto, cliente o entorno.';

  @override
  String get workspaceEditorHint => 'p. ej.: Personal, Trabajo, Homelab';

  @override
  String get saveError => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get yourWorkspaces => 'Tus espacios de trabajo';

  @override
  String get workspaceContexts => 'Un espacio para cada contexto.';

  @override
  String get removeWorkspace => 'Eliminar espacio de trabajo';

  @override
  String get noWorkspaces => 'Todavía no hay espacios de trabajo.';

  @override
  String get removeWorkspaceTitle => '¿Eliminar espacio de trabajo?';

  @override
  String get removeWorkspaceError =>
      'No se pudo eliminar el espacio de trabajo. Inténtalo de nuevo.';

  @override
  String get moveInstanceError =>
      'No se pudo mover la instancia. Inténtalo de nuevo.';

  @override
  String get sshDescription => 'Acceso al servidor mediante terminal';

  @override
  String get coolifyDescription => 'Descripción';

  @override
  String get hostRequired => 'Introduce la dirección de la instancia.';

  @override
  String get hostNoSpaces => 'La dirección no puede contener espacios.';

  @override
  String get httpsRequired =>
      'Usa una URL HTTPS, como https://coolify.example.com.';

  @override
  String get hostOnly => 'Usa solo el nombre de host o la IP del servidor.';

  @override
  String get privateKeyEmpty => 'La clave privada está vacía.';

  @override
  String get privateKeyFormatError =>
      'No se pudo leer la clave privada. Comprueba el formato y su contraseña.';

  @override
  String get instanceName => 'Nombre de la instancia';

  @override
  String get instanceHint => 'p. ej.: produccion-europa';

  @override
  String get instanceNameRequired => 'Pon un nombre a la instancia.';

  @override
  String get hostname => 'Nombre de host o IP';

  @override
  String get coolifyUrl => 'URL de Coolify';

  @override
  String get invalidUsername => 'Usuario no válido.';

  @override
  String get authentication => 'Autenticación';

  @override
  String get privateKey => 'Clave privada';

  @override
  String get sshPassword => 'Contraseña SSH';

  @override
  String get privateKeyLabel => 'Clave privada PEM / OpenSSH';

  @override
  String get privateKeyHint =>
      'Pega la clave completa, incluidas las líneas BEGIN y END.';

  @override
  String get passphraseLabel => 'Contraseña de la clave (opcional)';

  @override
  String get coolifyToken => 'Token de la API de Coolify';

  @override
  String get coolifyTokenHint =>
      'En Coolify, habilita la API y crea un token en Keys & Tokens → API tokens. Los tokens de lectura permiten consultar recursos. Para editar, usa write; los despliegues pueden requerir deploy o sensitive. Usa la URL base sin /api/v1.';

  @override
  String get localCredentials =>
      'La configuración y las credenciales se cifran en este dispositivo. La conexión es directa con tu servidor, sin cuenta de Capidock.';

  @override
  String get showCredential => 'Mostrar credencial';

  @override
  String get hideCredential => 'Ocultar credencial';

  @override
  String get credentialRequired => 'Introduce la credencial.';

  @override
  String get newInstanceTitle => 'Un nuevo lugar en tu dock.';

  @override
  String get saveConfiguration => 'Guardar configuración';

  @override
  String get findInstance => 'Buscar instancia';

  @override
  String get emptyInstances =>
      'Este espacio de trabajo todavía no tiene instancias.';

  @override
  String get noInstancesFound => 'No se encontraron instancias.';

  @override
  String get newInstance => 'Nueva instancia';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get rename => 'Renombrar';

  @override
  String get back => 'Volver';

  @override
  String get username => 'Usuario';

  @override
  String get port => 'Puerto';

  @override
  String get password => 'Contraseña';

  @override
  String get server => 'Servidor';

  @override
  String get connected => 'Conectado';

  @override
  String get refresh => 'Actualizar';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get workspaceStep => 'ESPACIO DE TRABAJO';

  @override
  String get instanceStep => 'INSTANCIA';

  @override
  String get connectionStep => 'CONEXIÓN';

  @override
  String get previousData => ' · datos anteriores';

  @override
  String get language => 'Idioma';

  @override
  String get languageSaveError =>
      'No se pudo guardar el idioma. Inténtalo de nuevo.';

  @override
  String emptyWorkspaceBody(String name) {
    return 'Añade una instancia SSH o Coolify al espacio de trabajo «$name».';
  }

  @override
  String removeInstanceBody(String name) {
    return 'La configuración de «$name» se eliminará de este dispositivo. El servidor no se modificará.';
  }

  @override
  String firstInstanceBody(String name) {
    return 'Cada instancia es un canal dentro de «$name». Empieza por la primera.';
  }

  @override
  String configureInstanceBody(String name) {
    return 'Configura el acceso a «$name». Puedes editar estos datos más adelante.';
  }

  @override
  String onboardingStep(int step, String name) {
    return 'PASO $step DE 3 · $name';
  }

  @override
  String workspaceLabel(String name) {
    return 'Espacio de trabajo $name';
  }

  @override
  String workspaceOptions(String name) {
    return 'Opciones de $name';
  }

  @override
  String removeWorkspaceBody(String name, int count) {
    return '«$name» y sus instancias ($count) se eliminarán de este dispositivo. Los servidores no se modificarán.';
  }

  @override
  String inWorkspace(String name) {
    return 'En el espacio de trabajo «$name».';
  }

  @override
  String lastRead(String time, String suffix) {
    return 'Última lectura: $time$suffix';
  }

  @override
  String httpError(int code) {
    return 'Coolify respondió con el error HTTP $code. Inténtalo de nuevo.';
  }

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instancias',
      one: '1 instancia',
      zero: '0 instancias',
    );
    return '$_temp0';
  }

  @override
  String workspaceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count espacios locales',
      one: '1 espacio local',
      zero: '0 espacios locales',
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
  String get coolifyOperations => 'Todas las operaciones';

  @override
  String get coolifyApplications => 'Aplicaciones';

  @override
  String get coolifyDatabases => 'Bases de datos';

  @override
  String get coolifyServices => 'Servicios';

  @override
  String get coolifyProjects => 'Proyectos';

  @override
  String get coolifyServers => 'Servidores';

  @override
  String get coolifyPermissions =>
      'La lectura requiere read. Para editar, usa write; los despliegues y las operaciones de servidor pueden requerir deploy o sensitive. La versión de Coolify determina las operaciones disponibles.';

  @override
  String get coolifySearch => 'Buscar recursos u operaciones';

  @override
  String get coolifyAll => 'Todas las categorías';

  @override
  String get coolifyCatalogHelp =>
      'Accede a las operaciones documentadas de la API de Coolify. Los nombres y las descripciones de los campos siguen la API oficial. Las operaciones recientes pueden no existir en instalaciones antiguas.';

  @override
  String get coolifyDetails => 'Detalles';

  @override
  String get coolifyEnvironment => 'Entorno';

  @override
  String get coolifyLogs => 'Registros';

  @override
  String get coolifyBackups => 'Copias de seguridad';

  @override
  String get coolifyStorages => 'Volúmenes y archivos';

  @override
  String get coolifyDeployments => 'Despliegues';

  @override
  String get coolifyCreate => 'Crear';

  @override
  String get coolifyEdit => 'Editar configuración';

  @override
  String get coolifyStart => 'Iniciar';

  @override
  String get coolifyStop => 'Detener';

  @override
  String get coolifyRestart => 'Reiniciar';

  @override
  String get coolifyDeploy => 'Desplegar';

  @override
  String get coolifyExecutions => 'Historial de ejecuciones';

  @override
  String get coolifyScheduleBackup => 'Programar copia';

  @override
  String get coolifyRunBackup => 'Ejecutar copia';

  @override
  String get coolifyEmpty => 'La API no devolvió resultados.';

  @override
  String get coolifyConfirm => 'Confirmar operación';

  @override
  String get coolifyDestructive => 'Confirmar operación destructiva';

  @override
  String get coolifyMutationWarning =>
      'Esta acción modifica el servidor remoto. Detener, reiniciar, desplegar, restaurar y eliminar puede interrumpir servicios o borrar datos. Comprueba el destino antes de continuar.';

  @override
  String coolifyTypeTarget(String target) {
    return 'Escribe $target para confirmar.';
  }

  @override
  String get coolifyExecute => 'Ejecutar operación';

  @override
  String get coolifyRead => 'Consultar datos';

  @override
  String get coolifyReveal =>
      'Mostrar valores y registros (pueden contener secretos)';

  @override
  String get coolifyChangedOnly =>
      'Solo se envían los campos editados. Los campos opcionales sin editar mantienen sus valores en el servidor. Una cadena vacía editada borra el valor. Las listas y los objetos usan JSON.';

  @override
  String get coolifyInvalidField => 'Comprueba el valor y el tipo requerido.';

  @override
  String get coolifyInvalidJson => 'Introduce JSON válido.';

  @override
  String get coolifyRequiredPayload =>
      'Rellena al menos un campo, todos los campos obligatorios y elige un archivo para subir.';

  @override
  String get coolifyChooseFile => 'Elegir archivo de copia de seguridad';

  @override
  String get coolifySuccess =>
      'Solicitud aceptada por Coolify. Las tareas en cola pueden seguir ejecutándose; actualiza su estado.';

  @override
  String get coolifyYes => 'Sí';

  @override
  String get coolifyNo => 'No';

  @override
  String get coolifyConflict =>
      'Hay otra operación en curso o el cambio entra en conflicto con el estado actual. Actualiza antes de volver a intentarlo.';

  @override
  String get coolifyValidationError =>
      'Coolify rechazó los campos. Comprueba los valores obligatorios, los tipos y la versión instalada de la API.';

  @override
  String get coolifyUploadSize =>
      'Elige un archivo de copia de seguridad no vacío de hasta 10 GiB.';

  @override
  String get coolifyCancelled =>
      'Conexión cerrada. Actualiza para comprobar si la operación remota se completó.';

  @override
  String get coolifySshTerminal =>
      'Coolify no ofrece un terminal interactivo mediante su API REST pública. Elige una conexión SSH guardada para acceder al servidor.';

  @override
  String get coolifyNoSsh =>
      'Añade primero una instancia SSH de este servidor a un workspace.';

  @override
  String get coolifyResources => 'Recursos';

  @override
  String get coolifyEnvironments => 'Entornos';

  @override
  String get coolifySharedVariables => 'Variables compartidas';

  @override
  String get coolifyName => 'Nombre';

  @override
  String get coolifyStatus => 'Estado';

  @override
  String get coolifyDomains => 'Dominios';

  @override
  String get coolifyRepository => 'Repositorio';

  @override
  String get coolifyBranch => 'Rama';

  @override
  String get coolifyBuildPack => 'Método de compilación';

  @override
  String get coolifyAddress => 'Dirección';

  @override
  String get coolifyPort => 'Puerto';

  @override
  String get coolifyUser => 'Usuario';

  @override
  String get coolifyFrequency => 'Programación';

  @override
  String get coolifyEnabled => 'Activo';

  @override
  String get coolifyMountPath => 'Ruta de montaje';

  @override
  String get coolifyHostPath => 'Ruta en el servidor';

  @override
  String get coolifyCreated => 'Creado';

  @override
  String get coolifyUpdated => 'Actualizado';

  @override
  String get coolifyValue => 'Valor';

  @override
  String get coolifyPreview => 'Vista previa';

  @override
  String get coolifySettings => 'Ajustes';

  @override
  String get coolifyType => 'Tipo';

  @override
  String get coolifyRunning => 'En ejecución';

  @override
  String get coolifyStopped => 'Detenido';

  @override
  String get coolifyConfiguration => 'Configuración';

  @override
  String get coolifyOverviewTitle => 'Resumen';

  @override
  String get coolifyResourceSearch => 'Buscar recursos';

  @override
  String get coolifyOtherSettings => 'Más ajustes';

  @override
  String get coolifyEnvironmentEmpty =>
      'Todavía no hay entornos en este proyecto.';

  @override
  String get coolifyLogsHidden =>
      'Muestra los registros para ver su contenido. Pueden contener secretos.';

  @override
  String get coolifyResourceEmpty => 'Todavía no hay recursos en este entorno.';

  @override
  String get coolifyRestricted => 'Valor protegido por los permisos del token.';

  @override
  String get coolifyVariables => 'Variables de entorno';

  @override
  String get coolifyNormalVariables => 'Variables normales';

  @override
  String get coolifyPreviewVariables => 'Variables de vista previa';

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
  String get deviceUnlockReason => 'Desbloquear las credenciales de Capidock';

  @override
  String get deviceUnlock => 'Desbloquear';

  @override
  String get deviceLockHelp =>
      'Configura un PIN, contraseña o biometría en el dispositivo para continuar.';

  @override
  String get termsOfUse => 'Términos de Uso';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String legalUpdated(String date) {
    return 'Actualizado: $date';
  }

  @override
  String get legalLoadError =>
      'No se pudo cargar este documento. Vuelve a abrirlo.';

  @override
  String get help => 'Ayuda';

  @override
  String get appSettings => 'Ajustes de la app';

  @override
  String get terminalFontSize => 'Tamaño del texto del terminal';

  @override
  String get lockNow => 'Bloquear ahora';

  @override
  String get trustedSshKeys => 'Identidades SSH de confianza';

  @override
  String get trustedSshHelp =>
      'Compara las fingerprints con tu servidor antes de confiar. Olvidar una identidad pide confirmación en la próxima conexión; una sesión existente sigue conectada.';

  @override
  String get localStorage => 'Almacenamiento local';

  @override
  String localCounts(int workspaces, int instances) {
    return '$workspaces workspaces · $instances instancias';
  }

  @override
  String get eraseLocalData => 'Borrar datos de servidores guardados';

  @override
  String get eraseLocalWarning =>
      'Elimina permanentemente todos los workspaces, credenciales e identidades SSH de este dispositivo. Tus servidores no cambian. Requiere autenticación del dispositivo.';

  @override
  String get eraseAuthReason =>
      'Autentícate para borrar los datos de servidores de Capidock';

  @override
  String get localEraseFailed =>
      'No se pudo verificar la eliminación de todos los datos locales de servidores. Desbloquea y comprueba los datos guardados antes de intentarlo de nuevo.';

  @override
  String get noTrustedKeys => 'Sin identidades de confianza';

  @override
  String get forgetSshWarning =>
      '¿Olvidar esta identidad SSH? Tendrás que verificar la fingerprint en la próxima conexión.';

  @override
  String get tokenAccess => 'Acceso del token';

  @override
  String get tokenAccessHelp =>
      'Son observaciones de las solicitudes de esta sesión, no los permisos exactos del token. La API pública no indica si un token es readonly o root. Los permisos no comprobados quedan desconocidos. Solo los errores explícitos de permisos desactivan acciones; los errores genéricos también pueden venir de reglas IP o proxies. El servidor valida cada solicitud.';

  @override
  String get accessUnknown => 'Desconocido';

  @override
  String get accessObserved => 'Observado';

  @override
  String get accessDenied => 'Denegado';

  @override
  String get coolifyPermissionDenied =>
      'El servidor indicó que falta un permiso para esta acción. Edita el token y vuelve a conectar para comprobarlo.';

  @override
  String get testConnection => 'Probar conexión';

  @override
  String get connectionVerified => 'Conexión verificada';

  @override
  String get connectionTestHelp =>
      'Prueba la autenticación sin guardar el formulario. SSH no abre terminal ni ejecuta comandos; la confianza confirmada aquí es temporal. Coolify usa una solicitud de lectura de la API, sin pruebas de escritura ni deploy.';

  @override
  String get noSearchResults => 'Ningún recurso coincide con la búsqueda.';

  @override
  String get logsPause => 'Pausar registros en directo';

  @override
  String get logsResume => 'Reanudar registros en directo';

  @override
  String get logsFollow => 'Seguir los últimos registros';

  @override
  String get backupTitle => 'Copia cifrada';

  @override
  String get backupEncrypted => 'Archivo protegido con contraseña';

  @override
  String get backupContents => 'Workspaces y credenciales de conexión';

  @override
  String get backupExport => 'Exportar copia';

  @override
  String get backupImport => 'Importar copia';

  @override
  String get backupPassword => 'Contraseña de la copia';

  @override
  String get backupConfirmPassword => 'Confirmar contraseña';

  @override
  String get backupPasswordWeak => 'Usa al menos 12 caracteres.';

  @override
  String get backupPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get backupPasswordHelp =>
      'Guarda esta contraseña. Capidock no puede recuperarla.';

  @override
  String get backupHelp =>
      'Las copias incluyen workspaces y credenciales guardados. El cifrado AES-256-GCM usa una clave derivada de la contraseña, que no se guarda. No incluyen identidades SSH de confianza, preferencias ni datos de los servidores. El proveedor de archivos elegido puede sincronizar el archivo cifrado. La importación añade copias y requiere verificar de nuevo las identidades SSH.';

  @override
  String get backupImportWarning =>
      'Estos workspaces se añadirán como nuevas copias. Se conservarán los datos existentes. Verifica las huellas SSH antes de conectarte.';

  @override
  String get backupAuthReason => 'Autentícate para gestionar copias cifradas.';

  @override
  String get backupExported => 'Copia cifrada guardada.';

  @override
  String get backupImported => 'Workspaces importados.';

  @override
  String get backupFailed =>
      'No se pudo completar la operación. Los datos guardados no se han sustituido.';

  @override
  String get backupInvalid => 'Copia inválida o no compatible.';

  @override
  String get backupUnlockFailed => 'Contraseña incorrecta o copia alterada.';

  @override
  String get backupTooLarge => 'La copia supera el límite de tamaño.';

  @override
  String get backupFileFailed => 'No se pudo acceder al archivo de la copia.';

  @override
  String get listSearch => 'Buscar';

  @override
  String get listAllStatuses => 'Todos los estados';

  @override
  String get listPrevious => 'Anterior';

  @override
  String get listNext => 'Siguiente';

  @override
  String get listNoMatches =>
      'No hay resultados que coincidan con los filtros.';

  @override
  String listPage(int page) {
    return 'Página $page';
  }

  @override
  String get logsLevelAll => 'Todos los niveles';

  @override
  String get logsLevelErrors => 'Errores';

  @override
  String get logsLevelWarnings => 'Avisos';

  @override
  String get logsLineLimit => 'Líneas de registros';

  @override
  String get listHistory => 'Historial';

  @override
  String get listSchedule => 'Programación';

  @override
  String get listDetails => 'Detalles';

  @override
  String get listPageFilterHelp =>
      'La búsqueda y los filtros se aplican a la página actual del servidor. Usa las flechas para consultar despliegues anteriores.';

  @override
  String get activitySize => 'Tamaño del archivo';

  @override
  String get activityCommit => 'Mensaje del commit';

  @override
  String get activityFinished => 'Finalizado';

  @override
  String get activityEnabled => 'Activo';

  @override
  String get logsShow => 'Mostrar registros';

  @override
  String get logsHide => 'Ocultar registros';

  @override
  String get coolifyTerminalServer => 'Servidor Coolify';

  @override
  String get coolifyTerminalContainer => 'Terminal del contenedor';

  @override
  String get coolifyTerminalHost => 'Terminal del servidor';

  @override
  String get coolifyTerminalNoContainers =>
      'No se encontraron contenedores en ejecución para este recurso.';

  @override
  String get coolifyTerminalServersFailed =>
      'No se pudieron cargar los servidores. Comprueba los permisos de la API y la conexión.';

  @override
  String get coolifyTerminalLinkFailed =>
      'No se pudo leer la asociación SSH guardada.';

  @override
  String get coolifyTerminalConnectFailed =>
      'No se pudo conectar o guardar la asociación SSH. Comprueba las credenciales y el almacenamiento seguro.';

  @override
  String get coolifyTerminalDockerFailed =>
      'No se pudieron listar los contenedores. Comprueba el acceso a Docker de este usuario SSH.';

  @override
  String get coolifyTerminalContainerGone =>
      'El contenedor ya no está en ejecución o ya no pertenece a este recurso. Actualiza la lista.';

  @override
  String get coolifyTerminalShellFailed =>
      'No se pudo abrir el terminal. Comprueba si la shell seleccionada está instalada. Vuelve a conectar para intentarlo.';

  @override
  String get coolifyTerminalHelp =>
      'Asocia la conexión SSH correcta al servidor Coolify seleccionado. Las credenciales permanecen cifradas en el dispositivo. El token de la API no es una credencial SSH. Los permisos SSH y Docker son independientes del token: el acceso a Docker puede dar control total del servidor. La lista muestra solo contenedores en ejecución de este recurso. Cierra la sesión al terminar; las sesiones también se cierran en segundo plano.';

  @override
  String get sftpFiles => 'Archivos';

  @override
  String get sftpUpload => 'Subir archivo';

  @override
  String get sftpDownload => 'Descargar';

  @override
  String get sftpReplace => '¿Reemplazar el archivo remoto?';

  @override
  String get sftpNewFolder => 'Nueva carpeta';

  @override
  String get sftpRename => 'Renombrar';

  @override
  String get sftpEditText => 'Editar texto';

  @override
  String get sftpParent => 'Carpeta superior';

  @override
  String get sftpEmpty => 'Esta carpeta está vacía.';

  @override
  String get sftpInvalidName =>
      'Usa un nombre sin barras ni caracteres de control.';

  @override
  String get sftpPermissionDenied => 'El servidor denegó el permiso.';

  @override
  String get sftpFailed =>
      'SFTP falló. Comprueba el acceso, los permisos y el soporte del subsistema; vuelve a conectar.';

  @override
  String get sftpDirectoryLimit =>
      'Esta carpeta supera el límite de 5.000 entradas.';

  @override
  String get sftpRegularOnly =>
      'Esta acción admite archivos regulares, no enlaces simbólicos.';

  @override
  String get sftpTooLarge =>
      'Límite de transferencia: 16 MiB. Límite del editor: 256 KiB.';

  @override
  String get sftpTextOnly => 'El editor admite texto UTF-8 sin bytes nulos.';

  @override
  String get sftpExists => 'El destino ya existe o no es un archivo regular.';

  @override
  String get sftpChanged =>
      'El archivo remoto ha cambiado. Vuelve a cargarlo antes de guardar.';

  @override
  String get sftpLocalFailed =>
      'No se pudo acceder al documento local seleccionado.';

  @override
  String get sftpHelp =>
      'SFTP usa esta conexión SSH verificada y los permisos del servidor. Transferencias de hasta 16 MiB; edición UTF-8 de hasta 256 KiB. No se guardan archivos en caché. Las descargas se guardan donde elijas y el proveedor puede sincronizarlas. SSH se cierra mientras el selector está abierto; las subidas reconectan tras autenticar el dispositivo. Solo se eliminan archivos, enlaces o carpetas vacías. Una transferencia interrumpida puede dejar un archivo remoto parcial. Reemplazar requiere soporte para renombrar sobre el destino; si falla, se conserva el original.';

  @override
  String get sftpConfirm => 'Confirmar';

  @override
  String get monitorTitle => 'Supervisión';

  @override
  String get monitorHelp =>
      'Las comprobaciones se realizan en este teléfono. Android puede retrasarlas en reposo o tras un cierre forzado. Una conexión fallida puede deberse a la red o VPN; no demuestra que el servidor esté caído. Dos fallos consecutivos generan una alerta. La disponibilidad es el porcentaje de comprobaciones accesibles de los últimos 30 días, no un uptime continuo. Se excluyen comprobaciones sin red o desconocidas. Coolify analiza los últimos 20 despliegues y la salud de los recursos; los fallos existentes son la referencia inicial. SSH requiere una clave de servidor ya verificada.';

  @override
  String get monitorEnable => 'Activar supervisión';

  @override
  String get monitorConsent =>
      '¿Permitir que Capidock utilice las credenciales cifradas de esta instancia para comprobaciones de solo lectura en segundo plano, incluso con la app bloqueada? El historial permanece cifrado localmente.';

  @override
  String get monitorInterval => 'Intervalo en segundo plano';

  @override
  String get monitorPermission => 'Notificaciones permitidas';

  @override
  String get monitorPermissionOff => 'Las notificaciones están desactivadas';

  @override
  String get monitorRequest => 'Permitir notificaciones';

  @override
  String get monitorCheck => 'Comprobar pronto';

  @override
  String get monitorScheduled =>
      'Comprobación programada. Android decide cuándo ejecutarla.';

  @override
  String get monitorEmpty => 'Crea una instancia para iniciar la supervisión.';

  @override
  String get monitorNoChecks => 'Sin comprobaciones todavía';

  @override
  String get monitorObserved => 'Disponibilidad observada';

  @override
  String get monitorHistory => 'Historial · últimos 30 días';

  @override
  String get monitorAlerts => 'Alertas';

  @override
  String get monitorAlertConnections => 'Problemas de conexión y acceso';

  @override
  String get monitorAlertDeployments => 'Eventos de deployments';

  @override
  String get monitorAlertResources => 'Cambios de estado de los recursos';

  @override
  String get monitorAlertRecovery => 'Recuperación';

  @override
  String get monitorUp => 'Accesible';

  @override
  String get monitorDown => 'Conexión fallida';

  @override
  String get monitorOffline => 'Teléfono sin red';

  @override
  String get monitorAuthentication => 'Revisa credenciales o permisos';

  @override
  String get monitorIdentity => 'Identidad SSH no verificada';

  @override
  String get monitorUnknown => 'Comprobación incompleta';

  @override
  String get monitorStale => 'Esperando una nueva comprobación';

  @override
  String get monitorLatency => 'Latencia';

  @override
  String get monitorLimit => 'Puedes supervisar hasta 20 instancias.';

  @override
  String get monitorFastTitle => 'Supervisión rápida de Coolify';

  @override
  String get monitorFastHelp =>
      'Comprueba las instancias Coolify activadas mientras la app está abierta y desbloqueada. Se pausa en segundo plano. Las conexiones lentas pueden retrasar las comprobaciones; los eventos breves pueden pasar desapercibidos.';

  @override
  String get monitorFastInterval => 'Intervalo con la app abierta';

  @override
  String get monitorDeploymentStarted => 'Deployment iniciado';

  @override
  String get monitorDeploymentSucceeded => 'Deployment completado';

  @override
  String get monitorDeploymentCancelled => 'Deployment cancelado';

  @override
  String get monitorResourceChanged => 'Estado del recurso modificado';

  @override
  String get monitorDeploymentFailed => 'El despliegue ha fallado';

  @override
  String get monitorResourceUnhealthy => 'Recurso con problemas';
}
