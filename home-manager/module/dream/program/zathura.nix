{
  self,
  flake,
  inputs,
  ...
}:
{
  pkgs,
  lib,
  config,
  ...
}:
with self.lib;
with lib;
let
  cfg = config.dream.program.${name};
  name = "zathura";
in
{
  options.dream.program.${name} = {
    enable = mkEnableOption "Enable program.${name}";
  };
  config = mkIf cfg.enable {
    programs.${name} = {
      enable = true;
      package = self.packages.${pkgs.system}.${name};
    };
    
    xdg.configFile."${name}/${name}rc".enable = false;
    # FIXME(hardcoded): have this in a reusable option
    home.activation."copy-${name}/${name}rc" = let
      storeFile = ./${name}/${name}rc;
    in lib.hm.dag.entryAfter ["writeBoundary"] ''
      file="${config.xdg.configHome}/${name}/${name}rc"
      run mkdir --parents "${config.xdg.configHome}/${name}"
      [ -f "$file" ] &&
        echo "WARNING: file '$file' already exists! Backing up..." &&
        ! diff -q ${storeFile} "$file" &&
        mv "$file" "$file.$(date +%s).bak"
      run cp --no-clobber --verbose "${storeFile}" "$file"
    '';
  };
}
