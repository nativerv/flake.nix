# Sane defaults module. Enables nix command, and makes your system use your
# flake inputs as both flake registries and legacy channels
{
  inputs ? null,
  ...
}:
{
  lib ? null,
  config ? null,
  ...
}:
{
  # Clean tmp just in case
  boot.tmp.cleanOnBoot = true;

  # Nix (the thing) config
  nix = {
    # This will add each flake input as a registry
    # and also pin 'nixpkgs' specifically to the unstable
    # channel, to make nix3 commands consistent with your flake
    registry =
      lib.mapAttrs (_: value: { flake = value; }) inputs
        # // { nixpkgs = { flake = inputs.nixpkgs-unstable; }; }
      ;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList
      (key: value: "${key}=${value.to.path}")
      config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";

      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };
}
