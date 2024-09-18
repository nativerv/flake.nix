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

    # X programs compatibility
    xwayland.enable = true;

    # Sane shit
    systemd.enableXdgAutostart = false;

    # Import DISPLAY, HYPRLAND_INSTANCE_SIGNATURE, WAYLAND_DISPLAY,
    # XDG_CURRENT_DESKTOP to systemd
    systemd = {
      enable = true;
      variables = [
        "WAYLAND_DISPLAY"
        "DISPLAY"
        "HYPRLAND_INSTANCE_SIGNATURE"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
        "MENU"
        "BEMENU_BACKEND"
        "QT_QPA_PLATFORM"
        "TERMINAL"
        "TERMCMD"
      ];
    };

    settings = lib.mkMerge [
      {
        monitor = [
          "HDMI-A-2, 1920x1080@71.91, 0x0, 1"
        ];
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

          # NOTE: fixes: nixpak: XAUTHORITY not set
          "XAUTHORITY,/dev/null"
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
          "$myMod SHIFT, f, fullscreenstate, -1 1,"

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
      {
        # For all categories and variables, see https://wiki.hyprland.org/Configuring/Variables/

        #exec = hyprctl keyword source ${XDG_CONFIG_HOME}/hypr/hyprland-animations.conf

        # Source this in vim and run :call HyprDefault() after selecting the
        # pasted lines and indenting them
        # function! HyprDefault() range
        #   silent! execute a:firstline . "," . a:lastline . 's/\v^(\s+)([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)/\1"\2" = "\5"; # [\4] [\5] \3'
        #   silent! execute a:firstline . "," . a:lastline . 's/\V[[Empty]]//gi'
        #   silent! execute a:firstline . "," . a:lastline . 's/\v(\s+".+" \= ")\[(.+)\]";(.*)\[\[(\S+,\s?\S+)\]\](.*)$/\1\2";\3[\4]\5'
        # endfunction
        # command! -range HyprDefault :call <range>HyprDefault()

        # Source this in vim and run :call HyprDefault() after selecting the
        # pasted lines and indenting them
        # function! HyprDefault() range
        #   silent! execute a:firstline . "," . a:lastline . 's/\v^(\s+)([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)/\1"\2" = "\5"; # [\4] [\5] \3'
        #   silent! execute a:firstline . "," . a:lastline . 's/\V[[Empty]]//g'
        #   silent! execute a:firstline . "," . a:lastline . 's/\v(\s+".+" \= ")\[(.+)\]";(.*)\[\[(\S+,\s?\S+)\]\](.*)$/\1\2";\3[\4]\5'
        #   silent! execute a:firstline . "," . a:lastline . 's/\v^(\s*)(.*\[\[Auto]].*)/\1#\2'
        # TODO: unset commenting
        # endfunction
        # command! -range HyprDefault :call <range>HyprDefault()

        general = {
          "sensitivity" = "1.0"; # [float] [1.0] mouse sensitivity (legacy, may cause bugs if not 1, prefer input:sensitivity)
          "border_size" = "1"; # [int] [1] size of the border around windows
          "no_border_on_floating" = "false"; # [bool] [false] disable borders for floating windows
          "gaps_in" = "5"; # [int] [5] gaps between windows, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)
          "gaps_out" = "10"; # [int] [20] gaps between windows and monitor edges, also supports css style gaps (top, right, bottom, left -> 5,10,15,20)
          "gaps_workspaces" = "0"; # [int] [0] gaps between workspaces. Stacks with gaps_out.
          "col.inactive_border" = "0x59595933"; # [gradient] [0xff444444] border color for inactive windows
          "col.active_border" = "0xffffffff"; # [gradient] [0xffffffff] border color for the active window
          "col.nogroup_border" = "0xffffaaff"; # [gradient] [0xffffaaff] inactive border color for window that cannot be added to a group (see denywindowfromgroup dispatcher)
          "col.nogroup_border_active" = "0xffff00ff"; # [gradient] [0xffff00ff] active border color for window that cannot be added to a group
          "layout" = "$myLayout"; # [str] [dwindle] which layout to use. [dwindle/master]
          "no_focus_fallback" = "false"; # [bool] [false] if true, will not fall back to the next available window when moving focus in a direction where no window was found
          "apply_sens_to_raw" = "false"; # [bool] [false] if on, will also apply the sensitivity to raw mouse output (e.g. sensitivity in games) NOTICE: really not recommended.
          "resize_on_border" = "false"; # [bool] [false] enables resizing windows by clicking and dragging on borders and gaps
          "extend_border_grab_area" = "15"; # [int] [15] extends the area around the border where you can click and drag on, only used when general:resize_on_border is on.
          "hover_icon_on_border" = "true"; # [bool] [true] show a cursor icon when hovering over borders, only used when general:resize_on_border is on.
          "allow_tearing" = "false"; # [bool] [false] master switch for allowing tearing to occur. See the Tearing page.
          "resize_corner" = "0"; # [int] [0] force floating windows to use a specific corner when being resized (1-4 going clockwise from top left, 0 to disable)
        };

        decoration = {
          "rounding" = "0"; # [int] [0] rounded corners’ radius (in layout px)
          "active_opacity" = "1.0"; # [float] [1.0] opacity of active windows. [0.0 - 1.0]
          "inactive_opacity" = "1.0"; # [float] [1.0] opacity of inactive windows. [0.0 - 1.0]
          "fullscreen_opacity" = "1.0"; # [float] [1.0] opacity of fullscreen windows. [0.0 - 1.0]
          "drop_shadow" = "true"; # [bool] [true] enable drop shadows on windows
          "shadow_range" = "4"; # [int] [4] Shadow range (“size”) in layout px
          "shadow_render_power" = "3"; # [int] [3] in what power to render the falloff (more power, the faster the falloff) [1 - 4]
          "shadow_ignore_window" = "true"; # [bool] [true] if true, the shadow will not be rendered behind the window itself, only around it.
          "col.shadow" = "0x1a1a1aee"; # [color] [0xee1a1a1a] shadow’s color. Alpha dictates shadow’s opacity.
          #"col.shadow_inactive" = "unset"; # [color] [unset] inactive shadow color. (if not set, will fall back to col.shadow)
          "shadow_offset" = "0, 0"; # [vec2] [0, 0] shadow’s rendering offset.
          "shadow_scale" = "1.0"; # [float] [1.0] shadow’s scale. [0.0 - 1.0]
          "dim_inactive" = "false"; # [bool] [false] enables dimming of inactive windows
          "dim_strength" = "0.5"; # [float] [0.5] how much inactive windows should be dimmed [0.0 - 1.0]
          "dim_special" = "0.2"; # [float] [0.2] how much to dim the rest of the screen by when a special workspace is open. [0.0 - 1.0]
          "dim_around" = "0.4"; # [float] [0.4] how much the dimaround window rule should dim by. [0.0 - 1.0]
          "screen_shader" = ""; # [str] [] a path to a custom shader to be applied at the end of rendering. See examples/screenShader.frag for an example.
          blur = {
            "enabled" = "false"; # [bool] [true] enable kawase window background blur
            "size" = "8"; # [int] [8] blur size (distance)
            "passes" = "1"; # [int] [1] the amount of passes to perform
            "ignore_opacity" = "false"; # [bool] [false] make the blur layer ignore the opacity of the window
            "new_optimizations" = "true"; # [bool] [true] whether to enable further optimizations to the blur. Recommended to leave on, as it will massively improve performance.
            "xray" = "false"; # [bool] [false] if enabled, floating windows will ignore tiled windows in their blur. Only available if blur_new_optimizations is true. Will reduce overhead on floating blur significantly.
            "noise" = "0.0117"; # [float] [0.0117] how much noise to apply. [0.0 - 1.0]
            "contrast" = "0.8916"; # [float] [0.8916] contrast modulation for blur. [0.0 - 2.0]
            "brightness" = "0.8172"; # [float] [0.8172] brightness modulation for blur. [0.0 - 2.0]
            "vibrancy" = "0.1696"; # [float] [0.1696] Increase saturation of blurred colors. [0.0 - 1.0]
            "vibrancy_darkness" = "0.0"; # [float] [0.0] How strong the effect of vibrancy is on dark areas . [0.0 - 1.0]
            "special" = "false"; # [bool] [false] whether to blur behind the special workspace (note: expensive)
            "popups" = "false"; # [bool] [false] whether to blur popups (e.g. right-click menus)
            "popups_ignorealpha" = "0.2"; # [float] [0.2] works like ignorealpha in layer rules. If pixel opacity is below set value, will not blur. [0.0 - 1.0]
          };
        };
        animations = {
          enabled = false;
        };
        input = {
          "kb_model" = ""; # [str] [] Appropriate XKB keymap parameter. See the note below.
          "kb_layout" = fromJSONIfUnlockedOr (
             warn "Repo is not unlocked! Hyprland will use EN layout only"
             "us"
           ) "${flake}/sus/nrv/eval/hyprland/kb_layout.json"; # [str] [us] Appropriate XKB keymap parameter
          "kb_variant" = ""; # [str] [] Appropriate XKB keymap parameter
          "kb_options" = "caps:escape,grp:switch"; # [str] [] Appropriate XKB keymap parameter
          "kb_rules" = ""; # [str] [] Appropriate XKB keymap parameter
          "kb_file" = ""; # [str] [] If you prefer, you can use a path to your custom .xkb file.
          "numlock_by_default" = "false"; # [bool] [false] Engage numlock by default.
          "resolve_binds_by_sym" = "false"; # [bool] [false] Determines how keybinds act when multiple layouts are used. If false, keybinds will always act as if the first specified layout is active. If true, keybinds specified by symbols are activated when you type the respective symbol with the current layout.
          "repeat_rate" = "35"; # [int] [25] The repeat rate for held-down keys, in repeats per second.
          "repeat_delay" = "400"; # [int] [600] Delay before a held-down key is repeated, in milliseconds.
          "sensitivity" = "0.0"; # [float] [0.0] Sets the mouse input sensitivity. Value is clamped to the range -1.0 to 1.0. libinput#pointer-acceleration
          "accel_profile" = ""; # [str] [] Sets the cursor acceleration profile. Can be one of adaptive, flat. Can also be custom, see below. Leave empty to use libinput’s default mode for your input device. libinput#pointer-acceleration [adaptive/flat/custom]
          "force_no_accel" = "false"; # [bool] [false] Force no cursor acceleration. This bypasses most of your pointer settings to get as raw of a signal as possible. Enabling this is not recommended due to potential cursor desynchronization.
          "left_handed" = "false"; # [bool] [false] Switches RMB and LMB
          "scroll_points" = ""; # [str] [] Sets the scroll acceleration profile, when accel_profile is set to custom. Has to be in the form <step> <points>. Leave empty to have a flat scroll curve.
          "scroll_method" = ""; # [str] [] Sets the scroll method. Can be one of 2fg (2 fingers), edge, on_button_down, no_scroll. libinput#scrolling [2fg/edge/on_button_down/no_scroll]
          "scroll_button" = "0"; # [int] [0] Sets the scroll button. Has to be an int, cannot be a string. Check wev if you have any doubts regarding the ID. 0 means default.
          "scroll_button_lock" = "0"; # [bool] [0] If the scroll button lock is enabled, the button does not need to be held down. Pressing and releasing the button toggles the button lock, which logically holds the button down or releases it. While the button is logically held down, motion events are converted to scroll events.
          "scroll_factor" = "1.0"; # [float] [1.0] Multiplier added to scroll movement for external mice. Note that there is a separate setting for touchpad scroll_factor.
          "natural_scroll" = "false"; # [bool] [false] Inverts scrolling direction. When enabled, scrolling moves content directly, rather than manipulating a scrollbar.
          "follow_mouse" = "1"; # [int] [1] Specify if and how cursor movement should affect window focus. See the note below. [0/1/2/3]
          # FIXME: reenable on 0.42
          #"focus_on_close" = "0"; # [int] [0] Controls the window focus behavior when a window is closed. When set to 0, focus will shift to the next window candidate. When set to 1, focus will shift to the window under the cursor. [0/1]
          "mouse_refocus" = "true"; # [bool] [true] If disabled, mouse focus won’t switch to the hovered window unless the mouse crosses a window boundary when follow_mouse=1.
          "float_switch_override_focus" = "1"; # [int] [1] If enabled (1 or 2), focus will change to the window under the cursor when changing from tiled-to-floating and vice versa. If 2, focus will also follow mouse on float-to-float switches.
          "special_fallthrough" = "false"; # [bool] [false] if enabled, having only floating windows in the special workspace will not block focusing windows in the regular workspace.
          "off_window_axis_events" = "1"; # [int] [1] Handles axis events around (gaps/border for tiled, dragarea/border for floated) a focused window. 0 ignores axis events 1 sends out-of-bound coordinates 2 fakes pointer coordinates to the closest point inside the window 3 warps the cursor to the closest point inside the window
          #"emulate_discrete_scroll" = "1"; # [int] [1] Emulates discrete scrolling from high resolution scrolling events. 0 disables it, 1 enables handling of non-standard events only, and 2 force enables all scroll wheel events to be handled
          touchpad = {
            "disable_while_typing" = "true"; # [bool] [true] Disable the touchpad while typing.
            "natural_scroll" = "false"; # [bool] [false] Inverts scrolling direction. When enabled, scrolling moves content directly, rather than manipulating a scrollbar.
            "scroll_factor" = "1.0"; # [float] [1.0] Multiplier applied to the amount of scroll movement.
            "middle_button_emulation" = "false"; # [bool] [false] Sending LMB and RMB simultaneously will be interpreted as a middle click. This disables any touchpad area that would normally send a middle click based on location. libinput#middle-button-emulation
            "tap_button_map" = ""; # [str] [] Sets the tap button mapping for touchpad button emulation. Can be one of lrm (default) or lmr (Left, Middle, Right Buttons). [lrm/lmr]
            "clickfinger_behavior" = "false"; # [bool] [false] Button presses with 1, 2, or 3 fingers will be mapped to LMB, RMB, and MMB respectively. This disables interpretation of clicks based on location on the touchpad. libinput#clickfinger-behavior
            "tap-to-click" = "true"; # [bool] [true] Tapping on the touchpad with 1, 2, or 3 fingers will send LMB, RMB, and MMB respectively.
            "drag_lock" = "false"; # [bool] [false] When enabled, lifting the finger off for a short time while dragging will not drop the dragged item. libinput#tap-and-drag
            "tap-and-drag" = "false"; # [bool] [false] Sets the tap and drag mode for the touchpad
          };
          touchdevice = {
            "transform" = "0"; # [int] [0] Transform the input from touchdevices. The possible transformations are the same as those of the monitors
            #"output" = "[[Auto]]"; # [string] [[[Auto]]] The monitor to bind touch devices. The default is auto-detection. To stop auto-detection, use an empty string or the “” value.
            "enabled" = "true"; # [bool] [true] Whether input is enabled for touch devices.
          };
          tablet = {
            "transform" = "0"; # [int] [0] transform the input from tablets. The possible transformations are the same as those of the monitors
            "output" = ""; # [string] [] the monitor to bind tablets. Empty means unbound.
            "region_position" = "0, 0"; # [vec2] [0, 0] position of the mapped region in monitor layout.
            "region_size" = "0, 0"; # [vec2] [0, 0] size of the mapped region. When this variable is set, tablet input will be mapped to the region. [0, 0] or invalid size means unset.
            "relative_input" = "false"; # [bool] [false] whether the input should be relative
            "left_handed" = "false"; # [bool] [false] if enabled, the tablet will be rotated 180 degrees
            "active_area_size" = "0, 0"; # [vec2] [0, 0] size of tablet’s active area in mm
            "active_area_position" = "0, 0"; # [vec2] [0, 0] position of the active area in mm
          };
        };
        group = {
          "insert_after_current" = "true"; # [bool] [true] whether new windows in a group spawn after current or at group tail
          "focus_removed_window" = "true"; # [bool] [true] whether Hyprland should focus on the window that has just been moved out of the group
          "col.border_active" = "0x66ffff00"; # [gradient] [0x66ffff00] active group border color
          "col.border_inactive" = "0x66777700"; # [gradient] [0x66777700] inactive (out of focus) group border color
          "col.border_locked_active" = "0x66ff5500"; # [gradient] [0x66ff5500] active locked group border color
          "col.border_locked_inactive" = "0x66775500"; # [gradient] [0x66775500] inactive locked group border color
          groupbar = {
            "enabled" = "true"; # [bool] [true] enables groupbars
            "font_family" = ""; # [string] [] font used to display groupbar titles, use misc:font_family if not specified
            "font_size" = "8"; # [int] [8] font size of groupbar title
            "gradients" = "true"; # [bool] [true] enables gradients
            "height" = "14"; # [int] [14] height of the groupbar
            "stacked" = "false"; # [bool] [false] render the groupbar as a vertical stack
            "priority" = "3"; # [int] [3] sets the decoration priority for groupbars
            "render_titles" = "true"; # [bool] [true] whether to render titles in the group bar decoration
            "scrolling" = "true"; # [bool] [true] whether scrolling in the groupbar changes group active window
            "text_color" = "0xffffffff"; # [color] [0xffffffff] controls the group bar text color
            "col.active" = "0x66ffff00"; # [gradient] [0x66ffff00] active group border color
            "col.inactive" = "0x66777700"; # [gradient] [0x66777700] inactive (out of focus) group border color
            "col.locked_active" = "0x66ff5500"; # [gradient] [0x66ff5500] active locked group border color
            "col.locked_inactive" = "0x66775500"; # [gradient] [0x66775500] inactive locked group border color
          };
        };
        misc = {
          "disable_hyprland_logo" = "true"; # [bool] [false] disables the random Hyprland logo / anime girl background. :(
          "disable_splash_rendering" = "true"; # [bool] [false] disables the Hyprland splash rendering. (requires a monitor reload to take effect)
          "col.splash" = "0xffffffff"; # [color] [0xffffffff] Changes the color of the splash text (requires a monitor reload to take effect).
          "font_family" = "monospace"; # [string] [Sans] Set the global default font to render the text including debug fps/notification, config error messages and etc., selected from system fonts.
          "splash_font_family" = ""; # [string] [] Changes the font used to render the splash text, selected from system fonts (requires a monitor reload to take effect).
          "force_default_wallpaper" = "2"; # [int] [-1] Enforce any of the 3 default wallpapers. Setting this to 0 or 1 disables the anime background. -1 means “random”. [-1/0/1/2]
          "vfr" = "true"; # [bool] [true] controls the VFR status of Hyprland. Heavily recommended to leave enabled to conserve resources.
          "vrr" = "1"; # [int] [0] controls the VRR (Adaptive Sync) of your monitors. 0 - off, 1 - on, 2 - fullscreen only [0/1/2]
          "mouse_move_enables_dpms" = "true"; # [bool] [false] If DPMS is set to off, wake up the monitors if the mouse moves.
          "key_press_enables_dpms" = "true"; # [bool] [false] If DPMS is set to off, wake up the monitors if a key is pressed.
          "always_follow_on_dnd" = "true"; # [bool] [true] Will make mouse focus follow the mouse when drag and dropping. Recommended to leave it enabled, especially for people using focus follows mouse at 0.
          "layers_hog_keyboard_focus" = "true"; # [bool] [true] If true, will make keyboard-interactive layers keep their focus on mouse move (e.g. wofi, bemenu)
          "animate_manual_resizes" = "false"; # [bool] [false] If true, will animate manual window resizes/moves
          "animate_mouse_windowdragging" = "false"; # [bool] [false] If true, will animate windows being dragged by mouse, note that this can cause weird behavior on some curves
          "disable_autoreload" = "false"; # [bool] [false] If true, the config will not reload automatically on save, and instead needs to be reloaded with hyprctl reload. Might save on battery.
          "enable_swallow" = "true"; # [bool] [false] Enable window swallowing
          "swallow_regex" = "^(footclient|foot|kitty|Alacritty)$"; # [str] [] The class regex to be used for windows that should be swallowed (usually, a terminal). To know more about the list of regex which can be used use this cheatsheet.
          "swallow_exception_regex" = ''(^wev$|\[DEBUG\])''; # [str] [] The title regex to be used for windows that should not be swallowed by the windows specified in swallow_regex (e.g. wev). The regex is matched against the parent (e.g. Kitty) window’s title on the assumption that it changes to whatever process it’s running.
          "focus_on_activate" = "false"; # [bool] [false] Whether Hyprland should focus an app that requests to be focused (an activate request)
          "mouse_move_focuses_monitor" = "true"; # [bool] [true] Whether mouse moving into a different monitor should focus it
          "render_ahead_of_time" = "false"; # [bool] [false] [Warning: buggy] starts rendering before your monitor displays a frame in order to lower latency
          "render_ahead_safezone" = "1"; # [int] [1] how many ms of safezone to add to rendering ahead of time. Recommended 1-2.
          "allow_session_lock_restore" = "false"; # [bool] [false] if true, will allow you to restart a lockscreen app in case it crashes (red screen of death)
          # TODO: colors
          "background_color" = "0x111111"; # [color] [0x111111] change the background color. (requires enabled disable_hyprland_logo)
          "close_special_on_empty" = "true"; # [bool] [true] close the special workspace if the last window is removed
          "new_window_takes_over_fullscreen" = "1"; # [int] [0] if there is a fullscreen or maximized window, decide whether a new tiled window opened should replace it, stay behind or disable the fullscreen/maximized state. 0 - behind, 1 - takes over, 2 - unfullscreen/unmaxize [0/1/2]
          # FIXME: reenable on 0.42
          "exit_window_retains_fullscreen" = "false"; # [bool] [false] if true, closing a fullscreen window makes the next focused window fullscreen
          "initial_workspace_tracking" = "1"; # [int] [1] if enabled, windows will open on the workspace they were invoked on. 0 - disabled, 1 - single-shot, 2 - persistent (all children too)
          "middle_click_paste" = "true"; # [bool] [true] whether to enable middle-click-paste (aka primary selection)
        };
        binds = {
          "pass_mouse_when_bound" = "false"; # [bool] [false] if disabled, will not pass the mouse events to apps / dragging windows around if a keybind has been triggered.
          "scroll_event_delay" = "1"; # [int] [300] in ms, how many ms to wait after a scroll event to allow passing another one for the binds.
          "workspace_back_and_forth" = "false"; # [bool] [false] If enabled, an attempt to switch to the currently focused workspace will instead switch to the previous workspace. Akin to i3’s auto_back_and_forth.
          "allow_workspace_cycles" = "false"; # [bool] [false] If enabled, workspaces don’t forget their previous workspace, so cycles can be created by switching to the first workspace in a sequence, then endlessly going to the previous workspace.
          "workspace_center_on" = "1"; # [int] [0] Whether switching workspaces should center the cursor on the workspace (0) or on the last active window for that workspace (1)
          "focus_preferred_method" = "0"; # [int] [0] sets the preferred focus finding method when using focuswindow/movewindow/etc with a direction. 0 - history (recent have priority), 1 - length (longer shared edges have priority)
          "ignore_group_lock" = "false"; # [bool] [false] If enabled, dispatchers like moveintogroup, moveoutofgroup and movewindoworgroup will ignore lock per group.
          "movefocus_cycles_fullscreen" = "true"; # [bool] [true] If enabled, when on a fullscreen window, movefocus will cycle fullscreen, if not, it will move the focus in a direction.
          "disable_keybind_grabbing" = "false"; # [bool] [false] If enabled, apps that request keybinds to be disabled (e.g. VMs) will not be able to do so.
          "window_direction_monitor_fallback" = "true"; # [bool] [true] If enabled, moving a window or focus over the edge of a monitor with a direction will move it to the next monitor in that direction.
        };
        xwayland = {
          "use_nearest_neighbor" = "true"; # [bool] [true] uses the nearest neighbor filtering for xwayland apps, making them pixelated rather than blurry
          "force_zero_scaling" = "false"; # [bool] [false] forces a scale of 1 on xwayland windows on scaled displays.
        };
        opengl = {
          "nvidia_anti_flicker" = "true"; # [bool] [true] reduces flickering on nvidia at the cost of possible frame drops on lower-end GPUs. On non-nvidia, this is ignored.
          "force_introspection" = "2"; # [int] [2] forces introspection at all times. Introspection is aimed at reducing GPU usage in certain cases, but might cause graphical glitches on nvidia. 0 - nothing, 1 - force always on, 2 - force always on if nvidia
        };
        render = {
          "explicit_sync" = "2"; # [int] [2] Whether to enable explicit sync support. Requires a hyprland restart. 0 - no, 1 - yes, 2 - auto based on the gpu driver
          "explicit_sync_kms" = "2"; # [int] [2] Whether to enable explicit sync support for the KMS layer. Requires explicit_sync to be enabled. 0 - no, 1 - yes, 2 - auto based on the gpu driver
          "direct_scanout" = "true"; # [bool] [false] Enables direct scanout. Direct scanout attempts to reduce lag when there is only one fullscreen application on a screen (e.g. game). It is also recommended to set this to false if the fullscreen application shows graphical glitches.
        };
        cursor = {
          # FIXME: reenable on 0.42
          #"sync_gsettings_theme" = "true"; # [bool] [true] sync xcursor theme with gsettings, it applies cursor-theme and cursor-size on theme load to gsettings making most CSD gtk based clients use same xcursor theme and size.
          "no_hardware_cursors" = "false"; # [bool] [false] disables hardware cursors
          "no_break_fs_vrr" = "true"; # [bool] [false] disables scheduling new frames on cursor movement for fullscreen apps with VRR enabled to avoid framerate spikes (requires no_hardware_cursors = true)
          "min_refresh_rate" = "24"; # [int] [24] minimum refresh rate for cursor movement when no_break_fs_vrr is active. Set to minimum supported refresh rate or higher
          "hotspot_padding" = "0"; # [int] [1] the padding, in logical px, between screen edges and the cursor
          "inactive_timeout" = "0"; # [float] [0] in seconds, after how many seconds of cursor’s inactivity to hide it. Set to 0 for never.
          "no_warps" = "false"; # [bool] [false] if true, will not warp the cursor in many cases (focusing, keybinds, etc)
          "persistent_warps" = "true"; # [bool] [false] When a window is refocused, the cursor returns to its last position relative to that window, rather than to the centre.
          "warp_on_change_workspace" = "true"; # [bool] [false] If true, move the cursor to the last focused window after changing the workspace.
          "default_monitor" = ""; # [str] [] the name of a default monitor for the cursor to be set to on startup (see hyprctl monitors for names)
          "zoom_factor" = "1.0"; # [float] [1.0] the factor to zoom by around the cursor. Like a magnifying glass. Minimum 1.0 (meaning no zoom)
          "zoom_rigid" = "true"; # [bool] [false] whether the zoom should follow the cursor rigidly (cursor is always centered if it can be) or loosely
          "enable_hyprcursor" = "true"; # [bool] [true] whether to enable hyprcursor support
          "hide_on_key_press" = "false"; # [bool] [false] Hides the cursor when you press any key until the mouse is moved.
          "hide_on_touch" = "true"; # [bool] [true] Hides the cursor when the last input was a touch input until a mouse input is done.
          # FIXME: reenable on 0.42
          "allow_dumb_copy" = "false"; # [bool] [false] Makes HW cursors work on Nvidia, at the cost of a possible hitch whenever the image changes
        };
        debug = {
          "overlay" = "false"; # [bool] [false] print the debug performance overlay. Disable VFR for accurate results.
          "damage_blink" = "false"; # [bool] [false] (epilepsy warning!) flash areas updated with damage tracking
          "disable_logs" = "true"; # [bool] [true] disable logging to a file
          "disable_time" = "true"; # [bool] [true] disables time logging
          "damage_tracking" = "2"; # [int] [2] redraw only the needed bits of the display. Do not change. (default: full - 2) monitor - 1, none - 0
          "enable_stdout_logs" = "false"; # [bool] [false] enables logging to stdout
          "manual_crash" = "0"; # [int] [0] set to 1 and then back to 0 to crash Hyprland.
          "suppress_errors" = "false"; # [bool] [false] if true, do not display config file parsing errors.
          "watchdog_timeout" = "5"; # [int] [5] sets the timeout in seconds for watchdog to abort processing of a signal of the main thread. Set to 0 to disable.
          "disable_scale_checks" = "false"; # [bool] [false] disables verification of the scale factors. Will result in pixel alignment and rounding errors.
          "error_limit" = "5"; # [int] [5] limits the number of displayed config file parsing errors.
          "error_position" = "0"; # [int] [0] sets the position of the error bar. top - 0, bottom - 1
          "colored_stdout_logs" = "true"; # [bool] [true] enables colors in the stdout logs.
        };
      }
      {
        windowrulev2 = let
          telegramMatch = "initialTitle:^Telegram$";
          telegramMediaViewerMatch = "initialTitle:^Media viewer$";
          telegramPopupMatch = "initialTitle:^TelegramDesktop$, floating:1";
          scrMatch = "class:imv, title:^scr$";
        in [
          # Window Rule v1: RULE,WINDOW
          # Window Rule v2: RULE,MATCH[,MATCH...]

          # Transparent terminals
          # "opacity 0.9 override 0.9 override,class:^(St|footclient|foot|Alacritty|kitty)$"

          # Make Neovim always opaque
          #opacity 1.0 override 1.0 override, title:NeoVim$

          # FIXME Prevent stuff from fullscreening/contain fullscreens inside of the window
          #fakefullscreen,      class:^(mpv|firefox)$
          #nofullscreenrequest, class:^(mpv|firefox)$
          #"fullscreenstate 1 0, class:^(mpv|firefox)$"

          # Telegram media viewer - fix animations (tiling by default resizes windows)
          "float,     ${telegramMediaViewerMatch}"
          "center,    ${telegramMediaViewerMatch}"
          "noanim,    ${telegramMediaViewerMatch}"
          "noborder,  ${telegramMediaViewerMatch}"

          # Telegram pop-up media viewer - location
          "float, ${telegramPopupMatch}"
          # "move 1500 160, ${telegramPopupMatch}"
          "noborder, ${telegramPopupMatch}"

          # Put telegram to workspace 9
          "workspace 9 silent, ${telegramMatch}"

          # Put VMs to workspace 2
          "workspace 2 silent, class:qemu"

          # scr screenshotting utility - fix animations (tiling by default resizes windows)
          "float, ${scrMatch}"
          "noanim, ${scrMatch}"
          "move 0 0, ${scrMatch}"
          "size 100% 100%, ${scrMatch}"

          # `zet graph`
          "tile, class:^Graphviz$"

          # xdg-desktop-portal-termfilechooser
          "float, title:ranger-filechooser"

          # Firefox Discord
          "idleinhibit always,title:Discord"

          # Syncplay pseudotile (not supported now for windows that force their sizes.)
          "pseudo, class:syncplay"
          "tile, class:syncplay"

          # Gimp Search Actions
          # FIXME: not working (forced focus)
          "stayfocused, initialTitle:^Search Actions$"

          # Firefox ignore fullscreen
          # FIXME: not working (ignore fullscreen)
          # "suppressevent fullscreen, class:firefox"

          # Sxiv
          "tile, class:^Sxiv$"

          # Glxgears
          "tile, initialTitle:^glxgears$"
        ];
      }
    ];
  };
}
