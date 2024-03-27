{ pkgs, nixpak, ... }: let
  mkNixPak = nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };
  name = "bash-nixpak";

  sandboxed = mkNixPak {
    config = { sloth, ... }: {

      # the application to isolate
      app.package = pkgs.writeShellScriptBin "${name}" ''exec ${pkgs.bash}/bin/bash'';

      # path to the executable to be wrapped
      # this is usually autodetected but
      # can be set explicitly nonetheless
      app.binPath = "bin/${name}";

      # enabled by default, flip to disable
      # and to remove dependency on xdg-dbus-proxy
      dbus.enable = true;

      # same usage as --see, --talk, --own
      dbus.policies = {
        "org.freedesktop.DBus" = "talk";
        "ca.desrt.dconf" = "talk";
      };

      # needs to be set for Flatpak emulation
      # defaults to com.nixpak.${name}
      # where ${name} is generated from the drv name like:
      # hello -> Hello
      # my-app -> MyApp
      flatpak.appId = "org.myself.BashApp";

      gpu.enable = false;

      bubblewrap = {
        # Bind only paths that app needs
        bindEntireStore = true;

        # disable all network access
        network = false;

        # lists of paths to be mounted inside the sandbox
        # supports runtime resolution of environment variables
        # see "Sloth values" below
        bind.rw = [
          #(sloth.concat' sloth.homeDir "/Documents")
          #(sloth.env "XDG_RUNTIME_DIR")
          ## a nested list represents a src -> dest mapping
          ## where src != dest
          #[
          #  (sloth.concat' sloth.homeDir "/.local/state/nixpak/${name}/config")
          #  (sloth.concat' sloth.homeDir "/.config")
          #]
        ];
        bind.ro = [
          #(sloth.concat' sloth.homeDir "/Downloads")
        ];
        bind.dev = [
          #"/dev/dri"
        ];
      };
    };
  };
in {
  # Just the wrapped /bin/${mainProgram} binary
  "${name}" = sandboxed.config.script;

  # A symlinkJoin that resembles the original package,
  # except the main binary is swapped for the
  # wrapper script, as are textual references
  # to the binary, like in D-Bus service files.
  # Useful for GUI apps.
  "${name}-env" = sandboxed.config.env;
}
