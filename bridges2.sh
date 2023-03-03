#!/usr/bin/env bash

set -euo pipefail

TOOLCHAIN="bridges2"
TESTSUITE="small"

# cluster specific environment
SPACKDIR="$PROJECT/spack"
SOURCEDIR="$PROJECT/nickcao/POT3D"
WORKDIR="$PROJECT/nickcao/workdir"

sbatch \
  --job-name=pot3d \
  --partition=RM \
  --nodes=4 \
  --ntasks-per-node=16 \
  --cpus-per-task=8 \
  --time=02:30:00 \
  --chdir="$WORKDIR" \
  --export="TOOLCHAIN=$TOOLCHAIN" \
  --export="TESTSUITE=$TESTSUITE" \
  --export="SPACKDIR=$SPACKDIR" \
  --export="SOURCEDIR=$SOURCEDIR" \
  --export="WORKDIR=$WORKDIR" \
  submit.sh
