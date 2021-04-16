#!/bin/bash
echo "$1"
jsonschema -i "$1" -F "ERROR: {error}" .\meta\event.schema.json