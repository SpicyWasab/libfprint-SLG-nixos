# When you use pkgs.callPackage, parameters here will be filled with packages from Nixpkgs (if there's a match)
{ lib
, stdenv
, fetchFromGitHub
, cmake
, ...
} @ args:

stdenv.mkDerivation rec {
  # Specify package name and version
  pname = "liboqs";
  version = "0.7.1";

  # Download source code from GitHub
  src = fetchFromGitHub ({
    owner = "open-quantum-safe";
    repo = "liboqs";
    # Commit or tag, note that fetchFromGitHub cannot follow a branch!
    rev = "0.7.1";
    # Download git submodules, most packages don't need this
    fetchSubmodules = false;
    # Don't know how to calculate the SHA256 here? Comment it out and build the package
    # Nix will raise an error and show the correct hash
    sha256 = "sha256-m20M4+3zsH40hTpMJG9cyIjXp0xcCUBS+cCiRVLXFqM=";
  });

  # Parallel building, drastically speeds up packaging, enabled by default.
  # You only want to turn this off for one of the rare packages that fails with this.
  enableParallelBuilding = true;
  # If you encounter some weird error when packaging CMake-based software, try enabling this
  # This disables some automatic fixes applied to CMake-based software
  dontFixCmake = true;

  # Add CMake to the building environment, to generate Makefile with it
  nativeBuildInputs = [ cmake ];

  # Arguments to CMake that controls functionalities of liboqs
  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DOQS_BUILD_ONLY_LIB=1"
    "-DOQS_USE_OPENSSL=OFF"
    "-DOQS_DIST_BUILD=ON"
  ];

  # stdenv.mkDerivation automatically does the rest for you
}
