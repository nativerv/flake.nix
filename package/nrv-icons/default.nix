{ stdenvNoCC, lib, ... }: stdenvNoCC.mkDerivation rec {
  name = pname;
  pname = "nrv-font";
  src = ./font;

  installPhase = ''
    dir=$out/share/fonts/truetype/${name}
    mkdir -p $dir
    install -Dm644 * -t $dir
  '';

  meta = {
    broken = true;

    description = "NRV's icons for statusbar and stuff";
    # homepage = "https://www.google.com/get/noto/";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
