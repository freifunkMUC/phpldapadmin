#!/bin/sh
set -eu

busybox crond -f -l 2 -L /dev/stderr &

exec "$@"
