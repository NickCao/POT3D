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

fs = import('fs')

test(
    'pot3d',
    pot3d,
    depends: [
        fs.copyfile('testsuite/validation/input/pot3d.dat'),
        fs.copyfile('testsuite/validation/input/br_input_tiny.h5'),
    ],
    workdir: meson.current_build_dir(),
)
