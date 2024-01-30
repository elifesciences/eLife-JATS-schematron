#!/bin/bash
set -e

folder=/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/
cd $folder
grantFolder=${folder}/grant-dois

if [ ! -d "$grantFolder" ]; then
    mkdir -p "$grantFolder"
fi

cursor="*"
api="https://api.crossref.org/works?filter=type:grant&rows=1000"
counter=1

while  true; do
    outputFile="$grantFolder/page-$counter.json"

    curl -s "$api&cursor=$cursor" > "$outputFile"

    if [ $? -eq 0 ]; then
        echo "Page saved to: $outputFile"

        # Count the number of items in the response
     itemsCount=$(jq '.message.items | length' "$outputFile")

        # if there are no items, exit
        [ "$itemsCount" -eq 0 ] && break


        # If there are items, extract the next cursor value from the response for the next iteration
        cursor=$(jq -r '.message."next-cursor"' "$outputFile")

        # Increment the counter for the next filename
        ((counter++))
    else
    echo "API request failed. Check the error and try again."
    break
  fi
done

echo "all data retrieved"