#!/usr/bin/env bash
#SBATCH --job-name=pot3d
#SBATCH --partition=RM
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=8

# Run POT3D with isc2023 input on both PSC bridges-2 and FAU Fritz CPU clusters using 4 nodes.
# Experiment with number of ranks per socket/numa domains to get the best results.
# Your job should converge at 25112 steps and print outputs like below:
# ### The CG solver has converged.
# Iteration:    25112   Residual:   9.972489313728662E-13

set -euo pipefail

export OMP_NUM_THREADS="$SLURM_CPUS_PER_TASK"
export FFLAGS="-ftree-parallelize-loops=$OMP_NUM_THREADS"

source "$PROJECT/spack/share/spack/setup-env.sh"

spack load python meson

module load openmpi/4.0.5-gcc10.2.0
module load hdf5/1.10.7-gcc10.2.0

WORKDIR="$PROJECT/nickcao/workdir/$SLURM_JOB_ID"
SOURCEDIR="$PROJECT/nickcao/POT3D"

git -C "$SOURCEDIR" rev-parse HEAD

meson setup --prefix "$WORKDIR/prefix" --buildtype release "$WORKDIR/builddir" "$SOURCEDIR"
meson install -C "$WORKDIR/builddir"

"$SOURCEDIR/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$WORKDIR/prefix/bin/pot3d" \
  --workdir   "$WORKDIR/work" \
  --testsuite "$SOURCEDIR/testsuite/isc2023" \
  --mca btl '^openib'
