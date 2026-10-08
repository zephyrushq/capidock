import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en', 'GB'),
    Locale('en', 'US'),
    Locale('pt', 'PT'),
    Locale('pt', 'BR'),
    Locale('es', 'ES'),
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @emptyProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'A space for\nevery project.'**
  String get emptyProjectTitle;

  /// No description provided for @emptyServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your next server\nstarts here.'**
  String get emptyServerTitle;

  /// No description provided for @emptyProjectBody.
  ///
  /// In en, this message translates to:
  /// **'Create a workspace to organise your SSH and Coolify instances.'**
  String get emptyProjectBody;

  /// No description provided for @createWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create workspace'**
  String get createWorkspace;

  /// No description provided for @addInstance.
  ///
  /// In en, this message translates to:
  /// **'Add instance'**
  String get addInstance;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'A dock for all your servers.\n\nEach workspace brings together your SSH and Coolify channels. Settings and credentials stay encrypted on this device. Connect directly via SSH or browse resources through the Coolify API.'**
  String get aboutDescription;

  /// No description provided for @aboutLicence.
  ///
  /// In en, this message translates to:
  /// **'Open source under GPL-3.0-only. You may redistribute and modify the app under the licence terms. No warranty, to the extent permitted by law.\n\nLicence texts, credits and trademark policy are available under View licences, even offline.'**
  String get aboutLicence;

  /// No description provided for @sourceCode.
  ///
  /// In en, this message translates to:
  /// **'Source code: https://github.com/zephyrushq/capidock-mobile'**
  String get sourceCode;

  /// No description provided for @removeInstanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove instance?'**
  String get removeInstanceTitle;

  /// No description provided for @removeInstanceError.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the instance. Try again.'**
  String get removeInstanceError;

  /// No description provided for @preservedData.
  ///
  /// In en, this message translates to:
  /// **'Your saved data has been preserved.'**
  String get preservedData;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @openInstances.
  ///
  /// In en, this message translates to:
  /// **'Open instances'**
  String get openInstances;

  /// No description provided for @firstWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create your first workspace'**
  String get firstWorkspace;

  /// No description provided for @instanceOptions.
  ///
  /// In en, this message translates to:
  /// **'Instance options'**
  String get instanceOptions;

  /// No description provided for @editInstance.
  ///
  /// In en, this message translates to:
  /// **'Edit instance'**
  String get editInstance;

  /// No description provided for @moveInstance.
  ///
  /// In en, this message translates to:
  /// **'Move to workspace'**
  String get moveInstance;

  /// No description provided for @removeInstance.
  ///
  /// In en, this message translates to:
  /// **'Remove instance'**
  String get removeInstance;

  /// No description provided for @aboutCapidock.
  ///
  /// In en, this message translates to:
  /// **'About Capidock'**
  String get aboutCapidock;

  /// No description provided for @unnamedResource.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get unnamedResource;

  /// No description provided for @unavailableStatus.
  ///
  /// In en, this message translates to:
  /// **'Status unavailable'**
  String get unavailableStatus;

  /// No description provided for @coolifyHttpsError.
  ///
  /// In en, this message translates to:
  /// **'Coolify requires a valid HTTPS URL.'**
  String get coolifyHttpsError;

  /// No description provided for @apiTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Configure the API token.'**
  String get apiTokenRequired;

  /// No description provided for @invalidToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired token. Edit the instance credential.'**
  String get invalidToken;

  /// No description provided for @coolifyAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied. Check token permissions, the API and the IP allowlist.'**
  String get coolifyAccessDenied;

  /// No description provided for @apiNotFound.
  ///
  /// In en, this message translates to:
  /// **'API not found. Check the base URL and whether the API is enabled.'**
  String get apiNotFound;

  /// No description provided for @rateLimited.
  ///
  /// In en, this message translates to:
  /// **'Request limit reached. Wait and try again.'**
  String get rateLimited;

  /// No description provided for @redirectError.
  ///
  /// In en, this message translates to:
  /// **'The server redirected the request. Configure the final HTTPS URL directly.'**
  String get redirectError;

  /// No description provided for @responseTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The Coolify response exceeded the 4 MiB limit.'**
  String get responseTooLarge;

  /// No description provided for @coolifyTimeout.
  ///
  /// In en, this message translates to:
  /// **'Coolify timed out. Check your network/VPN.'**
  String get coolifyTimeout;

  /// No description provided for @invalidApiResponse.
  ///
  /// In en, this message translates to:
  /// **'The API returned an unexpected response. Check the URL and Coolify version.'**
  String get invalidApiResponse;

  /// No description provided for @coolifyConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not contact Coolify. Check your network and HTTPS certificate.'**
  String get coolifyConnectionError;

  /// No description provided for @sshSessionEnded.
  ///
  /// In en, this message translates to:
  /// **'The SSH session ended. You can reconnect.'**
  String get sshSessionEnded;

  /// No description provided for @systemInfoError.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve system information. The terminal remains available. Summary commands require Linux/POSIX.'**
  String get systemInfoError;

  /// No description provided for @sshAuthError.
  ///
  /// In en, this message translates to:
  /// **'Authentication refused. Check the username and SSH credential.'**
  String get sshAuthError;

  /// No description provided for @sshHostKeyError.
  ///
  /// In en, this message translates to:
  /// **'The server identity was not accepted. The connection was stopped.'**
  String get sshHostKeyError;

  /// No description provided for @sshPrivateKeyError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the private key. Check the key and passphrase.'**
  String get sshPrivateKeyError;

  /// No description provided for @sshTimeout.
  ///
  /// In en, this message translates to:
  /// **'The connection timed out. Check your network and SSH port.'**
  String get sshTimeout;

  /// No description provided for @serverUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Server unreachable. Check the address, port and network/VPN.'**
  String get serverUnreachable;

  /// No description provided for @sshConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the SSH session. Check server access and try again.'**
  String get sshConnectionError;

  /// No description provided for @confirmSshServer.
  ///
  /// In en, this message translates to:
  /// **'Confirm SSH server'**
  String get confirmSshServer;

  /// No description provided for @serverKeyChanged.
  ///
  /// In en, this message translates to:
  /// **'The server key has changed'**
  String get serverKeyChanged;

  /// No description provided for @compareFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Compare this fingerprint with your server\'s fingerprint before trusting it.'**
  String get compareFingerprint;

  /// No description provided for @changedKeyWarning.
  ///
  /// In en, this message translates to:
  /// **'This may be a reinstallation or a connection to a different server. Only replace the key after verifying it independently.'**
  String get changedKeyWarning;

  /// No description provided for @savedKey.
  ///
  /// In en, this message translates to:
  /// **'Saved key:'**
  String get savedKey;

  /// No description provided for @verifyKeyCommand.
  ///
  /// In en, this message translates to:
  /// **'On the server: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub (adjust for the displayed key type).'**
  String get verifyKeyCommand;

  /// No description provided for @trustAndConnect.
  ///
  /// In en, this message translates to:
  /// **'Trust and connect'**
  String get trustAndConnect;

  /// No description provided for @replaceKey.
  ///
  /// In en, this message translates to:
  /// **'Replace key'**
  String get replaceKey;

  /// No description provided for @yourServer.
  ///
  /// In en, this message translates to:
  /// **'Your server'**
  String get yourServer;

  /// No description provided for @yourResources.
  ///
  /// In en, this message translates to:
  /// **'Your resources'**
  String get yourResources;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @receivedData.
  ///
  /// In en, this message translates to:
  /// **'Data received'**
  String get receivedData;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @addCredentials.
  ///
  /// In en, this message translates to:
  /// **'Add a credential to connect this instance. The saved address has been preserved.'**
  String get addCredentials;

  /// No description provided for @configureAccess.
  ///
  /// In en, this message translates to:
  /// **'Configure access'**
  String get configureAccess;

  /// No description provided for @connectInstance.
  ///
  /// In en, this message translates to:
  /// **'Connect to instance'**
  String get connectInstance;

  /// No description provided for @editAccess.
  ///
  /// In en, this message translates to:
  /// **'Edit access'**
  String get editAccess;

  /// No description provided for @openTerminal.
  ///
  /// In en, this message translates to:
  /// **'Open terminal'**
  String get openTerminal;

  /// No description provided for @connectForInfo.
  ///
  /// In en, this message translates to:
  /// **'Connect to check system information, uptime, memory and disk usage, or use the interactive terminal.'**
  String get connectForInfo;

  /// No description provided for @noCoolifyResources.
  ///
  /// In en, this message translates to:
  /// **'The API returned no resources for this token\'s team.'**
  String get noCoolifyResources;

  /// No description provided for @coolifyOverview.
  ///
  /// In en, this message translates to:
  /// **'Browse your team\'s applications, databases and services. Status comes directly from the Coolify API.'**
  String get coolifyOverview;

  /// No description provided for @connectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'SSH connections close when you switch instances or put the app in the background. Credentials stay encrypted on your device.'**
  String get connectionPrivacy;

  /// No description provided for @activeSshSession.
  ///
  /// In en, this message translates to:
  /// **'Active SSH session'**
  String get activeSshSession;

  /// No description provided for @terminalDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Terminal disconnected'**
  String get terminalDisconnected;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @openKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Open keyboard'**
  String get openKeyboard;

  /// No description provided for @loadWorkspacesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load saved workspaces.'**
  String get loadWorkspacesError;

  /// No description provided for @secureSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save to secure storage. Your fields have been preserved; try again.'**
  String get secureSaveError;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your servers.\nYour dock.'**
  String get welcomeTitle;

  /// No description provided for @firstServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Make room for\nyour first server.'**
  String get firstServerTitle;

  /// No description provided for @connectionTitle.
  ///
  /// In en, this message translates to:
  /// **'How shall we\nconnect?'**
  String get connectionTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Capidock. Create a workspace to bring your project instances together.'**
  String get welcomeBody;

  /// No description provided for @workspaceName.
  ///
  /// In en, this message translates to:
  /// **'Workspace name'**
  String get workspaceName;

  /// No description provided for @workspaceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Personal, Company or Project'**
  String get workspaceHint;

  /// No description provided for @workspaceNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your workspace a name.'**
  String get workspaceNameRequired;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @configureConnection.
  ///
  /// In en, this message translates to:
  /// **'Configure connection'**
  String get configureConnection;

  /// No description provided for @createAndOpen.
  ///
  /// In en, this message translates to:
  /// **'Create and open instance'**
  String get createAndOpen;

  /// No description provided for @localByChoice.
  ///
  /// In en, this message translates to:
  /// **'Local by choice. No account, no sync.'**
  String get localByChoice;

  /// No description provided for @manageWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Manage workspaces'**
  String get manageWorkspaces;

  /// No description provided for @newWorkspace.
  ///
  /// In en, this message translates to:
  /// **'New workspace'**
  String get newWorkspace;

  /// No description provided for @renameWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Rename workspace'**
  String get renameWorkspace;

  /// No description provided for @workspaceGrouping.
  ///
  /// In en, this message translates to:
  /// **'Group servers by project, client or environment.'**
  String get workspaceGrouping;

  /// No description provided for @workspaceEditorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Personal, Work, Homelab'**
  String get workspaceEditorHint;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get saveError;

  /// No description provided for @yourWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Your workspaces'**
  String get yourWorkspaces;

  /// No description provided for @workspaceContexts.
  ///
  /// In en, this message translates to:
  /// **'A space for every context.'**
  String get workspaceContexts;

  /// No description provided for @removeWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Remove workspace'**
  String get removeWorkspace;

  /// No description provided for @noWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'No workspaces yet.'**
  String get noWorkspaces;

  /// No description provided for @removeWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove workspace?'**
  String get removeWorkspaceTitle;

  /// No description provided for @removeWorkspaceError.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the workspace. Try again.'**
  String get removeWorkspaceError;

  /// No description provided for @moveInstanceError.
  ///
  /// In en, this message translates to:
  /// **'Could not move the instance. Try again.'**
  String get moveInstanceError;

  /// No description provided for @sshDescription.
  ///
  /// In en, this message translates to:
  /// **'Server access through a terminal'**
  String get sshDescription;

  /// No description provided for @coolifyDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get coolifyDescription;

  /// No description provided for @hostRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the instance address.'**
  String get hostRequired;

  /// No description provided for @hostNoSpaces.
  ///
  /// In en, this message translates to:
  /// **'The address cannot contain spaces.'**
  String get hostNoSpaces;

  /// No description provided for @httpsRequired.
  ///
  /// In en, this message translates to:
  /// **'Use an HTTPS URL, such as https://coolify.example.com.'**
  String get httpsRequired;

  /// No description provided for @hostOnly.
  ///
  /// In en, this message translates to:
  /// **'Use only the server hostname or IP address.'**
  String get hostOnly;

  /// No description provided for @privateKeyEmpty.
  ///
  /// In en, this message translates to:
  /// **'The private key is empty.'**
  String get privateKeyEmpty;

  /// No description provided for @privateKeyFormatError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the private key. Check its format and passphrase.'**
  String get privateKeyFormatError;

  /// No description provided for @instanceName.
  ///
  /// In en, this message translates to:
  /// **'Instance name'**
  String get instanceName;

  /// No description provided for @instanceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. production-europe'**
  String get instanceHint;

  /// No description provided for @instanceNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your instance a name.'**
  String get instanceNameRequired;

  /// No description provided for @hostname.
  ///
  /// In en, this message translates to:
  /// **'Hostname or IP'**
  String get hostname;

  /// No description provided for @coolifyUrl.
  ///
  /// In en, this message translates to:
  /// **'Coolify URL'**
  String get coolifyUrl;

  /// No description provided for @invalidUsername.
  ///
  /// In en, this message translates to:
  /// **'Invalid username.'**
  String get invalidUsername;

  /// No description provided for @authentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// No description provided for @privateKey.
  ///
  /// In en, this message translates to:
  /// **'Private key'**
  String get privateKey;

  /// No description provided for @sshPassword.
  ///
  /// In en, this message translates to:
  /// **'SSH password'**
  String get sshPassword;

  /// No description provided for @privateKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'PEM / OpenSSH private key'**
  String get privateKeyLabel;

  /// No description provided for @privateKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the full key, including the BEGIN and END lines.'**
  String get privateKeyHint;

  /// No description provided for @passphraseLabel.
  ///
  /// In en, this message translates to:
  /// **'Key passphrase (optional)'**
  String get passphraseLabel;

  /// No description provided for @coolifyToken.
  ///
  /// In en, this message translates to:
  /// **'Coolify API token'**
  String get coolifyToken;

  /// No description provided for @coolifyTokenHint.
  ///
  /// In en, this message translates to:
  /// **'In Coolify, enable the API and create a token under Keys & Tokens → API tokens. Read-only tokens can view resources. Editing needs write; deployment operations may need deploy or sensitive. Use the base URL without /api/v1.'**
  String get coolifyTokenHint;

  /// No description provided for @localCredentials.
  ///
  /// In en, this message translates to:
  /// **'Settings and credentials are encrypted on this device. Connect directly to your server without a Capidock account.'**
  String get localCredentials;

  /// No description provided for @showCredential.
  ///
  /// In en, this message translates to:
  /// **'Show credential'**
  String get showCredential;

  /// No description provided for @hideCredential.
  ///
  /// In en, this message translates to:
  /// **'Hide credential'**
  String get hideCredential;

  /// No description provided for @credentialRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the credential.'**
  String get credentialRequired;

  /// No description provided for @newInstanceTitle.
  ///
  /// In en, this message translates to:
  /// **'A new place in your dock.'**
  String get newInstanceTitle;

  /// No description provided for @saveConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Save configuration'**
  String get saveConfiguration;

  /// No description provided for @findInstance.
  ///
  /// In en, this message translates to:
  /// **'Find instance'**
  String get findInstance;

  /// No description provided for @emptyInstances.
  ///
  /// In en, this message translates to:
  /// **'This workspace has no instances yet.'**
  String get emptyInstances;

  /// No description provided for @noInstancesFound.
  ///
  /// In en, this message translates to:
  /// **'No instances found.'**
  String get noInstancesFound;

  /// No description provided for @newInstance.
  ///
  /// In en, this message translates to:
  /// **'New instance'**
  String get newInstance;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @workspaceStep.
  ///
  /// In en, this message translates to:
  /// **'WORKSPACE'**
  String get workspaceStep;

  /// No description provided for @instanceStep.
  ///
  /// In en, this message translates to:
  /// **'INSTANCE'**
  String get instanceStep;

  /// No description provided for @connectionStep.
  ///
  /// In en, this message translates to:
  /// **'CONNECTION'**
  String get connectionStep;

  /// No description provided for @previousData.
  ///
  /// In en, this message translates to:
  /// **' · previous data'**
  String get previousData;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your language. Try again.'**
  String get languageSaveError;

  /// No description provided for @emptyWorkspaceBody.
  ///
  /// In en, this message translates to:
  /// **'Add an SSH or Coolify instance to workspace “{name}”.'**
  String emptyWorkspaceBody(String name);

  /// No description provided for @removeInstanceBody.
  ///
  /// In en, this message translates to:
  /// **'The configuration for “{name}” will be removed from this device. The server will not be changed.'**
  String removeInstanceBody(String name);

  /// No description provided for @firstInstanceBody.
  ///
  /// In en, this message translates to:
  /// **'Each instance is a channel in “{name}”. Start with your first one.'**
  String firstInstanceBody(String name);

  /// No description provided for @configureInstanceBody.
  ///
  /// In en, this message translates to:
  /// **'Configure access to “{name}”. You can edit these details later.'**
  String configureInstanceBody(String name);

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'STEP {step} OF 3 · {name}'**
  String onboardingStep(int step, String name);

  /// No description provided for @workspaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Workspace {name}'**
  String workspaceLabel(String name);

  /// No description provided for @workspaceOptions.
  ///
  /// In en, this message translates to:
  /// **'Options for {name}'**
  String workspaceOptions(String name);

  /// No description provided for @removeWorkspaceBody.
  ///
  /// In en, this message translates to:
  /// **'“{name}” and its instances ({count}) will be removed from this device. The servers will not be changed.'**
  String removeWorkspaceBody(String name, int count);

  /// No description provided for @inWorkspace.
  ///
  /// In en, this message translates to:
  /// **'In workspace “{name}”.'**
  String inWorkspace(String name);

  /// No description provided for @lastRead.
  ///
  /// In en, this message translates to:
  /// **'Last read: {time}{suffix}'**
  String lastRead(String time, String suffix);

  /// No description provided for @httpError.
  ///
  /// In en, this message translates to:
  /// **'Coolify returned HTTP error {code}. Try again.'**
  String httpError(int code);

  /// No description provided for @instanceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 instances} one{1 instance} other{{count} instances}}'**
  String instanceCount(int count);

  /// No description provided for @workspaceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 local workspaces} one{1 local workspace} other{{count} local workspaces}}'**
  String workspaceCount(int count);

  /// No description provided for @resourceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 resources} one{1 resource} other{{count} resources}}'**
  String resourceCount(int count);

  /// No description provided for @coolifyOperations.
  ///
  /// In en, this message translates to:
  /// **'All operations'**
  String get coolifyOperations;

  /// No description provided for @coolifyApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get coolifyApplications;

  /// No description provided for @coolifyDatabases.
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get coolifyDatabases;

  /// No description provided for @coolifyServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get coolifyServices;

  /// No description provided for @coolifyProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get coolifyProjects;

  /// No description provided for @coolifyServers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get coolifyServers;

  /// No description provided for @coolifyPermissions.
  ///
  /// In en, this message translates to:
  /// **'Reads need read permission. Editing needs write; deploys and server operations may need deploy or sensitive permission. Your Coolify version determines which operations are available.'**
  String get coolifyPermissions;

  /// No description provided for @coolifySearch.
  ///
  /// In en, this message translates to:
  /// **'Search resources or operations'**
  String get coolifySearch;

  /// No description provided for @coolifyAll.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get coolifyAll;

  /// No description provided for @coolifyCatalogHelp.
  ///
  /// In en, this message translates to:
  /// **'Access the documented Coolify API operations. Field names and descriptions follow the official API. Newer operations may not exist on older installations.'**
  String get coolifyCatalogHelp;

  /// No description provided for @coolifyDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get coolifyDetails;

  /// No description provided for @coolifyEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get coolifyEnvironment;

  /// No description provided for @coolifyLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get coolifyLogs;

  /// No description provided for @coolifyBackups.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get coolifyBackups;

  /// No description provided for @coolifyStorages.
  ///
  /// In en, this message translates to:
  /// **'Volumes and files'**
  String get coolifyStorages;

  /// No description provided for @coolifyDeployments.
  ///
  /// In en, this message translates to:
  /// **'Deployments'**
  String get coolifyDeployments;

  /// No description provided for @coolifyCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get coolifyCreate;

  /// No description provided for @coolifyEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit configuration'**
  String get coolifyEdit;

  /// No description provided for @coolifyStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get coolifyStart;

  /// No description provided for @coolifyStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get coolifyStop;

  /// No description provided for @coolifyRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get coolifyRestart;

  /// No description provided for @coolifyDeploy.
  ///
  /// In en, this message translates to:
  /// **'Deploy'**
  String get coolifyDeploy;

  /// No description provided for @coolifyExecutions.
  ///
  /// In en, this message translates to:
  /// **'Execution history'**
  String get coolifyExecutions;

  /// No description provided for @coolifyScheduleBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup schedule'**
  String get coolifyScheduleBackup;

  /// No description provided for @coolifyRunBackup.
  ///
  /// In en, this message translates to:
  /// **'Run backup'**
  String get coolifyRunBackup;

  /// No description provided for @coolifyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results returned by the API.'**
  String get coolifyEmpty;

  /// No description provided for @coolifyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm operation'**
  String get coolifyConfirm;

  /// No description provided for @coolifyDestructive.
  ///
  /// In en, this message translates to:
  /// **'Confirm destructive operation'**
  String get coolifyDestructive;

  /// No description provided for @coolifyMutationWarning.
  ///
  /// In en, this message translates to:
  /// **'This changes the remote server. Stop, restart, deploy, restore and delete operations can interrupt services or remove data. Check the target before continuing.'**
  String get coolifyMutationWarning;

  /// No description provided for @coolifyTypeTarget.
  ///
  /// In en, this message translates to:
  /// **'Type {target} to confirm.'**
  String coolifyTypeTarget(String target);

  /// No description provided for @coolifyExecute.
  ///
  /// In en, this message translates to:
  /// **'Execute operation'**
  String get coolifyExecute;

  /// No description provided for @coolifyRead.
  ///
  /// In en, this message translates to:
  /// **'Read data'**
  String get coolifyRead;

  /// No description provided for @coolifyReveal.
  ///
  /// In en, this message translates to:
  /// **'Show values and logs (may contain secrets)'**
  String get coolifyReveal;

  /// No description provided for @coolifyChangedOnly.
  ///
  /// In en, this message translates to:
  /// **'Only edited fields are sent. Optional fields left untouched keep their server values. Empty edited strings clear a value. Arrays and objects use JSON.'**
  String get coolifyChangedOnly;

  /// No description provided for @coolifyInvalidField.
  ///
  /// In en, this message translates to:
  /// **'Check this value and its required type.'**
  String get coolifyInvalidField;

  /// No description provided for @coolifyInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Enter valid JSON.'**
  String get coolifyInvalidJson;

  /// No description provided for @coolifyRequiredPayload.
  ///
  /// In en, this message translates to:
  /// **'Fill in at least one field, all required fields, and choose a file for uploads.'**
  String get coolifyRequiredPayload;

  /// No description provided for @coolifyChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose backup file'**
  String get coolifyChooseFile;

  /// No description provided for @coolifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Request accepted by Coolify. Queued jobs may still be running; refresh their status.'**
  String get coolifySuccess;

  /// No description provided for @coolifyYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get coolifyYes;

  /// No description provided for @coolifyNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get coolifyNo;

  /// No description provided for @coolifyConflict.
  ///
  /// In en, this message translates to:
  /// **'Another operation is in progress or this change conflicts with the current state. Refresh before trying again.'**
  String get coolifyConflict;

  /// No description provided for @coolifyValidationError.
  ///
  /// In en, this message translates to:
  /// **'Coolify rejected the fields. Check required values, types and your installed API version.'**
  String get coolifyValidationError;

  /// No description provided for @coolifyUploadSize.
  ///
  /// In en, this message translates to:
  /// **'Choose a non-empty backup file no larger than 10 GiB.'**
  String get coolifyUploadSize;

  /// No description provided for @coolifyCancelled.
  ///
  /// In en, this message translates to:
  /// **'Connection closed. Refresh to check whether the remote operation completed.'**
  String get coolifyCancelled;

  /// No description provided for @coolifySshTerminal.
  ///
  /// In en, this message translates to:
  /// **'Coolify does not expose an interactive terminal through its public REST API. Choose a saved SSH connection to access the server.'**
  String get coolifySshTerminal;

  /// No description provided for @coolifyNoSsh.
  ///
  /// In en, this message translates to:
  /// **'Add an SSH instance for this server to a workspace first.'**
  String get coolifyNoSsh;

  /// No description provided for @coolifyResources.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get coolifyResources;

  /// No description provided for @coolifyEnvironments.
  ///
  /// In en, this message translates to:
  /// **'Environments'**
  String get coolifyEnvironments;

  /// No description provided for @coolifySharedVariables.
  ///
  /// In en, this message translates to:
  /// **'Shared variables'**
  String get coolifySharedVariables;

  /// No description provided for @coolifyName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get coolifyName;

  /// No description provided for @coolifyStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get coolifyStatus;

  /// No description provided for @coolifyDomains.
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get coolifyDomains;

  /// No description provided for @coolifyRepository.
  ///
  /// In en, this message translates to:
  /// **'Repository'**
  String get coolifyRepository;

  /// No description provided for @coolifyBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get coolifyBranch;

  /// No description provided for @coolifyBuildPack.
  ///
  /// In en, this message translates to:
  /// **'Build method'**
  String get coolifyBuildPack;

  /// No description provided for @coolifyAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get coolifyAddress;

  /// No description provided for @coolifyPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get coolifyPort;

  /// No description provided for @coolifyUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get coolifyUser;

  /// No description provided for @coolifyFrequency.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get coolifyFrequency;

  /// No description provided for @coolifyEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get coolifyEnabled;

  /// No description provided for @coolifyMountPath.
  ///
  /// In en, this message translates to:
  /// **'Mount path'**
  String get coolifyMountPath;

  /// No description provided for @coolifyHostPath.
  ///
  /// In en, this message translates to:
  /// **'Host path'**
  String get coolifyHostPath;

  /// No description provided for @coolifyCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get coolifyCreated;

  /// No description provided for @coolifyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get coolifyUpdated;

  /// No description provided for @coolifyValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get coolifyValue;

  /// No description provided for @coolifyPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get coolifyPreview;

  /// No description provided for @coolifySettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get coolifySettings;

  /// No description provided for @coolifyType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get coolifyType;

  /// No description provided for @coolifyRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get coolifyRunning;

  /// No description provided for @coolifyStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get coolifyStopped;

  /// No description provided for @coolifyConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get coolifyConfiguration;

  /// No description provided for @coolifyOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get coolifyOverviewTitle;

  /// No description provided for @coolifyResourceSearch.
  ///
  /// In en, this message translates to:
  /// **'Search resources'**
  String get coolifyResourceSearch;

  /// No description provided for @coolifyOtherSettings.
  ///
  /// In en, this message translates to:
  /// **'More settings'**
  String get coolifyOtherSettings;

  /// No description provided for @coolifyEnvironmentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No environments in this project yet.'**
  String get coolifyEnvironmentEmpty;

  /// No description provided for @coolifyLogsHidden.
  ///
  /// In en, this message translates to:
  /// **'Reveal logs to view their contents. They may contain secrets.'**
  String get coolifyLogsHidden;

  /// No description provided for @coolifyResourceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No resources in this environment yet.'**
  String get coolifyResourceEmpty;

  /// No description provided for @coolifyRestricted.
  ///
  /// In en, this message translates to:
  /// **'Value protected by token permissions.'**
  String get coolifyRestricted;

  /// No description provided for @coolifyVariables.
  ///
  /// In en, this message translates to:
  /// **'Environment variables'**
  String get coolifyVariables;

  /// No description provided for @coolifyNormalVariables.
  ///
  /// In en, this message translates to:
  /// **'Normal variables'**
  String get coolifyNormalVariables;

  /// No description provided for @coolifyPreviewVariables.
  ///
  /// In en, this message translates to:
  /// **'Preview variables'**
  String get coolifyPreviewVariables;

  /// No description provided for @coolifyShowValue.
  ///
  /// In en, this message translates to:
  /// **'Show value'**
  String get coolifyShowValue;

  /// No description provided for @coolifyHideValue.
  ///
  /// In en, this message translates to:
  /// **'Hide value'**
  String get coolifyHideValue;

  /// No description provided for @coolifyEditValue.
  ///
  /// In en, this message translates to:
  /// **'Edit value'**
  String get coolifyEditValue;

  /// No description provided for @coolifySaveValue.
  ///
  /// In en, this message translates to:
  /// **'Save value'**
  String get coolifySaveValue;

  /// No description provided for @deviceLocked.
  ///
  /// In en, this message translates to:
  /// **'Capidock locked'**
  String get deviceLocked;

  /// No description provided for @deviceUnlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Capidock credentials'**
  String get deviceUnlockReason;

  /// No description provided for @deviceUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get deviceUnlock;

  /// No description provided for @deviceLockHelp.
  ///
  /// In en, this message translates to:
  /// **'Set up a device PIN, password or biometrics to continue.'**
  String get deviceLockHelp;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @legalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {date}'**
  String legalUpdated(String date);

  /// No description provided for @legalLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this document. Please reopen it.'**
  String get legalLoadError;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get appSettings;

  /// No description provided for @terminalFontSize.
  ///
  /// In en, this message translates to:
  /// **'Terminal text size'**
  String get terminalFontSize;

  /// No description provided for @lockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get lockNow;

  /// No description provided for @trustedSshKeys.
  ///
  /// In en, this message translates to:
  /// **'Trusted SSH identities'**
  String get trustedSshKeys;

  /// No description provided for @trustedSshHelp.
  ///
  /// In en, this message translates to:
  /// **'Compare fingerprints with your server before trusting them. Forgetting an identity asks for confirmation on the next connection; an existing session stays connected.'**
  String get trustedSshHelp;

  /// No description provided for @localStorage.
  ///
  /// In en, this message translates to:
  /// **'Local storage'**
  String get localStorage;

  /// No description provided for @localCounts.
  ///
  /// In en, this message translates to:
  /// **'{workspaces} workspaces · {instances} instances'**
  String localCounts(int workspaces, int instances);

  /// No description provided for @eraseLocalData.
  ///
  /// In en, this message translates to:
  /// **'Erase saved server data'**
  String get eraseLocalData;

  /// No description provided for @eraseLocalWarning.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes all saved workspaces, credentials and SSH identities from this device. Your servers are not changed. Device authentication is required.'**
  String get eraseLocalWarning;

  /// No description provided for @eraseAuthReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to erase saved Capidock server data'**
  String get eraseAuthReason;

  /// No description provided for @localEraseFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify that all local server data was erased. Unlock and check your saved data before trying again.'**
  String get localEraseFailed;

  /// No description provided for @noTrustedKeys.
  ///
  /// In en, this message translates to:
  /// **'No trusted identities'**
  String get noTrustedKeys;

  /// No description provided for @forgetSshWarning.
  ///
  /// In en, this message translates to:
  /// **'Forget this SSH identity? You will need to verify its fingerprint on the next connection.'**
  String get forgetSshWarning;

  /// No description provided for @tokenAccess.
  ///
  /// In en, this message translates to:
  /// **'Token access'**
  String get tokenAccess;

  /// No description provided for @tokenAccessHelp.
  ///
  /// In en, this message translates to:
  /// **'These are observations of requests in this session, not the token’s exact permissions. The public API does not report whether a token is readonly or root. Unchecked permissions remain unknown. Only explicit permission errors disable actions; generic access failures can also come from IP rules or proxies. The server validates every request.'**
  String get tokenAccessHelp;

  /// No description provided for @accessUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get accessUnknown;

  /// No description provided for @accessObserved.
  ///
  /// In en, this message translates to:
  /// **'Observed'**
  String get accessObserved;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get accessDenied;

  /// No description provided for @coolifyPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'The server reported a missing permission for this action. Edit the token and reconnect to check again.'**
  String get coolifyPermissionDenied;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @connectionVerified.
  ///
  /// In en, this message translates to:
  /// **'Connection verified'**
  String get connectionVerified;

  /// No description provided for @connectionTestHelp.
  ///
  /// In en, this message translates to:
  /// **'Tests authentication without saving your draft. SSH does not open a terminal or run commands, and trust confirmed here is temporary. Coolify uses a read-only API request; no write or deploy probes are sent.'**
  String get connectionTestHelp;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching resources.'**
  String get noSearchResults;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
    case 'es':
      {
        switch (locale.countryCode) {
          case 'ES':
            return AppLocalizationsEsEs();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
