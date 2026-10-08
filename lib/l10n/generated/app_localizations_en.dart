// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get emptyProjectTitle => 'A space for\nevery project.';

  @override
  String get emptyServerTitle => 'Your next server\nstarts here.';

  @override
  String get emptyProjectBody =>
      'Create a workspace to organise your SSH and Coolify instances.';

  @override
  String get createWorkspace => 'Create workspace';

  @override
  String get addInstance => 'Add instance';

  @override
  String get aboutDescription =>
      'A dock for all your servers.\n\nEach workspace brings together your SSH and Coolify channels. Settings and credentials stay encrypted on this device. Connect directly via SSH or browse resources through the Coolify API.';

  @override
  String get aboutLicence =>
      'Open source under GPL-3.0-only. You may redistribute and modify the app under the licence terms. No warranty, to the extent permitted by law.\n\nLicence texts, credits and trademark policy are available under View licences, even offline.';

  @override
  String get sourceCode =>
      'Source code: https://github.com/zephyrushq/capidock-mobile';

  @override
  String get removeInstanceTitle => 'Remove instance?';

  @override
  String get removeInstanceError => 'Could not remove the instance. Try again.';

  @override
  String get preservedData => 'Your saved data has been preserved.';

  @override
  String get retry => 'Try again';

  @override
  String get openInstances => 'Open instances';

  @override
  String get firstWorkspace => 'Create your first workspace';

  @override
  String get instanceOptions => 'Instance options';

  @override
  String get editInstance => 'Edit instance';

  @override
  String get moveInstance => 'Move to workspace';

  @override
  String get removeInstance => 'Remove instance';

  @override
  String get aboutCapidock => 'About Capidock';

  @override
  String get unnamedResource => 'Unnamed';

  @override
  String get unavailableStatus => 'Status unavailable';

  @override
  String get coolifyHttpsError => 'Coolify requires a valid HTTPS URL.';

  @override
  String get apiTokenRequired => 'Configure the API token.';

  @override
  String get invalidToken =>
      'Invalid or expired token. Edit the instance credential.';

  @override
  String get coolifyAccessDenied =>
      'Access denied. Check token permissions, the API and the IP allowlist.';

  @override
  String get apiNotFound =>
      'API not found. Check the base URL and whether the API is enabled.';

  @override
  String get rateLimited => 'Request limit reached. Wait and try again.';

  @override
  String get redirectError =>
      'The server redirected the request. Configure the final HTTPS URL directly.';

  @override
  String get responseTooLarge =>
      'The Coolify response exceeded the 4 MiB limit.';

  @override
  String get coolifyTimeout => 'Coolify timed out. Check your network/VPN.';

  @override
  String get invalidApiResponse =>
      'The API returned an unexpected response. Check the URL and Coolify version.';

  @override
  String get coolifyConnectionError =>
      'Could not contact Coolify. Check your network and HTTPS certificate.';

  @override
  String get sshSessionEnded => 'The SSH session ended. You can reconnect.';

  @override
  String get systemInfoError =>
      'Could not retrieve system information. The terminal remains available. Summary commands require Linux/POSIX.';

  @override
  String get sshAuthError =>
      'Authentication refused. Check the username and SSH credential.';

  @override
  String get sshHostKeyError =>
      'The server identity was not accepted. The connection was stopped.';

  @override
  String get sshPrivateKeyError =>
      'Could not read the private key. Check the key and passphrase.';

  @override
  String get sshTimeout =>
      'The connection timed out. Check your network and SSH port.';

  @override
  String get serverUnreachable =>
      'Server unreachable. Check the address, port and network/VPN.';

  @override
  String get sshConnectionError =>
      'Could not open the SSH session. Check server access and try again.';

  @override
  String get confirmSshServer => 'Confirm SSH server';

  @override
  String get serverKeyChanged => 'The server key has changed';

  @override
  String get compareFingerprint =>
      'Compare this fingerprint with your server\'s fingerprint before trusting it.';

  @override
  String get changedKeyWarning =>
      'This may be a reinstallation or a connection to a different server. Only replace the key after verifying it independently.';

  @override
  String get savedKey => 'Saved key:';

  @override
  String get verifyKeyCommand =>
      'On the server: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (adjust for the displayed key type).';

  @override
  String get trustAndConnect => 'Trust and connect';

  @override
  String get replaceKey => 'Replace key';

  @override
  String get yourServer => 'Your server';

  @override
  String get yourResources => 'Your resources';

  @override
  String get connecting => 'Connecting…';

  @override
  String get receivedData => 'Data received';

  @override
  String get notConnected => 'Not connected';

  @override
  String get addCredentials =>
      'Add a credential to connect this instance. The saved address has been preserved.';

  @override
  String get configureAccess => 'Configure access';

  @override
  String get connectInstance => 'Connect to instance';

  @override
  String get editAccess => 'Edit access';

  @override
  String get openTerminal => 'Open terminal';

  @override
  String get connectForInfo =>
      'Connect to check system information, uptime, memory and disk usage, or use the interactive terminal.';

  @override
  String get noCoolifyResources =>
      'The API returned no resources for this token\'s team.';

  @override
  String get coolifyOverview =>
      'Browse your team\'s applications, databases and services. Status comes directly from the Coolify API.';

  @override
  String get connectionPrivacy =>
      'SSH connections close when you switch instances or put the app in the background. Credentials stay encrypted on your device.';

  @override
  String get activeSshSession => 'Active SSH session';

  @override
  String get terminalDisconnected => 'Terminal disconnected';

  @override
  String get connection => 'Connection';

  @override
  String get openKeyboard => 'Open keyboard';

  @override
  String get loadWorkspacesError => 'Could not load saved workspaces.';

  @override
  String get secureSaveError =>
      'Could not save to secure storage. Your fields have been preserved; try again.';

  @override
  String get welcomeTitle => 'Your servers.\nYour dock.';

  @override
  String get firstServerTitle => 'Make room for\nyour first server.';

  @override
  String get connectionTitle => 'How shall we\nconnect?';

  @override
  String get welcomeBody =>
      'Welcome to Capidock. Create a workspace to bring your project instances together.';

  @override
  String get workspaceName => 'Workspace name';

  @override
  String get workspaceHint => 'e.g. Personal, Company or Project';

  @override
  String get workspaceNameRequired => 'Give your workspace a name.';

  @override
  String get saving => 'Saving…';

  @override
  String get configureConnection => 'Configure connection';

  @override
  String get createAndOpen => 'Create and open instance';

  @override
  String get localByChoice => 'Local by choice. No account, no sync.';

  @override
  String get manageWorkspaces => 'Manage workspaces';

  @override
  String get newWorkspace => 'New workspace';

  @override
  String get renameWorkspace => 'Rename workspace';

  @override
  String get workspaceGrouping =>
      'Group servers by project, client or environment.';

  @override
  String get workspaceEditorHint => 'e.g. Personal, Work, Homelab';

  @override
  String get saveError => 'Could not save. Try again.';

  @override
  String get yourWorkspaces => 'Your workspaces';

  @override
  String get workspaceContexts => 'A space for every context.';

  @override
  String get removeWorkspace => 'Remove workspace';

  @override
  String get noWorkspaces => 'No workspaces yet.';

  @override
  String get removeWorkspaceTitle => 'Remove workspace?';

  @override
  String get removeWorkspaceError =>
      'Could not remove the workspace. Try again.';

  @override
  String get moveInstanceError => 'Could not move the instance. Try again.';

  @override
  String get sshDescription => 'Server access through a terminal';

  @override
  String get coolifyDescription => 'Description';

  @override
  String get hostRequired => 'Enter the instance address.';

  @override
  String get hostNoSpaces => 'The address cannot contain spaces.';

  @override
  String get httpsRequired =>
      'Use an HTTPS URL, such as https://coolify.example.com.';

  @override
  String get hostOnly => 'Use only the server hostname or IP address.';

  @override
  String get privateKeyEmpty => 'The private key is empty.';

  @override
  String get privateKeyFormatError =>
      'Could not read the private key. Check its format and passphrase.';

  @override
  String get instanceName => 'Instance name';

  @override
  String get instanceHint => 'e.g. production-europe';

  @override
  String get instanceNameRequired => 'Give your instance a name.';

  @override
  String get hostname => 'Hostname or IP';

  @override
  String get coolifyUrl => 'Coolify URL';

  @override
  String get invalidUsername => 'Invalid username.';

  @override
  String get authentication => 'Authentication';

  @override
  String get privateKey => 'Private key';

  @override
  String get sshPassword => 'SSH password';

  @override
  String get privateKeyLabel => 'PEM / OpenSSH private key';

  @override
  String get privateKeyHint =>
      'Paste the full key, including the BEGIN and END lines.';

  @override
  String get passphraseLabel => 'Key passphrase (optional)';

  @override
  String get coolifyToken => 'Coolify API token';

  @override
  String get coolifyTokenHint =>
      'In Coolify, enable the API and create a token under Keys & Tokens → API tokens. Read-only tokens can view resources. Editing needs write; deployment operations may need deploy or sensitive. Use the base URL without /api/v1.';

  @override
  String get localCredentials =>
      'Settings and credentials are encrypted on this device. Connect directly to your server without a Capidock account.';

  @override
  String get showCredential => 'Show credential';

  @override
  String get hideCredential => 'Hide credential';

  @override
  String get credentialRequired => 'Enter the credential.';

  @override
  String get newInstanceTitle => 'A new place in your dock.';

  @override
  String get saveConfiguration => 'Save configuration';

  @override
  String get findInstance => 'Find instance';

  @override
  String get emptyInstances => 'This workspace has no instances yet.';

  @override
  String get noInstancesFound => 'No instances found.';

  @override
  String get newInstance => 'New instance';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get save => 'Save';

  @override
  String get rename => 'Rename';

  @override
  String get back => 'Back';

  @override
  String get username => 'Username';

  @override
  String get port => 'Port';

  @override
  String get password => 'Password';

  @override
  String get server => 'Server';

  @override
  String get connected => 'Connected';

  @override
  String get refresh => 'Refresh';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get workspaceStep => 'WORKSPACE';

  @override
  String get instanceStep => 'INSTANCE';

  @override
  String get connectionStep => 'CONNECTION';

  @override
  String get previousData => ' · previous data';

  @override
  String get language => 'Language';

  @override
  String get languageSaveError => 'Could not save your language. Try again.';

  @override
  String emptyWorkspaceBody(String name) {
    return 'Add an SSH or Coolify instance to workspace “$name”.';
  }

  @override
  String removeInstanceBody(String name) {
    return 'The configuration for “$name” will be removed from this device. The server will not be changed.';
  }

  @override
  String firstInstanceBody(String name) {
    return 'Each instance is a channel in “$name”. Start with your first one.';
  }

  @override
  String configureInstanceBody(String name) {
    return 'Configure access to “$name”. You can edit these details later.';
  }

  @override
  String onboardingStep(int step, String name) {
    return 'STEP $step OF 3 · $name';
  }

  @override
  String workspaceLabel(String name) {
    return 'Workspace $name';
  }

  @override
  String workspaceOptions(String name) {
    return 'Options for $name';
  }

  @override
  String removeWorkspaceBody(String name, int count) {
    return '“$name” and its instances ($count) will be removed from this device. The servers will not be changed.';
  }

  @override
  String inWorkspace(String name) {
    return 'In workspace “$name”.';
  }

  @override
  String lastRead(String time, String suffix) {
    return 'Last read: $time$suffix';
  }

  @override
  String httpError(int code) {
    return 'Coolify returned HTTP error $code. Try again.';
  }

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instances',
      one: '1 instance',
      zero: '0 instances',
    );
    return '$_temp0';
  }

  @override
  String workspaceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count local workspaces',
      one: '1 local workspace',
      zero: '0 local workspaces',
    );
    return '$_temp0';
  }

  @override
  String resourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resources',
      one: '1 resource',
      zero: '0 resources',
    );
    return '$_temp0';
  }

  @override
  String get coolifyOperations => 'All operations';

  @override
  String get coolifyApplications => 'Applications';

  @override
  String get coolifyDatabases => 'Databases';

  @override
  String get coolifyServices => 'Services';

  @override
  String get coolifyProjects => 'Projects';

  @override
  String get coolifyServers => 'Servers';

  @override
  String get coolifyPermissions =>
      'Reads need read permission. Editing needs write; deploys and server operations may need deploy or sensitive permission. Your Coolify version determines which operations are available.';

  @override
  String get coolifySearch => 'Search resources or operations';

  @override
  String get coolifyAll => 'All categories';

  @override
  String get coolifyCatalogHelp =>
      'Access the documented Coolify API operations. Field names and descriptions follow the official API. Newer operations may not exist on older installations.';

  @override
  String get coolifyDetails => 'Details';

  @override
  String get coolifyEnvironment => 'Environment';

  @override
  String get coolifyLogs => 'Logs';

  @override
  String get coolifyBackups => 'Backups';

  @override
  String get coolifyStorages => 'Volumes and files';

  @override
  String get coolifyDeployments => 'Deployments';

  @override
  String get coolifyCreate => 'Create';

  @override
  String get coolifyEdit => 'Edit configuration';

  @override
  String get coolifyStart => 'Start';

  @override
  String get coolifyStop => 'Stop';

  @override
  String get coolifyRestart => 'Restart';

  @override
  String get coolifyDeploy => 'Deploy';

  @override
  String get coolifyExecutions => 'Execution history';

  @override
  String get coolifyScheduleBackup => 'Backup schedule';

  @override
  String get coolifyRunBackup => 'Run backup';

  @override
  String get coolifyEmpty => 'No results returned by the API.';

  @override
  String get coolifyConfirm => 'Confirm operation';

  @override
  String get coolifyDestructive => 'Confirm destructive operation';

  @override
  String get coolifyMutationWarning =>
      'This changes the remote server. Stop, restart, deploy, restore and delete operations can interrupt services or remove data. Check the target before continuing.';

  @override
  String coolifyTypeTarget(String target) {
    return 'Type $target to confirm.';
  }

  @override
  String get coolifyExecute => 'Execute operation';

  @override
  String get coolifyRead => 'Read data';

  @override
  String get coolifyReveal => 'Show values and logs (may contain secrets)';

  @override
  String get coolifyChangedOnly =>
      'Only edited fields are sent. Optional fields left untouched keep their server values. Empty edited strings clear a value. Arrays and objects use JSON.';

  @override
  String get coolifyInvalidField => 'Check this value and its required type.';

  @override
  String get coolifyInvalidJson => 'Enter valid JSON.';

  @override
  String get coolifyRequiredPayload =>
      'Fill in at least one field, all required fields, and choose a file for uploads.';

  @override
  String get coolifyChooseFile => 'Choose backup file';

  @override
  String get coolifySuccess =>
      'Request accepted by Coolify. Queued jobs may still be running; refresh their status.';

  @override
  String get coolifyYes => 'Yes';

  @override
  String get coolifyNo => 'No';

  @override
  String get coolifyConflict =>
      'Another operation is in progress or this change conflicts with the current state. Refresh before trying again.';

  @override
  String get coolifyValidationError =>
      'Coolify rejected the fields. Check required values, types and your installed API version.';

  @override
  String get coolifyUploadSize =>
      'Choose a non-empty backup file no larger than 10 GiB.';

  @override
  String get coolifyCancelled =>
      'Connection closed. Refresh to check whether the remote operation completed.';

  @override
  String get coolifySshTerminal =>
      'Coolify does not expose an interactive terminal through its public REST API. Choose a saved SSH connection to access the server.';

  @override
  String get coolifyNoSsh =>
      'Add an SSH instance for this server to a workspace first.';

  @override
  String get coolifyResources => 'Resources';

  @override
  String get coolifyEnvironments => 'Environments';

  @override
  String get coolifySharedVariables => 'Shared variables';

  @override
  String get coolifyName => 'Name';

  @override
  String get coolifyStatus => 'Status';

  @override
  String get coolifyDomains => 'Domains';

  @override
  String get coolifyRepository => 'Repository';

  @override
  String get coolifyBranch => 'Branch';

  @override
  String get coolifyBuildPack => 'Build method';

  @override
  String get coolifyAddress => 'Address';

  @override
  String get coolifyPort => 'Port';

  @override
  String get coolifyUser => 'User';

  @override
  String get coolifyFrequency => 'Schedule';

  @override
  String get coolifyEnabled => 'Enabled';

  @override
  String get coolifyMountPath => 'Mount path';

  @override
  String get coolifyHostPath => 'Host path';

  @override
  String get coolifyCreated => 'Created';

  @override
  String get coolifyUpdated => 'Updated';

  @override
  String get coolifyValue => 'Value';

  @override
  String get coolifyPreview => 'Preview';

  @override
  String get coolifySettings => 'Settings';

  @override
  String get coolifyType => 'Type';

  @override
  String get coolifyRunning => 'Running';

  @override
  String get coolifyStopped => 'Stopped';

  @override
  String get coolifyConfiguration => 'Configuration';

  @override
  String get coolifyOverviewTitle => 'Overview';

  @override
  String get coolifyResourceSearch => 'Search resources';

  @override
  String get coolifyOtherSettings => 'More settings';

  @override
  String get coolifyEnvironmentEmpty => 'No environments in this project yet.';

  @override
  String get coolifyLogsHidden =>
      'Reveal logs to view their contents. They may contain secrets.';

  @override
  String get coolifyResourceEmpty => 'No resources in this environment yet.';

  @override
  String get coolifyRestricted => 'Value protected by token permissions.';

  @override
  String get coolifyVariables => 'Environment variables';

  @override
  String get coolifyNormalVariables => 'Normal variables';

  @override
  String get coolifyPreviewVariables => 'Preview variables';

  @override
  String get coolifyShowValue => 'Show value';

  @override
  String get coolifyHideValue => 'Hide value';

  @override
  String get coolifyEditValue => 'Edit value';

  @override
  String get coolifySaveValue => 'Save value';

  @override
  String get deviceLocked => 'Capidock locked';

  @override
  String get deviceUnlockReason => 'Unlock Capidock credentials';

  @override
  String get deviceUnlock => 'Unlock';

  @override
  String get deviceLockHelp =>
      'Set up a device PIN, password or biometrics to continue.';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String legalUpdated(String date) {
    return 'Updated: $date';
  }

  @override
  String get legalLoadError =>
      'Unable to load this document. Please reopen it.';

  @override
  String get help => 'Help';

  @override
  String get appSettings => 'App settings';

  @override
  String get terminalFontSize => 'Terminal text size';

  @override
  String get lockNow => 'Lock now';

  @override
  String get trustedSshKeys => 'Trusted SSH identities';

  @override
  String get trustedSshHelp =>
      'Compare fingerprints with your server before trusting them. Forgetting an identity asks for confirmation on the next connection; an existing session stays connected.';

  @override
  String get localStorage => 'Local storage';

  @override
  String localCounts(int workspaces, int instances) {
    return '$workspaces workspaces · $instances instances';
  }

  @override
  String get eraseLocalData => 'Erase saved server data';

  @override
  String get eraseLocalWarning =>
      'This permanently removes all saved workspaces, credentials and SSH identities from this device. Your servers are not changed. Device authentication is required.';

  @override
  String get eraseAuthReason =>
      'Authenticate to erase saved Capidock server data';

  @override
  String get localEraseFailed =>
      'Unable to verify that all local server data was erased. Unlock and check your saved data before trying again.';

  @override
  String get noTrustedKeys => 'No trusted identities';

  @override
  String get forgetSshWarning =>
      'Forget this SSH identity? You will need to verify its fingerprint on the next connection.';

  @override
  String get tokenAccess => 'Token access';

  @override
  String get tokenAccessHelp =>
      'These are observations of requests in this session, not the token’s exact permissions. The public API does not report whether a token is readonly or root. Unchecked permissions remain unknown. Only explicit permission errors disable actions; generic access failures can also come from IP rules or proxies. The server validates every request.';

  @override
  String get accessUnknown => 'Unknown';

  @override
  String get accessObserved => 'Observed';

  @override
  String get accessDenied => 'Denied';

  @override
  String get coolifyPermissionDenied =>
      'The server reported a missing permission for this action. Edit the token and reconnect to check again.';

  @override
  String get testConnection => 'Test connection';

  @override
  String get connectionVerified => 'Connection verified';

  @override
  String get connectionTestHelp =>
      'Tests authentication without saving your draft. SSH does not open a terminal or run commands, and trust confirmed here is temporary. Coolify uses a read-only API request; no write or deploy probes are sent.';

  @override
  String get noSearchResults => 'No matching resources.';

  @override
  String get logsPause => 'Pause live logs';

  @override
  String get logsResume => 'Resume live logs';

  @override
  String get logsFollow => 'Follow latest logs';

  @override
  String get backupTitle => 'Encrypted backup';

  @override
  String get backupEncrypted => 'Password-protected file';

  @override
  String get backupContents => 'Workspaces and connection credentials';

  @override
  String get backupExport => 'Export backup';

  @override
  String get backupImport => 'Import backup';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get backupConfirmPassword => 'Confirm password';

  @override
  String get backupPasswordWeak => 'Use at least 12 characters.';

  @override
  String get backupPasswordMismatch => 'The passwords do not match.';

  @override
  String get backupPasswordHelp =>
      'Keep this password safe. Capidock cannot recover it.';

  @override
  String get backupHelp =>
      'Backups include saved workspaces and credentials. AES-256-GCM encryption uses a key derived from your password. The password is not saved. SSH trust, app preferences and server data are excluded. The chosen file provider may sync the encrypted file. Import adds copies and requires verifying SSH identities again.';

  @override
  String get backupImportWarning =>
      'These workspaces will be added as new copies. Existing data stays in place. Verify SSH fingerprints before connecting.';

  @override
  String get backupAuthReason => 'Authenticate to manage encrypted backups.';

  @override
  String get backupExported => 'Encrypted backup saved.';

  @override
  String get backupImported => 'Workspaces imported.';

  @override
  String get backupFailed =>
      'Unable to complete the backup operation. Your saved data has not been replaced.';

  @override
  String get backupInvalid => 'Invalid or unsupported backup.';

  @override
  String get backupUnlockFailed => 'Incorrect password or altered backup.';

  @override
  String get backupTooLarge => 'The backup exceeds the size limit.';

  @override
  String get backupFileFailed => 'Unable to access the backup file.';

  @override
  String get listSearch => 'Search';

  @override
  String get listAllStatuses => 'All statuses';

  @override
  String get listPrevious => 'Previous';

  @override
  String get listNext => 'Next';

  @override
  String get listNoMatches => 'No matching entries.';

  @override
  String listPage(int page) {
    return 'Page $page';
  }

  @override
  String get logsLevelAll => 'All levels';

  @override
  String get logsLevelErrors => 'Errors';

  @override
  String get logsLevelWarnings => 'Warnings';

  @override
  String get logsLineLimit => 'Log lines';

  @override
  String get listHistory => 'History';

  @override
  String get listSchedule => 'Schedule';

  @override
  String get listDetails => 'Details';

  @override
  String get listPageFilterHelp =>
      'Search and status filters apply to the current server page. Use the arrows to browse older deployments.';

  @override
  String get activitySize => 'File size';

  @override
  String get activityCommit => 'Commit message';

  @override
  String get activityFinished => 'Finished';

  @override
  String get activityEnabled => 'Enabled';

  @override
  String get logsShow => 'Show logs';

  @override
  String get logsHide => 'Hide logs';

  @override
  String get coolifyTerminalServer => 'Coolify server';

  @override
  String get coolifyTerminalContainer => 'Container terminal';

  @override
  String get coolifyTerminalHost => 'Server terminal';

  @override
  String get coolifyTerminalNoContainers =>
      'No running containers found for this resource.';

  @override
  String get coolifyTerminalServersFailed =>
      'Could not load servers. Check API permissions and connectivity.';

  @override
  String get coolifyTerminalLinkFailed =>
      'Could not read the saved SSH association.';

  @override
  String get coolifyTerminalConnectFailed =>
      'Could not connect or save the SSH association. Check your credentials and secure storage.';

  @override
  String get coolifyTerminalDockerFailed =>
      'Could not list containers. Check Docker access for this SSH user.';

  @override
  String get coolifyTerminalContainerGone =>
      'This container is no longer running or no longer belongs to this resource. Refresh the list.';

  @override
  String get coolifyTerminalShellFailed =>
      'Could not open the terminal. Check that the selected shell is installed. Reconnect to try again.';

  @override
  String get coolifyTerminalHelp =>
      'Associate the correct SSH connection with the selected Coolify server. Credentials remain encrypted on your device. The API token is not an SSH credential. SSH and Docker permissions apply independently of the token: Docker access can grant full server control. Only running containers belonging to this resource are listed. Close the session when finished; sessions also close in the background.';

  @override
  String get sftpFiles => 'Files';

  @override
  String get sftpUpload => 'Upload file';

  @override
  String get sftpDownload => 'Download';

  @override
  String get sftpReplace => 'Replace remote file?';

  @override
  String get sftpNewFolder => 'New folder';

  @override
  String get sftpRename => 'Rename';

  @override
  String get sftpEditText => 'Edit text';

  @override
  String get sftpParent => 'Parent folder';

  @override
  String get sftpEmpty => 'This folder is empty.';

  @override
  String get sftpInvalidName =>
      'Use a filename without slashes or control characters.';

  @override
  String get sftpPermissionDenied => 'Permission denied by the server.';

  @override
  String get sftpFailed =>
      'SFTP failed. Check access, permissions and subsystem support; reconnect to try again.';

  @override
  String get sftpDirectoryLimit => 'This folder exceeds the 5,000 entry limit.';

  @override
  String get sftpRegularOnly =>
      'This action supports regular files only, not symbolic links.';

  @override
  String get sftpTooLarge =>
      'Transfer limit: 16 MiB. Text editor limit: 256 KiB.';

  @override
  String get sftpTextOnly =>
      'The editor supports UTF-8 text without null bytes.';

  @override
  String get sftpExists =>
      'The destination already exists or is not a regular file.';

  @override
  String get sftpChanged => 'The remote file changed. Reload it before saving.';

  @override
  String get sftpLocalFailed => 'Could not access the selected local document.';

  @override
  String get sftpHelp =>
      'SFTP uses this verified SSH connection and your server permissions. Transfers are limited to 16 MiB; UTF-8 editing to 256 KiB. Files are not cached on the phone. Downloads are saved to the location you choose and may be synced by that provider. SSH closes while the document picker is open; uploads reconnect after device authentication. Delete removes only files, links or empty folders. Interrupted transfers may leave a partial remote file. Replacing a file requires overwrite-rename support; the original is preserved when replacement fails.';

  @override
  String get sftpConfirm => 'Confirm';

  @override
  String get monitorTitle => 'Monitoring';

  @override
  String get monitorHelp =>
      'Checks run locally on this phone. Android may delay them while asleep or after force stop. A failed connection can be caused by your network or VPN; it does not prove the server is down. Two consecutive failures trigger an alert. Availability is the percentage of reachable checks over the last 30 days, not continuous uptime. Offline and unknown checks are excluded. Coolify checks inspect the latest 20 deployments and resource health; existing failures form the initial baseline. SSH must already have a trusted host key.';

  @override
  String get monitorEnable => 'Enable monitoring';

  @override
  String get monitorConsent =>
      'Allow Capidock to use this instance’s encrypted credentials for read-only checks in the background, even while the app is locked? History stays encrypted locally.';

  @override
  String get monitorInterval => 'Background check interval';

  @override
  String get monitorPermission => 'Notifications allowed';

  @override
  String get monitorPermissionOff => 'Notifications are disabled';

  @override
  String get monitorRequest => 'Allow notifications';

  @override
  String get monitorCheck => 'Check soon';

  @override
  String get monitorScheduled =>
      'Check scheduled. Android decides when it runs.';

  @override
  String get monitorEmpty => 'Create an instance to start monitoring.';

  @override
  String get monitorNoChecks => 'No checks yet';

  @override
  String get monitorObserved => 'Observed availability';

  @override
  String get monitorHistory => 'Check history · last 30 days';

  @override
  String get monitorAlerts => 'Alerts';

  @override
  String get monitorAlertConnections => 'Connection and access problems';

  @override
  String get monitorAlertDeployments => 'Deployment events';

  @override
  String get monitorAlertResources => 'Resource state changes';

  @override
  String get monitorAlertRecovery => 'Recovery';

  @override
  String get monitorUp => 'Reachable';

  @override
  String get monitorDown => 'Connection failed';

  @override
  String get monitorOffline => 'Phone offline';

  @override
  String get monitorAuthentication => 'Check credentials or permissions';

  @override
  String get monitorIdentity => 'SSH identity not verified';

  @override
  String get monitorUnknown => 'Check incomplete';

  @override
  String get monitorStale => 'Waiting for a fresh check';

  @override
  String get monitorLatency => 'Latency';

  @override
  String get monitorLimit => 'You can monitor up to 20 instances.';

  @override
  String get monitorFastTitle => 'Fast Coolify monitoring';

  @override
  String get monitorFastHelp =>
      'Checks enabled Coolify instances while the app is open and unlocked. Pauses in the background. Checks may take longer on slow connections; brief events can be missed.';

  @override
  String get monitorFastInterval => 'App open check interval';

  @override
  String get monitorDeploymentStarted => 'Deployment started';

  @override
  String get monitorDeploymentSucceeded => 'Deployment completed';

  @override
  String get monitorDeploymentCancelled => 'Deployment cancelled';

  @override
  String get monitorResourceChanged => 'Resource state changed';

  @override
  String get monitorDeploymentFailed => 'Deployment failed';

  @override
  String get monitorResourceUnhealthy => 'Resource unhealthy';
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get emptyProjectTitle => 'A space for\nevery project.';

  @override
  String get emptyServerTitle => 'Your next server\nstarts here.';

  @override
  String get emptyProjectBody =>
      'Create a workspace to organise your SSH and Coolify instances.';

  @override
  String get createWorkspace => 'Create workspace';

  @override
  String get addInstance => 'Add instance';

  @override
  String get aboutDescription =>
      'A dock for all your servers.\n\nEach workspace brings together your SSH and Coolify channels. Settings and credentials stay encrypted on this device. Connect directly via SSH or browse resources through the Coolify API.';

  @override
  String get aboutLicence =>
      'Open source under GPL-3.0-only. You may redistribute and modify the app under the licence terms. No warranty, to the extent permitted by law.\n\nLicence texts, credits and trademark policy are available under View licences, even offline.';

  @override
  String get sourceCode =>
      'Source code: https://github.com/zephyrushq/capidock-mobile';

  @override
  String get removeInstanceTitle => 'Remove instance?';

  @override
  String get removeInstanceError => 'Could not remove the instance. Try again.';

  @override
  String get preservedData => 'Your saved data has been preserved.';

  @override
  String get retry => 'Try again';

  @override
  String get openInstances => 'Open instances';

  @override
  String get firstWorkspace => 'Create your first workspace';

  @override
  String get instanceOptions => 'Instance options';

  @override
  String get editInstance => 'Edit instance';

  @override
  String get moveInstance => 'Move to workspace';

  @override
  String get removeInstance => 'Remove instance';

  @override
  String get aboutCapidock => 'About Capidock';

  @override
  String get unnamedResource => 'Unnamed';

  @override
  String get unavailableStatus => 'Status unavailable';

  @override
  String get coolifyHttpsError => 'Coolify requires a valid HTTPS URL.';

  @override
  String get apiTokenRequired => 'Configure the API token.';

  @override
  String get invalidToken =>
      'Invalid or expired token. Edit the instance credential.';

  @override
  String get coolifyAccessDenied =>
      'Access denied. Check token permissions, the API and the IP allowlist.';

  @override
  String get apiNotFound =>
      'API not found. Check the base URL and whether the API is enabled.';

  @override
  String get rateLimited => 'Request limit reached. Wait and try again.';

  @override
  String get redirectError =>
      'The server redirected the request. Configure the final HTTPS URL directly.';

  @override
  String get responseTooLarge =>
      'The Coolify response exceeded the 4 MiB limit.';

  @override
  String get coolifyTimeout => 'Coolify timed out. Check your network/VPN.';

  @override
  String get invalidApiResponse =>
      'The API returned an unexpected response. Check the URL and Coolify version.';

  @override
  String get coolifyConnectionError =>
      'Could not contact Coolify. Check your network and HTTPS certificate.';

  @override
  String get sshSessionEnded => 'The SSH session ended. You can reconnect.';

  @override
  String get systemInfoError =>
      'Could not retrieve system information. The terminal remains available. Summary commands require Linux/POSIX.';

  @override
  String get sshAuthError =>
      'Authentication refused. Check the username and SSH credential.';

  @override
  String get sshHostKeyError =>
      'The server identity was not accepted. The connection was stopped.';

  @override
  String get sshPrivateKeyError =>
      'Could not read the private key. Check the key and passphrase.';

  @override
  String get sshTimeout =>
      'The connection timed out. Check your network and SSH port.';

  @override
  String get serverUnreachable =>
      'Server unreachable. Check the address, port and network/VPN.';

  @override
  String get sshConnectionError =>
      'Could not open the SSH session. Check server access and try again.';

  @override
  String get confirmSshServer => 'Confirm SSH server';

  @override
  String get serverKeyChanged => 'The server key has changed';

  @override
  String get compareFingerprint =>
      'Compare this fingerprint with your server\'s fingerprint before trusting it.';

  @override
  String get changedKeyWarning =>
      'This may be a reinstallation or a connection to a different server. Only replace the key after verifying it independently.';

  @override
  String get savedKey => 'Saved key:';

  @override
  String get verifyKeyCommand =>
      'On the server: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (adjust for the displayed key type).';

  @override
  String get trustAndConnect => 'Trust and connect';

  @override
  String get replaceKey => 'Replace key';

  @override
  String get yourServer => 'Your server';

  @override
  String get yourResources => 'Your resources';

  @override
  String get connecting => 'Connecting…';

  @override
  String get receivedData => 'Data received';

  @override
  String get notConnected => 'Not connected';

  @override
  String get addCredentials =>
      'Add a credential to connect this instance. The saved address has been preserved.';

  @override
  String get configureAccess => 'Configure access';

  @override
  String get connectInstance => 'Connect to instance';

  @override
  String get editAccess => 'Edit access';

  @override
  String get openTerminal => 'Open terminal';

  @override
  String get connectForInfo =>
      'Connect to check system information, uptime, memory and disk usage, or use the interactive terminal.';

  @override
  String get noCoolifyResources =>
      'The API returned no resources for this token\'s team.';

  @override
  String get coolifyOverview =>
      'Browse your team\'s applications, databases and services. Status comes directly from the Coolify API.';

  @override
  String get connectionPrivacy =>
      'SSH connections close when you switch instances or put the app in the background. Credentials stay encrypted on your device.';

  @override
  String get activeSshSession => 'Active SSH session';

  @override
  String get terminalDisconnected => 'Terminal disconnected';

  @override
  String get connection => 'Connection';

  @override
  String get openKeyboard => 'Open keyboard';

  @override
  String get loadWorkspacesError => 'Could not load saved workspaces.';

  @override
  String get secureSaveError =>
      'Could not save to secure storage. Your fields have been preserved; try again.';

  @override
  String get welcomeTitle => 'Your servers.\nYour dock.';

  @override
  String get firstServerTitle => 'Make room for\nyour first server.';

  @override
  String get connectionTitle => 'How shall we\nconnect?';

  @override
  String get welcomeBody =>
      'Welcome to Capidock. Create a workspace to bring your project instances together.';

  @override
  String get workspaceName => 'Workspace name';

  @override
  String get workspaceHint => 'e.g. Personal, Company or Project';

  @override
  String get workspaceNameRequired => 'Give your workspace a name.';

  @override
  String get saving => 'Saving…';

  @override
  String get configureConnection => 'Configure connection';

  @override
  String get createAndOpen => 'Create and open instance';

  @override
  String get localByChoice => 'Local by choice. No account, no sync.';

  @override
  String get manageWorkspaces => 'Manage workspaces';

  @override
  String get newWorkspace => 'New workspace';

  @override
  String get renameWorkspace => 'Rename workspace';

  @override
  String get workspaceGrouping =>
      'Group servers by project, client or environment.';

  @override
  String get workspaceEditorHint => 'e.g. Personal, Work, Homelab';

  @override
  String get saveError => 'Could not save. Try again.';

  @override
  String get yourWorkspaces => 'Your workspaces';

  @override
  String get workspaceContexts => 'A space for every context.';

  @override
  String get removeWorkspace => 'Remove workspace';

  @override
  String get noWorkspaces => 'No workspaces yet.';

  @override
  String get removeWorkspaceTitle => 'Remove workspace?';

  @override
  String get removeWorkspaceError =>
      'Could not remove the workspace. Try again.';

  @override
  String get moveInstanceError => 'Could not move the instance. Try again.';

  @override
  String get sshDescription => 'Server access through a terminal';

  @override
  String get coolifyDescription => 'Description';

  @override
  String get hostRequired => 'Enter the instance address.';

  @override
  String get hostNoSpaces => 'The address cannot contain spaces.';

  @override
  String get httpsRequired =>
      'Use an HTTPS URL, such as https://coolify.example.com.';

  @override
  String get hostOnly => 'Use only the server hostname or IP address.';

  @override
  String get privateKeyEmpty => 'The private key is empty.';

  @override
  String get privateKeyFormatError =>
      'Could not read the private key. Check its format and passphrase.';

  @override
  String get instanceName => 'Instance name';

  @override
  String get instanceHint => 'e.g. production-europe';

  @override
  String get instanceNameRequired => 'Give your instance a name.';

  @override
  String get hostname => 'Hostname or IP';

  @override
  String get coolifyUrl => 'Coolify URL';

  @override
  String get invalidUsername => 'Invalid username.';

  @override
  String get authentication => 'Authentication';

  @override
  String get privateKey => 'Private key';

  @override
  String get sshPassword => 'SSH password';

  @override
  String get privateKeyLabel => 'PEM / OpenSSH private key';

  @override
  String get privateKeyHint =>
      'Paste the full key, including the BEGIN and END lines.';

  @override
  String get passphraseLabel => 'Key passphrase (optional)';

  @override
  String get coolifyToken => 'Coolify API token';

  @override
  String get coolifyTokenHint =>
      'In Coolify, enable the API and create a token under Keys & Tokens → API tokens. Read-only tokens can view resources. Editing needs write; deployment operations may need deploy or sensitive. Use the base URL without /api/v1.';

  @override
  String get localCredentials =>
      'Settings and credentials are encrypted on this device. Connect directly to your server without a Capidock account.';

  @override
  String get showCredential => 'Show credential';

  @override
  String get hideCredential => 'Hide credential';

  @override
  String get credentialRequired => 'Enter the credential.';

  @override
  String get newInstanceTitle => 'A new place in your dock.';

  @override
  String get saveConfiguration => 'Save configuration';

  @override
  String get findInstance => 'Find instance';

  @override
  String get emptyInstances => 'This workspace has no instances yet.';

  @override
  String get noInstancesFound => 'No instances found.';

  @override
  String get newInstance => 'New instance';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get save => 'Save';

  @override
  String get rename => 'Rename';

  @override
  String get back => 'Back';

  @override
  String get username => 'Username';

  @override
  String get port => 'Port';

  @override
  String get password => 'Password';

  @override
  String get server => 'Server';

  @override
  String get connected => 'Connected';

  @override
  String get refresh => 'Refresh';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get workspaceStep => 'WORKSPACE';

  @override
  String get instanceStep => 'INSTANCE';

  @override
  String get connectionStep => 'CONNECTION';

  @override
  String get previousData => ' · previous data';

  @override
  String get language => 'Language';

  @override
  String get languageSaveError => 'Could not save your language. Try again.';

  @override
  String emptyWorkspaceBody(String name) {
    return 'Add an SSH or Coolify instance to workspace “$name”.';
  }

  @override
  String removeInstanceBody(String name) {
    return 'The configuration for “$name” will be removed from this device. The server will not be changed.';
  }

  @override
  String firstInstanceBody(String name) {
    return 'Each instance is a channel in “$name”. Start with your first one.';
  }

  @override
  String configureInstanceBody(String name) {
    return 'Configure access to “$name”. You can edit these details later.';
  }

  @override
  String onboardingStep(int step, String name) {
    return 'STEP $step OF 3 · $name';
  }

  @override
  String workspaceLabel(String name) {
    return 'Workspace $name';
  }

  @override
  String workspaceOptions(String name) {
    return 'Options for $name';
  }

  @override
  String removeWorkspaceBody(String name, int count) {
    return '“$name” and its instances ($count) will be removed from this device. The servers will not be changed.';
  }

  @override
  String inWorkspace(String name) {
    return 'In workspace “$name”.';
  }

  @override
  String lastRead(String time, String suffix) {
    return 'Last read: $time$suffix';
  }

  @override
  String httpError(int code) {
    return 'Coolify returned HTTP error $code. Try again.';
  }

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instances',
      one: '1 instance',
      zero: '0 instances',
    );
    return '$_temp0';
  }

  @override
  String workspaceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count local workspaces',
      one: '1 local workspace',
      zero: '0 local workspaces',
    );
    return '$_temp0';
  }

  @override
  String resourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resources',
      one: '1 resource',
      zero: '0 resources',
    );
    return '$_temp0';
  }

  @override
  String get coolifyOperations => 'All operations';

  @override
  String get coolifyApplications => 'Applications';

  @override
  String get coolifyDatabases => 'Databases';

  @override
  String get coolifyServices => 'Services';

  @override
  String get coolifyProjects => 'Projects';

  @override
  String get coolifyServers => 'Servers';

  @override
  String get coolifyPermissions =>
      'Reads need read permission. Editing needs write; deploys and server operations may need deploy or sensitive permission. Your Coolify version determines which operations are available.';

  @override
  String get coolifySearch => 'Search resources or operations';

  @override
  String get coolifyAll => 'All categories';

  @override
  String get coolifyCatalogHelp =>
      'Access the documented Coolify API operations. Field names and descriptions follow the official API. Newer operations may not exist on older installations.';

  @override
  String get coolifyDetails => 'Details';

  @override
  String get coolifyEnvironment => 'Environment';

  @override
  String get coolifyLogs => 'Logs';

  @override
  String get coolifyBackups => 'Backups';

  @override
  String get coolifyStorages => 'Volumes and files';

  @override
  String get coolifyDeployments => 'Deployments';

  @override
  String get coolifyCreate => 'Create';

  @override
  String get coolifyEdit => 'Edit configuration';

  @override
  String get coolifyStart => 'Start';

  @override
  String get coolifyStop => 'Stop';

  @override
  String get coolifyRestart => 'Restart';

  @override
  String get coolifyDeploy => 'Deploy';

  @override
  String get coolifyExecutions => 'Execution history';

  @override
  String get coolifyScheduleBackup => 'Backup schedule';

  @override
  String get coolifyRunBackup => 'Run backup';

  @override
  String get coolifyEmpty => 'No results returned by the API.';

  @override
  String get coolifyConfirm => 'Confirm operation';

  @override
  String get coolifyDestructive => 'Confirm destructive operation';

  @override
  String get coolifyMutationWarning =>
      'This changes the remote server. Stop, restart, deploy, restore and delete operations can interrupt services or remove data. Check the target before continuing.';

  @override
  String coolifyTypeTarget(String target) {
    return 'Type $target to confirm.';
  }

  @override
  String get coolifyExecute => 'Execute operation';

  @override
  String get coolifyRead => 'Read data';

  @override
  String get coolifyReveal => 'Show values and logs (may contain secrets)';

  @override
  String get coolifyChangedOnly =>
      'Only edited fields are sent. Optional fields left untouched keep their server values. Empty edited strings clear a value. Arrays and objects use JSON.';

  @override
  String get coolifyInvalidField => 'Check this value and its required type.';

  @override
  String get coolifyInvalidJson => 'Enter valid JSON.';

  @override
  String get coolifyRequiredPayload =>
      'Fill in at least one field, all required fields, and choose a file for uploads.';

  @override
  String get coolifyChooseFile => 'Choose backup file';

  @override
  String get coolifySuccess =>
      'Request accepted by Coolify. Queued jobs may still be running; refresh their status.';

  @override
  String get coolifyYes => 'Yes';

  @override
  String get coolifyNo => 'No';

  @override
  String get coolifyConflict =>
      'Another operation is in progress or this change conflicts with the current state. Refresh before trying again.';

  @override
  String get coolifyValidationError =>
      'Coolify rejected the fields. Check required values, types and your installed API version.';

  @override
  String get coolifyUploadSize =>
      'Choose a non-empty backup file no larger than 10 GiB.';

  @override
  String get coolifyCancelled =>
      'Connection closed. Refresh to check whether the remote operation completed.';

  @override
  String get coolifySshTerminal =>
      'Coolify does not expose an interactive terminal through its public REST API. Choose a saved SSH connection to access the server.';

  @override
  String get coolifyNoSsh =>
      'Add an SSH instance for this server to a workspace first.';

  @override
  String get coolifyResources => 'Resources';

  @override
  String get coolifyEnvironments => 'Environments';

  @override
  String get coolifySharedVariables => 'Shared variables';

  @override
  String get coolifyName => 'Name';

  @override
  String get coolifyStatus => 'Status';

  @override
  String get coolifyDomains => 'Domains';

  @override
  String get coolifyRepository => 'Repository';

  @override
  String get coolifyBranch => 'Branch';

  @override
  String get coolifyBuildPack => 'Build method';

  @override
  String get coolifyAddress => 'Address';

  @override
  String get coolifyPort => 'Port';

  @override
  String get coolifyUser => 'User';

  @override
  String get coolifyFrequency => 'Schedule';

  @override
  String get coolifyEnabled => 'Enabled';

  @override
  String get coolifyMountPath => 'Mount path';

  @override
  String get coolifyHostPath => 'Host path';

  @override
  String get coolifyCreated => 'Created';

  @override
  String get coolifyUpdated => 'Updated';

  @override
  String get coolifyValue => 'Value';

  @override
  String get coolifyPreview => 'Preview';

  @override
  String get coolifySettings => 'Settings';

  @override
  String get coolifyType => 'Type';

  @override
  String get coolifyRunning => 'Running';

  @override
  String get coolifyStopped => 'Stopped';

  @override
  String get coolifyConfiguration => 'Configuration';

  @override
  String get coolifyOverviewTitle => 'Overview';

  @override
  String get coolifyResourceSearch => 'Search resources';

  @override
  String get coolifyOtherSettings => 'More settings';

  @override
  String get coolifyEnvironmentEmpty => 'No environments in this project yet.';

  @override
  String get coolifyLogsHidden =>
      'Reveal logs to view their contents. They may contain secrets.';

  @override
  String get coolifyResourceEmpty => 'No resources in this environment yet.';

  @override
  String get coolifyRestricted => 'Value protected by token permissions.';

  @override
  String get coolifyVariables => 'Environment variables';

  @override
  String get coolifyNormalVariables => 'Normal variables';

  @override
  String get coolifyPreviewVariables => 'Preview variables';

  @override
  String get coolifyShowValue => 'Show value';

  @override
  String get coolifyHideValue => 'Hide value';

  @override
  String get coolifyEditValue => 'Edit value';

  @override
  String get coolifySaveValue => 'Save value';

  @override
  String get deviceLocked => 'Capidock locked';

  @override
  String get deviceUnlockReason => 'Unlock Capidock credentials';

  @override
  String get deviceUnlock => 'Unlock';

  @override
  String get deviceLockHelp =>
      'Set up a device PIN, password or biometrics to continue.';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String legalUpdated(String date) {
    return 'Updated: $date';
  }

  @override
  String get legalLoadError =>
      'Unable to load this document. Please reopen it.';

  @override
  String get help => 'Help';

  @override
  String get appSettings => 'App settings';

  @override
  String get terminalFontSize => 'Terminal text size';

  @override
  String get lockNow => 'Lock now';

  @override
  String get trustedSshKeys => 'Trusted SSH identities';

  @override
  String get trustedSshHelp =>
      'Compare fingerprints with your server before trusting them. Forgetting an identity asks for confirmation on the next connection; an existing session stays connected.';

  @override
  String get localStorage => 'Local storage';

  @override
  String localCounts(int workspaces, int instances) {
    return '$workspaces workspaces · $instances instances';
  }

  @override
  String get eraseLocalData => 'Erase saved server data';

  @override
  String get eraseLocalWarning =>
      'This permanently removes all saved workspaces, credentials and SSH identities from this device. Your servers are not changed. Device authentication is required.';

  @override
  String get eraseAuthReason =>
      'Authenticate to erase saved Capidock server data';

  @override
  String get localEraseFailed =>
      'Unable to verify that all local server data was erased. Unlock and check your saved data before trying again.';

  @override
  String get noTrustedKeys => 'No trusted identities';

  @override
  String get forgetSshWarning =>
      'Forget this SSH identity? You will need to verify its fingerprint on the next connection.';

  @override
  String get tokenAccess => 'Token access';

  @override
  String get tokenAccessHelp =>
      'These are observations of requests in this session, not the token’s exact permissions. The public API does not report whether a token is readonly or root. Unchecked permissions remain unknown. Only explicit permission errors disable actions; generic access failures can also come from IP rules or proxies. The server validates every request.';

  @override
  String get accessUnknown => 'Unknown';

  @override
  String get accessObserved => 'Observed';

  @override
  String get accessDenied => 'Denied';

  @override
  String get coolifyPermissionDenied =>
      'The server reported a missing permission for this action. Edit the token and reconnect to check again.';

  @override
  String get testConnection => 'Test connection';

  @override
  String get connectionVerified => 'Connection verified';

  @override
  String get connectionTestHelp =>
      'Tests authentication without saving your draft. SSH does not open a terminal or run commands, and trust confirmed here is temporary. Coolify uses a read-only API request; no write or deploy probes are sent.';

  @override
  String get noSearchResults => 'No matching resources.';

  @override
  String get logsPause => 'Pause live logs';

  @override
  String get logsResume => 'Resume live logs';

  @override
  String get logsFollow => 'Follow latest logs';

  @override
  String get backupTitle => 'Encrypted backup';

  @override
  String get backupEncrypted => 'Password-protected file';

  @override
  String get backupContents => 'Workspaces and connection credentials';

  @override
  String get backupExport => 'Export backup';

  @override
  String get backupImport => 'Import backup';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get backupConfirmPassword => 'Confirm password';

  @override
  String get backupPasswordWeak => 'Use at least 12 characters.';

  @override
  String get backupPasswordMismatch => 'The passwords do not match.';

  @override
  String get backupPasswordHelp =>
      'Keep this password safe. Capidock cannot recover it.';

  @override
  String get backupHelp =>
      'Backups include saved workspaces and credentials. AES-256-GCM encryption uses a key derived from your password. The password is not saved. SSH trust, app preferences and server data are excluded. The chosen file provider may sync the encrypted file. Import adds copies and requires verifying SSH identities again.';

  @override
  String get backupImportWarning =>
      'These workspaces will be added as new copies. Existing data stays in place. Verify SSH fingerprints before connecting.';

  @override
  String get backupAuthReason => 'Authenticate to manage encrypted backups.';

  @override
  String get backupExported => 'Encrypted backup saved.';

  @override
  String get backupImported => 'Workspaces imported.';

  @override
  String get backupFailed =>
      'Unable to complete the backup operation. Your saved data has not been replaced.';

  @override
  String get backupInvalid => 'Invalid or unsupported backup.';

  @override
  String get backupUnlockFailed => 'Incorrect password or altered backup.';

  @override
  String get backupTooLarge => 'The backup exceeds the size limit.';

  @override
  String get backupFileFailed => 'Unable to access the backup file.';

  @override
  String get listSearch => 'Search';

  @override
  String get listAllStatuses => 'All statuses';

  @override
  String get listPrevious => 'Previous';

  @override
  String get listNext => 'Next';

  @override
  String get listNoMatches => 'No matching entries.';

  @override
  String listPage(int page) {
    return 'Page $page';
  }

  @override
  String get logsLevelAll => 'All levels';

  @override
  String get logsLevelErrors => 'Errors';

  @override
  String get logsLevelWarnings => 'Warnings';

  @override
  String get logsLineLimit => 'Log lines';

  @override
  String get listHistory => 'History';

  @override
  String get listSchedule => 'Schedule';

  @override
  String get listDetails => 'Details';

  @override
  String get listPageFilterHelp =>
      'Search and status filters apply to the current server page. Use the arrows to browse older deployments.';

  @override
  String get activitySize => 'File size';

  @override
  String get activityCommit => 'Commit message';

  @override
  String get activityFinished => 'Finished';

  @override
  String get activityEnabled => 'Enabled';

  @override
  String get logsShow => 'Show logs';

  @override
  String get logsHide => 'Hide logs';

  @override
  String get coolifyTerminalServer => 'Coolify server';

  @override
  String get coolifyTerminalContainer => 'Container terminal';

  @override
  String get coolifyTerminalHost => 'Server terminal';

  @override
  String get coolifyTerminalNoContainers =>
      'No running containers found for this resource.';

  @override
  String get coolifyTerminalServersFailed =>
      'Could not load servers. Check API permissions and connectivity.';

  @override
  String get coolifyTerminalLinkFailed =>
      'Could not read the saved SSH association.';

  @override
  String get coolifyTerminalConnectFailed =>
      'Could not connect or save the SSH association. Check your credentials and secure storage.';

  @override
  String get coolifyTerminalDockerFailed =>
      'Could not list containers. Check Docker access for this SSH user.';

  @override
  String get coolifyTerminalContainerGone =>
      'This container is no longer running or no longer belongs to this resource. Refresh the list.';

  @override
  String get coolifyTerminalShellFailed =>
      'Could not open the terminal. Check that the selected shell is installed. Reconnect to try again.';

  @override
  String get coolifyTerminalHelp =>
      'Associate the correct SSH connection with the selected Coolify server. Credentials remain encrypted on your device. The API token is not an SSH credential. SSH and Docker permissions apply independently of the token: Docker access can grant full server control. Only running containers belonging to this resource are listed. Close the session when finished; sessions also close in the background.';

  @override
  String get sftpFiles => 'Files';

  @override
  String get sftpUpload => 'Upload file';

  @override
  String get sftpDownload => 'Download';

  @override
  String get sftpReplace => 'Replace remote file?';

  @override
  String get sftpNewFolder => 'New folder';

  @override
  String get sftpRename => 'Rename';

  @override
  String get sftpEditText => 'Edit text';

  @override
  String get sftpParent => 'Parent folder';

  @override
  String get sftpEmpty => 'This folder is empty.';

  @override
  String get sftpInvalidName =>
      'Use a filename without slashes or control characters.';

  @override
  String get sftpPermissionDenied => 'Permission denied by the server.';

  @override
  String get sftpFailed =>
      'SFTP failed. Check access, permissions and subsystem support; reconnect to try again.';

  @override
  String get sftpDirectoryLimit => 'This folder exceeds the 5,000 entry limit.';

  @override
  String get sftpRegularOnly =>
      'This action supports regular files only, not symbolic links.';

  @override
  String get sftpTooLarge =>
      'Transfer limit: 16 MiB. Text editor limit: 256 KiB.';

  @override
  String get sftpTextOnly =>
      'The editor supports UTF-8 text without null bytes.';

  @override
  String get sftpExists =>
      'The destination already exists or is not a regular file.';

  @override
  String get sftpChanged => 'The remote file changed. Reload it before saving.';

  @override
  String get sftpLocalFailed => 'Could not access the selected local document.';

  @override
  String get sftpHelp =>
      'SFTP uses this verified SSH connection and your server permissions. Transfers are limited to 16 MiB; UTF-8 editing to 256 KiB. Files are not cached on the phone. Downloads are saved to the location you choose and may be synced by that provider. SSH closes while the document picker is open; uploads reconnect after device authentication. Delete removes only files, links or empty folders. Interrupted transfers may leave a partial remote file. Replacing a file requires overwrite-rename support; the original is preserved when replacement fails.';

  @override
  String get sftpConfirm => 'Confirm';

  @override
  String get monitorTitle => 'Monitoring';

  @override
  String get monitorHelp =>
      'Checks run locally on this phone. Android may delay them while asleep or after force stop. A failed connection can be caused by your network or VPN; it does not prove the server is down. Two consecutive failures trigger an alert. Availability is the percentage of reachable checks over the last 30 days, not continuous uptime. Offline and unknown checks are excluded. Coolify checks inspect the latest 20 deployments and resource health; existing failures form the initial baseline. SSH must already have a trusted host key.';

  @override
  String get monitorEnable => 'Enable monitoring';

  @override
  String get monitorConsent =>
      'Allow Capidock to use this instance’s encrypted credentials for read-only checks in the background, even while the app is locked? History stays encrypted locally.';

  @override
  String get monitorInterval => 'Background check interval';

  @override
  String get monitorPermission => 'Notifications allowed';

  @override
  String get monitorPermissionOff => 'Notifications are disabled';

  @override
  String get monitorRequest => 'Allow notifications';

  @override
  String get monitorCheck => 'Check soon';

  @override
  String get monitorScheduled =>
      'Check scheduled. Android decides when it runs.';

  @override
  String get monitorEmpty => 'Create an instance to start monitoring.';

  @override
  String get monitorNoChecks => 'No checks yet';

  @override
  String get monitorObserved => 'Observed availability';

  @override
  String get monitorHistory => 'Check history · last 30 days';

  @override
  String get monitorAlerts => 'Alerts';

  @override
  String get monitorAlertConnections => 'Connection and access problems';

  @override
  String get monitorAlertDeployments => 'Deployment events';

  @override
  String get monitorAlertResources => 'Resource state changes';

  @override
  String get monitorAlertRecovery => 'Recovery';

  @override
  String get monitorUp => 'Reachable';

  @override
  String get monitorDown => 'Connection failed';

  @override
  String get monitorOffline => 'Phone offline';

  @override
  String get monitorAuthentication => 'Check credentials or permissions';

  @override
  String get monitorIdentity => 'SSH identity not verified';

  @override
  String get monitorUnknown => 'Check incomplete';

  @override
  String get monitorStale => 'Waiting for a fresh check';

  @override
  String get monitorLatency => 'Latency';

  @override
  String get monitorLimit => 'You can monitor up to 20 instances.';

  @override
  String get monitorFastTitle => 'Fast Coolify monitoring';

  @override
  String get monitorFastHelp =>
      'Checks enabled Coolify instances while the app is open and unlocked. Pauses in the background. Checks may take longer on slow connections; brief events can be missed.';

  @override
  String get monitorFastInterval => 'App open check interval';

  @override
  String get monitorDeploymentStarted => 'Deployment started';

  @override
  String get monitorDeploymentSucceeded => 'Deployment completed';

  @override
  String get monitorDeploymentCancelled => 'Deployment cancelled';

  @override
  String get monitorResourceChanged => 'Resource state changed';

  @override
  String get monitorDeploymentFailed => 'Deployment failed';

  @override
  String get monitorResourceUnhealthy => 'Resource unhealthy';
}

