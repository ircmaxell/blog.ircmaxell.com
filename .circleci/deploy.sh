#!/bin/bash

DIR=$1
DEST=$2

aws s3 sync "$DIR" "s3://$DEST" --delete

aws s3 cp "s3://$DEST" "s3://$DEST" --exclude '*' --include '*.css' --include '*.js' --recursive --cache-control 'public, max-age=31536000' --metadata-directive REPLACE 

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