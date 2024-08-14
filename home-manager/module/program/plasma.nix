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
      # WARNING: why is this called Panel 2 out of the box in clean Plasma?
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
      # TODO: battery
      # battery = {
      #   powerButtonAction = "sleep";
      #   whenSleepingEnter = "standbyThenHibernate";
      # };
      # lowBattery = {
      #   whenLaptopLidClosed = "hibernate";
      # };
    };

    # Shortcuts: Custom actions (commands)
    hotkeys.commands = {
      "launch-terminal" = {
        name = "Open a terminal";
        key = "Meta+Shift+Return";
        command = "kitty";
      };
      "launch-bemenu" = {
        name = "Open bemenu";
        key = "Meta+P";
        command = "bemenu-run";
      };
    };

    # Shortcuts: Builtin actions
    # The low level differs from this helper option in that the key are
    # duplicated twice in it
    shortcuts = {
      "KDE Keyboard Layout Switcher" = {
        "Switch to Last-Used Keyboard Layout" = "";
        "Switch to Next Keyboard Layout" = "Meta+`";
      };
      "kwin" = {
        "Walk Through Windows of Current Application" = "";
	# wut i thought this works
	# "Switch to Next Keyboard Layout" = "Meta+`";
      };
    };

    workspace = {
      # Dark theme
      lookAndFeel = "org.kde.breezedark.desktop";

      # Set to 'open' for the click-to-open default from Plasma 5
      clickItemTo = "select"; 

      # # Too big imo, default is fine
      # cursor = {
      #   theme = "Bibata-Modern-Ice";
      #   size = 32;
      # };
      # # This makes the icons dark-on-dark
      #iconTheme = "Papirus-Dark";
      #wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
    };
    # The panel config refused to work. Don't need it anyway ¯\_(ツ)_/¯
    # panels = [
    #   # Windows-like panel at the bottom
    #   {
    #     location = "bottom";
    #     widgets = [
    #       # We can configure the widgets by adding the name and config
    #       # attributes. For example to add the the kickoff widget and set the
    #       # icon to "nix-snowflake-white" use the below configuration. This will
    #       # add the "icon" key to the "General" group for the widget in
    #       # ~/.config/plasma-org.kde.plasma.desktop-appletsrc.
    #       {
    #         name = "org.kde.plasma.kickoff";
    #         config = {
    #           General = {
    #             icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
    #             alphaSort = true;
    #           };
    #         };
    #       }
    #       # Or you can configure the widgets by adding the widget-specific options for it.
    #       # See modules/widgets for supported widgets and options for these widgets.
    #       # For example:
    #       # {
    #       #   kickoff = {
    #       #     sortAlphabetically = true;
    #       #     icon = "nix-snowflake-white";
    #       #   };
    #       # }
    #       # Adding configuration to the widgets can also for example be used to
    #       # pin apps to the task-manager, which this example illustrates by
    #       # pinning dolphin and konsole to the task-manager by default with widget-specific options.
    #       {
    #         iconTasks = {
    #           launchers = [
    #             "applications:org.kde.dolphin.desktop"
    #             "applications:org.kde.konsole.desktop"
    #           ];
    #         };
    #       }
    #       # Or you can do it manually, for example:
    #       {
    #         name = "org.kde.plasma.icontasks";
    #         config = {
    #           General = {
    #             launchers = [
    #               "applications:org.kde.dolphin.desktop"
    #               "applications:org.kde.konsole.desktop"
    #             ];
    #           };
    #         };
    #       }
    #       # If no configuration is needed, specifying only the name of the
    #       # widget will add them with the default configuration.
    #       "org.kde.plasma.marginsseparator"
    #       # If you need configuration for your widget, instead of specifying the
    #       # the keys and values directly using the config attribute as shown
    #       # above, plasma-manager also provides some higher-level interfaces for
    #       # configuring the widgets. See modules/widgets for supported widgets
    #       # and options for these widgets. The widgets below shows two examples
    #       # of usage, one where we add a digital clock, setting 12h time and
    #       # first day of the week to Sunday and another adding a systray with
    #       # some modifications in which entries to show.
    #       {
    #         digitalClock = {
    #           calendar.firstDayOfWeek = "monday";
    #           time.format = "24h";
    #         };
    #       }
    #       # {
    #       #   systemTray = {};
    #       # }
    #       # {
    #       #   systemTray.items = {
    #       #     # We explicitly show bluetooth and battery
    #       #     shown = [
    #       #       "org.kde.plasma.battery"
    #       #       "org.kde.plasma.bluetooth"
    #       #     ];
    #       #     # And explicitly hide networkmanagement and volume
    #       #     hidden = [
    #       #       "org.kde.plasma.networkmanagement"
    #       #       "org.kde.plasma.volume"
    #       #     ];
    #       #   };
    #       # }
    #     ];
    #     #hiding = "autohide";
    #   }
    # ];
  };
}
