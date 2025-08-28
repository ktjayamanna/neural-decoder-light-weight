#!/bin/bash
# Script to precompose T.fst and L.fst into TL.fst for lazy composition with G.fst

set -e

usage() {
    echo "Usage: $0 <model_directory>"
    echo "Creates TL.fst by precomposing T.fst and L.fst"
    exit 1
}

if [ $# -ne 1 ]; then
    usage
fi

MODEL_DIR="$1"

if [ ! -d "$MODEL_DIR" ]; then
    echo "Error: Model directory '$MODEL_DIR' does not exist"
    exit 1
fi

T_FST="$MODEL_DIR/T.fst"
L_FST="$MODEL_DIR/L.fst"
G_FST="$MODEL_DIR/G.fst"
TL_FST="$MODEL_DIR/TL.fst"

if [ ! -f "$T_FST" ]; then
    echo "Error: T.fst not found in $MODEL_DIR"
    exit 1
fi

if [ ! -f "$L_FST" ]; then
    echo "Error: L.fst not found in $MODEL_DIR"
    exit 1
fi

if [ ! -f "$G_FST" ]; then
    echo "Error: G.fst not found in $MODEL_DIR"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

LOCAL_INSTALL_DIR="$WORKSPACE_DIR/local"
if [ -d "$LOCAL_INSTALL_DIR/bin" ]; then
    export PATH="$LOCAL_INSTALL_DIR/bin:$PATH"
    export LD_LIBRARY_PATH="$LOCAL_INSTALL_DIR/lib:$LD_LIBRARY_PATH"
fi

if ! command -v fstcompose >/dev/null 2>&1; then
    echo "Error: OpenFST tools not found"
    exit 1
fi

if [ -f "$TL_FST" ]; then
    echo "Warning: TL.fst already exists in $MODEL_DIR"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo "Creating TL.fst..."

TEMP_COMPOSED=$(mktemp)
TEMP_DETERMINIZED=$(mktemp)

cleanup() {
    rm -f "$TEMP_COMPOSED" "$TEMP_DETERMINIZED"
}
trap cleanup EXIT

if ! fstcompose "$T_FST" "$L_FST" "$TEMP_COMPOSED"; then
    echo "Error: Failed to compose T.fst and L.fst"
    exit 1
fi

if ! fstdeterminize "$TEMP_COMPOSED" "$TEMP_DETERMINIZED"; then
    echo "Error: Failed to determinize composed FST"
    exit 1
fi

if ! fstminimize "$TEMP_DETERMINIZED" "$TL_FST"; then
    echo "Error: Failed to minimize determinized FST"
    exit 1
fi

echo "TL.fst created successfully at $TL_FST"
