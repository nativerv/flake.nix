{
  flake,
  self,
  inputs,

  # NOTE: Change this for other platforms (like `aarch64-linux`)
  # Import this file with `system` argument passed to reuse this file for other
  # platforms.
  system ? "x86_64-linux",
  ...
}: let
  # INFO: `nixpkgs-flake`: inserted with an overlay into `self.legacyPackages`.
  inherit (pkgs) nixpkgs-flake;
  pkgs = import inputs.nixpkgs-unstable {
    inherit system;
    overlays = [
      (final: prev: { nixpkgs-flake = inputs.nixpkgs-unstable; })
      self.overlays.default
    ];
    config = { pkgs }: {
      allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
        # Unfree Redistributable packages
        # TODO: disable some of this bullshit
        "linux-firmware"
        "intel2200BGFirmware"
        "rtl8192su-unstable"
        "rtl8192su"
        "rt5677-firmware-zstd"
        "rt5677-firmware"
        "rtl8761b-firmware-zstd"
        "rtl8761b-firmware"
        "rtw88-firmware-zstd"
        "rtw88-firmware-unstable"
        "rtw88-firmware"
        "libreelec-dvb-firmware"
        "libreelec-dvb-firmware"

        # Microcode
        "amd-ucode"
      ];
    };
  };

  # Use folder name as name of this system
  name = builtins.baseNameOf ./.;

in nixpkgs-flake.lib.nixosSystem {
  inherit pkgs;
  modules = [
    ({ networking.hostName = name; })
    (import ./${name}.nix { inherit flake self inputs; })
  ];
}
