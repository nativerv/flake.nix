{ pkgs, mkNixPak, ... }: let
  name = "nixpak-test";
  appId = "org.myself.${name}";
  package = pkgs.buildEnv {
    inherit name;
    paths = with pkgs; [
      coreutils
      glib
      util-linux
      bash
      xdg-utils
      grim
      chafa
      (writeShellScriptBin "${name}" ''
        exec ${pkgs.bash}/bin/bash
      '')
    ];
    buildInputs = [ pkgs.bash ];
  };

  sandboxed = mkNixPak {
    config = { sloth, ... }: {

      # the application to isolate

      app.package = package;

      # path to the executable to be wrapped
      # this is usually autodetected but
      # can be set explicitly nonetheless
      app.binPath = "bin/${name}";

      # enabled by default, flip to disable
      # and to remove dependency on xdg-dbus-proxy
      dbus.enable = true;

      # same usage as --see, --talk, --own
      dbus.policies = {
        #"org.freedesktop.DBus" = "talk";
        #"ca.desrt.dconf" = "talk";
        "org.freedesktop.portal.Desktop" = "talk";

        # allow sending notifications
        "org.freedesktop.Notifications" = "talk";
      };

      # needs to be set for Flatpak emulation
      # defaults to com.nixpak.${name}
      # where ${name} is generated from the drv name like:
      # hello -> Hello
      # my-app -> MyApp
      flatpak.appId = appId;

      gpu.enable = false;

      waylandProxy.enable = true;

      bubblewrap = {
        env.PATH = "${package}/bin";

        # Bind only paths that app needs
        bindEntireStore = true;

        # disable all network access
        network = false;

        sockets = {
          wayland = true;
          pulse = true;
          pipewire = true;
        };

        # lists of paths to be mounted inside the sandbox
        # supports runtime resolution of environment variables
        # see "Sloth values" below
        bind.rw = with sloth; [
          ## bind src to dest
          [ (mkdir (concat [xdgStateHome "/sandboxes/${name}/home"])) homeDir ]
          [ (mkdir "/tmp/sandboxes/${name}") "/tmp" ]
          ## bind when src is dest
          #"/path/to/dir"
        ];
        bind.ro = [ ];
        bind.dev = [
          #"/dev/dri"
        ];
      };
    };
  };
in
  # Just the wrapped /bin/${mainProgram} binary
  #sandboxed.config.script;

  # A symlinkJoin that resembles the original package,
  # except the main binary is swapped for the
  # wrapper script, as are textual references
  # to the binary, like in D-Bus service files.
  # Useful for GUI apps.
  sandboxed.config.env
