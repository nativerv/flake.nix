# This is a home-manager configuration module (home.nix)
# Use this to configure your home environment (acts as legacy ~/.config/home-manager/home.nix)
{
  self,
  flake,
  inputs,
  ...
}:
{
  lib ? null,
  config ? null,
  pkgs ? null,
  ...
}: let
  name = builtins.baseNameOf ./.;
in {
  imports = [
    self.homeManagerModules."program.zsh"
    self.homeManagerModules."program.tmux"
    self.homeManagerModules."program.git"
    self.homeManagerModules."program.plasma"
    self.homeManagerModules."program.hyprland"
    self.homeManagerModules."program.kitty"
    self.homeManagerModules."program.neovim"
    self.homeManagerModules."program.zathura"
    self.homeManagerModules."program.firefox"
    self.homeManagerModules."program.readline"
    inputs.envrund.homeManagerModules.default
  ];

  services.envrund.enable = true;

  # For some reason they separate some stuff under `home.*`
  home = {
    username = "${name}";
    homeDirectory = "/home/${name}";
    packages = with pkgs; let
      pass = config.programs.password-store.package;
    in [
      git-annex
      delta
      pulsemixer
      inputs.tmux-sessionizer.packages.${system}.default
      wl-clipboard
      jq
      ripgrep
      sxiv
      inputs.clip.packages.${system}.default
      self.packages.${system}.hotkey-scripts
      inputs.tl.packages.${system}.default
      (pkgs.wrapPackages [ pkgs.restic ] {
        environment = {
          RESTIC_PASSWORD_COMMAND = "${pass}/bin/pass show ${self.config.backups.restic.key.sk.pass-path or "dummy"}";
          RESTIC_COMPRESSION = "max";
          RCLONE_PASSWORD_COMMAND="${pass}/bin/pass show ${self.config.backups.rclone.key.adamantia.pass-path or "dummy"}";
        };
      })
      (pkgs.wrapPackages [ pkgs.rclone ] {
        environment = {
          RCLONE_PASSWORD_COMMAND="${pass}/bin/pass show ${self.config.backups.rclone.key.adamantia.pass-path or "dummy"}";
        };
      })
    ];

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };

  xdg = let
    homeDir = "${config.home.homeDirectory}";
  in {
    enable = true;
    userDirs = {
      enable = true;
      pictures = "${homeDir}/pix";
      videos = "${homeDir}/vid";
      music = "${homeDir}/mus";
      documents = "${homeDir}/vid";
      download = "${homeDir}/dl";
      desktop = "${homeDir}/desk";
      publicShare = "${homeDir}/pub";
      templates = "${config.xdg.dataHome}/templates";
    };
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;

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
  #xdg.configFile."zsh/home-manager".source = pkgs.writeText "home-manager" ''
  #  # \'\' is multi-line string escape for... reasons
  #  . "''${XDG_STATE_HOME}/nix/profiles/home-manager/home-path/etc/profile.d/hm-session-vars.sh"
  #  # vim:ft=zsh
  #'';

  # Terminal

  # GPG
  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
  # Cache passpharses for some time
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-bemenu;
    # NOTE: (that's what i've thought:) Type password from tty instead of the
    #       GUI - useful for SSH
    enableZshIntegration = true;
    defaultCacheTtl = 60*60;
    maxCacheTtl = 60*60*24;
  };

  # SSH agent - cache passphrases for some time
  services.ssh-agent.enable = true;

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