/// The translations for English, as used in the United States (`en_US`).
class AppLocalizationsEnUs extends AppLocalizationsEn {
  AppLocalizationsEnUs() : super('en_US');

  @override
  String get emptyProjectTitle => 'A space for\nevery project.';

  @override
  String get emptyServerTitle => 'Your next server\nstarts here.';

  @override
  String get emptyProjectBody =>
      'Create a workspace to organize your SSH and Coolify instances.';

  @override
  String get createWorkspace => 'Create workspace';

  @override
  String get addInstance => 'Add instance';

  @override
  String get aboutDescription =>
      'A dock for all your servers.\n\nEach workspace brings together your SSH and Coolify channels. Settings and credentials stay encrypted on this device. Connect directly via SSH or browse resources through the Coolify API.';

  @override
  String get aboutLicence =>
      'Open source under GPL-3.0-only. You may redistribute and modify the app under the license terms. No warranty, to the extent permitted by law.\n\nLicence texts, credits and trademark policy are available under View licenses, even offline.';

  @override
  String get sourceCode =>
      'Source code: https://github.com/zephyrushq/capidock-mobile';

  @override
  String get removeInstanceTitle => 'Remove instance?';

  @override
  String get removeInstanceError => 'Could not remove the instance. Try again.';

  @override
  String get preservedData => 'Your saved data has been preserved.';

