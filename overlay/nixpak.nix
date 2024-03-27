{ nixpak, ... }:
final: prev: {
  mkNixPak = nixpak.lib.nixpak {
    inherit (prev) lib pkgs;
  };
}
