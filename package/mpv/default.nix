{ pkgs, lib, mkNixPak, ... }:

let
  name = "mpv";
  appId = "io.mpv.Mpv";

  sandboxed = mkNixPak {
    config = { sloth, ... }: {

      # the application to isolate
      app.package = pkgs.${name};

      # path to the executable to be wrapped
      # this is usually autodetected but
      # can be set explicitly nonetheless
      app.binPath = "bin/${name}";
      app.extraEntrypoints = [
      ];

      # enabled by default, flip to disable
      # and to remove dependency on xdg-dbus-proxy
      dbus.enable = true;

      # same usage as xdg-dbus-proxy(1) --see, --talk, --own
      dbus.policies = {
        # mpv-owned
        "${appId}" = "own";
        "${appId}.*" = "own";
        "org.mpris.MediaPlayer2.mpv.*" = "own";

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
        bindEntireStore = true; # mpv won't start without this (at least in VM)

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
          [ (mkdir (concat [runtimeDir "/sandbox/${name}"])) "/tmp" ]
          [ (concat [runtimeDir "/doc/by-app/${appId}"]) (concat [runtimeDir "/doc"]) ]
          (concat [xdgStateHome "${name}"])
        ];
        bind.ro = with sloth; [
          # FIXME: make arguments automatically document-portaled. This probably requires Nixpak launcher changes
          (concat [xdgConfigHome "${name}"])
          xdgPicturesDir
          xdgVideosDir
          "/srv/media/movies"
          "/srv/media/shows"
          "/srv/media/audiobooks"
          "/srv/media/podcasts"
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