  @override
  String get retry => 'Try again';

  @override
  String get openInstances => 'Open instances';

  @override
  String get firstWorkspace => 'Create your first workspace';

  @override
  String get instanceOptions => 'Instance options';

  @override
  String get editInstance => 'Edit instance';

  @override
  String get moveInstance => 'Move to workspace';

  @override
  String get removeInstance => 'Remove instance';

  @override
  String get aboutCapidock => 'About Capidock';

  @override
  String get unnamedResource => 'Unnamed';

  @override
  String get unavailableStatus => 'Status unavailable';

  @override
  String get coolifyHttpsError => 'Coolify requires a valid HTTPS URL.';

  @override
  String get apiTokenRequired => 'Configure the API token.';

  @override
  String get invalidToken =>
      'Invalid or expired token. Edit the instance credential.';

  @override
  String get coolifyAccessDenied =>
      'Access denied. Check token permissions, the API and the IP allowlist.';

  @override
  String get apiNotFound =>
      'API not found. Check the base URL and whether the API is enabled.';

  @override
  String get rateLimited => 'Request limit reached. Wait and try again.';

  @override
  String get redirectError =>
      'The server redirected the request. Configure the final HTTPS URL directly.';

  @override
  String get responseTooLarge =>
      'The Coolify response exceeded the 4 MiB limit.';

