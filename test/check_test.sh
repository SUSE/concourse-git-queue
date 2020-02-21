#!/bin/bash
LATEST_VERSION=$(docker run --rm -i $IMAGE_NAME sh /opt/resource/check <<EOF
{
  "source": {
    "bucket": "kubecf-ci",
    "bucket_subfolder": "build-queue",
    "filter": "json",
    "aws_access_key_id": "$AWS_KEY_ID",
    "aws_secret_access_key": "$AWS_SECRET_ACCESS_KEY"
  }
}
EOF
)

echo $LATEST_VERSION
if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" == "[]" ];
then
  echo "test failed"
  exit 1
fi

LATEST_VERSION=$(docker run --rm -i $IMAGE_NAME sh /opt/resource/check <<EOF
{
  "source": {
    "bucket": "kubecf-ci",
    "bucket_subfolder": "build-queue",
    "filter": "json",
    "aws_access_key_id": "$AWS_KEY_ID",
    "aws_secret_access_key": "$AWS_SECRET_ACCESS_KEY"
  },
  "version": {"ref": "afb0afd27ed7377c0bff4620e3a7f19d8d25eecc"}
}
EOF
)

echo $LATEST_VERSIONS
if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" == "[]" ];
then
  echo "test failed"
  exit 1
fi

RESULTS=$(echo ${LATEST_VERSION} | jq ". | length")
if [[ $RESULTS -lt 1  ]]; then
  echo "Not all results returned"
  exit 1
fi
