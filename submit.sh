#!/usr/bin/env bash
#SBATCH --job-name=pot3d
#SBATCH --partition=RM
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128

# Run POT3D with isc2023 input on both PSC bridges-2 and FAU Fritz CPU clusters using 4 nodes.
# Experiment with number of ranks per socket/numa domains to get the best results.
# Your job should converge at 25112 steps and print outputs like below:
# ### The CG solver has converged.
# Iteration:    25112   Residual:   9.972489313728662E-13

module load openmpi/4.0.5-nvhpc22.9
module load hdf5/1.10.7-gcc10.2.0
module load python/3.8.6

"$PROJECT/nickcao/POT3D/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$PROJECT/nickcao/POT3D/builddir/pot3d" \
  --workdir   "$PROJECT/nickcao/workdir/$SLURM_JOB_ID" \
  --testsuite "$PROJECT/nickcao/POT3D/testsuite/validation" \
  --mca btl '^openib'
