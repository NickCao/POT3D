#!/usr/bin/env bash

set -euo pipefail

# load spack
source "$SPACKDIR/share/spack/setup-env.sh"
spack load python meson

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
  fau-intel-openmpi)
    source /usr/share/Modules/init/bash
    module load git
    module load hdf5/1.12.2-intel2021.7.0-ompi
  fau-intel-intelmpi)
    source /usr/share/Modules/init/bash
    module load git
    module load hdf5/1.12.2-intel2021.7.0-impi
    ;;
  fau-gnu-openmpi)
    source /usr/share/Modules/init/bash
    module load git
    module load hdf5/1.12.2-gcc12.2.0-ompi
  fau-gnu-intelmpi)
    source /usr/share/Modules/init/bash
    module load git
    module load hdf5/1.12.2-gcc12.2.0-impi
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
  -Db_lto=true -Db_ndebug=if-release -Db_pgo=generate \
  "$JOBDIR/builddir" "$SOURCEDIR"
meson compile -C "$JOBDIR/builddir"

"$SOURCEDIR/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$JOBDIR/builddir/pot3d" \
  --workdir   "$JOBDIR/gen" \
  --testsuite "$SOURCEDIR/testsuite/$TESTSUITE"

# second pass
meson configure -Db_pgo=use \
  "$JOBDIR/builddir"
meson compile -C "$JOBDIR/builddir"

"$SOURCEDIR/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$JOBDIR/builddir/pot3d" \
  --workdir   "$JOBDIR/use" \
  --testsuite "$SOURCEDIR/testsuite/$TESTSUITE"
