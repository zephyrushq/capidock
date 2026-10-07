#!/usr/bin/env bash
# Run only against a temporary, loopback-only SSH endpoint.
set -euo pipefail
smoke_dir=$(mktemp -d)
server_pid=''
cleanup() {
  if [ -n "$server_pid" ]; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  rm -rf -- "$smoke_dir"
}
trap cleanup EXIT
"${CAPIDOCK_TEST_PYTHON:-python3}" tool/testing/ssh_smoke_server.py --config "$smoke_dir/connection.json" &
server_pid=$!
for attempt in $(seq 1 100); do
  if [ -s "$smoke_dir/connection.json" ]; then break; fi
  kill -0 "$server_pid"
  sleep 0.1
done
test -s "$smoke_dir/connection.json"
"${CAPIDOCK_TEST_FLUTTER:-flutter}" test test/ssh_transport_test.dart \
  --dart-define="SSH_TEST_CONFIG=$smoke_dir/connection.json" --reporter expanded
