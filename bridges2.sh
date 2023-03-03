#!/usr/bin/env bash

set -euo pipefail

export TOOLCHAIN="bridges2"
export TESTSUITE="small"

# cluster specific environment
export SPACKDIR="$PROJECT/spack"
export SOURCEDIR="$PROJECT/nickcao/POT3D"
export WORKDIR="$PROJECT/nickcao/workdir"

sbatch \
  --job-name=pot3d \
  --partition=RM \
  --nodes=4 \
  --ntasks-per-node=16 \
  --cpus-per-task=8 \
  --time=02:30:00 \
  --chdir="$WORKDIR" \
  --export="TOOLCHAIN,TESTSUITE,SPACKDIR,SOURCEDIR,WORKDIR" \
  submit.sh
