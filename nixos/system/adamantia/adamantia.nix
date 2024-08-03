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

  virtualisation = let
    vm-config = {
      imports = [
        self.nixosModules."platform.qemu"
      ];

      # FIXME: impermanence breaks VMs (stage-1 waiting for device /mnt-root/...
      #        something)
      environment.persistence = lib.mkForce {};

      virtualisation = {
        forwardPorts = [
          # TODO: factor out the port to config/
          { from = "host"; host.port = 40500; guest.port = 22; }
        ];
        # diskSize = 1024*10;
        diskImage = null;
        cores = 3;
        writableStoreUseTmpfs = false;
        memorySize = 1024*10;
        qemu.drives = [
          {
            name = config.system.name;
            file = "\${VM_DISK}";
          }
        ];
        sharedDirectories = {
          persist-data = {
            source = ''/tmp/${config.system.name}/persist/data'';
            securityModel = "none";
            target = "/persist/data";
          };
          persist-log = {
            source = ''/tmp/${config.system.name}/persist/log'';
            securityModel = "none";
            target = "/persist/log";
          };
          persist-state = {
            source = ''/tmp/${config.system.name}/persist/state'';
            securityModel = "none";
            target = "/persist/state";
          };
          persist-cache = {
            source = ''/tmp/${config.system.name}/persist/cache'';
            securityModel = "none";
            target = "/persist/cache";
          };
          persist-cred = {
            source = ''/tmp/${config.system.name}/persist/cred'';
            securityModel = "none";
            target = "/persist/cred";
          };
          # FIXME: there seems to be race condition between mounting this and
          #        sops activation script.
          # NOTE: they're all set as `neededForBoot = true` by the module. I'm
          #       confused now.
          # NOTE: maybe setting `diskImage` to `null` solved this?
          ssh-host-keys = {
            source = ''''${SECRET_DIR:-"/tmp/${config.system.name}"}/ssh'';
            securityModel = "none";
            target = "/persist/cred/etc/ssh";
          };
          sops = {
            source = ''''${SECRET_DIR:-"/tmp/${config.system.name}"}/sops'';
            securityModel = "none";
            target = "/persist/cred/etc/sops";
          };
        };
      };

      # Autologin nrv in the VM
      services.getty.autologinUser = "nrv";
      services.displayManager.autoLogin.enable = lib.mkForce true;
      services.displayManager.autoLogin.user = lib.mkForce "nrv";
      services.displayManager.sddm.enable = lib.mkForce false;
      services.displayManager.sddm.wayland.enable = lib.mkForce false;

      # Backdoor for when ssh host keys are wrong
      users.users.root.password = lib.mkForce "123";
      users.users.root.hashedPassword = lib.mkForce null;
      users.users.root.hashedPasswordFile = lib.mkForce null;
      users.users.root.initialPassword = lib.mkForce null;
      users.users.root.passwordFile = lib.mkForce null;
    };
  in {
    # FIXME: still ERROR: cptofs failed. diskSize might be too small for closure.
    vmVariantWithBootLoader = vm-config // {
      virtualisation.diskSize = 1024*40;
      virtualisation.diskImage = "./${config.system.name}.qcow";
    };
    vmVariant = vm-config;
  };

  boot.kernelParams = [ "rd.systemd.debug_shell" ];
  specialisation = {
    root-autologin.configuration = {
      # Backdoor for easy debugging
      users.users.root.password = lib.mkForce "123";
      users.users.root.hashedPassword = lib.mkForce null;
      users.users.root.hashedPasswordFile = lib.mkForce null;
      users.users.root.initialPassword = lib.mkForce null;
      users.users.root.passwordFile = lib.mkForce null;
      services.displayManager.sddm.enable = lib.mkForce false;
      services.xserver.displayManager.gdm.enable = lib.mkForce false;
      services.xserver.displayManager.lightdm.enable = lib.mkForce false;
      services.getty.autologinUser = lib.mkForce "root";
    };
    zfs-force.configuration = {
      # FIXME: the pool should just be imported fine at the first boot without
      #        intervention of booting with this spec.
      boot.kernelParams = [ "zfs_force=1" ];
    };
  };

  # FIXME: move this somewhere
  users.mutableUsers = false;

  # Secrets config
  sops = {
    gnupg.sshKeyPaths = [ ];
    age.sshKeyPaths = [ "/persist/cred/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = "/persist/cred/etc/sops/default.yaml";
    validateSopsFiles = false;
  };
  sops.secrets."passwd/root".neededForUsers = true;
  sops.secrets."passwd/nrv".neededForUsers = true;
  sops.secrets."passwd/gamer".neededForUsers = true;


  # Setup ZFS
  disko.extraRootModules = [ "zfs" ];
  networking.hostId = self.lib.fromJSONIfUnlockedOr
    (lib.warn
      "Repo is not unlocked! Will use default networking.hostId"
      # Not really required to be unique if disks are not shared across network
      "8425e349")
    "${flake}/sus/${config.system.name}/eval/hostid.json"; 
  # FIXME: other kernel packages, also verify latest ZFS version
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.supportedFilesystems.zfs = true;
  boot.zfs.forceImportRoot = false;

  # Impermanence
  # rollback / and /home
  # NOTE: doesn't exist with boot.initrd.systemd which i've enabled for some
  #       reason when i couldn't boot with ZFS.
  # TODO: investigate switching back to scripted initrd (or if it's worth it
  #       for speed)
  # boot.initrd.postDeviceCommands = lib.mkAfter ''
  #   zfs rollback ${config.disko.devices.disk.main.name}/sys/${config.system.name}/local@blank
  #   zfs rollback ${config.disko.devices.disk.main.name}/sys/${config.system.name}/local/home@blank
  # '';
  boot.initrd.systemd.services.rollback = {
    # Bruh this is boring >
    # description = "Rollback root filesystem to a pristine state on boot";
    description = "Execute: rm -rf /...";
    # "zfs.target"
    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-${config.disko.devices.disk.main.name}.service" ];
    before = [ "sysroot.mount" ];
    path = with pkgs; [
      zfs
    ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      # TODO: saving the previous state as readonly datasets.
      zfs rollback ${config.disko.devices.disk.main.name}/sys/${config.system.name}/local@blank && echo " === rm -rf /...Done. === "
      zfs rollback ${config.disko.devices.disk.main.name}/sys/${config.system.name}/local/home@blank && echo " === rm -rf /home...Done. == "
    '';
  };
  # FIXME: provisioned ssh host keys modified by NixOS at some point for some
  #        reason - the comment among something else in the private key -
  #        fingerprint changes.
  services.openssh.hostKeys = [
    { path = "/persist/cred/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    { path = "/persist/cred/etc/ssh/ssh_host_rsa_key"; type = "rsa"; bits = 4096; }
  ];

  # FIXME: Permit for deployment while testing.
  # TODO: Find a way to enable that on non-vm build, but which is in fact
  #       running in a VM.
  services.openssh.settings.PermitRootLogin = "yes";

  # TODO: fix env vars (xdg & otherwise)
  environment.persistence = {
    "/persist/data" = {
      enable = true;
      enableDebugging = true;
      hideMounts = true;
      directories = [
        "/home/gamer"
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
      enableDebugging = true;
      hideMounts = true;
      directories = [
        # "/nix/var/log"
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
      enableDebugging = true;
      hideMounts = true;
      directories = [
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/docker"
        "/var/lib/mlocate"
        "/var/lib/acme"
        "/var/lib/flatpak"
        "/var/db/sudo/lectured"
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
      enableDebugging = true;
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
      enableDebugging = true;
      hideMounts = true;
      directories = [
        { directory = "/etc/sops"; mode = "0700"; }
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

  # Root
  users.users.root.openssh.authorizedKeys.keys = [
    # TODO: move the key to config/?
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/EhBI6sJb2yHbTkqhZiCzUrsLE6t+CZe7RhS22z7w5 nrv@desktop"
  ];
  users.users.root.hashedPasswordFile = self.lib.ifUnlockedOr
    (lib.warn "Repo is not unlocked! Will use default password, CHANGE IT!!!!!!"
        "${pkgs.writeText
          "le-secure-password"
          "$6$FRXEt5XKYRw47Rql$siQrlRJJDjOiSlbChV5Te365XY2v5sKXRomsV90/iApy0kQlGbeFsgNeuL/DbJ7mnhZIoS82Fv6znvMClAh9B0"}")
    config.sops.secrets."passwd/root".path;
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

  # Bootloader
  # TODO: 1s delay
  #       .5s?
  boot.loader.grub.device = "nodev";
  boot.loader.grub.devices = lib.mkForce [ "nodev" ];
  boot.loader.grub.enable = true;
  # Install GRUB with EFI support
  boot.loader.grub.efiSupport = true;
  # GRUB writes itself to a hardcoded EFI spec location that's always tried
  # first, instead of relying on EFI NVRAM load order.
  boot.loader.grub.efiInstallAsRemovable = true;
  # NOTE: This just makes things easier frankly... however i don't think it's
  #       required for my config
  boot.initrd.systemd.enable = true;
  
  # Hardware config (nixos-generate-config)
  boot.initrd.availableKernelModules = [ "nvme" "usbhid" "xhci_pci" "usb_storage" ];
  boot.initrd.kernelModules = [];
  # TODO: test what happens when kvm-amd removed. Is it loaded anyway in lsmod?
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  # FIXME: enable me pls
  hardware.enableRedistributableFirmware = true;
  # ===

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";

  # Flatpak
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  security.rtkit.enable = true;
  # environment.etc."flatpak/remotes.d/flathub.flatpakrepo".source = pkgs.fetchurl {
  #   url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
  #   # Let this run once and you will get the hash as an error.
  #   hash = "";
  # };
  systemd.services.install-flatpak-repos = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig.Type = "oneshot";
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

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
    openssl

    #self.packages.${system}.nixpak-test
    self.packages.${system}.firefox
    self.packages.${system}.telegram-desktop
    self.packages.${system}.ungoogled-chromium
    self.packages.${system}.gimp
    self.packages.${system}.mpv
    self.packages.${system}.vlc
    self.packages.${system}.zathura
  ];

  # Firejail example for later
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
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  # FIXME: SDDM is broken (something related to themes?) and i need this to
  #        login:
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "nrv";
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
