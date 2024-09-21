{ stdenv, makeWrapper, pkgs, system, inputs, ... }: stdenv.mkDerivation {
  name = "statusbar-scripts";
  pname = "statusbar-scripts";
  src = ./.;

  # nativeBuildInputs = with pkgs; [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install -Dm755 script/* -t $out/bin
  '';

  nativeBuildInputs = [ makeWrapper ];

  postFixup = with pkgs; ''
    for bin in $out/bin/*; do
      wrapProgram $bin \
        --set PATH ${lib.makeBinPath [
          coreutils
          jq
          socat
          gnugrep
          gnused
          gawk
          findutils

          curl         # sb-weather
          hyprland     # current workspace, input lang, etc.
          mpc-cli      # sb-mus-listen
          pulseaudio   # sb-source-mute
          lm_sensors   # sb-cpu-temp
          inputs.ev.packages.${system}.default # event-based meters (lang, mute)
          procps       # sb-memory
          calc         # sb-memory - account for ZFS
          mount        # sb-memory - account for ZFS
        ]}:${./script}
    done
  '';
}
