#!/bin/bash

DIR=$1
DEST=$2

aws s3 sync "$DIR" "s3://$DEST" --delete

FILELIST=$(find "$DIR" -name "index.xml")

if [ -z "$FILELIST" ]; then
  # No files to upload
  exit 0;
fi

while read -r line; do
  LOCALDIR=$(dirname "$line")
  SYNCDIR=${LOCALDIR#$"$DIR"}
  aws s3 cp --content-type xml "$line" "s3://$DEST$SYNCDIR" 
done <<< "$FILELIST"