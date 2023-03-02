#!/usr/bin/env bash

set -euo pipefail

new=$(tail -n 4 "$1")
ref=$(tail -n 4 "$2")

if [ "$new" == "$ref" ]; then
  echo "PASSED"
  exit 0
else
  echo "FAILED"
  exit 1
fi
