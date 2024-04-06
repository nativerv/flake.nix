{ pkgs, mkNixPak, ... }: let
  name = "telegram-desktop";
  appId = "org.telegram.desktop";

  sandboxed = mkNixPak {
    config = { sloth, ... }: {

      # the application to isolate
      app.package = pkgs.${name};

      # path to the executable to be wrapped
      # this is usually autodetected but
      # can be set explicitly nonetheless
      app.binPath = "bin/${name}";

      # enabled by default, flip to disable
      # and to remove dependency on xdg-dbus-proxy
      dbus.enable = true;

      # same usage as xdg-dbus-proxy(1) --see, --talk, --own
      dbus.policies = {
        # gtk's app configuration framework. telegram is qt so idk
        #"ca.desrt.dconf" = "see";

        # telegram-desktop stuff
        "org.telegram.desktop" = "own";
        "org.telegram.desktop.*" = "own";

        # don't read messages when afk (i think)
        "org.gnome.Mutter.IdleMonitor" = "talk";
        "org.kde.StatusNotifierWatcher" = "talk";

        # some stuff. probably tray
        #"com.canonical.AppMenu.Registrar" = "talk";
        #"com.canonical.indicator.application" = "talk";
        #"org.ayatana.indicator.application" = "talk";

        # allow whatever the hell. maybe this allows all of them, maybe this allows usage of any of them whatsoever
        # TODO: granual portal permissions, don't allow every portal
        "org.freedesktop.portal.Desktop" = "talk";

        # allow sending notifications
        "org.freedesktop.Notifications" = "talk";

        # allow inhibiting screensavers
        "org.freedesktop.ScreenSaver" = "talk";
      };

      # TODO: find a way for this to work.
      # Example: --call=org.freedesktop.portal.*=* --broadcast=org.freedesktop.portal.*=@/org/freedesktop/portal/*
      #dbus.rules.call = {
      #  "org.freedesktop.portal.ScreenCast.*" = [ "*" ];
      #  "org.freedesktop.Notifications" = [ "*" ];
      #};
      #dbus.rules.broadcast = {
      #  "org.freedesktop.portal.ScreenCast.*" = [ "@/*" ];
      #  "org.freedesktop.Notifications" = [ "@/*" ];
      #};

      # flatpak id: for Flatpak emulation and the portals (documents, etc) to work
      flatpak.appId = appId;

      gpu.enable = true;

      etc.sslCertificates.enable = true;
      fonts.enable = true;

      bubblewrap = {
        # Bind only paths that app needs
        bindEntireStore = false;

        # network access
        network = true;

        sockets = {
          wayland = true;
          pulse = true;
          pipewire = true;
        };

        # lists of paths to be mounted inside the sandbox
        # supports runtime resolution of environment variables
        # see "Sloth values" below
        bind.rw = with sloth; [
          [ (mkdir (concat [xdgStateHome "/sandbox/${name}/home"])) homeDir ]
          [ (mkdir "/tmp/sandbox/${name}") "/tmp" ]
          [ (concat [runtimeDir "/doc/by-app/${appId}"]) (concat [runtimeDir "/doc"]) ]
        ];
        bind.ro = [ ];
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