  @override
  String get coolifyTimeout => 'Coolify timed out. Check your network/VPN.';

  @override
  String get invalidApiResponse =>
      'The API returned an unexpected response. Check the URL and Coolify version.';

  @override
  String get coolifyConnectionError =>
      'Could not contact Coolify. Check your network and HTTPS certificate.';

  @override
  String get sshSessionEnded => 'The SSH session ended. You can reconnect.';

  @override
  String get systemInfoError =>
      'Could not retrieve system information. The terminal remains available. Summary commands require Linux/POSIX.';

  @override
  String get sshAuthError =>
      'Authentication refused. Check the username and SSH credential.';

  @override
  String get sshHostKeyError =>
      'The server identity was not accepted. The connection was stopped.';

  @override
  String get sshPrivateKeyError =>
      'Could not read the private key. Check the key and passphrase.';

  @override
  String get sshTimeout =>
      'The connection timed out. Check your network and SSH port.';

  @override
  String get serverUnreachable =>
      'Server unreachable. Check the address, port and network/VPN.';

  @override
  String get sshConnectionError =>
      'Could not open the SSH session. Check server access and try again.';

  @override
  String get confirmSshServer => 'Confirm SSH server';

  @override
  String get serverKeyChanged => 'The server key has changed';

  @override
  String get compareFingerprint =>
      'Compare this fingerprint with your server\'s fingerprint before trusting it.';

