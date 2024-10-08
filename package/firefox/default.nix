{
  pkgs,
  mkNixPak,
  inputs,

  nativeMessagingHosts ? [ ],
  ...
}: let
  name = "firefox";
  appId = "org.mozilla.firefox";

  package = pkgs.firefox-bin.override {
    inherit nativeMessagingHosts;
  };

  sandboxed = mkNixPak {
    config = { sloth, ... }: {

      # the application to isolate
      app.package = package;

      # NOTE: Swap with this comment to test stuff:

      # app.package = pkgs.symlinkJoin {
      #   inherit name;
      #   paths = [ (pkgs.writeShellScriptBin "${name}" ''
      #     # ${pkgs.coreutils}/bin/ls -la ~
      #     # ${pkgs.coreutils}/bin/ls -la ~/pr
      #     # ${pkgs.coreutils}/bin/ls -la /home/nrv/pr/pipewire-screenaudio/native/connector-rs/target/debug
      #     # ${pkgs.coreutils}/bin/cat ~/pr/pipewire-screenaudio/native/native-messaging-hosts/firefox.json
      #     # ${pkgs.coreutils}/bin/cat /usr/lib/mozilla/native-messaging-hosts/com.icedborn.pipewirescreenaudioconnector.json
      #     # echo
      #     # echo Current system
      #     # ${pkgs.findutils}/bin/find -L /run/current-system/sw/lib/mozilla
      #     # echo
      #     # ${pkgs.findutils}/bin/find -L / -maxdepth 2
      #
      #     ${pkgs.coreutils}/bin/ls -la /usr/share/icons/breeze_cursors
      #     ${pkgs.file}/bin/file /usr/share/icons/breeze_cursors/cursors/default
      #     ${pkgs.file}/bin/file ~/.icons/breeze_cursors/cursors/default
      #
      #     echo
      #     # ${pkgs.findutils}/bin/find -L /usr
      #
      #     echo XCURSOR_THEME=$XCURSOR_THEME
      #     echo XCURSOR_PATH=
      #     echo $XCURSOR_PATH | tr ':' '\n'
      #
      #     ${pkgs.file}/bin/file ~/.config/gtk-3.0/settings.ini
      #
      #     echo XDG_STATE_HOME=$XDG_STATE_HOME
      #     echo XDG_CONFIG_HOME=$XDG_CONFIG_HOME
      #
      #     ${package}/bin/${name} ''${@}
      #   '') package ];
      # };

      # path to the executable to be wrapped
      # this is usually autodetected but
      # can be set explicitly nonetheless
      app.binPath = "bin/${name}";

      # enabled by default, flip to disable
      # and to remove dependency on xdg-dbus-proxy
      dbus.enable = true;

      # same usage as xdg-dbus-proxy(1) --see, --talk, --own
      dbus.policies = {
        # gtk's app configuration framework. firefox is gtk, so
        #"ca.desrt.dconf" = "see";

        # firefox-owned
        "org.mozilla.Firefox.*" = "own";
        "org.mozilla.firefox.*" = "own";
        #"org.mozilla.firefox_beta.*" = "own";
        # media player remote interfacing
        "org.mpris.MediaPlayer2.firefox.*" = "own";

        # allow whatever the hell. maybe this allows all of them, maybe this allows usage of any of them whatsoever
        # TODO: granual portal permissions, don't allow every portal
        "org.freedesktop.portal.Desktop" = "talk";

        # allow sending notifications
        "org.freedesktop.Notifications" = "talk";

        # allow inhibiting screensavers
        "org.freedesktop.ScreenSaver" = "talk";

        # allow opening directories and pointing at files to the user with native file manager
        "org.freedesktop.FileManager1" = "talk";

        # accessibility bus - don't know/can't find what it allows so commented out
        #"org.a11y.Bus" = "talk";

        # some gnome stuff - commented out for now, same as org.a11y.Bus ^
        # gvfs package was on my arch machine only because of Nautilus
        # which i installed once and never even used. so probably useless for me
        #"org.gtk.vfs.*" = "talk";
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

      etc.sslCertificates.enable = true;
      fonts.enable = true;

      bubblewrap = {
        # Bind only paths that app needs
        bindEntireStore = true;

        # network access
        network = true;

        sockets = {
          wayland = true;
          pulse = true;
          pipewire = true;
          # TODO: pcsc (smart cards)
          # TODO: cups (printers)
        };

        # lists of paths to be mounted inside the sandbox
        # supports runtime resolution of environment variables
        # see "Sloth values" below
        bind.rw = with sloth; [
          [ (mkdir (concat [xdgStateHome "/sandbox/${name}/home"])) homeDir ]
          [ (mkdir (concat [runtimeDir "/sandbox/${name}"])) "/tmp" ]
          [ (concat [runtimeDir "/doc/by-app/${appId}"]) (concat [runtimeDir "/doc"]) ]

          # kerberos auth stuff. use it if you need it
          #/run/.heim_org.h5l.kcm-socket
        ];
        bind.ro = with sloth; [
          (concat [runtimeDir "speech-dispatcher"]) # TODO: move that to Nixpak

          # NOTE: The following is required for native-messaging-hosts to work,
          # at least `pipewire-screenaudio`.
          # TODO: restrict this further up to `bindEntireStore = false`
          # XXX: Maybe just remove this line?
          "/run/current-system/sw"
          [ "${package}/lib/mozilla" "/usr/lib/mozilla" ]
          [ "/run/current-system/sw/share/icons" "/usr/share/icons" ]

          # Themes/Theming/Icons/Cursors
          (concat [homeDir "/.icons"])
          (concat [xdgDataHome "/icons"])
          (concat [xdgConfigHome "/gtk-3.0"])
          (concat [xdgConfigHome "/gtk-4.0"])
          (concat [xdgConfigHome "/dconf"])
          # (concat [xdgStateHome "/nix/profile"])
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
