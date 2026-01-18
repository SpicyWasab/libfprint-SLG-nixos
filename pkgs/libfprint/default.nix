{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  meson,
  python3,
  ninja,
  gusb,
  pixman,
  glib,
  gobject-introspection,
  cairo,
  libgudev,
  udevCheckHook,
  gtk-doc,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libfprint";
  version = "0.0.1";
  outputs = [
    "out"
    "devdoc"
  ];

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

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    gobject-introspection
    udevCheckHook
  ];

  buildInputs = [
    gusb
    pixman
    glib
    cairo
    libgudev
    openssl
  ];

  mesonFlags = [
    "-Dudev_rules_dir=${placeholder "out"}/lib/udev/rules.d"
    # Include virtual drivers for fprintd tests
    # "-Ddrivers=all" # doesn't build if I don't uncomment this
    "-Dinstalled-tests=false" # doesn't work if I don't disable this. I guess it's due to this version not having proper tests or something like that
    "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
  ];

  # nativeInstallCheckInputs = [
  #   (python3.withPackages (p: with p; [ pygobject3 ]))
  # ];

  # We need to run tests _after_ install so all the paths that get loaded are in
  # the right place.
  doCheck = false;

  doInstallCheck = false;

  installCheckPhase = ''
    runHook preInstallCheck

    ninjaCheckPhase

    runHook postInstallCheck
  '';

  meta = {
    homepage = "https://fprint.freedesktop.org/";
    description = "Library designed to make it easy to add support for consumer fingerprint readers";
    license = lib.licenses.lgpl21Only;
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
})
