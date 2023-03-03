#!/usr/bin/env bash

set -euo pipefail

export TOOLCHAIN="fau"
export TESTSUITE="small"

# cluster specific environment
export SPACKDIR="$HOME/spack"
export SOURCEDIR="$HOME/nickcao/POT3D"
export WORKDIR="$HOME/nickcao/workdir"

sbatch \
  --job-name=pot3d \
  --nodes=4 \
  --ntasks-per-node=72 \
  --cpus-per-task=1 \
  --time=02:30:00 \
  --chdir="$WORKDIR" \
  --export="TOOLCHAIN,TESTSUITE,SPACKDIR,SOURCEDIR,WORKDIR" \
  submit.sh
