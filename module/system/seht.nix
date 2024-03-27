{
  inputs ? null,
  flake ? null,
  self ? null,
  ...
}:
{
  config ? null, 
  pkgs ? null, 
  lib ? null, 
  modulesPath ? null,
  ...
}: {
  # Modules of which this host consists
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops

    self.nixosModules."platform.nixos-shell"
    self.nixosModules."platform.qemu"

    self.nixosModules."archetype.minimal"
    self.nixosModules."archetype.sane"

    #self.nixosModules."bootloader.grub"

    self.nixosModules."subsystem.zram"

    self.nixosModules."server.sshd"

    self.nixosModules."program.neovim"
    self.nixosModules."program.htop"
    self.nixosModules."program.bash"
    self.nixosModules."program.sudo"
    self.nixosModules."program.nix-index"

    self.nixosModules."user.nrv"
  ];

  virtualisation = {
    forwardPorts = [
      { from = "host"; host.port = 2223; guest.port = 22; }
    ];
    diskSize = 1024*10;
    cores = 3;
    writableStoreUseTmpfs = false;
    memorySize = 1024*3;
  };

  #services.openssh.enable = true;

  sops.secrets."test".sopsFile = "${flake}/sus/nrv/test.yaml";

  # The name
  # networking.hostName = "seht";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";

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
    imv
    (self.packages.${system}.bash-nixpak)
    (self.lib.renamePackageBinary pkgs self.packages.${system}.bash-nixpak-env "bash-nixpak-env")

    (self.packages.${system}.firefox)
  ];
  services.desktopManager.plasma6.enable = true;
  services.xserver.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "nrv";
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.wayland.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    #konsole
    (lib.getBin qttools) # Expose qdbus in PATH

    ark
    elisa
    gwenview
    okular
    kate
    khelpcenter
    print-manager
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
