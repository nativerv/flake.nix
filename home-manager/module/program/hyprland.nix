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
  xdg.portal = {
    enable = false;

    # For NixOS FHS envs (and maybe will work for my sandboxes too? dunno, they
    # are 'flatpaks' anyway)
    xdgOpenUsePortal = true;

    # FIXME: trace: warning: xdg-desktop-portal 1.17 reworked how portal
    # implementations are loaded, you should either set `xdg.portal.config`
    # or `xdg.portal.configPackages` to specify which portal backend to use
    # for the requested interface.
    #
    # https://github.com/flatpak/xdg-desktop-portal/blob/1.18.1/doc/portals.conf.rst.in
    #
    # If you simply want to keep the behaviour in < 1.17, which uses the
    # first portal implementation found in lexicographical order, use the
    # following:
    config.common.default = "*";
    # You must include a portal impl here. Can't have multiple it seems...
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;

    # Sane shit
    systemd.enableXdgAutostart = false;

    # Import DISPLAY, HYPRLAND_INSTANCE_SIGNATURE, WAYLAND_DISPLAY,
    # XDG_CURRENT_DESKTOP to systemd
    systemd.enable = true;

    settings = lib.mkMerge [
      {
        env = [
          "QT_QPA_PLATFORM,wayland"
          "MOZ_ENABLE_WAYLAND,1"
          #"XDG_CURRENT_DESKTOP,Hyprland:wlroots:gnome"
          "XDG_SESSION_TYPE,wayland"
          "TERMCMD,$myTerminal"
          "TERMINAL,$myTerminal"
          "MENU,${pkgs.bemenu}/bin/bemenu"
          "LAUNCHER,${pkgs.bemenu}/bin/bemenu-run"
          "BEMENU_BACKEND,wayland"
        ];

        # The primary modifier key
        "$myMod" = "SUPER";

        # Terminal that i use on this compositor
        "$myTerminal" = "${pkgs.kitty}/bin/kitty";

        # Windowing layout
        "$myLayout" = "dwindle";
      }
      {
        bind = [
          # Launch terminal
          "$myMod SHIFT, return, exec, $myTerminal"

          # Launch an app
          "$myMod, p, exec, $LAUNCHER"

          # Close focused
          "$myMod, backspace, killactive,"

          # Float/Unfloat focused
          "$myMod, f, togglefloating"

          # Move focus with myMod + arrow keys
          "$myMod, h, movefocus, l"
          "$myMod, l, movefocus, r"
          "$myMod, k, movefocus, u"
          "$myMod, j, movefocus, d"

          # Cycle through windows with myMod + tab
          "$myMod, TAB, cyclenext,"
          "$myMod SHIFT, TAB, cyclenext, prev"
        ];
      }
      {
        # Change splitratio with myMod + shift + h/l
        binde = [
          "$myMod SHIFT, h, resizeactive, -15 0"
          "$myMod SHIFT, l, resizeactive, 15 0"
          "$myMod SHIFT, j, resizeactive, 0 15"
          "$myMod SHIFT, k, resizeactive, 0 -15"
        ];
      }
      {
        bind = [
          # Move windows with myMod + ctrl + hjkl
          "$myMod CTRL, h, movewindow, l"
          "$myMod CTRL, l, movewindow, r"
          "$myMod CTRL, k, movewindow, u"
          "$myMod CTRL, j, movewindow, d"

          # Switch workspaces with myMod + [0-9]
          "$myMod, 1, workspace, 1"
          "$myMod, 2, workspace, 2"
          "$myMod, 3, workspace, 3"
          "$myMod, 4, workspace, 4"
          "$myMod, 5, workspace, 5"
          "$myMod, 6, workspace, 6"
          "$myMod, 7, workspace, 7"
          "$myMod, 8, workspace, 8"
          "$myMod, 9, workspace, 9"
          "$myMod, 0, workspace, 10"

          # Move active window to a workspace with myMod + SHIFT + [0-9]
          "$myMod SHIFT, 1, movetoworkspacesilent, 1"
          "$myMod SHIFT, 2, movetoworkspacesilent, 2"
          "$myMod SHIFT, 3, movetoworkspacesilent, 3"
          "$myMod SHIFT, 4, movetoworkspacesilent, 4"
          "$myMod SHIFT, 5, movetoworkspacesilent, 5"
          "$myMod SHIFT, 6, movetoworkspacesilent, 6"
          "$myMod SHIFT, 7, movetoworkspacesilent, 7"
          "$myMod SHIFT, 8, movetoworkspacesilent, 8"
          "$myMod SHIFT, 9, movetoworkspacesilent, 9"
          "$myMod SHIFT, 0, movetoworkspacesilent, 10"
	];
      }

      {
        binde = [
          # Cycle through existing workspaces with myMod + scroll or i/o
          "$myMod, i, workspace, -1"
          "$myMod, o, workspace, +1"
        ];
      }

      {
        bindm = [
          # Move/resize windows with myMod + LMB/RMB and dragging
          "$myMod, mouse:272, movewindow"
          "$myMod, mouse:273, resizewindow"
        ];
      }

      {
        bind = [
          # General layout keys

          # Monocle view
          "$myMod, SPACE, fullscreen, 1"
          "$myMod SHIFT, SPACE, fullscreen, 0"

          # Contain fullscreen inside window - manual toggle
          "$myMod SHIFT, f, fakefullscreen,"

          # Dwindle layout keys

          # Pseudotile the window (respect it's floating size hints)
          "$myMod, BRACKETRIGHT, pseudo,           # dwindle"

          # Combine current window and it's siblings into a tabbed group
          "$myMod, t, togglegroup"
          # Tabbed group - switch tabs
          "$myMod SHIFT, i, changegroupactive, b"
          "$myMod SHIFT, o, changegroupactive, f"

          # Rotate split 90°
          "$myMod, BRACKETLEFT, togglesplit,"
          "$myMod, APOSTROPHE, pin"

          "SUPER, mouse_up, exec, zoom out"
          "SUPER, mouse_down, exec, zoom in"
          "SUPER, ESCAPE, exec, zoom 1.0"
        ];
      }
      {
        # Load wal colors if awailable
        #exec = "hyprctl keyword source ${config.xdg.cacheHome}/wal/hyprland.conf";
      }
    ];
  };
}
