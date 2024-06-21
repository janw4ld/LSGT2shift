#!/usr/bin/env bash
set -xeuo pipefail

CC=${CC:-clang}
CFLAGS=${CFLAGS:-'-Wall -Werror -pedantic -flto -O3 -march=native'}

$CC $CFLAGS -o lsgt2shift lsgt2shift.c
