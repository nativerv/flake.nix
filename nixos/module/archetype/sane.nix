# Sane defaults module.
# Does independent stuff that you would want on any system.
{
  inputs ? null,
  flake ? null,
  self ? null,
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

  # Symlink /etc/nixos to this flake.
  # NOTE: maybe not *that* sane? Let's see if this spits errors or overwrites the stateful/handwritten config or whatever.
  system.activationScripts.symlinkFlakeToEtcNixos.text = /* bash */ ''
    rmdir '/etc/nixos' || true
    ln -s ${flake} '/etc/nixos'
  '';

  # Nix (the thing) config
  nix = {
    # This will add each flake input as a registry
    # and also pin 'nixpkgs' specifically to the unstable
    # channel, to make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs
      // { dream.flake = self; };

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList
      (key: value: "${key}=${value.to.path}")
      config.nix.registry;

    # Disable channels - no reason for them when using flakes.
    channel.enable = false;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";

      # Enbale sandboxing builds (this is enabled by default but just in case)
      sandbox = true;

      # Deduplicate and optimize nix store
      auto-optimise-store = true;

      # Don't shit in user's HOME
      use-xdg-base-directories = true;

      # WARNING: Setting this on `true` sometimes causes: `error: cached failure of attribute 'legacyPackages.x86_64-linux'`
      # NOTE: Docs: Whether to use the flake evaluation cache (in ~/.cache/nix)
      eval-cache = true;
    };
  };
}
