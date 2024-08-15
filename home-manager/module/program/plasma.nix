{
  self,
  flake,
  inputs,
  ...
}:
{
  pkgs,
  lib,
  config,
  ...
}:
with self.lib;
with lib;
let
in {
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];
  # See the source code of plasma-manager, the ~/.config/k* files as you change
  # stuff in the settings, and `nix run .#plasma-manager.rc2nix` to understand
  # how did i get any of the shit below in here (apart of what came from the
  # example)
  # WARNING: I'm almost certain this shit will break on Plasma updates.
  #          Can't really blame them as this is all private state and not an
  #          API... but oh well. See git blame for this line and grab a nixpkgs
  #          rev that works i guess.
  #          ...I can however blame the author of plasma-manager module for
  #          it's unintuitiveness. Enable options? Never heard of them. However
  #          it's nice that there's warnings/assertions for the unintuitive
  #          parts at least.
  programs.plasma = {
    enable = true;
    configFile = {
      # Disable the stupid file index (they didn't invent `locatedb` in Plasma
      # devs' timeline)
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;

      # Always Translucent - instead of switching back and forth when adapting
      # WARNING: why is this called 'Panel 2' out of the box in clean Plasma?
      plasmashellrc."PlasmaViews/Panel 2".panelOpacity = 2;

      # Input languages
      plasmarc.OSD.kbdLayoutChangedEnabled = false;
      kxkbrc.Layout = fromJSONIfUnlockedOr (
        warn "Repo is not unlocked! Plasma will use EN layout only" {
	  DisplayNames = "en";
          LayoutList = "us";
	  Use = true;
	}
      ) "${flake}/sus/nrv/eval/plasma/kxkbrc-layout.json";
    };

    # Screen locking manager
    kscreenlocker = {
      autoLock = true;

      # Sane default
      lockOnResume = true;

      # Leave 30s to press any key before it actually locks
      passwordRequiredDelay = 30;

      # AFK minutes to lock screen
      timeout = 10;
    };

    # Display on/off, Sleep, Hibernation and Shutdown manager
    powerdevil = {
      AC = {
        powerButtonAction = "showLogoutScreen";
        autoSuspend = {
          action = "nothing";
	  # Seconds
          #idleTimeout = 60*30;
        };
        turnOffDisplay = {
          idleTimeout = 60*9;
          #idleTimeoutWhenLocked = "immediately";
        };
      };
      # TODO: battery (steal from plasma-manager examples or history of this
      #       file)
    };

    # Shortcuts: Custom actions (commands)
    hotkeys.commands = {
      "launch-terminal" = {
        name = "Open a terminal";
        key = "Meta+Shift+Return";
        command = "kitty";
      };
      # "launch-bemenu" = {
      #   name = "Open bemenu";
      #   key = "Meta+P";
      #   command = "bemenu-run";
      # };
    };

    # Shortcuts: Builtin actions
    # The low level differs from this helper option in that the key are
    # duplicated twice in it
    shortcuts = {
      "KDE Keyboard Layout Switcher" = {
	# Just because
        "Switch to Last-Used Keyboard Layout" = "";
	# Cycle active input layout
        "Switch to Next Keyboard Layout" = "Meta+`";
      };
      "kwin" = {
	# Unbind Alt-` so my tmux prefix works (fuck the non-Meta binds that
	# steal application bindings)
        "Walk Through Windows of Current Application" = "";
	# Let's go full ZOOM with this: all-in-one launcher, window search etc.
	# instead of the usual dmenu-like lanucher
        "Overview" = "Meta+P";
      };
    };

    workspace = {
      # Dark theme
      lookAndFeel = "org.kde.breezedark.desktop";
      # Set to 'open' for the click-to-open default from Plasma 5
      clickItemTo = "select";
      # You can click 'Open Containing Folder' in the wallpaper settings to get
      # paths for the default ones
      wallpaper = "${pkgs.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images_dark/5120x2880.png";
    };
  };
}
