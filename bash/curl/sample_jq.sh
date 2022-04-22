#!/bin/bash

######################################################
# NOTE:                                              #
#   This script requires "jq" command line tool!     #
#   See https://stedolan.github.io/jq/               #
######################################################


IMAGE=${1}
OUTPUT_IMAGE="result.png"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Run base sample script to get raw output.
raw_response=$(bash ${DIR}/sample.sh "${IMAGE}")

# Parse response and save file.
jq -r ".results[0].entities[0].image" <<< ${raw_response} | base64 -d > "${OUTPUT_IMAGE}"
echo "💬 The ${OUTPUT_IMAGE} image is saved to the current directory."

