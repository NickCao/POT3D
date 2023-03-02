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
fs = import('fs')

test(
    'pot3d',
    mpirun,
    args: [
        '--mca',
        'btl',
        'tcp,self',
        '--mca',
        'btl_tcp_if_include',
        'lo',
        '-np',
        '2',
        pot3d.full_path(),
    ],
    depends: [
        fs.copyfile('testsuite/validation/input/pot3d.dat'),
        fs.copyfile('testsuite/validation/input/br_input_tiny.h5'),
    ],
    workdir: meson.current_build_dir(),
    timeout: 600,
)
