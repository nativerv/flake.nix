{
  inputs ? null, 
  config ? null, 
  pkgs ? null, 
  lib ? null, 
  flake ? null, 
  ...
}: {
  # Modules of which this host consists
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops

    (flake + /module/platform/x86_64.nix)

    (flake + /module/archetype/minimal.nix)
    (flake + /module/archetype/sane.nix)

    (flake + /module/bootloader/grub.nix)

    (flake + /module/subsystem/zram.nix)

    (flake + /module/server/sshd.nix)

    (flake + /module/program/neovim.nix)
    (flake + /module/program/htop.nix)
    (flake + /module/program/bash.nix)
    (flake + /module/program/sudo.nix)
    (flake + /module/program/nix-index.nix)

    (flake + /module/user/nrv.nix)
  ];

  sops.secrets."test".sopsFile = "${flake}/sus/nrv/test.yaml";

  # The name
  networking.hostName = "seht";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.11";

  # Autologin nrv in the VM
  services.getty.autologinUser = "nrv";

  # Set TERM to xterm so that i can use vim properly.
  # TODO: also fix it it mangling my terminal
  # (temporary fix is doing `&& reset`)
  #boot.kernelParams = [ "TERM=xterm" ]; # thougth this would do the TODO.
  environment.variables.TERM = "xterm";

  # services.xserver.desktopManager.xfce.enable = true;
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.enable = true;

  # Setup devices
  # disko.devices = import ./seht-disks.nix {
  #   inherit lib;
  #   disks = [ "/dev/vda" ];
  # };

  environment.systemPackages = with pkgs; [
    git
    stow
  ];

  # Nicely reload system units when changing configs
  #systemd.user.startServices = "sd-switch";

  # WARNING: This does not do anything when using flakes!
  # WARNING: Provide this config when using nixpkgs input.
  nixpkgs = {
    # You can add overlays (package additions and overrides) here
    overlays = [];
    # Configure your nixpkgs instance.
    config = {};
  };
}
