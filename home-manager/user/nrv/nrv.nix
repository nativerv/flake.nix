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
    self.homeManagerModules.dream
    inputs.envrund.homeManagerModules.default
    inputs.ev.homeManagerModules.default
  ];

  services.envrund.enable = true;
  services.ev.enable = true;

  dream.archetype.sane.enable = true;

  dream.program = {
    ranger.enable = true;
    eww.enable = true;
    zsh.enable = true;
    tmux.enable = true;
    git.enable = true;
    plasma.enable = true;
    hyprland.enable = true;
    kitty.enable = true;
    neovim.enable = true;
    zathura.enable = true;
    firefox.enable = true;
    readline.enable = true;
    direnv.enable = true;
    gdb.enable = true;
  };

  # For some reason they separate some stuff under `home.*`
  home = {
    username = "${name}";
    homeDirectory = "/home/${name}";
    packages = with pkgs; let
      pass = config.programs.password-store.package;
    in [
      # for transcrypt
      transcrypt
      vim

      # the rest
      self.packages.${system}.telegram-desktop
      self.packages.${system}.ungoogled-chromium
      self.packages.${system}.mpv
      self.packages.${system}.vlc
      self.packages.${system}.zathura
      eza
      calc
      openssl # for something dk prob need to rm and see what happens
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
      playerctl
      libnotify
      lm_sensors
      fastfetch
      unzip
      zip
      chafa
      pulseaudio
      manix
      nix-search-cli
      inputs.scr.packages.${system}.default
      self.packages.${system}.scripts
      pcmanfm
      
      # from often-`nix run`/`nix shell`ed
      yt-dlp
      nvtopPackages.amd
      fd
      rlwrap
      zbar
      qrencode
      obs-studio
      lsof

      (self.packages.${system}.firefox.override {
        firefoxPackage = librewolf;
        name = "librewolf";
        appId = "net.librewolf.librewolf";
      })

      # overrides
      (pkgs.wrapPackages [ gnome-graphs ] {
        environment.GDK_DEBUG = "gl-prefer-gl"; # INFO: this one counters a segfault on startup for me.
      })
      (self.packages.${system}.gimp.override {
        package = pkgs.wrapPackages [ (pkgs.gimp-with-plugins.override {
          plugins = [ ];
        }) ] {
          flags = [ "--no-splash" ];
        };
      })
      (inputs.nixpkgs-24-05.legacyPackages.${system}.nerdfonts.override {
        fonts = [ "NerdFontsSymbolsOnly" ];
      })
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

  # Notification daemon
  services.dunst.enable = true;

  # XDG config
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
    mimeApps = {
      enable = true;
      defaultApplications = {

        # Files
        "application/x-shellscript" = [ "nvim.desktop" ];
        "text/x-shellscript" = [ "nvim.desktop" ];
        "text/plain" = [ "nvim.desktop" ];
        "inode/directory" = [ "pcmanfm.desktop" ];

        # Images
        "image/png" = [ "sxiv.desktop" ];
        "image/jpeg" = [ "sxiv.desktop" ];
        "image/gif" = [ "sxiv.desktop" ];
        "image/webp" = [ "sxiv.desktop" ];
        "image/x-xcf" = [ "gimp.desktop" ];

        # Videos
        "video/x-matroska" = [ "mpv.desktop" ];

        # # Application-specific
        # "application/postscript" = [ "pdf.desktop" ];
        # "application/pdf" = [ "pdf.desktop" ];
        # "application/rss+xml" = [ "rss.desktop" ];
        # "application/x-bittorrent" = [ "torrent.desktop" ];

        # Protocols
        "x-scheme-handler/http"  = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        # "x-scheme-handler/magnet" = [ "torrent.desktop" ];
        # "x-scheme-handler/mailto" = [ "mail.desktop" ];
        # "x-scheme-handler/lbry" = [ "lbry.desktop" ];
        # "x-scheme-handler/tg" = [ "telegram.desktop" ];

        # text/x-shellscript=text.desktop;
        # x-scheme-handler/magnet=torrent.desktop;
        # application/x-bittorrent=torrent.desktop;
        # x-scheme-handler/mailto=mail.desktop;
        # text/plain=text.desktop;
        # application/postscript=pdf.desktop;
        # application/pdf=pdf.desktop;
        # image/png=img.desktop;
        # image/jpeg=img.desktop;
        # image/gif=img.desktop;
        # image/webp=img.desktop;
        # application/rss+xml=rss.desktop;
        # video/x-matroska=video.desktop;
        # x-scheme-handler/lbry=lbry.desktop;
        # inode/directory=file.desktop;
        # text/html=chromium.desktop;
        # x-scheme-handler/http=chromium.desktop;
        # x-scheme-handler/https=chromium.desktop;
        # x-scheme-handler/about=chromium.desktop;
        # x-scheme-handler/unknown=chromium.desktop;
      };
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

  # From hyprland wiki - setup cursor theme
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;

    # Use breeze cursor as a compromise
    package = pkgs.kdePackages.breeze;
    name = "breeze_cursors";

    # Kind of resembles the vanilla Xorg cursor but worse quality?
    # package = pkgs.vanilla-dmz;
    # name = "DMZ-Black";

    # Better resembles Xorg one than above but i'm not sure
    # NOTE: sandboxed firefox with $XDG_STATE_HOME/nix/profile shared uses the
    # vanilla Xorg cursor!
    # package = pkgs.simp1e-cursors;
    # name = "Simp1e-Dark";

    size = 1080 / 48;
  };
  gtk = {
    enable = true;

    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.kdePackages.breeze-icons;
      name = "breeze";
    };

    font = {
      name = "Sans";
      size = 12;
    };
  };
}
