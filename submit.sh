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
TESTSUITE=isc2023

export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"

source "$SPACKDIR/share/spack/setup-env.sh"

spack load python meson

TOOLCHAIN="intel"

case "$TOOLCHAIN" in
  gnu)
    module load openmpi/4.0.5-gcc10.2.0
    module load hdf5/1.10.7-gcc10.2.0
    export FFLAGS="-ftree-parallelize-loops=$OMP_NUM_THREADS"
    MPIARG=("--mca" "btl" '^openib')
    ;;
  intel)
    module load intel/20.4
    module load openmpi/4.0.2-intel20.4
    module load hdf5/1.12.0-intel20.4
    MPIARG=()
    ;;
  fau)
    module load gcc/12.2.0
    module load openmpi/4.1.4-gcc12.2.0
    module load hdf5/1.12.2-gcc12.2.0-ompi
    MPIARG=("--mca" "btl" '^openib')
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
