{ pkgs, lib, mkNixPak, ... }:

# FIXME: Nixpak'ed GTK2 (or X11?) apps (GIMP 2.x).

# Assert that we're on GIMP 2, as this profile is hardcoded for GIMP 2/GTK2 only.
assert !lib.versionAtLeast pkgs.gimp.version "2.11";

let
  name = "gimp";
  appId = "org.gimp.GIMP";

  sandboxed = mkNixPak {
    config = { sloth, ... }: {

      # the application to isolate
      app.package = pkgs.gimp-with-plugins.override {
        plugins = [
          #pkgs.gimpPlugins.resynthesizer
        ];
      };

      # path to the executable to be wrapped
      # this is usually autodetected but
      # can be set explicitly nonetheless
      app.binPath = "bin/${name}";
      app.extraEntrypoints = [
        "/bin/gimp-2.10"
        "/bin/gimp-console"
        "/bin/gimp-console-2.10"
        "/bin/gimp-test-clipboard-2.0"
        "/bin/gimptool-2.0"

        # These cause collision errors
        # "/bin/.gimp-2.10-wrapped"
        # "/bin/.gimp-2.10-wrapped_"
        # "/bin/.gimp-console-2.10-wrapped"
      ];

      # enabled by default, flip to disable
      # and to remove dependency on xdg-dbus-proxy
      dbus.enable = true;

      # same usage as xdg-dbus-proxy(1) --see, --talk, --own
      dbus.policies = {
        # gtk's app configuration framework. gimp is gtk, so
        #"ca.desrt.dconf" = "see";

        # gimp-owned
        "${appId}" = "own";
        "${appId}.*" = "own";

        # allow whatever the hell. maybe this allows all of them, maybe this allows usage of any of them whatsoever
        # TODO: granual portal permissions, don't allow every portal
        "org.freedesktop.portal.Desktop" = "talk";

        # allow sending notifications
        "org.freedesktop.Notifications" = "talk";

        # allow opening directories and pointing at files to the user with native file manager
        "org.freedesktop.FileManager1" = "talk";

        # some gnome stuff - commented out for now, not sure about it
        # gvfs package was on my arch machine only because of Nautilus
        # which i installed once and never even used. so probably useless for me
        #"org.gtk.vfs.*" = "talk";

        # allow GIMP to do screenshots. not sure about interactivity/permissions so commented out.
        #"org.gnome.Shell.Screenshot" = "talk";
        #"org.kde.kwin.Screenshot" = "talk";
      };

      # TODO: find a way for this to work (granular portals access).
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

      etc.sslCertificates.enable = false;
      fonts.enable = true;
      locale.enable = true;

      bubblewrap = {
        # Bind only paths that app needs
        bindEntireStore = true;

        # disable all network access
        network = false;

        sockets = {
          x11 = true;
        };

        # lists of paths to be mounted inside the sandbox
        # supports runtime resolution of environment variables
        # see "Sloth values" below
        bind.rw = with sloth; [
          [ (mkdir (concat [xdgStateHome "/sandbox/${name}/home"])) homeDir ]
          [ (mkdir "/tmp/sandbox/${name}") "/tmp" ]
          [ (concat [runtimeDir "/doc/by-app/${appId}"]) (concat [runtimeDir "/doc"]) ]

          (concat [xdgConfigHome "gtk-2.0"])
          (concat [xdgConfigHome "gtk-3.0"])
          (concat [xdgConfigHome "GIMP"])

          xdgDocumentsDir
          xdgPicturesDir

          # kerberos auth stuff. use it if you need it
          #/run/.heim_org.h5l.kcm-socket
        ];
        bind.ro = with sloth; [ ];
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
