#!/bin/bash
set -e

folder=/Users/fredatherden/Documents/GitHub/eLife-JATS-schematron/
cd $folder
grantFolder=${folder}grant-dois

if [ ! -d "$grantFolder" ]; then
    mkdir -p "$grantFolder"
fi

echo "Retrieving DataCite grant data"

next_url='https://api.datacite.org/dois?resource-type-id=award&page%5Bcursor%5D=1&page%5Bsize%5D=1000'
counter=1

while [ -n "$next_url" ]; do
    outputFile="$grantFolder/datacite-page-$counter.json"

    curl -s "$next_url" > "$outputFile"

    if [ $? -eq 0 ]; then
        echo "Page saved to: $outputFile"

        # Increment the counter for the next filename
        ((counter++))

        # Find the next url from the response
        next_url=$(jq -r '.links.next' "$outputFile")

        if [ "$next_url" = "null" ] || [ -z "$next_url" ]; then
            next_url=""
        fi

    else
    echo "API request failed. Check the error and try again."
    break
  fi
done

echo "all DataCite data retrieved"

echo "Retrieving Crossref grant data"

cursor="*"
crossrefApi="https://api.crossref.org/works?filter=type:grant&rows=1000"
counter=1

while true; do
    outputFile="$grantFolder/crossref-page-$counter.json"

    curl -s "$crossrefApi&cursor=$cursor" > "$outputFile"

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

echo "all Crossref data retrieved"