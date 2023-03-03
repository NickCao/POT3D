#!/usr/bin/env bash
#SBATCH --job-name=pot3d
#SBATCH --partition=RM
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=8
#SBATCH --time=02:00:00

# Run POT3D with isc2023 input on both PSC bridges-2 and FAU Fritz CPU clusters using 4 nodes.
# Experiment with number of ranks per socket/numa domains to get the best results.
# Your job should converge at 25112 steps and print outputs like below:
# ### The CG solver has converged.
# Iteration:    25112   Residual:   9.972489313728662E-13

set -euo pipefail

# cluster specific environment
SPACKDIR="$PROJECT/spack"
SOURCEDIR="$PROJECT/nickcao/POT3D"
WORKDIR="$PROJECT/nickcao/workdir/$SLURM_JOB_ID"
TESTSUITE="small"

export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"

source "$SPACKDIR/share/spack/setup-env.sh"

spack load python meson

TOOLCHAIN="bridges2"

case "$TOOLCHAIN" in
  bridges2)
    # spack install intel-oneapi-compilers
    # spack compiler add `spack location -i intel-oneapi-compilers`/compiler/latest/linux/bin/intel64
    # spack install openmpi%intel+legacylaunchers fabrics=ucx schedulers=slurm
    # spack install hdf5%intel+fortran+hl~mpi
    # patch mesonbuild/dependencies/mpi.py
    spack load intel-oneapi-compilers
    spack load openmpi%intel
    spack load hdf5%intel
    export CC=icc FC=mpifort
    MPIARG=()
    ;;
  fau)
    module load openmpi/4.1.4-gcc12.2.0
    module load hdf5/1.12.2-gcc12.2.0-ompi
    MPIARG=("--mca" "btl" '^openib')
    ;;
  *)
    exit 1
    ;;
esac

# show source info
git -C "$SOURCEDIR" rev-parse HEAD

# load spack
source "$SPACKDIR/share/spack/setup-env.sh"
spack load python meson

# first pass
meson setup --buildtype release \
  -Db_lto=true -Db_ndebug=if-release -Db_pgo=generate \
  "$WORKDIR/builddir" "$SOURCEDIR"
meson compile -C "$WORKDIR/builddir"

"$SOURCEDIR/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$WORKDIR/builddir/pot3d" \
  --workdir   "$WORKDIR/generate" \
  --testsuite "$SOURCEDIR/testsuite/$TESTSUITE" \
  "${MPIARG[@]}"

# second pass
meson configure -Db_pgo=use \
  "$WORKDIR/builddir"
meson compile -C "$WORKDIR/builddir"

"$SOURCEDIR/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$WORKDIR/builddir/pot3d" \
  --workdir   "$WORKDIR/use" \
  --testsuite "$SOURCEDIR/testsuite/$TESTSUITE" \
  "${MPIARG[@]}"
