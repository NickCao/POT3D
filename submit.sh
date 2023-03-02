#!/usr/bin/env bash
#SBATCH --job-name=pot3d
#SBATCH --partition=RM
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=128

# Run POT3D with isc2023 input on both PSC bridges-2 and FAU Fritz CPU clusters using 4 nodes.
# Experiment with number of ranks per socket/numa domains to get the best results.
# Your job should converge at 25112 steps and print outputs like below:
# ### The CG solver has converged.
# Iteration:    25112   Residual:   9.972489313728662E-13

set -euo pipefail

source "$PROJECT/spack/share/spack/setup-env.sh"

module use "$PROJECT/nickcao/nvhpc/modulefiles"
module load python-3.10.8-gcc-8.3.1-ythg3kx
module load meson-1.0.0-gcc-8.3.1-u3sn4aw
module load ninja-1.11.1-gcc-8.3.1-6g2xce3
module load nvhpc/23.1
# spack install hdf5%nvhpc+fortran+hl~mpi
module load hdf5-1.14.0-nvhpc-23.1-3wmji6d

WORKDIR="$PROJECT/nickcao/workdir/$SLURM_JOB_ID"
SOURCEDIR="$PROJECT/nickcao/POT3D"

meson setup --prefix "$WORKDIR/prefix" --buildtype release "$WORKDIR/builddir" "$SOURCEDIR"
meson install -C "$WORKDIR/builddir"

"$SOURCEDIR/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$WORKDIR/prefix/bin/pot3d" \
  --workdir   "$WORKDIR/work" \
  --testsuite "$SOURCEDIR/testsuite/isc2023" \
  --mca btl '^openib'
