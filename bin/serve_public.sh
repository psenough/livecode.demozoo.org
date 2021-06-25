#!/bin/sh

# Serve everything in `public/` via HTTP (for development only!).

BASEDIR=$(dirname $0)
python -m http.server --directory $BASEDIR/../public
