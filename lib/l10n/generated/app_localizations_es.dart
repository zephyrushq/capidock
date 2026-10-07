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
  String get coolifyDescription => 'Aplicaciones y despliegues';

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
      'En Coolify, habilita la API y crea un token de lectura en Keys & Tokens → API tokens. Usa la URL base sin /api/v1.';

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
  String get coolifyDescription => 'Aplicaciones y despliegues';

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
      'En Coolify, habilita la API y crea un token de lectura en Keys & Tokens → API tokens. Usa la URL base sin /api/v1.';

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
}