  @override
  String get changedKeyWarning =>
      'This may be a reinstallation or a connection to a different server. Only replace the key after verifying it independently.';

  @override
  String get savedKey => 'Saved key:';

  @override
  String get verifyKeyCommand =>
      'On the server: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (adjust for the displayed key type).';

  @override
  String get trustAndConnect => 'Trust and connect';

  @override
  String get replaceKey => 'Replace key';

  @override
  String get yourServer => 'Your server';

  @override
  String get yourResources => 'Your resources';

  @override
  String get connecting => 'Connecting…';

  @override
  String get receivedData => 'Data received';

  @override
  String get notConnected => 'Not connected';

  @override
  String get addCredentials =>
      'Add a credential to connect this instance. The saved address has been preserved.';

  @override
  String get configureAccess => 'Configure access';

  @override
  String get connectInstance => 'Connect to instance';

  @override
  String get editAccess => 'Edit access';

  @override
  String get openTerminal => 'Open terminal';

  @override
  String get connectForInfo =>
      'Connect to check system information, uptime, memory and disk usage, or use the interactive terminal.';

  @override
  String get noCoolifyResources =>
      'The API returned no resources for this token\'s team.';

  @override
  String get coolifyOverview =>
      'Browse your team\'s applications, databases and services. Status comes directly from the Coolify API.';

