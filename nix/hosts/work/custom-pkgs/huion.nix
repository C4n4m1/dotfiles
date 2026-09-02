{ stdenv, fetchurl, dpkg, autoPatchelfHook }:

stdenv.mkDerivation {
  pname = "foo-driver";
  version = "1.0";

  src = fetchurl { url = "https://vendor.example/driver.deb"; hash = ""; };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];

  unpackPhase = ''
    dpkg-deb -x $src $TMPDIR/unpacked
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib
    cp -r $TMPDIR/unpacked/usr/bin/* $out/bin/
    cp -r $TMPDIR/unpacked/usr/lib/* $out/lib/
    runHook postInstall
  '';
}
