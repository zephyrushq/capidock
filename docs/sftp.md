# SFTP in SSH instances

The Files tab uses the existing authenticated SSH transport, host-key verification
and algorithm policy. No extra instance, FTP connection, shell commands or root
credentials are required. A file-only connection does not open an interactive
shell; selecting Terminal afterwards opens one explicitly if the server allows it.
The server must enable its SFTP subsystem and the SSH user must have filesystem
permissions. There is no automatic sudo.

Features: home/parent/folder navigation, directories first, name search, 50-entry
pages, folder creation, rename, file upload/download, UTF-8 text editing and
confirmed deletion. Directory deletion is non-recursive and accepts empty folders
only. Symbolic links are not followed for file reads/edits; deleting a link removes
the link itself. Names cannot contain slashes, traversal entries or control bytes.

Transfers are bounded to 16 MiB; the text editor to 256 KiB; listings to 5,000
entries. Payloads stay in memory until explicitly saved through Android SAF. No
plaintext app cache or broad storage permission is used. The chosen provider may
sync downloads; exported plaintext documents are outside the encrypted app vault.
Mutable buffers are cleared on completion where possible; Dart strings and runtime
copies cannot be guaranteed to be zeroised.

SSH closes when the document picker backgrounds the app. The existing protected
picker flow conceals the app and requests fresh device authentication on return.
Uploads then reconnect through the normal SSH identity check, before confirmation
and writing. Downloads need no remote connection after retrieval. Ordinary
backgrounding, leaving Files or changing the instance closes the SFTP subsystem.
Disconnect cancels transfers, including remote changes already in progress.

New uploads use exclusive creation to avoid truncating an existing destination.
Replacing/editing files requires explicit confirmation and stages a complete
remote temporary file before rename. The editor compares the original content and
checks attributes again before replacement. Ownership/permission preservation can
be refused by the server. Servers without replacement-rename support may reject
the replacement; the existing destination is not deleted as a workaround. These
checks are not a distributed file lock: external writers may race the final rename.
Interrupted operations may leave a partial file or `.capidock-*.part` file on the
server; completed writes are cleaned up on ordinary failures when the transport
is still available. Rename checks for an existing destination, but concurrent
server-side changes remain possible.

Validation includes a loopback AsyncSSH SFTP server rooted in a temporary test
folder. It tests read/write, edit conflict detection, rename, empty/non-empty folder
deletion, symlink handling, limits and disconnect. Widget tests cover five locales
at 320 x 640. Real Android document providers and the user's production SSH/SFTP
servers still need device validation.
