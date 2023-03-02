#!/usr/bin/env bash
#SBATCH --job-name=pot3d
#SBATCH --partition=RM
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128

module load openmpi/4.0.5-nvhpc22.9
module load hdf5/1.10.7-gcc10.2.0
module load python/3.8.6

"$PROJECT/nickcao/POT3D/scripts/validate" \
  --mpirun    "$(type -P mpirun)" \
  --pot3d     "$PROJECT/nickcao/POT3D/builddir/pot3d" \
  --workdir   "$PROJECT/nickcao/workdir" \
  --testsuite "$PROJECT/nickcao/POT3D/testsuite/validation"
