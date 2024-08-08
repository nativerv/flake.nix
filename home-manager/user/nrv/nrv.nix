# This is a home-manager configuration module (home.nix)
# Use this to configure your home environment (acts as legacy ~/.config/home-manager/home.nix)
{
  self,
  flake,
  inputs,
  ...
}:
{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
  ];

  # For some reason they separate some stuff under `home.*`
  home = {
    username = "nrv";
    homeDirectory = "/home/nrv";
    packages = with pkgs; [
      hello
      git-annex
    ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };

  xdg.enable = true;
  programs.zsh.enable = true;

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  #wayland.windowManager.hyprland.enable = true;
  #programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # FIXME: If first set to "nix/path" and then changed to "nix/path/nixpkgs",
  #        `home-manager switch` fails with error: ln: permission denied
  # NOTE: The following are not ideal way of doing channels anyway.
  #       See `nix.channels` for that below or wherever in this flake.
  #xdg.configFile."nix/channels/nixpkgs".source = pkgs.nixpkgs-flake;
  #nix.nixPath = [ "${config.xdg.configHome}/nix/channels" ];

  # Setup declarative user channels / access to <nixpkgs> in
  # legacy nix commands
  nix.package = pkgs.nixVersions.latest;
  #nix.settings = (pkgs.callPackage (import "${flake}/nixos/module/archetype/sane.nix" { inherit self flake inputs; }) {}).nix.settings;
  nix.settings = {
    use-xdg-base-directories = true;
  };
  nix.channels = {
    nixpkgs = pkgs.nixpkgs-flake;
  };

  # Source home manager session variables in ZSH config
  xdg.configFile."zsh/home-manager".source = pkgs.writeText "home-manager" ''
    # \'\' is multi-line string escape for... reasons
    . "''${XDG_STATE_HOME}/nix/profiles/home-manager/home-path/etc/profile.d/hm-session-vars.sh"
    # vim:ft=zsh
  '';

  # GPG
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-bemenu;
    # NOTE: (that's what i've thought:) Type password from tty instead of the
    #       GUI - useful for SSH
    enableZshIntegration = true;
    defaultCacheTtl = 60*60; 
    maxCacheTtl = 60*60*24; 
  };

  # Password store
  programs.password-store = {
    enable = true;
    package = (pkgs.pass.override {
      x11Support = false;
      waylandSupport = false;
      dmenuSupport = false;
    }).withExtensions (exts: with exts; [
      pass-otp
    ]);
    # package = (pkgs.pass.withExtensions (exts: with exts; [
    #   pass-otp
    # ])).override {
    #   x11Support = false;
    #   waylandSupport = false;
    #   dmenuSupport = false;
    # };
    settings.PASSWORD_STORE_DIR = "${config.xdg.dataHome}/pass";
  };
}
