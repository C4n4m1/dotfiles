{
  lib,
  stdenv,
  fetchurl,
  zstd,
  autoPatchelfHook,
  dbus,
  fontconfig,
  libxcb,
  libx11,
  libxkbcommon,
  vulkan-loader,
  wayland,
  libGL,
  alsa-lib,
  zlib,
}:

# Repackages the upstream Arch release asset (a plain tarball of usr/{bin,share})
# and patches the ELF binaries for the Nix store.
stdenv.mkDerivation (finalAttrs: {
  pname = "tusk";
  version = "0.2.1";

  src = fetchurl {
    url = "https://github.com/alpcanaydin/tusk/releases/download/v${finalAttrs.version}/Tusk-${finalAttrs.version}-arch-x86_64.pkg.tar.zst";
    # First build prints the real hash in the "got:" line; paste it here.
    hash = "sha256-n/TKNtadWLMndITOXm4jCkOt02IgFfe1kv6GBJon5o0=";
  };

  nativeBuildInputs = [
    zstd
    autoPatchelfHook
  ];

  # Libraries the binaries are linked against (DT_NEEDED).
  buildInputs = [
    stdenv.cc.cc.lib # libstdc++ / libgcc_s
    dbus # libdbus-1 (keyring -> Secret Service)
    fontconfig
    libxcb
    libxkbcommon # also provides libxkbcommon-x11
    alsa-lib
    zlib
  ];

  # Libraries GPUI loads with dlopen at runtime. autoPatchelfHook adds these to
  # the RPATH of the executables, so no LD_LIBRARY_PATH is needed (that would
  # leak into the agent CLIs and language servers Tusk spawns).
  runtimeDependencies = [
    vulkan-loader
    wayland
    libxkbcommon
    libxcb
    libx11
    libGL
    fontconfig
  ];

  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir extracted
    tar --zstd -xf $src -C extracted
    mkdir -p $out
    cp -r extracted/usr/. $out/

    runHook postInstall
  '';

  meta = {
    description = "GPU-rendered, keyboard-driven database client (GPUI)";
    homepage = "https://github.com/alpcanaydin/tusk";
    license = lib.licenses.mit;
    mainProgram = "tusk";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
