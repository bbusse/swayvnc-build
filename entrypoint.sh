#!/bin/sh
set -o errexit

case "$1" in
    sh|bash)
        set -- "$@"
    ;;
    *)
        while [ 1 ]; do sleep 1; done
    ;;
esac

exec "$@"
