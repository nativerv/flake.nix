{
  self ? null,
  ...
}:
{
  config ? null,
  lib ? null,
  pkgs ? null,
  modulesPath ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.platform.qemu;
in
{
  imports = optional cfg.enable (modulesPath + "/profiles/qemu-guest.nix");
  options.dream.platform.qemu = {
    enable = mkEnableOption "Enable platform.qemu";
  };
  config = mkIf cfg.enable {
    boot.initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "sr_mod"
      "virtio_blk"
    ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    # This is here so vm don't run out of space for no reason
    services.journald.extraConfig = ''
      SystemMaxUse=10M
      MaxFileSec=7day
    '';

    boot.kernelParams = [
      "console=tty1"
      "console=ttyS0,115200"
    ];

    # TODO: make this (or an alternative) work
    # resize in console tty - for usage in terminal emulators
    # programs.bash.interactiveShellInit = ''
    #   trap "${pkgs.xterm}/bin/resize" WINCH
    # '';
  };
}
