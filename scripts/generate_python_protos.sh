#!/bin/bash

set -e

PROTOS_DIR=$1
PYTHON_PROTOS_OUTPUT_DIR=$2

if [ -d "$PYTHON_PROTOS_OUTPUT_DIR" ]; then
    rm -rf "$PYTHON_PROTOS_OUTPUT_DIR"
fi

mkdir -p "$PYTHON_PROTOS_OUTPUT_DIR"

# if ! find "$PROTOS_DIR" -name "*.proto" -exec python -m grpc_tools.protoc \
#     -I"$PROTOS_DIR" \
#     --python_out="$PYTHON_PROTOS_OUTPUT_DIR" \
#     --pyi_out="$PYTHON_PROTOS_OUTPUT_DIR" \
#     --grpc_python_out="$PYTHON_PROTOS_OUTPUT_DIR" {} \; ; then
#     echo "Failed to generate Python protos"
#     exit 1
# fi

# generate python protos for each proto file and if it fails, exit
for proto_file in $(find "$PROTOS_DIR" -name "*.proto"); do
    if ! python -m grpc_tools.protoc \
        -I"$PROTOS_DIR" \
        --python_out="$PYTHON_PROTOS_OUTPUT_DIR" \
        --pyi_out="$PYTHON_PROTOS_OUTPUT_DIR" \
        --grpc_python_out="$PYTHON_PROTOS_OUTPUT_DIR" \
        "$proto_file"; then
        echo "Failed to generate Python protos"
        exit 1
    fi
done

# print all proto directories
echo "Proto directories:"
for proto_dir in "${proto_dirs[@]}"; do
    echo "$proto_dir"
done

# generate python protos for each proto directory and if it fails, exit
for proto_dir in "${proto_dirs[@]}"; do
    if ! python -m grpc_tools.protoc \
        -I"$proto_dir" \
        --python_out="$PYTHON_PROTOS_OUTPUT_DIR" \
        --pyi_out="$PYTHON_PROTOS_OUTPUT_DIR" \
        --grpc_python_out="$PYTHON_PROTOS_OUTPUT_DIR" \
        "$proto_dir"/*.proto; then
        echo "Failed to generate Python protos"
        exit 1
    fi
done

bash ./scripts/add_init_files.sh "$PYTHON_PROTOS_OUTPUT_DIR"
