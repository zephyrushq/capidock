#!/usr/bin/env bash
# Real Docker operations confined to owned disposable fixtures and a loopback SSH endpoint.
set -euo pipefail
smoke_dir=$(mktemp -d)
server_pid=''
container_id=''
create_name=''
volume_name=''
cleanup() {
  if [ -n "$server_pid" ]; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  if [ -n "$create_name" ] && [ "$(docker inspect --format '{{index .Config.Labels "capidock.smoke.parent"}}' "$create_name" 2>/dev/null || true)" = "$container_id" ]; then
    docker rm -f "$create_name" >/dev/null
  fi
  if [ -n "$volume_name" ] && [ "$(docker volume inspect --format '{{index .Labels "capidock.smoke.parent"}}' "$volume_name" 2>/dev/null || true)" = "$container_id" ]; then
    docker volume rm "$volume_name" >/dev/null
  fi
  if [ -n "$container_id" ]; then docker rm -f "$container_id" >/dev/null; fi
  rm -rf -- "$smoke_dir"
}
trap cleanup EXIT
container_id=$(docker run -d --name "capidock-docker-smoke-$$" \
  --network none --read-only --cap-drop ALL --security-opt no-new-privileges \
  --memory 64m --pids-limit 64 --stop-timeout 1 alpine:3.21 \
  sh -c 'printf "capidock-docker-stdout\n"; printf "capidock-docker-stderr\n" >&2; exec sleep 3600')
create_name="capidock-created-${container_id:0:12}"
volume_name="$create_name-data"
docker volume create --label "capidock.smoke.parent=$container_id" "$volume_name" >/dev/null
"${CAPIDOCK_TEST_PYTHON:-python3}" tool/testing/ssh_smoke_server.py \
  --config "$smoke_dir/connection.json" --docker-container "$container_id" --docker-create-name "$create_name" &
server_pid=$!
for attempt in $(seq 1 100); do
  if [ -s "$smoke_dir/connection.json" ]; then break; fi
  kill -0 "$server_pid"
  sleep 0.1
done
test -s "$smoke_dir/connection.json"
"${CAPIDOCK_TEST_FLUTTER:-flutter}" test test/docker_transport_test.dart \
  --dart-define="DOCKER_SSH_TEST_CONFIG=$smoke_dir/connection.json" --reporter expanded
