{ stdenv, ... }: stdenv.mkDerivation {
  name = "dream-scripts";
  pname = "dream-scripts";
  src = ./.;

  # nativeBuildInputs = with pkgs; [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 script/* -t $out/bin
  '';

  # postFixup = with pkgs; ''
  #   for bin in $out/bin/*; do
  #     wrapProgram $bin \
  #       --suffix PATH : ${lib.makeBinPath [
  #         coreutils
  #         sudo
  #         gawk
  #         gnugrep
  #         bash
  #         procps
  #       ]}
  #   done
  # '';
}
