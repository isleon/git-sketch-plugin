#!/bin/bash

DIR_PATH="$1"
EXPORT_FOLDER="$2"
FILE_FOLDER="$3"
BUNDLE_PATH="$4"
FILENAME="$5"
SCALE="$6"


cd "$DIR_PATH"
mkdir -p "$EXPORT_FOLDER"

# move old artboards to temp directory to compare them with the new ones
rm -rf .oldArtboards
mv "$FILE_FOLDER" .oldArtboards 2>/dev/null

# generate new artboards
mkdir -p "$FILE_FOLDER"
$BUNDLE_PATH/Contents/Resources/sketchtool/bin/sketchtool export artboards "$FILENAME" --scales="$SCALE" --output="$FILE_FOLDER" --overwriting=YES

# compare new artboards with the old ones
for artboardPath in "$FILE_FOLDER"/*
do
  artboard=$(basename "$artboardPath")
  if [[ -f .oldArtboards/"$artboard" ]]; then
    # Get base64 encoded artboard
    newArtboard="$(cat "$FILE_FOLDER"/"$artboard" | base64)"
    oldArtboard="$(cat .oldArtboards/"$artboard" | base64)"

    # See if the artboards are the same
    if [ "$newArtboard" == "$oldArtboard" ]; then
      # keep the old artboard
      rm "$artboardPath"
    	mv .oldArtboards/"$artboard" "$artboardPath"
    fi
  fi
done

git add "$EXPORT_FOLDER"
rm -rf .oldArtboards
