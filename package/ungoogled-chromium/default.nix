{ pkgs, mkNixPak, ... }: let
  name = "ungoogled-chromium";
  appId = "org.chromium.Chromium";

  sandboxed = mkNixPak {
    config = { sloth, ... }: {

      # the application to isolate
      app.package = pkgs.${name};

      # path to the executable to be wrapped
      # this is usually autodetected but
      # can be set explicitly nonetheless
      app.binPath = "bin/chromium";

      # enabled by default, flip to disable
      # and to remove dependency on xdg-dbus-proxy
      dbus.enable = true;

      # same usage as xdg-dbus-proxy(1) --see, --talk, --own
      dbus.policies = {
        # TODO: figure these out when system bus is implemented
        #  - --system-talk-name=org.bluez
        #  - --system-talk-name=org.freedesktop.Avahi
        #  - --system-talk-name=org.freedesktop.UPower

        # gtk's app configuration framework. chromium is gtk, so
        # disallow for now.
        #"ca.desrt.dconf" = "see";

        # chromium stuff - don't give access. i want chromiums totally isolated
        #"org.chromium.Chromium" = "own";
        #"org.chromium.Chromium.*" = "own";
        "org.mpris.MediaPlayer2.chromium.*" = "own";


        # allow access to all the desktop portals (screenshare, save/open files, etc.).
        "org.freedesktop.portal.Desktop" = "talk";

        # allow sending notifications
        "org.freedesktop.Notifications" = "talk";

        # allow inhibiting screensavers
        "org.freedesktop.ScreenSaver" = "talk";

        # sounds sus - enable if you need it.
        #"org.freedesktop.secrets" = "talk";
        #"org.kde.kwalletd5" = "talk";
        #"com.canonical.AppMenu.Registrar" = "talk";
        #"org.gnome.SessionManager" = "talk";

        # allow opening directories and pointing at files to the user with native file manager
        "org.freedesktop.FileManager1" = "talk";
      };

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
          # TODO: cups (printers)
        };

        # lists of paths to be mounted inside the sandbox
        # supports runtime resolution of environment variables
        # see "Sloth values" below
        bind.rw = with sloth; [
          [ (mkdir (concat [xdgStateHome "/sandbox/${name}/home"])) homeDir ]
          [ (mkdir "/tmp/sandbox/${name}") "/tmp" ]
          [ (concat [runtimeDir "/doc/by-app/${appId}"]) (concat [runtimeDir "/doc"]) ]

          # kerberos auth stuff. use it if you need it
          #/run/.heim_org.h5l.kcm-socket
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
