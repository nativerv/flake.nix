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

    inputs.impermanence.nixosModules.impermanence

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
    self.nixosModules."user.gamer"
  ];

  # Virtual machine-scoped config
  virtualisation.vmVariant = {
    virtualisation = {
      forwardPorts = [
        { from = "host"; host.port = 40500; guest.port = 22; }
      ];
      # diskSize = 1024*10;
      diskImage = null;
      cores = 3;
      writableStoreUseTmpfs = false;
      memorySize = 1024*3;
      sharedDirectories = {
        # FIXME: there seems to be race condition between mounting this and
        #        sops activation script.
        # NOTE: they're all set as `neededForBoot = true` by the module. I'm
        #       confused now.
        # NOTE: maybe setting `diskImage` to `null` solved this?
        ssh-host-keys = {
          source = ''''${SECRET_DIR:-"/tmp/${config.networking.hostName}"}/ssh'';
          securityModel = "none";
          target = "/etc/ssh";
        };
        sops = {
          source = ''''${SECRET_DIR:-"/tmp/${config.networking.hostName}"}/sops'';
          securityModel = "none";
          target = "/etc/sops";
        };
        persist-data = {
          source = ''/tmp/${config.networking.hostName}/persist/data'';
          securityModel = "none";
          target = "/persist/data";
        };
        persist-log = {
          source = ''/tmp/${config.networking.hostName}/persist/log'';
          securityModel = "none";
          target = "/persist/log";
        };
        persist-state = {
          source = ''/tmp/${config.networking.hostName}/persist/state'';
          securityModel = "none";
          target = "/persist/state";
        };
        persist-cache = {
          source = ''/tmp/${config.networking.hostName}/persist/cache'';
          securityModel = "none";
          target = "/persist/cache";
        };
        persist-cred = {
          source = ''/tmp/${config.networking.hostName}/persist/cred'';
          securityModel = "none";
          target = "/persist/cred";
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

  # disko.devices.disk.vdb.imageSize = "32G";

  # Setup ZFS
  disko.extraRootModules = [ "zfs" ];
  networking.hostId = self.lib.fromJSONIfUnlockedOr
    (lib.warn
      "Repo is not unlocked! Will use default networking.hostId"
      # Not really required to be unique if disks are not shared across network
      "8425e349")
    "${flake}/sus/${config.networking.hostName}/hostid.json"; 
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.supportedFilesystems.zfs = true;
  boot.zfs.forceImportRoot = false;

  # Impermanence
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback ${config.disko.devices.disk.main.name}/sys/${config.networking.hostName}/local@blank
    zfs rollback ${config.disko.devices.disk.main.name}/sys/${config.networking.hostName}/local/home@blank
  '';
  services.openssh.hostKeys = [
    {
      path = "/persist/cred/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
    {
      path = "/persist/cred/etc/ssh/ssh_host_rsa_key";
      type = "rsa";
      bits = 4096;
    }
  ];
  # TODO: fix env vars (xdg & otherwise)
  environment.persistence = {
    "/persist/data" = {
      enable = true;
      hideMounts = true;
      directories = [
      ];
      files = [
      ];
      users.nrv.directories = [
        "desk"
        "dl"
        "pub"
        "dox"
        "mus"
        "pix"
        "vid"
        ".local/share/templates"
        "pr"
        "dot"
        ".config/nvim/spell"
        ".local/share/lyrics"
      ];
      users.nrv.files = [
      ];
    };
    "/persist/log" = {
      enable = true;
      hideMounts = true;
      directories = [
        "/nix/var/log"
        "/var/log"
        "/var/lib/systemd/coredump"
      ];
      files = [
      ];
      users.nrv.directories = [
      ];
      users.nrv.files = [
      ];
    };
    "/persist/state" = {
      enable = true;
      hideMounts = true;
      directories = [
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/docker"
        "/var/lib/mlocate"
        "/var/lib/acme"
      ];
      files = [
      ];
      users.nrv.directories = [
        ".mozilla"
        ".local/state/sandbox"
      ];
      users.nrv.files = [
      ];
    };
    "/persist/cache" = {
      enable = true;
      hideMounts = true;
      directories = [
      ];
      files = [
      ];
      users.nrv.directories = [
        ".cache"
      ];
      users.nrv.files = [
      ];
    };
    "/persist/cred" = {
      enable = true;
      hideMounts = true;
      directories = [
      ];
      files = [
        "/etc/machine-id"
      ];
      users.nrv.directories = [
        { directory = ".ssh"; mode = "0700"; }
        { directory = ".config/sops"; mode = "0700"; }
        { directory = ".config/rclone"; mode = "0700"; }
        { directory = ".local/share/pass"; mode = "0700"; }
        { directory = ".local/share/gnupg"; mode = "0700"; }
        { directory = ".local/share/rustu2f"; mode = "0700"; }
      ];
      users.nrv.files = [
      ];
    };
  };

  # User password
  users.users.nrv.hashedPasswordFile = self.lib.ifUnlockedOr
    (lib.warn "Repo is not unlocked! Will use default password, CHANGE IT!!!!!!"
        "${pkgs.writeText
          "le-secure-password"
          "$6$FRXEt5XKYRw47Rql$siQrlRJJDjOiSlbChV5Te365XY2v5sKXRomsV90/iApy0kQlGbeFsgNeuL/DbJ7mnhZIoS82Fv6znvMClAh9B0"}")
    config.sops.secrets."passwd/nrv".path;
  # Gamer password
  users.users.gamer.hashedPasswordFile = self.lib.ifUnlockedOr
    (lib.warn "Repo is not unlocked! Will use default password, CHANGE IT!!!!!!"
        "${pkgs.writeText
          "le-secure-password"
          "$6$FRXEt5XKYRw47Rql$siQrlRJJDjOiSlbChV5Te365XY2v5sKXRomsV90/iApy0kQlGbeFsgNeuL/DbJ7mnhZIoS82Fv6znvMClAh9B0"}")
    config.sops.secrets."passwd/gamer".path;

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
  sops.secrets."passwd/gamer".neededForUsers = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";

  # Flatpak
  services.flatpak.enable = true;
  xdg.portal.enable = true;
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
    kitty
    rsync
    restic
    rclone
    file
    ranger
    eza
    ncdu
    sops
    calc
    p7zip

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
  services.desktopManager.plasma6.enable = true;
  services = {
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
}
