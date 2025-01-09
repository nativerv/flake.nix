{
  sops,
  pkgs,
  lib,
  ...
}: let
  scriptOverride = pkgs.writeShellScriptBin "sops" ''
    set -uo pipefail
    set -x

    if [ -n "''${SOPS_AGE_KEY_COMMAND:-}" ]; then
      dir="$(mktemp -d)"
      chmod 700 "''${dir}"
      export SOPS_AGE_KEY_FILE="$(mktemp --tmpdir="$dir")"
      chmod 600 "''${SOPS_AGE_KEY_FILE}"
      trap 'rm -f "''${SOPS_AGE_KEY_FILE}"' INT TERM EXIT
      sh -c "''${SOPS_AGE_KEY_COMMAND}" > "''${SOPS_AGE_KEY_FILE}"
    fi
    ${sops}/bin/sops "''${@}"
  '';
in pkgs.symlinkJoin {
  name = "sops-dream";
  paths = [ scriptOverride sops ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    set -x
    for bin in $out/bin/*; do
      wrapProgram "$bin" \
        --prefix PATH : ${lib.makeBinPath (with pkgs; [
          coreutils
        ])} \
        --suffix PATH : ${lib.makeBinPath (with pkgs; [
          age # expected to be used by ${SOPS_AGE_KEY_COMMAND}
        ])}
    done
  '';

  meta = sops.meta // {
    description = "${sops.meta.description} -- `dream` wrapper. Provides custom source for `age` master key.";
  };
}
