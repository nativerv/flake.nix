{ pkgs, lib, mkNixPak, ... }:

let
  name = "vlc";
  appId = "org.videolan.VLC";

  sandboxed = mkNixPak {
    config = { sloth, ... }: {

      # the application to isolate
      app.package = pkgs.${name};

      # path to the executable to be wrapped
      # this is usually autodetected but
      # can be set explicitly nonetheless
      app.binPath = "bin/${name}";
      app.extraEntrypoints = [
        "/bin/cvlc"
        "/bin/nvlc"
        "/bin/qvlc"
        "/bin/rvlc"
        "/bin/svlc"
        "/bin/vlc-wrapper"
      ];

      # enabled by default, flip to disable
      # and to remove dependency on xdg-dbus-proxy
      dbus.enable = true;

      # same usage as xdg-dbus-proxy(1) --see, --talk, --own
      dbus.policies = {
        # gtk's app configuration framework. vlc is qt so idk
        #"ca.desrt.dconf" = "talk";

        # vlc-owned
        "${appId}" = "own";
        "${appId}.*" = "own";
        "org.mpris.MediaPlayer2.vlc" = "own";

        # allow vlc to control other players. enable if you need it
        #"org.mpris.MediaPlayer2.Player" = "talk":

        # allow whatever the hell. maybe this allows all of them, maybe this allows usage of any of them whatsoever
        # TODO: granual portal permissions, don't allow every portal
        "org.freedesktop.portal.Desktop" = "talk";

        # allow sending notifications
        "org.freedesktop.Notifications" = "talk";
      };

      # flatpak id: for Flatpak emulation and the portals (documents, etc) to work
      flatpak.appId = appId;

      gpu.enable = true;

      etc.sslCertificates.enable = true;
      locale.enable = true;
      fonts.enable = true;

      bubblewrap = {
        # Bind only paths that app needs
        bindEntireStore = true;

        # network access
        network = true;

        sockets = {
          wayland = true;
          pipewire = true;
          pulse = true;
        };

        # lists of paths to be mounted inside the sandbox
        # supports runtime resolution of environment variables
        # see "Sloth values" below
        bind.rw = with sloth; [
          [ (mkdir (concat [xdgStateHome "/sandbox/${name}/home"])) homeDir ]
          [ (mkdir "/tmp/sandbox/${name}") "/tmp" ]
          [ (concat [runtimeDir "/doc/by-app/${appId}"]) (concat [runtimeDir "/doc"]) ]
        ];
        bind.ro = with sloth; [
          # FIXME: make arguments automatically document-portaled. This probably requires Nixpak launcher changes
          (concat [xdgConfigHome "${name}"])
          (concat [xdgDataHome "${name}"])
          xdgVideosDir
          "/srv/media/movies"
          #"/etc"
          #"/run/current-system"
        ];
        bind.dev = [
          "/dev/dri"
        ];
      };
    };
  };
in 
  # Just the wrapped /bin/${mainProgram} binary
  #sandboxed.config.script

  # A symlinkJoin that resembles the original package,
  # except the main binary is swapped for the
  # wrapper script, as are textual references
  # to the binary, like in D-Bus service files.
  # Useful for GUI apps.
  sandboxed.config.env
