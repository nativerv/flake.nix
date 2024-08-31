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
  programs.kitty = {
    enable = true;

    settings = {
      # Is it Microsoft Visual Studio? Or what the fuck in the hell are you
      # doing?
      update_check_interval = 0;

      # Sane shit
      cursor_blink_interval = 0;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      confirm_os_window_close = 0;
      remember_window_size = false;

      # Looks
      # I hate that it's in pts instead of px
      font_size = 10;
      initial_window_width = 1008;
      initial_window_height = 567;

      # Bahavior
      # Allow changing opacity at runtime with a key
      dynamic_background_opacity = true;
    };

    keybindings = {
      "ctrl+shift+[" = "set_background_opacity -0.1";
      "ctrl+shift+]" = "set_background_opacity +0.1";
    };

    # FIXME: This won't work until i implement sourcing it in my config
    shellIntegration = {
      mode = "no-rc";
    };
  };
}
