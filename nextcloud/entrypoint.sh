#!/bin/sh
set -eu

busybox crond -f -l 0 -L /dev/stdout &

exec "$@"
