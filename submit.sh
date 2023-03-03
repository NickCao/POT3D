#!/usr/bin/env bash

set -euo pipefail

# load spack
source "$SPACKDIR/share/spack/setup-env.sh"
spack load python meson

case "$TOOLCHAIN" in
  bridges2)
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
  fau)
    source /usr/share/Modules/init/bash
    module load git
    module load intelmpi/2021.7.1
    module load hdf5/1.12.2-intel2021.7.0-impi
    ;;
  *)
    exit 1
    ;;
esac

# show source info
git -C "$SOURCEDIR" rev-parse HEAD

# setup env vars
export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"

# first pass
meson setup --buildtype release \
  -Db_lto=true -Db_ndebug=if-release -Db_pgo=generate \
  "$WORKDIR/builddir" "$SOURCEDIR"
meson compile -C "$WORKDIR/builddir"

"$SOURCEDIR/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$WORKDIR/builddir/pot3d" \
  --workdir   "$WORKDIR/gen" \
  --testsuite "$SOURCEDIR/testsuite/$TESTSUITE"

# second pass
meson configure -Db_pgo=use \
  "$WORKDIR/builddir"
meson compile -C "$WORKDIR/builddir"

"$SOURCEDIR/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$WORKDIR/builddir/pot3d" \
  --workdir   "$WORKDIR/use" \
  --testsuite "$SOURCEDIR/testsuite/$TESTSUITE"
