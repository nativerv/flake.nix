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

      # The default Plasma screenshot utility config
      # This actually applies updates after rebuild without Plasma restart lul
      spectaclerc = {
        "General" = {
          autoSaveImage = true;
          clipboardGroup = "PostScreenshotCopyImage";
          launchAction = "TakeScreenshot";
          rememberSelectionRect = "Always";
        };
        "GuiConfig" = {
          includePointer = true;
        };
        "ImageSave" = {
          translatedScreenshotsFolder = "scr";
        };
        "VideoSave" = {
          translatedScreencastsFolder = "scr";
        };
      };

      # Make the Overview menu and Krunner usable (does wrong things when you
      # type fast by default)
      krunnerrc."Plugins/Favorites"."plugins" = "krunner_services,krunner_systemsettings";
      krunnerrc."Plugins" = {
        "baloosearchEnabled" = false;
        "calculatorEnabled" = true;
        "helprunnerEnabled" = false;
        "krunner_appstreamEnabled" = false;
        "krunner_bookmarksrunnerEnabled" = false;
        "krunner_charrunnerEnabled" = false;
        "krunner_dictionaryEnabled" = false;
        "krunner_katesessionsEnabled" = false;
        "krunner_konsoleprofilesEnabled" = false;
        "krunner_placesrunnerEnabled" = false;
        "krunner_powerdevilEnabled" = false;
        "krunner_recentdocumentsEnabled" = false;
        "krunner_sessionsEnabled" = false;
        "krunner_spellcheckEnabled" = false;
        "krunner_systemsettingsEnabled" = false;
        "krunner_webshortcutsEnabled" = false;
        "locationsEnabled" = false;
        "org.kde.activities2Enabled" = false;
        "org.kde.datetimeEnabled" = false;
        "unitconverterEnabled" = true;
      };

      kwinrc."Desktops"."Number" = {
        value = 3;
        # Forces kde to not change this value (even through the settings app).
	# FIXME: does not work though, can still change them (should i not?)
	#        and no mention of immutability in the config file (should
	#        there be?)
        immutable = true;
      };
    };

    # Screen locking manager
    # Hide screen at 00:09:00 and lock it at 00:09:30
    kscreenlocker = {
      autoLock = true;

      # Sane default
      lockOnResume = true;

      # Leave 30s to press any key before it actually locks
      passwordRequiredDelay = 30;

      # AFK minutes to lock screen
      timeout = 9;
    };

    # Display on/off, Sleep, Hibernation and Shutdown manager
    # Immediately turn off display at 00:09:30
    powerdevil = {
      AC = {
        powerButtonAction = "showLogoutScreen";
        autoSuspend = {
          action = "nothing";
        };
        turnOffDisplay = {
          idleTimeout = 60*9+30;
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
	# Disable this - don't bother me, but just because
        "Switch to Last-Used Keyboard Layout" = "";
	# Cycle active input layout
        "Switch to Next Keyboard Layout" = "Meta+`";
      };
      "plasmashell" = {
        # Unbind Meta
        "activate application launcher" = "Meta+F1";
      };
      "kwin" = mkMerge [
        {
          # Unbind Alt-` so my tmux prefix works (fuck the non-Meta binds that
          # steal application bindings)
          "Walk Through Windows of Current Application" = "";
          # Let's go full ZOOM with this: all-in-one launcher, window search etc.
          # instead of the usual dmenu-like lanucher
          "Overview" = [ "Meta+W" "Meta+P" ];

          "Window Maximize" = "Meta+Space";
        }

        # Workspace/Virtual desktop cycling
        (pipe (range 1 9) [
          (map (n: nameValuePair "Switch to Desktop ${toString n}" "Meta+${toString n}"))
          listToAttrs
        ])
        {
          "Switch to Next Desktop" = "Meta+O";
          "Switch to Previous Desktop" = "Meta+I";
        }

        # Move Window to Desktop N
	{
          "Window to Desktop 1" = "Meta+!";
          "Window to Desktop 2" = "Meta+@";
          "Window to Desktop 3" = "Meta+#";
          "Window to Desktop 4" = "Meta+$";
          "Window to Desktop 5" = "Meta+%";
          "Window to Desktop 6" = "Meta+^";
          "Window to Desktop 7" = "Meta+&";
          "Window to Desktop 8" = "Meta+*";
          "Window to Desktop 9" = "Meta+(";
        }
      ];
    };

    workspace = {
      # Dark theme
      lookAndFeel = "org.kde.breezedark.desktop";
      # Set to 'open' for the click-to-open default from Plasma 5
      clickItemTo = "select";
      # You can click 'Open Containing Folder' in the wallpaper settings to get
      # paths for the default ones
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images_dark/5120x2880.png";
    };
    kscreenlocker.appearance.wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images_dark/5120x2880.png";
  };
}
