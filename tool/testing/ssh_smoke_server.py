"""Temporary loopback SSH server for transport tests; requires AsyncSSH.

Creates fresh credentials in a private directory. Never exposes a shell: the
only accepted operations are a read-only probe, a synthetic container listing,
a fixed container PTY command and a printf challenge. With --docker-container,
additional allowlisted commands access only owned disposable real fixtures.
Run with --config /tmp/<private-directory>/connection.json, then use that path
as SSH_TEST_CONFIG when running test/ssh_transport_test.dart.
"""
import argparse
import asyncio
import json
import os
import pty
import re
import shlex
import fcntl
import struct
import termios
import tty
from pathlib import Path
import secrets

import asyncssh

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--config', type=Path, required=True)
parser.add_argument('--docker-container', help='Optional isolated real Docker container ID')
parser.add_argument('--docker-create-name', help='Optional disposable creation fixture name')
args = parser.parse_args()
if args.docker_container and not re.fullmatch(r'[a-f0-9]{64}', args.docker_container):
    parser.error('Expected an immutable Docker container ID')
if args.docker_create_name and not re.fullmatch(r'capidock-created-[a-f0-9]{12}', args.docker_create_name):
    parser.error('Invalid Docker creation fixture name')
docker_targets = {args.docker_container} if args.docker_container else set()
args.config.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
password = secrets.token_urlsafe(32)
passphrase = secrets.token_urlsafe(32)
client_key = asyncssh.generate_private_key('ssh-ed25519')
remote_root = args.config.parent / 'sftp-root'
remote_root.mkdir(mode=0o700, exist_ok=True)
(remote_root / 'hello.txt').write_text('SFTP fixture only\n')
(remote_root / 'folder').mkdir(exist_ok=True)
(remote_root / 'link').symlink_to('hello.txt')
activity_path = Path(str(args.config) + '.activity')
channel_requests = 0
activity_path.write_text('0')


class Server(asyncssh.SSHServer):
    def begin_auth(self, username):
        return True

    def password_auth_supported(self):
        return True

    def validate_password(self, username, candidate):
        return username in ('capidock-test', 'capidock-test-auth-only', 'capidock-test-overflow', 'capidock-test-cancel') and candidate == password

    def public_key_auth_supported(self):
        return True

    def validate_public_key(self, username, key):
        return username == 'capidock-test' and key == client_key.convert_to_public()


