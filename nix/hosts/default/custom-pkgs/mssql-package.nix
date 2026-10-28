{
  lib,
  stdenv,
  fetchurl,
  rpm,
  cpio,
  autoPatchelfHook,
  python3,
  openssl,
  curl,
  openldap,
  krb5,
  cyrus_sasl,
  libunwind,
  util-linux, # libuuid
  numactl,
  libcap,
  zlib,
  pam,
  udev,
  sssd,
  e2fsprogs, # libcom_err
  bash,
}:

let
  # SQL Server 2025 is built against OpenSSL 3.0 and references EVP_md2.
  # OpenSSL 3.5 no longer compiles MD2 support in by default, so rebuild it
  # with --enable-md2. The upstream test suite assumes MD2 is absent, so skip
  # the tests; the resulting libcrypto is ABI-compatible with the default one.
  openssl' = (openssl.override { enableMD2 = true; }).overrideAttrs (_: {
    doCheck = false;
  });
in

# Repackages Microsoft's official SQL Server RPM (the same payload the Arch
# AUR `mssql-server` package unpacks) and patches the ELF files for NixOS.
#
# Layout is kept as upstream ships it: everything lives under $out/opt/mssql.
# SQL Server hardcodes /opt/mssql (binaries) and /var/opt/mssql (data), so the
# NixOS module symlinks /opt/mssql to this package.
#
# Unfree: needs `nixpkgs.config.allowUnfree` or an allowUnfreePredicate.
stdenv.mkDerivation rec {
  pname = "mssql-server";

  # SQL Server 2025 CU10. Confirm the current build here before bumping:
  # https://learn.microsoft.com/en-us/troubleshoot/sql/releases/sqlserver-2025/kb5005684-build-versions
  # The RPM naming is `mssql-server-<version>-<release>.x86_64.rpm`.
  version = "17.0.5035.5";
  release = "3";

  src = fetchurl {
    # RHEL 9 build: older glibc baseline than the RHEL 10 one, so it is the
    # safer choice. Swap `rhel/9` for `rhel/10` if you prefer.
    url = "https://packages.microsoft.com/rhel/9/mssql-server-2025/Packages/m/mssql-server-${version}-${release}.x86_64.rpm";
    hash = "sha256-rRVsR/o0Sg3PiYhfiop7ZG6Veu68ZtAFz+P0AYC+C2A=";
  };

  nativeBuildInputs = [
    rpm
    cpio
    autoPatchelfHook
    python3 # used by patchShebangs for mssql-conf.py
  ];

  # Linked (DT_NEEDED) libraries plus the optional dlopen() targets
  # (SASL/LDAP/Kerberos for AD authentication).
  buildInputs = [
    stdenv.cc.cc.lib # libstdc++, libgcc_s, libatomic
    openssl'
    curl
    openldap
    krb5
    cyrus_sasl
    libunwind
    util-linux.lib
    numactl
    libcap
    zlib
    pam
    udev
    sssd # libsss_nss_idmap.so.0 is a hard DT_NEEDED of sqlservr
    e2fsprogs # libcom_err.so.2
  ];

  # Libraries SQL Server dlopen()s at runtime (LDAP / Kerberos / TLS paths).
  # autoPatchelfHook cannot see these in DT_NEEDED, so it adds them to RPATH.
  runtimeDependencies = [
    openssl'
    curl
    openldap
    krb5
    cyrus_sasl
  ];

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    rpm2cpio $src | cpio -idm --no-absolute-filenames
    chmod -R u+w .
    runHook postUnpack
  '';

  dontConfigure = true;
  dontBuild = true;

  # Do not strip: this is a proprietary binary and stripping buys nothing.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a opt $out/opt

    # Keep the unit Microsoft ships so the NixOS module can be diffed against it.
    mkdir -p $out/share/mssql-server
    find . -name mssql-server.service -exec cp {} $out/share/mssql-server/ \;

    mkdir -p $out/bin
    ln -s $out/opt/mssql/bin/sqlservr $out/bin/sqlservr
    ln -s $out/opt/mssql/bin/mssql-conf $out/bin/mssql-conf

    # The helpers hardcode /bin/bash and (for the Python entry point) rely on
    # /usr/bin/env. patchShebangs fixes the #! lines; substitute the remaining
    # inline /bin/bash calls so mssql-conf and its setup wrapper work on NixOS.
    patchShebangs $out/opt/mssql/lib/mssql-conf $out/opt/mssql/bin
    # The launcher locates its Python implementation relative to $0. That is
    # correct for /opt/mssql/bin/mssql-conf but wrong for the $out/bin symlink,
    # so anchor it to this package's real location.
    substituteInPlace $out/opt/mssql/bin/mssql-conf \
      --replace-fail '$(dirname $0)/../lib' "$out/opt/mssql/lib" \
      --replace-fail '/bin/bash -c' '${bash}/bin/bash -c'
    substituteInPlace $out/opt/mssql/lib/mssql-conf/invokesqlservr.sh \
      --replace-fail '/bin/bash -c' '${bash}/bin/bash -c'

    # libc++.so.1 / libc++abi.so.1 / libunwind.so.8 are bundled in
    # opt/mssql/lib and are only reachable through the binaries' $ORIGIN
    # RUNPATH. Make them visible to autoPatchelfHook so it can resolve the
    # dependencies without pulling in a second, possibly incompatible libc++.
    addAutoPatchelfSearchPath $out/opt/mssql/lib

    runHook postInstall
  '';

  # Keep the original $ORIGIN RUNPATH entries in addition to the Nix store
  # paths added by autoPatchelfHook.
  autoPatchelfFlagsArray = [ "--preserve-origin" ];

  meta = {
    description = "Microsoft SQL Server database engine for Linux (repackaged upstream RPM)";
    homepage = "https://learn.microsoft.com/en-us/sql/linux/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "sqlservr";
  };
}
