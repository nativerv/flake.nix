{
  pkgs ? null,
  modulesPath ? null,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

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
}
