# This is a home-manager configuration module (home.nix)
# Use this to configure your home environment (acts as legacy ~/.config/home-manager/home.nix)
{
  self,
  inputs,
  ...
}:
{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
  ];

  # For some reason they separate some stuff under `home.*`
  home = {
    username = "nrv";
    homeDirectory = "/home/nrv";
    packages = with pkgs; [
      hello
    ];
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  #programs.git.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
