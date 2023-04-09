#!/usr/bin/env bash

set -euo pipefail

# load spack
source "$SPACKDIR/share/spack/setup-env.sh"
spack load python%gcc@12 meson%gcc@12

if [ "$CLUSTER" == "fau" ]; then
  source /usr/share/Modules/init/bash
  module load git
fi

case "$CLUSTER-$TOOLCHAIN-$COMM" in
  bridges2-intel-intelmpi)
    # spack install intel-oneapi-compilers
    # spack compiler add `spack location -i intel-oneapi-compilers`/compiler/latest/linux/bin/intel64
    # spack install openmpi%intel+legacylaunchers fabrics=ucx schedulers=slurm
    # spack install hdf5%intel+fortran+hl~mpi
    # patch with https://github.com/mesonbuild/meson/pull/10056
    spack load intel-oneapi-compilers
    spack load intel-oneapi-mpi
    spack load hdf5%intel
    export CC=icc FC=ifort
    ;;
  fau-gnu-openmpi)
    module load gcc/12.2.0
    spack load openmpi/3xk5fdp hdf5/o6kmihv
    ;;
  *)
    exit 1
    ;;
esac

# show source info
git -C "$SOURCEDIR" rev-parse HEAD

# setup env vars
export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"
export JOBDIR="$WORKDIR/$SLURM_JOB_ID"

# first pass
meson setup --buildtype release \
  -Db_lto=true -Db_ndebug=if-release \
  "$JOBDIR/builddir" "$SOURCEDIR"
meson compile -C "$JOBDIR/builddir"

"$SOURCEDIR/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$JOBDIR/builddir/pot3d" \
  --workdir   "$JOBDIR/work" \
  --testsuite "$SOURCEDIR/testsuite/$TESTSUITE"
