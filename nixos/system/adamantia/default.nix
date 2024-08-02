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
      allowUnfreePredicate = self.lib.unfreeWhiteList (with pkgs; [
        linux-firmware

        # TODO: disable some of this bullshit
        intel2200BGFirmware
        rtl8192su-firmware
        rt5677-firmware
        rtl8761b-firmware
        rtw88-firmware
      ]);
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
