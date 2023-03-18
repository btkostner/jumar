#!/bin/sh

set -eu

HOME="${HOME:-/root}"

echo "Saving certificates to file system ..."

mkdir -p "$HOME/.cockroach-certs"

echo "${DB_CA_CRT}" | base64 --decode --ignore-garbage > "$HOME/.cockroach-certs/ca.crt"
echo "${DB_NODE_CRT}" | base64 --decode --ignore-garbage > "$HOME/.cockroach-certs/node.crt"
echo "${DB_NODE_KEY}" | base64 --decode --ignore-garbage > "$HOME/.cockroach-certs/node.key"

chmod 0600 "$HOME/.cockroach-certs/node.key"

unset DB_CA_CRT
unset DB_NODE_CRT
unset DB_NODE_KEY

echo "Starting cockroach $FLY_APP_NAME cluster..."

exec /cockroach/cockroach start \
  --logtostderr \
  --locality="region=$FLY_REGION" \
  --cluster-name="$FLY_APP_NAME" \
  --join="$FLY_APP_NAME.internal" \
  --advertise-addr="$(hostname -s).vm.$FLY_APP_NAME.internal" \
  --http-addr 0.0.0.0
