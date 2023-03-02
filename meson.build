project('POT3D', ['fortran', 'c'])

hdf5 = dependency('hdf5', language: 'fortran')
mpi = dependency('mpi', language: 'fortran')

compiler = meson.get_compiler('fortran')

flags = compiler.get_supported_arguments(
    '-Ofast',
    '-march=native',
    '-mtune=native',
)

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
    fortran_args: flags,
    install: true,
)

mpirun = find_program('mpirun')
validate = find_program(
    'validate',
    ['scripts/validate'],
)

testsuites = [
    'validation',
]

if get_option('large_tests')
    testsuites += [
        'small',
        'medium',
        'large',
        'isc2023',
    ]
endif

foreach testsuite : testsuites
    test(
        testsuite,
        validate,
        args: [
            '--mpirun',
            mpirun.full_path(),
            '--pot3d',
            pot3d.full_path(),
            '--workdir',
            meson.current_build_dir() / testsuite,
            '--testsuite',
            meson.current_source_dir() / 'testsuite' / testsuite,
            '-np',
            '2',
        ],
        timeout: 600,
    )
endforeach
