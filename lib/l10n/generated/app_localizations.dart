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
  /// **'Applications and deployments'**
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
  /// **'In Coolify, enable the API and create a read-only token under Keys & Tokens → API tokens. Use the base URL without /api/v1.'**
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
