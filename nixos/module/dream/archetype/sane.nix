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
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.archetype.sane;
in
{
  options.dream.archetype.sane = {
    enable = mkEnableOption "Enable archetype.sane";
  };
  config = mkIf cfg.enable {
    # NOTE: setting time zone here actually matters
    #       KDE spectale **segfaults** when this isn not set LUL
    time.timeZone = mkDefault "UTC";

    # Clean tmp just in case
    boot.tmp.cleanOnBoot = true;

    # By default NixOS has /tmp on disk because Nix needs a lot of space here.
    # This is bad because secrets usually go here not to mention the performance
    # hit. This sets up a cache dir specifically for Nix instead
    # Credit: https://lantian.pub/en/article/modify-computer/nixos-impermanence.lantian/
    # TODO: is it cleaned between reboots?
    systemd.services.nix-daemon = {
      # Location for temporary files
      environment.TMPDIR = "/var/cache/nix";
      # Create /var/cache/nix automatically on Nix Daemon start
      serviceConfig.CacheDirectory = "nix";
    };
    # However, this option does not apply to the root user. This is caused by the
    # nix command handling the build request itself under root user, rather than
    # passing it to the Nix Daemon. Therefore, we need to add an environment
    # variable NIX_REMOTE=daemon, to force the nix command to call the daemon:
    environment.variables.NIX_REMOTE = "daemon";

    # Symlink /etc/nixos to this flake.
    # NOTE: maybe not *that* sane? Let's see if this spits errors or overwrites the stateful/handwritten config or whatever.
    # WARNING: This was causing some (possibly critical) errors during initial
    #          disko-impermanence setup... ditch for now.
    # system.activationScripts.symlinkFlakeToEtcNixos.text = /* bash */ ''
    #   rmdir '/etc/nixos' || true
    #   ln -s ${flake} '/etc/nixos' || true
    # '';

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

        # Lock down nix to sudoers
        allowed-users = [ "@wheel" ];
      };
    };
  };
}
