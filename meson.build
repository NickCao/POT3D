project('POT3D', ['fortran', 'c'])

hdf5 = dependency('hdf5', language: 'fortran', method: 'config-tool')
mpi = dependency('mpi', language: 'fortran')

executable(
    'pot3d',
    'src/number_types.f',
    'src/zm_parse_modules.f',
    'src/zm_parse.f',
    'src/zm_sds_modules.f',
    'src/zm_sds.f',
    'src/pot3d.F',
    dependencies: [hdf5, mpi],
)
