"""Temporary loopback SSH server for transport tests; requires AsyncSSH.

Creates fresh credentials in a private directory. Never exposes a shell: the
only accepted operations are the fixed read-only probe and a printf challenge.
Run with --config /tmp/<private-directory>/connection.json, then use that path
as SSH_TEST_CONFIG when running test/ssh_transport_test.dart.
"""
import argparse
import asyncio
import json
import os
from pathlib import Path
import secrets

import asyncssh

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--config', type=Path, required=True)
args = parser.parse_args()
args.config.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
password = secrets.token_urlsafe(32)
passphrase = secrets.token_urlsafe(32)
client_key = asyncssh.generate_private_key('ssh-ed25519')
activity_path = Path(str(args.config) + '.activity')
channel_requests = 0
activity_path.write_text('0')


class Server(asyncssh.SSHServer):
    def begin_auth(self, username):
        return True

    def password_auth_supported(self):
        return True

    def validate_password(self, username, candidate):
        return username in ('capidock-test', 'capidock-test-auth-only') and candidate == password

    def public_key_auth_supported(self):
        return True

    def validate_public_key(self, username, key):
        return username == 'capidock-test' and key == client_key.convert_to_public()


async def handle(process):
    global channel_requests
    if process.get_extra_info('username') == 'capidock-test-auth-only':
        channel_requests += 1
        activity_path.write_text(str(channel_requests))
    try:
        if process.command:
            # Actual system information without accepting arbitrary shell input.
            for title, command in [
                ('SYSTEM', ['uname', '-snr']), ('UPTIME', ['uptime']),
                ('MEMORY (MiB)', ['free', '-m']), ('DISK /', ['df', '-h', '/']),
            ]:
                process.stdout.write(title + '\n')
                child = await asyncio.create_subprocess_exec(*command, stdout=asyncio.subprocess.PIPE)
                output, _ = await child.communicate()
                process.stdout.write(output.decode())
            process.exit(0)
        else:
            process.stdout.write('SSH transport test ready\r\n')
            async for line in process.stdin:
                if line.strip() == 'printf capidock-transport-ok':
                    child = await asyncio.create_subprocess_exec('printf', 'capidock-transport-ok', stdout=asyncio.subprocess.PIPE)
                    output, _ = await child.communicate()
                    process.stdout.write(output.decode() + '\r\n')
                elif line.strip() == 'exit':
                    process.exit(0)
                    return
                else:
                    process.stderr.write('Command outside smoke-test scope\r\n')
    except (asyncssh.BreakReceived, asyncssh.TerminalSizeChanged):
        process.exit(0)


async def main():
    server = await asyncssh.create_server(Server, '127.0.0.1', 0,
        server_host_keys=[asyncssh.generate_private_key('ssh-ed25519')],
        process_factory=handle)
    config = dict(port=server.get_port(), username='capidock-test', password=password,
        privateKey=client_key.export_private_key('openssh', passphrase=passphrase).decode(),
        passphrase=passphrase)
    fd = os.open(args.config, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, 'w') as stream:
        json.dump(config, stream)
    print(f'SSH smoke server listening on loopback port {server.get_port()}', flush=True)
    async with server:
        await server.serve_forever()


asyncio.run(main())
