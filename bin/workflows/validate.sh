#!/bin/bash
set -e

echo ">>>>"
echo "$1"
jsonschema -i "$1" -F "ERROR: {error}" ./meta/event.schema.json
echo "<<<"