  @override
  String get connectionPrivacy =>
      'SSH connections close when you switch instances or put the app in the background. Credentials stay encrypted on your device.';

  @override
  String get activeSshSession => 'Active SSH session';

  @override
  String get terminalDisconnected => 'Terminal disconnected';

  @override
  String get connection => 'Connection';

  @override
  String get openKeyboard => 'Open keyboard';

  @override
  String get loadWorkspacesError => 'Could not load saved workspaces.';

  @override
  String get secureSaveError =>
      'Could not save to secure storage. Your fields have been preserved; try again.';

  @override
  String get welcomeTitle => 'Your servers.\nYour dock.';

  @override
  String get firstServerTitle => 'Make room for\nyour first server.';

  @override
  String get connectionTitle => 'How shall we\nconnect?';

  @override
  String get welcomeBody =>
      'Welcome to Capidock. Create a workspace to bring your project instances together.';

  @override
  String get workspaceName => 'Workspace name';

  @override
  String get workspaceHint => 'e.g. Personal, Company or Project';

  @override
  String get workspaceNameRequired => 'Give your workspace a name.';

  @override
  String get saving => 'Saving…';

  @override
  String get configureConnection => 'Configure connection';

  @override
  String get createAndOpen => 'Create and open instance';

  @override
  String get localByChoice => 'Local by choice. No account, no sync.';

  @override
  String get manageWorkspaces => 'Manage workspaces';

  @override
  String get newWorkspace => 'New workspace';

  @override
  String get renameWorkspace => 'Rename workspace';

  @override
  String get workspaceGrouping =>
      'Group servers by project, client or environment.';

  @override
  String get workspaceEditorHint => 'e.g. Personal, Work, Homelab';

  @override
  String get saveError => 'Could not save. Try again.';

  @override
  String get yourWorkspaces => 'Your workspaces';

  @override
  String get workspaceContexts => 'A space for every context.';

  @override
  String get removeWorkspace => 'Remove workspace';

  @override
  String get noWorkspaces => 'No workspaces yet.';

  @override
  String get removeWorkspaceTitle => 'Remove workspace?';

  @override
  String get removeWorkspaceError =>
      'Could not remove the workspace. Try again.';

  @override
  String get moveInstanceError => 'Could not move the instance. Try again.';

  @override
  String get sshDescription => 'Server access through a terminal';

  @override
  String get coolifyDescription => 'Description';

  @override
  String get hostRequired => 'Enter the instance address.';

