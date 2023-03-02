project('POT3D', ['fortran', 'c'])

hdf5 = dependency('hdf5', language: 'fortran', method: 'config-tool')
mpi = dependency('mpi', language: 'fortran')

pot3d = executable(
    'pot3d',
    'src/number_types.f',
    'src/zm_parse_modules.f',
    'src/zm_parse.f',
    'src/zm_sds_modules.f',
    'src/zm_sds.f',
    'src/pot3d.F',
    dependencies: [hdf5, mpi],
    link_language: 'fortran',
)

mpirun = find_program('mpirun')
validate = find_program(
    'validate',
    ['scripts/validate'],
)

test(
    'validation',
    validate,
    args: [
        '--mpirun',
        mpirun.full_path(),
        '--pot3d',
        pot3d.full_path(),
        '--workdir',
        join_paths(meson.current_build_dir(), 'validation'),
        '--testsuite',
        join_paths(meson.current_source_dir(), 'testsuite/validation'),
    ],
    timeout: 600,
)
