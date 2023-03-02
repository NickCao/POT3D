{
  inputs = {
    nixpkgs.url = "github:NickCao/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = import nixpkgs { inherit system; }; in with pkgs;{
          devShells.default = mkShell {
            nativeBuildInputs = [
              meson
              ninja
              gfortran
              pkg-config
            ];
            buildInputs = [
              mpi
              hdf5-fortran
            ];
          };
        }
      );
}