  @override
  String get hostNoSpaces => 'The address cannot contain spaces.';

  @override
  String get httpsRequired =>
      'Use an HTTPS URL, such as https://coolify.example.com.';

  @override
  String get hostOnly => 'Use only the server hostname or IP address.';

  @override
  String get privateKeyEmpty => 'The private key is empty.';

  @override
  String get privateKeyFormatError =>
      'Could not read the private key. Check its format and passphrase.';

  @override
  String get instanceName => 'Instance name';

  @override
  String get instanceHint => 'e.g. production-europe';

  @override
  String get instanceNameRequired => 'Give your instance a name.';

  @override
  String get hostname => 'Hostname or IP';

  @override
  String get coolifyUrl => 'Coolify URL';

  @override
  String get invalidUsername => 'Invalid username.';

  @override
  String get authentication => 'Authentication';

  @override
  String get privateKey => 'Private key';

  @override
  String get sshPassword => 'SSH password';

  @override
  String get privateKeyLabel => 'PEM / OpenSSH private key';

  @override
  String get privateKeyHint =>
      'Paste the full key, including the BEGIN and END lines.';

  @override
  String get passphraseLabel => 'Key passphrase (optional)';

  @override
  String get coolifyToken => 'Coolify API token';

  @override
  String get coolifyTokenHint =>
      'In Coolify, enable the API and create a token under Keys & Tokens → API tokens. Read-only tokens can view resources. Editing needs write; deployment operations may need deploy or sensitive. Use the base URL without /api/v1.';

  @override
  String get localCredentials =>
      'Settings and credentials are encrypted on this device. Connect directly to your server without a Capidock account.';

  @override
  String get showCredential => 'Show credential';

  @override
  String get hideCredential => 'Hide credential';

  @override
  String get credentialRequired => 'Enter the credential.';

  @override
  String get newInstanceTitle => 'A new place in your dock.';

  @override
  String get saveConfiguration => 'Save configuration';

  @override
  String get findInstance => 'Find instance';

  @override
  String get emptyInstances => 'This workspace has no instances yet.';

  @override
  String get noInstancesFound => 'No instances found.';

  @override
  String get newInstance => 'New instance';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get save => 'Save';

  @override
  String get rename => 'Rename';

  @override
  String get back => 'Back';

  @override
  String get username => 'Username';

  @override
  String get port => 'Port';

  @override
  String get password => 'Password';

  @override
  String get server => 'Server';

  @override
  String get connected => 'Connected';

  @override
  String get refresh => 'Refresh';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get workspaceStep => 'WORKSPACE';

  @override
  String get instanceStep => 'INSTANCE';

  @override
  String get connectionStep => 'CONNECTION';

  @override
  String get previousData => ' · previous data';

  @override
  String get language => 'Language';

  @override
  String get languageSaveError => 'Could not save your language. Try again.';

  @override
  String emptyWorkspaceBody(String name) {
    return 'Add an SSH or Coolify instance to workspace “$name”.';
  }

  @override
  String removeInstanceBody(String name) {
    return 'The configuration for “$name” will be removed from this device. The server will not be changed.';
  }

  @override
  String firstInstanceBody(String name) {
    return 'Each instance is a channel in “$name”. Start with your first one.';
  }

  @override
  String configureInstanceBody(String name) {
    return 'Configure access to “$name”. You can edit these details later.';
  }

  @override
  String onboardingStep(int step, String name) {
    return 'STEP $step OF 3 · $name';
  }

  @override
  String workspaceLabel(String name) {
    return 'Workspace $name';
  }

  @override
  String workspaceOptions(String name) {
    return 'Options for $name';
  }

  @override
  String removeWorkspaceBody(String name, int count) {
    return '“$name” and its instances ($count) will be removed from this device. The servers will not be changed.';
  }

  @override
  String inWorkspace(String name) {
    return 'In workspace “$name”.';
  }

  @override
  String lastRead(String time, String suffix) {
    return 'Last read: $time$suffix';
  }

  @override
  String httpError(int code) {
    return 'Coolify returned HTTP error $code. Try again.';
  }

