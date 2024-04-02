{ pkgs, mkNixPak, ... }: let
  name = "firefox";
  appId = "org.mozilla.firefox";

  sandboxed = mkNixPak {
    config = { sloth, ... }: {

      # the application to isolate
      app.package = pkgs.firefox;

      # path to the executable to be wrapped
      # this is usually autodetected but
      # can be set explicitly nonetheless
      app.binPath = "bin/${name}";

      # enabled by default, flip to disable
      # and to remove dependency on xdg-dbus-proxy
      dbus.enable = true;

      # same usage as --see, --talk, --own
      dbus.policies = {
        # core dbus interface - ask dbus daemon stuff.
        #"org.freedesktop.DBus" = "talk";

        # gtk's app configuration framework. firefox is gtk, so
        "ca.desrt.dconf" = "see";

        # firefox stuff
        "org.mozilla.Firefox.*" = "own";
        "org.mozilla.firefox.*" = "own";

        # allow whatever the hell. maybe this allows all of them, maybe this allows usage of any of them whatsoever
        # TODO: granual portal permissions, don't allow every portal
        "org.freedesktop.portal.Desktop" = "talk";

        # allow sending notifications
        "org.freedesktop.Notifications" = "talk";

        # allow inhibiting screensavers
        "org.freedesktop.ScreenSaver" = "talk";

        # allow sharing screen
        # (included in the org.freedeskto.portal.Desktop?)
        #"org.freedesktop.portal.ScreenCast" = "talk";

        # file chooser: save, open. only provides paths as usual
        # (included in the org.freedeskto.portal.Desktop?)
        #"org.freedesktop.portal.FileChooser" = "talk";

        # actually passes files on demand to the sandbox. wires with FileChooser somehow (using dark magic)
        # (included in the org.freedeskto.portal.Desktop?)
        # TODO: research how exactly the access is granted (can it request any access? the access is provided by FileChooser?).
        #"org.freedesktop.portal.Documents" = "talk";
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

      # needs to be set for Flatpak emulation
      # defaults to com.nixpak.${name}
      # where ${name} is generated from the drv name like:
      # hello -> Hello
      # my-app -> MyApp
      flatpak.appId = appId;

      gpu.enable = true;

      etc.sslCertificates.enable = true;
      fonts.enable = true;

      bubblewrap = {
        # Bind only paths that app needs
        bindEntireStore = false;

        # disable all network access
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
          [ (mkdir (concat [xdgStateHome "/sandboxes/${name}/home"])) homeDir ]
          [ (mkdir "/tmp/sandboxes/${name}") "/tmp" ]
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
