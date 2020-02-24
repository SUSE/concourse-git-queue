#!/bin/bash
set -xe

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR=`mktemp -d -p "$DIR"`
if [[ ! "$WORK_DIR" || ! -d "$WORK_DIR" ]]; then
  echo "Could not create temp dir"
  exit 1
fi
function cleanup {      
  echo "I want to delete ${WORK_DIR}. It was populated with data from docker as root so I will need your sudo permissions."
  sudo rm -rf "$WORK_DIR"
  echo "Deleted temp working directory $WORK_DIR"
}
trap cleanup EXIT


docker run --rm -i -v $WORK_DIR:/output $IMAGE_NAME sh /opt/resource/in /output <<EOF
{
  "version": { "ref": "afb0afd27ed7377c0bff4620e3a7f19d8d25eecc" },
  "source": {
    "bucket": "kubecf-ci",
    "bucket_subfolder": "build-queue",
    "aws_access_key_id": "$AWS_KEY_ID",
    "aws_secret_access_key": "$AWS_SECRET_ACCESS_KEY"
  }
}
EOF

if [ ! -d "${WORK_DIR}/src" ]; then
  echo "repository wasn't checked out"
  exit 1
fi
