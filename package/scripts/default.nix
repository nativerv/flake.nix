{ stdenv, pkgs, ... }: stdenv.mkDerivation {
  name = "dream-scripts";
  pname = "dream-scripts";
  src = ./.;

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 script/* -t $out/bin
  '';

  nativeBuildInputs = with pkgs; [ makeWrapper ];
  postFixup = with pkgs; /* bash */ ''
    for bin in $out/bin/*; do
      wrapProgram $bin \
        --suffix PATH : ${lib.makeBinPath [
          # FIXME(hardcoded): dep of one specific script
          glib # for xdg-doc-allow
          pandoc # for dict, render
        ]}
    done
  '';
}