async def real_docker(process):
    """Allowlisted Docker operations confined to owned disposable fixtures."""
    target = args.docker_container
    targets = docker_targets
    command = process.command or ''
    terminal_prefix = f'docker exec -it {target} '
    if command in (terminal_prefix + 'sh', terminal_prefix + 'bash'):
        if process.term_type != 'xterm-256color':
            process.exit(1)
            return True
        master, slave = pty.openpty()
        tty.setraw(slave)
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 24, 80, 0, 0))
        child = await asyncio.create_subprocess_exec('docker', 'exec', '-it', target,
            command.rsplit(' ', 1)[1], stdin=slave, stdout=slave, stderr=slave)
        os.close(slave)
        async def output():
            while True:
                try:
                    chunk = await asyncio.to_thread(os.read, master, 4096)
                except OSError:
                    return
                if not chunk:
                    return
                process.stdout.write(chunk.decode(errors='replace'))
        async def input_data():
            while chunk := await process.stdin.read(4096):
                os.write(master, chunk.encode())
        tasks = [asyncio.create_task(output()), asyncio.create_task(input_data())]
        try:
            code = await child.wait()
            await tasks[0]
            process.exit(code)
        finally:
            for task in tasks:
                task.cancel()
            os.close(master)
            if child.returncode is None:
                child.terminate()
                await child.wait()
        return True
    if not command.startswith('LC_ALL=C docker '):
        return False
    argv = shlex.split(command)[1:]
    merge_logs = argv[-1:] == ['2>&1']
    if merge_logs:
        argv = argv[:-1]
    valid = False
    creation = False
    payload = None
    if argv[:2] == ['docker', 'create'] and args.docker_create_name:
        # Only one inert Alpine fixture, with owned mounts and loopback ports.
        options = argv[2:-1]
        if len(options) % 2 or argv[-1] != 'alpine:3.21':
            process.exit(1)
            return True
        pairs = list(zip(options[::2], options[1::2]))
        expected = [('--name', args.docker_create_name), ('--env-file', '/dev/stdin')]
        valid = pairs[:2] == expected and all(
            (key == '--publish' and value == '127.0.0.1:18080:80/tcp') or
            (key == '--mount' and value == f'type=volume,source={args.docker_create_name}-data,target=/data')
            for key, value in pairs[2:])
        if valid:
            creation = True
            payload = (await process.stdin.read()).encode()
            if len(payload) > 65536:
                process.exit(1)
                return True
            argv[2:2] = ['--label', f'capidock.smoke.parent={target}']
    elif argv[:5] == ['docker', 'ps', '-a', '--no-trunc', '--format'] and len(argv) == 6:
        # Never enumerate unrelated containers on the developer's Docker host.
        argv[2:2] = [part for identity in targets for part in ('--filter', f'id={identity}')]
        valid = True
    elif argv[:5] == ['docker', 'inspect', '--type', 'container', '--format'] and len(argv) == 7:
        valid = argv[-1] in targets
    elif argv[:5] == ['docker', 'stats', '--no-stream', '--no-trunc', '--format'] and len(argv) == 7:
        valid = argv[-1] in targets
    elif argv[:5] == ['docker', 'logs', '--tail', '200', '--timestamps'] and len(argv) == 6:
        valid = argv[-1] in targets and merge_logs
    elif len(argv) == 3 and argv[0] == 'docker' and argv[1] in ('start', 'stop', 'restart'):
        valid = argv[-1] in targets
    if not valid:
        process.stderr.write('Outside Docker smoke-test scope\n')
        process.exit(1)
        return True
    child = await asyncio.create_subprocess_exec(*argv, stdin=asyncio.subprocess.PIPE if creation else None, stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.STDOUT if merge_logs else asyncio.subprocess.PIPE)
    stdout, stderr = await child.communicate(payload)
    if creation and child.returncode == 0:
        identity = stdout.decode().strip()
        if re.fullmatch(r'[a-f0-9]{64}', identity):
            targets.add(identity)
    process.stdout.write(stdout.decode(errors='replace'))
    if stderr:
        process.stderr.write(stderr.decode(errors='replace'))
    process.exit(child.returncode)
    return True


async def handle(process):
    global channel_requests
    if process.get_extra_info('username') == 'capidock-test-auth-only':
        channel_requests += 1
        activity_path.write_text(str(channel_requests))
    try:
        fixture_command = 'LC_ALL=C docker logs --tail 200 --timestamps ' + 'a' * 64 + ' 2>&1'
        if process.command == fixture_command:
            if process.get_extra_info('username') == 'capidock-test-overflow':
                process.stdout.write('x' * 600000)
                process.exit(0)
                return
            if process.get_extra_info('username') == 'capidock-test-cancel':
                await process.stdin.read()
                return
        if args.docker_container and await real_docker(process):
            return
        if process.command == "docker ps --no-trunc --format '{{json .}}'":
            process.stdout.write(json.dumps(dict(ID='a' * 64, Names='smoke-container',
                Labels='coolify.applicationUuid=smoke-resource', Image='fixture')) + '\n')
            process.exit(0)
            return
        container_command = 'docker exec -it ' + 'a' * 64 + ' sh'
        if process.command == container_command and process.term_type != 'xterm-256color':
            process.stderr.write('Interactive container requires PTY\n')
            process.exit(1)
            return
        if process.command and process.command != container_command:
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
        line_editor=False,
        server_host_keys=[asyncssh.generate_private_key('ssh-ed25519')],
        process_factory=handle,
        sftp_factory=lambda channel: asyncssh.SFTPServer(channel, chroot=str(remote_root)))
    config = dict(dockerId=args.docker_container, dockerCreateName=args.docker_create_name, port=server.get_port(), username='capidock-test', password=password,
        privateKey=client_key.export_private_key('openssh', passphrase=passphrase).decode(),
        passphrase=passphrase)
    fd = os.open(args.config, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, 'w') as stream:
        json.dump(config, stream)
    print(f'SSH smoke server listening on loopback port {server.get_port()}', flush=True)
    async with server:
        await server.serve_forever()


asyncio.run(main())
