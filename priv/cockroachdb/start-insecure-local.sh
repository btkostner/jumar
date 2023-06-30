#!/bin/sh

set -eu

echo "Starting cockroach in insecure local mode..."

exec /cockroach/cockroach start-single-node \
  --logtostderr \
  --insecure
