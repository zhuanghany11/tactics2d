#!/bin/bash


PROTOC_ZIP="protoc-27.3-linux-x86_64.zip"
PROTOC_URL="https://github.com/protocolbuffers/protobuf/releases/download/v27.3/${PROTOC_ZIP}"
WORK_DIR=$(pwd)

# 下载并解压 Protobuf 编译器
echo "Downloading Protobuf compiler..."
wget -q ${PROTOC_URL} -O ${PROTOC_ZIP}
unzip -q ${PROTOC_ZIP} -d ${WORK_DIR}
chmod +x ${WORK_DIR}/bin/protoc


PROTO_PATHS=("${WORK_DIR}/pb2" "${WORK_DIR}/pb3")


echo "Compiling .proto files in the specified directories..."
for path in "${PROTO_PATHS[@]}"; do
    if [ -d "${path}" ]; then
        echo "Compiling .proto files in ${path}..."
        ${WORK_DIR}/bin/protoc -I=${path} --python_out=${path} ${path}/*.proto
    else
        echo "Directory ${path} does not exist, skipping..."
    fi
done


if [ $? -ne 0 ]; then
    echo "Proto compilation failed."
    exit 1
fi


echo "Running script to fix import references in all compiled .py files..."
for path in "${PROTO_PATHS[@]}"; do
    find ${path} -name '*.py' | while read -r file; do

        if [[ $file == *"pb2"* ]]; then
            PB_VERSION="pb2"
        elif [[ $file == *"pb3"* ]]; then
            PB_VERSION="pb3"
        else
            echo "Unknown pb version for file ${file}, skipping..."
            continue
        fi

        python3 ${WORK_DIR}/auto_fix_refs.py "${file}" "${path}" "${PB_VERSION}"
    done
done


echo "All tasks completed successfully."

echo "Cleaning up downloaded and extracted files..."

rm -f ${WORK_DIR}/${PROTOC_ZIP}

rm -rf ${WORK_DIR}/include ${WORK_DIR}/bin ${WORK_DIR}/readme.txt

echo "Cleanup completed."