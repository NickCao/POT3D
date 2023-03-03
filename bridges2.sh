#!/usr/bin/env bash

set -euo pipefail

# cluster specific environment
TOOLCHAIN="bridges2"
SPACKDIR="$PROJECT/spack"
SOURCEDIR="$PROJECT/nickcao/POT3D"
WORKDIR="$PROJECT/nickcao/workdir/$SLURM_JOB_ID"
TESTSUITE="small"

sbatch \
  --job-name=pot3d \
  --partition=RM \
  --nodes=4 \
  --ntasks-per-node=16 \
  --cpus-per-task=8 \
  --time=02:30:00 \
  --chdir="$PROJECT/nickcao/workdir" \
  --export="TOOLCHAIN=$TOOLCHAIN" \
  --export="SPACKDIR=$SPACKDIR" \
  --export="SOURCEDIR=$SOURCEDIR" \
  --export="WORKDIR=$WORKDIR"
  --export="TESTSUITE=$TESTSUITE" \
  submit.sh
