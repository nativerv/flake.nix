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
    (import "${modulesPath}/installer/scan/not-detected.nix")
    # If you want to use modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-cpu-amd-zenpower
    inputs.hardware.nixosModules.common-pc-ssd

    inputs.disko.nixosModules.disko
    (import ./disko.nix { inherit lib; })

    inputs.sops-nix.nixosModules.sops

    self.nixosModules."archetype.minimal"
    self.nixosModules."archetype.default"

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

  virtualisation.vmVariant = {
    virtualisation = {
      forwardPorts = [
        { from = "host"; host.port = 40500; guest.port = 22; }
      ];
      diskSize = 1024*10;
      cores = 3;
      writableStoreUseTmpfs = false;
      memorySize = 1024*3;
      sharedDirectories = {
        ssh-host-keys = {
          source = ''/tmp/${config.networking.hostName}/ssh'';
          securityModel = "none";
          target = "/etc/ssh";
        };
        sops = {
          source = ''/tmp/${config.networking.hostName}/sops'';
          securityModel = "none";
          target = "/etc/sops";
        };
      };
    };

    imports = [
      self.nixosModules."platform.qemu"
    ];

    # Autologin nrv in the VM
    services.getty.autologinUser = "nrv";

    # Backdoor for when ssh host keys are wrong
    users.users.root.password = lib.mkForce "123";
    users.users.root.hashedPassword = lib.mkForce null;
    users.users.root.hashedPasswordFile = lib.mkForce null;
    users.users.root.initialPassword = lib.mkForce null;
    users.users.root.passwordFile = lib.mkForce null;
  };

  users.mutableUsers = false;

  disko.devices.disk.vdb.imageSize = "32G";

  # Required for ZFS
  disko.extraRootModules = [ "zfs" ];
  # Not really required to be unique if disks are not shared across network
  networking.hostId = self.lib.fromJSONIfUnlockedOr
    (lib.warn
      "Repo is not unlocked! Will use default networking.hostId"
      "8425e349")
    "${flake}/sus/adamantia/hostid.json"; 
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;

  # User password
  users.users.nrv.hashedPasswordFile = self.lib.ifUnlockedOr
    (lib.warn "Repo is not unlocked! Will use default password, CHANGE IT!!!!!!"
        "${pkgs.writeText
          "le-secure-password"
          "$6$FRXEt5XKYRw47Rql$siQrlRJJDjOiSlbChV5Te365XY2v5sKXRomsV90/iApy0kQlGbeFsgNeuL/DbJ7mnhZIoS82Fv6znvMClAh9B0"}")
    config.sops.secrets."passwd/nrv".path;

  # Hardware config (nixos-generate-config)
  boot.initrd.availableKernelModules = [ "nvme" "usbhid" "xhci_pci" "usb_storage" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = false;
  # ===

  # Secrets config
  sops = {
    gnupg.sshKeyPaths = [ ];
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = "/etc/sops/default.yaml";
    validateSopsFiles = false;
  };
  sops.secrets."passwd/nrv".neededForUsers = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";

  # Set TERM to xterm so that i can use vim properly.
  # TODO: also fix it it mangling my terminal
  # (temporary fix is doing `&& reset`)
  #boot.kernelParams = [ "TERM=xterm" ]; # thougth this would do the TODO.
  environment.variables.TERM = "xterm";

  # services.xserver.desktopManager.xfce.enable = true;
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.enable = true;

  # Flatpak
  services.flatpak.enable = true;
  security.rtkit.enable = true;

  # GTK apps outside GNOME - cursor, theming & window decorations. 
  programs.dconf.enable = true;

  # Sound
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

    #self.packages.${system}.nixpak-test
    self.packages.${system}.firefox
    self.packages.${system}.telegram-desktop
    self.packages.${system}.ungoogled-chromium
    self.packages.${system}.gimp
    self.packages.${system}.mpv
    self.packages.${system}.vlc
    self.packages.${system}.zathura
  ];
  # programs.firejail = {
  #   enable = true;
  #   wrappedBinaries = {
  #     mpv-firejailed = {
  #       executable = "${pkgs.mpv}/bin/mpv";
  #       profile = "${pkgs.firejail}/etc/firejail/mpv.profile";
  #       desktop = "${pkgs.mpv}/share/applications/mpv.desktop";
  #     };
  #   };
  # };
  #services.desktopManager.plasma6.enable = true;
  #services.xserver = {
  #  enable = true;
  #  displayManager.autoLogin.enable = true;
  #  displayManager.autoLogin.user = "nrv";
  #  displayManager.sddm.enable = true;
  #  displayManager.sddm.wayland.enable = true;
  #};
  #environment.plasma6.excludePackages = with pkgs.kdePackages; [
  #  plasma-browser-integration
  #  #konsole
  #  (lib.getBin qttools) # Expose qdbus in PATH

  #  ark
  #  elisa
  #  gwenview
  #  okular
  #  kate
  #  khelpcenter
  #  print-manager
  #];

  programs.hyprland.enable = true;

  # Nicely reload system units when changing configs
  #systemd.user.startServices = "sd-switch";

  nixpkgs = {
    # You can add overlays (package additions and overrides) here
    overlays = [];

    # Configure your nixpkgs instance.
    # WARNING: This does not work when using `import nixpkgs { ... }`!
    # WARNING: Provide this config when importing nixpkgs input.
    # Failed assertions:
    # - Your system configures nixpkgs with an externally created instance.
    # `nixpkgs.config` options should be passed when creating the instance instead.
    config = {};
  };
}
