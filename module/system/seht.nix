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

  services.flatpak.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  environment.systemPackages = with pkgs; [
    git
    stow
    imv
    foot

    self.packages.${system}.nixpak-test
    self.packages.${system}.firefox
    self.packages.${system}.telegram-desktop
    self.packages.${system}.ungoogled-chromium
  ];
  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "nrv";
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
  };
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

  programs.hyprland.enable = true;

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
