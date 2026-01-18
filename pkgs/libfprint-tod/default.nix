{
  lib,
  libfprint,
  fetchFromGitHub,
}:

# for the curious, "tod" means "Touch OEM Drivers" meaning it can load
# external .so's.
libfprint.overrideAttrs (
  {
    postPatch ? "",
    mesonFlags ? [ ],
    ...
  }:
  let
    version = "1.94.9+tod1";
  in
  {
    pname = "libfprint-tod";
    inherit version;

    src = fetchFromGitHub ({
      owner = "xerootg";
      repo = "libfprint";
      # Commit or tag, note that fetchFromGitHub cannot follow a branch!
      rev = "9f169dc";
      # Download git submodules, most packages don't need this
      fetchSubmodules = false;
      # Don't know how to calculate the SHA256 here? Comment it out and build the package
      # Nix will raise an error and show the correct hash
      sha256 = "sha256-8VF3NcUdZ5XBi3l/uglEH6MxdDkapcd6wL8XrXALgEU=";
    });

    mesonFlags = [
      # Include virtual drivers for fprintd tests
      # "-Ddrivers=all"
      "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
      "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
      "-Dinstalled-tests=false" # doesn't work if I don't disable this. I guess it's due to this version not having proper tests or something like that

    ];

    # postPatch = ''
    #   ${postPatch}
    #   patchShebangs \
    #     ./libfprint/tod/tests/*.sh \
    #     ./tests/*.py \
    #     ./tests/*.sh \
    # '';

    doCheck = false;

    doInstallCheck = false;

    meta = with lib; {
      homepage = "https://gitlab.freedesktop.org/3v1n0/libfprint";
      description = "Library designed to make it easy to add support for consumer fingerprint readers, with support for loaded drivers";
      license = licenses.lgpl21;
      platforms = platforms.linux;
      maintainers = with maintainers; [ grahamc ];
    };
  }
)