  @override
  String instanceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instances',
      one: '1 instance',
      zero: '0 instances',
    );
    return '$_temp0';
  }

  @override
  String workspaceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count local workspaces',
      one: '1 local workspace',
      zero: '0 local workspaces',
    );
    return '$_temp0';
  }

  @override
  String resourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resources',
      one: '1 resource',
      zero: '0 resources',
    );
    return '$_temp0';
  }

  @override
  String get coolifyOperations => 'All operations';

  @override
  String get coolifyApplications => 'Applications';

  @override
  String get coolifyDatabases => 'Databases';

  @override
  String get coolifyServices => 'Services';

  @override
  String get coolifyProjects => 'Projects';

  @override
  String get coolifyServers => 'Servers';

  @override
  String get coolifyPermissions =>
      'Reads need read permission. Editing needs write; deploys and server operations may need deploy or sensitive permission. Your Coolify version determines which operations are available.';

  @override
  String get coolifySearch => 'Search resources or operations';

  @override
  String get coolifyAll => 'All categories';

  @override
  String get coolifyCatalogHelp =>
      'Access the documented Coolify API operations. Field names and descriptions follow the official API. Newer operations may not exist on older installations.';

  @override
  String get coolifyDetails => 'Details';

  @override
  String get coolifyEnvironment => 'Environment';

  @override
  String get coolifyLogs => 'Logs';

  @override
  String get coolifyBackups => 'Backups';

  @override
  String get coolifyStorages => 'Volumes and files';

  @override
  String get coolifyDeployments => 'Deployments';

  @override
  String get coolifyCreate => 'Create';

  @override
  String get coolifyEdit => 'Edit configuration';

  @override
  String get coolifyStart => 'Start';

  @override
  String get coolifyStop => 'Stop';

  @override
  String get coolifyRestart => 'Restart';

  @override
  String get coolifyDeploy => 'Deploy';

  @override
  String get coolifyExecutions => 'Execution history';

  @override
  String get coolifyScheduleBackup => 'Backup schedule';

  @override
  String get coolifyRunBackup => 'Run backup';

  @override
  String get coolifyEmpty => 'No results returned by the API.';

  @override
  String get coolifyConfirm => 'Confirm operation';

  @override
  String get coolifyDestructive => 'Confirm destructive operation';

  @override
  String get coolifyMutationWarning =>
      'This changes the remote server. Stop, restart, deploy, restore and delete operations can interrupt services or remove data. Check the target before continuing.';

  @override
  String coolifyTypeTarget(String target) {
    return 'Type $target to confirm.';
  }

  @override
  String get coolifyExecute => 'Execute operation';

  @override
  String get coolifyRead => 'Read data';

  @override
  String get coolifyReveal => 'Show values and logs (may contain secrets)';

  @override
  String get coolifyChangedOnly =>
      'Only edited fields are sent. Optional fields left untouched keep their server values. Empty edited strings clear a value. Arrays and objects use JSON.';

  @override
  String get coolifyInvalidField => 'Check this value and its required type.';

  @override
  String get coolifyInvalidJson => 'Enter valid JSON.';

  @override
  String get coolifyRequiredPayload =>
      'Fill in at least one field, all required fields, and choose a file for uploads.';

  @override
  String get coolifyChooseFile => 'Choose backup file';

  @override
  String get coolifySuccess =>
      'Request accepted by Coolify. Queued jobs may still be running; refresh their status.';

  @override
  String get coolifyYes => 'Yes';

  @override
  String get coolifyNo => 'No';

  @override
  String get coolifyConflict =>
      'Another operation is in progress or this change conflicts with the current state. Refresh before trying again.';

  @override
  String get coolifyValidationError =>
      'Coolify rejected the fields. Check required values, types and your installed API version.';

  @override
  String get coolifyUploadSize =>
      'Choose a non-empty backup file no larger than 10 GiB.';

  @override
  String get coolifyCancelled =>
      'Connection closed. Refresh to check whether the remote operation completed.';

  @override
  String get coolifySshTerminal =>
      'Coolify does not expose an interactive terminal through its public REST API. Choose a saved SSH connection to access the server.';

  @override
  String get coolifyNoSsh =>
      'Add an SSH instance for this server to a workspace first.';

  @override
  String get coolifyResources => 'Resources';

  @override
  String get coolifyEnvironments => 'Environments';

  @override
  String get coolifySharedVariables => 'Shared variables';

  @override
  String get coolifyName => 'Name';

  @override
  String get coolifyStatus => 'Status';

  @override
  String get coolifyDomains => 'Domains';

  @override
  String get coolifyRepository => 'Repository';

  @override
  String get coolifyBranch => 'Branch';

  @override
  String get coolifyBuildPack => 'Build method';

  @override
  String get coolifyAddress => 'Address';

  @override
  String get coolifyPort => 'Port';

  @override
  String get coolifyUser => 'User';

  @override
  String get coolifyFrequency => 'Schedule';

  @override
  String get coolifyEnabled => 'Enabled';

  @override
  String get coolifyMountPath => 'Mount path';

  @override
  String get coolifyHostPath => 'Host path';

  @override
  String get coolifyCreated => 'Created';

  @override
  String get coolifyUpdated => 'Updated';

  @override
  String get coolifyValue => 'Value';

  @override
  String get coolifyPreview => 'Preview';

  @override
  String get coolifySettings => 'Settings';

  @override
  String get coolifyType => 'Type';

  @override
  String get coolifyRunning => 'Running';

  @override
  String get coolifyStopped => 'Stopped';

  @override
  String get coolifyConfiguration => 'Configuration';

  @override
  String get coolifyOverviewTitle => 'Overview';

  @override
  String get coolifyResourceSearch => 'Search resources';

  @override
  String get coolifyOtherSettings => 'More settings';

  @override
  String get coolifyEnvironmentEmpty => 'No environments in this project yet.';

  @override
  String get coolifyLogsHidden =>
      'Reveal logs to view their contents. They may contain secrets.';

  @override
  String get coolifyResourceEmpty => 'No resources in this environment yet.';

  @override
  String get coolifyRestricted => 'Value protected by token permissions.';

  @override
  String get coolifyVariables => 'Environment variables';

  @override
  String get coolifyNormalVariables => 'Normal variables';

  @override
  String get coolifyPreviewVariables => 'Preview variables';

  @override
  String get coolifyShowValue => 'Show value';

  @override
  String get coolifyHideValue => 'Hide value';

  @override
  String get coolifyEditValue => 'Edit value';

  @override
  String get coolifySaveValue => 'Save value';

  @override
  String get deviceLocked => 'Capidock locked';

  @override
  String get deviceUnlockReason => 'Unlock Capidock credentials';

  @override
  String get deviceUnlock => 'Unlock';

  @override
  String get deviceLockHelp =>
      'Set up a device PIN, password or biometrics to continue.';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String legalUpdated(String date) {
    return 'Updated: $date';
  }

  @override
  String get legalLoadError =>
      'Unable to load this document. Please reopen it.';

  @override
  String get help => 'Help';

  @override
  String get appSettings => 'App settings';

  @override
  String get terminalFontSize => 'Terminal text size';

  @override
  String get lockNow => 'Lock now';

  @override
  String get trustedSshKeys => 'Trusted SSH identities';

  @override
  String get trustedSshHelp =>
      'Compare fingerprints with your server before trusting them. Forgetting an identity asks for confirmation on the next connection; an existing session stays connected.';

  @override
  String get localStorage => 'Local storage';

  @override
  String localCounts(int workspaces, int instances) {
    return '$workspaces workspaces · $instances instances';
  }

  @override
  String get eraseLocalData => 'Erase saved server data';

  @override
  String get eraseLocalWarning =>
      'This permanently removes all saved workspaces, credentials and SSH identities from this device. Your servers are not changed. Device authentication is required.';

  @override
  String get eraseAuthReason =>
      'Authenticate to erase saved Capidock server data';

  @override
  String get localEraseFailed =>
      'Unable to verify that all local server data was erased. Unlock and check your saved data before trying again.';

  @override
  String get noTrustedKeys => 'No trusted identities';

  @override
  String get forgetSshWarning =>
      'Forget this SSH identity? You will need to verify its fingerprint on the next connection.';

  @override
  String get tokenAccess => 'Token access';

  @override
  String get tokenAccessHelp =>
      'These are observations of requests in this session, not the token’s exact permissions. The public API does not report whether a token is readonly or root. Unchecked permissions remain unknown. Only explicit permission errors disable actions; generic access failures can also come from IP rules or proxies. The server validates every request.';

  @override
  String get accessUnknown => 'Unknown';

  @override
  String get accessObserved => 'Observed';

  @override
  String get accessDenied => 'Denied';

  @override
  String get coolifyPermissionDenied =>
      'The server reported a missing permission for this action. Edit the token and reconnect to check again.';

  @override
  String get testConnection => 'Test connection';

  @override
  String get connectionVerified => 'Connection verified';

  @override
  String get connectionTestHelp =>
      'Tests authentication without saving your draft. SSH does not open a terminal or run commands, and trust confirmed here is temporary. Coolify uses a read-only API request; no write or deploy probes are sent.';

  @override
  String get noSearchResults => 'No matching resources.';

  @override
  String get logsPause => 'Pause live logs';

  @override
  String get logsResume => 'Resume live logs';

  @override
  String get logsFollow => 'Follow latest logs';

  @override
  String get backupTitle => 'Encrypted backup';

  @override
  String get backupEncrypted => 'Password-protected file';

  @override
  String get backupContents => 'Workspaces and connection credentials';

  @override
  String get backupExport => 'Export backup';

  @override
  String get backupImport => 'Import backup';

  @override
  String get backupPassword => 'Backup password';

  @override
  String get backupConfirmPassword => 'Confirm password';

  @override
  String get backupPasswordWeak => 'Use at least 12 characters.';

  @override
  String get backupPasswordMismatch => 'The passwords do not match.';

  @override
  String get backupPasswordHelp =>
      'Keep this password safe. Capidock cannot recover it.';

  @override
  String get backupHelp =>
      'Backups include saved workspaces and credentials. AES-256-GCM encryption uses a key derived from your password. The password is not saved. SSH trust, app preferences and server data are excluded. The chosen file provider may sync the encrypted file. Import adds copies and requires verifying SSH identities again.';

  @override
  String get backupImportWarning =>
      'These workspaces will be added as new copies. Existing data stays in place. Verify SSH fingerprints before connecting.';

  @override
  String get backupAuthReason => 'Authenticate to manage encrypted backups.';

  @override
  String get backupExported => 'Encrypted backup saved.';

  @override
  String get backupImported => 'Workspaces imported.';

  @override
  String get backupFailed =>
      'Unable to complete the backup operation. Your saved data has not been replaced.';

  @override
  String get backupInvalid => 'Invalid or unsupported backup.';

  @override
  String get backupUnlockFailed => 'Incorrect password or altered backup.';

  @override
  String get backupTooLarge => 'The backup exceeds the size limit.';

  @override
  String get backupFileFailed => 'Unable to access the backup file.';

  @override
  String get listSearch => 'Search';

  @override
  String get listAllStatuses => 'All statuses';

  @override
  String get listPrevious => 'Previous';

  @override
  String get listNext => 'Next';

  @override
  String get listNoMatches => 'No matching entries.';

  @override
  String listPage(int page) {
    return 'Page $page';
  }

  @override
  String get logsLevelAll => 'All levels';

  @override
  String get logsLevelErrors => 'Errors';

  @override
  String get logsLevelWarnings => 'Warnings';

  @override
  String get logsLineLimit => 'Log lines';

  @override
  String get listHistory => 'History';

  @override
  String get listSchedule => 'Schedule';

  @override
  String get listDetails => 'Details';

  @override
  String get listPageFilterHelp =>
      'Search and status filters apply to the current server page. Use the arrows to browse older deployments.';

  @override
  String get activitySize => 'File size';

  @override
  String get activityCommit => 'Commit message';

  @override
  String get activityFinished => 'Finished';

  @override
  String get activityEnabled => 'Enabled';

  @override
  String get logsShow => 'Show logs';

  @override
  String get logsHide => 'Hide logs';

  @override
  String get coolifyTerminalServer => 'Coolify server';

  @override
  String get coolifyTerminalContainer => 'Container terminal';

  @override
  String get coolifyTerminalHost => 'Server terminal';

  @override
  String get coolifyTerminalNoContainers =>
      'No running containers found for this resource.';

  @override
  String get coolifyTerminalServersFailed =>
      'Could not load servers. Check API permissions and connectivity.';

  @override
  String get coolifyTerminalLinkFailed =>
      'Could not read the saved SSH association.';

  @override
  String get coolifyTerminalConnectFailed =>
      'Could not connect or save the SSH association. Check your credentials and secure storage.';

  @override
  String get coolifyTerminalDockerFailed =>
      'Could not list containers. Check Docker access for this SSH user.';

  @override
  String get coolifyTerminalContainerGone =>
      'This container is no longer running or no longer belongs to this resource. Refresh the list.';

  @override
  String get coolifyTerminalShellFailed =>
      'Could not open the terminal. Check that the selected shell is installed. Reconnect to try again.';

  @override
  String get coolifyTerminalHelp =>
      'Associate the correct SSH connection with the selected Coolify server. Credentials remain encrypted on your device. The API token is not an SSH credential. SSH and Docker permissions apply independently of the token: Docker access can grant full server control. Only running containers belonging to this resource are listed. Close the session when finished; sessions also close in the background.';

  @override
  String get sftpFiles => 'Files';

  @override
  String get sftpUpload => 'Upload file';

  @override
  String get sftpDownload => 'Download';

  @override
  String get sftpReplace => 'Replace remote file?';

  @override
  String get sftpNewFolder => 'New folder';

  @override
  String get sftpRename => 'Rename';

  @override
  String get sftpEditText => 'Edit text';

  @override
  String get sftpParent => 'Parent folder';

  @override
  String get sftpEmpty => 'This folder is empty.';

  @override
  String get sftpInvalidName =>
      'Use a filename without slashes or control characters.';

  @override
  String get sftpPermissionDenied => 'Permission denied by the server.';

  @override
  String get sftpFailed =>
      'SFTP failed. Check access, permissions and subsystem support; reconnect to try again.';

  @override
  String get sftpDirectoryLimit => 'This folder exceeds the 5,000 entry limit.';

  @override
  String get sftpRegularOnly =>
      'This action supports regular files only, not symbolic links.';

  @override
  String get sftpTooLarge =>
      'Transfer limit: 16 MiB. Text editor limit: 256 KiB.';

  @override
  String get sftpTextOnly =>
      'The editor supports UTF-8 text without null bytes.';

  @override
  String get sftpExists =>
      'The destination already exists or is not a regular file.';

  @override
  String get sftpChanged => 'The remote file changed. Reload it before saving.';

  @override
  String get sftpLocalFailed => 'Could not access the selected local document.';

  @override
  String get sftpHelp =>
      'SFTP uses this verified SSH connection and your server permissions. Transfers are limited to 16 MiB; UTF-8 editing to 256 KiB. Files are not cached on the phone. Downloads are saved to the location you choose and may be synced by that provider. SSH closes while the document picker is open; uploads reconnect after device authentication. Delete removes only files, links or empty folders. Interrupted transfers may leave a partial remote file. Replacing a file requires overwrite-rename support; the original is preserved when replacement fails.';

  @override
  String get sftpConfirm => 'Confirm';

  @override
  String get monitorTitle => 'Monitoring';

  @override
  String get monitorHelp =>
      'Checks run locally on this phone. Android may delay them while asleep or after force stop. A failed connection can be caused by your network or VPN; it does not prove the server is down. Two consecutive failures trigger an alert. Availability is the percentage of reachable checks over the last 30 days, not continuous uptime. Offline and unknown checks are excluded. Coolify checks inspect the latest 20 deployments and resource health; existing failures form the initial baseline. SSH must already have a trusted host key.';

  @override
  String get monitorEnable => 'Enable monitoring';

  @override
  String get monitorConsent =>
      'Allow Capidock to use this instance’s encrypted credentials for read-only checks in the background, even while the app is locked? History stays encrypted locally.';

  @override
  String get monitorInterval => 'Background check interval';

  @override
  String get monitorPermission => 'Notifications allowed';

  @override
  String get monitorPermissionOff => 'Notifications are disabled';

  @override
  String get monitorRequest => 'Allow notifications';

  @override
  String get monitorCheck => 'Check soon';

  @override
  String get monitorScheduled =>
      'Check scheduled. Android decides when it runs.';

  @override
  String get monitorEmpty => 'Create an instance to start monitoring.';

  @override
  String get monitorNoChecks => 'No checks yet';

  @override
  String get monitorObserved => 'Observed availability';

  @override
  String get monitorHistory => 'Check history · last 30 days';

  @override
  String get monitorAlerts => 'Alerts';

  @override
  String get monitorAlertConnections => 'Connection and access problems';

  @override
  String get monitorAlertDeployments => 'Deployment events';

  @override
  String get monitorAlertResources => 'Resource state changes';

  @override
  String get monitorAlertRecovery => 'Recovery';

  @override
  String get monitorUp => 'Reachable';

  @override
  String get monitorDown => 'Connection failed';

  @override
  String get monitorOffline => 'Phone offline';

  @override
  String get monitorAuthentication => 'Check credentials or permissions';

  @override
  String get monitorIdentity => 'SSH identity not verified';

  @override
  String get monitorUnknown => 'Check incomplete';

  @override
  String get monitorStale => 'Waiting for a fresh check';

  @override
  String get monitorLatency => 'Latency';

  @override
  String get monitorLimit => 'You can monitor up to 20 instances.';

  @override
  String get monitorFastTitle => 'Fast Coolify monitoring';

  @override
  String get monitorFastHelp =>
      'Checks enabled Coolify instances while the app is open and unlocked. Pauses in the background. Checks may take longer on slow connections; brief events can be missed.';

  @override
  String get monitorFastInterval => 'App open check interval';

  @override
  String get monitorDeploymentStarted => 'Deployment started';

  @override
  String get monitorDeploymentSucceeded => 'Deployment completed';

  @override
  String get monitorDeploymentCancelled => 'Deployment cancelled';

  @override
  String get monitorResourceChanged => 'Resource state changed';

  @override
  String get monitorDeploymentFailed => 'Deployment failed';

  @override
  String get monitorResourceUnhealthy => 'Resource unhealthy';
}
