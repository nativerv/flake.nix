{
  lib,
  pkgs,
  stdenv,
  ...
}:
with builtins;
with lib;
let
in {
  with-secrets = stdenv.mkDerivation {
    name = "with-secrets";
    pname = "with-secrets";
    src = ./.;

    installPhase = ''
      mkdir -p $out/bin
      install -Dm755 tool/with-secrets -t $out/bin
    '';

    nativeBuildInputs = with pkgs; [ makeWrapper ];
    postFixup = with pkgs; /* bash */ ''
      for bin in $out/bin/*; do
        wrapProgram $bin \
          --prefix PATH : ${lib.makeBinPath [
            coreutils
            cryfs
          ]}
      done
    '';
  };
}
