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
  echo "No versions found"
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
  "version": {"ref": "1f76ad043df336c9379a38fd8152d96d6ec0"}
}
EOF
)

echo $LATEST_VERSION
if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" == "[]" ];
then
  echo "No versions found 2"
  exit 1
fi

RESULTS=$(echo ${LATEST_VERSION} | jq ". | length")
if [[ $RESULTS -lt 1  ]]; then
  echo "Not all results returned"
  exit 1
fi
