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
  name = "zathura";
in mkMerge [
  {
    programs.${name} = {
      enable = true;
      package = self.packages.${pkgs.system}.${name};
    };
    
    xdg.configFile."${name}/${name}rc".enable = false;
    # FIXME(hardcoded): have this in a reusable option
    home.activation."copy-${name}/${name}rc" = let
      storeFile = ./${name}/${name}rc;
    in lib.hm.dag.entryAfter ["writeBoundary"] ''
      file="$XDG_CONFIG_HOME/${name}/${name}rc"
      run mkdir --parents "$XDG_CONFIG_HOME/${name}"
      [ -f "$file" ] &&
        echo "WARNING: file '$file' already exists! Backing up..." &&
        ! diff -q ${storeFile} "$file" &&
        mv "$file" "$file.$(date +%s).bak"
      run cp --no-clobber --verbose "${storeFile}" "$file"
    '';
  }
]
