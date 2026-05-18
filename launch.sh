#!/usr/bin/env bash
# Launch helper.
#
# Usage:
#   ./launch.sh tiny                                # CPU smoke test
#   ./launch.sh small                               # single GPU
#   ./launch.sh medium 8                            # 8-GPU DDP
#   ./launch.sh small --resume-from ckpt/ckpt-1000  # resume
set -euo pipefail

CFG="${1:-tiny}"
shift || true

CONFIG_PATH="configs/${CFG}.yaml"
if [ ! -f "$CONFIG_PATH" ]; then
    echo "config not found: $CONFIG_PATH" >&2
    exit 1
fi

# If the next arg is a number, treat it as nproc-per-node.
NPROC=""
if [[ "${1-}" =~ ^[0-9]+$ ]]; then
    NPROC="$1"
    shift
fi

if [ -n "$NPROC" ]; then
    echo "[launch] DDP: ${NPROC} processes, config=${CONFIG_PATH}"
    exec torchrun --standalone --nproc-per-node="${NPROC}" \
        -m open_mythos.training.trainer --config "${CONFIG_PATH}" "$@"
else
    echo "[launch] single process, config=${CONFIG_PATH}"
    exec python -m open_mythos.training.trainer --config "${CONFIG_PATH}" "$@"
fi
