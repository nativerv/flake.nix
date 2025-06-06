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
    (import ./disko.nix { inherit self flake inputs; })

    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops

    self.nixosModules."home-manager.standalone"
    self.nixosModules.dream
  ];

  dream.program = {
    neovim.enable = true;
    nix-index.enable = true;
    keyd.enable = true;
  };

  dream.service.sshd.enable = true;

  dream.subsystem.networking = { 
    dns.dnscrypt = true;
  };

  dream.subsystem = {
    zram.enable = true;
  };

  dream.archetype = {
    minimal.enable = true; # -everything unnecessary by default
    default.enable = true;
    remote.enable = true; # +remote login
    graphical.enable = true; # +interactive
    quick.enable = true; # various depending on the above, e.g. quick graphical
  };

  dream.user = {
    nrv.enable = true;
    gamer.enable = true;
  };

  nix.package = pkgs.nixVersions.latest;

  home-manager.standalone.users.nrv = {
    enable = true;
    defaultConfiguration = self.homeConfigurations.nrv.activationPackage;
    verbose = true;
    backupFileExtension = "hm-bak";
  };

  # System zone
  # NOTE: setting time zone here actually matters
  #       KDE spectale **segfaults** when this isn not set LUL
  time.timeZone = self.lib.fromJSONIfUnlockedOr (
    warn "Repo is not unlocked! Will use default time zone: 'UTC'" "UTC"
  ) "${flake}/sus/${config.system.name}/eval/timezone.json";

  # Virtual machine-scoped config
  virtualisation = let
    vm-config = {
      imports = [
        self.nixosModules."platform.qemu"
      ];
      dream.platform.qemu.enable = true;

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

  # /tmp on tmpfs
  boot.tmp.useTmpfs = true;

  # Setup ZFS
  disko.extraRootModules = [ "zfs" ];
  networking.hostId = self.lib.fromJSONIfUnlockedOr
    (lib.warn
      "Repo is not unlocked! Will use default networking.hostId"
      # Not really required to be unique if disks are not shared across network
      "8425e349")
    "${flake}/sus/${config.system.name}/eval/hostid.json"; 
  # FIXME: other kernel packages, also verify latest ZFS version
  boot.kernelPackages = self.packageGroups.${pkgs.system}.zfs-compatible-linux-kernels.latest;
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
  boot.initrd.systemd = let 
    zfs-roll-darlings = (pkgs.writeShellScriptBin "zfs-roll-darlings" "exec ${flake}/scripts/zfs-roll-darlings.sh");
  in {
    enable = true;
    extraBin.zfs-roll-darlings = "${flake}/scripts/zfs-roll-darlings.sh";
    services.roll-darlings = {
      description = "Execute: rm -rf /...";
      wantedBy = [ "initrd.target" ];
      after = [ "zfs-import-${config.disko.devices.disk.main.name}.service" ];
      before = [ "sysroot.mount" ];
      path = with pkgs; [
        zfs
        coreutils
        util-linux
        zfs-roll-darlings
      ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = with pkgs; ''
        export ZRD_POOL="${config.disko.devices.disk.main.name}"
        export ZRD_SYSTEM="${config.system.name}"
        export ZRD_MAX="128"
        # FIXME: can't include dependencies in initrd no matter what i try, so
        #        read & inline instead
        #exec zfs-roll-darlings
        ${builtins.readFile "${flake}/scripts/zfs-roll-darlings"}
      '';
    };
  };

  services.openssh.hostKeys = [
    { path = "/persist/cred/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    { path = "/persist/cred/etc/ssh/ssh_host_rsa_key"; type = "rsa"; bits = 4096; }
  ];

  # # Permit for deployment while testing.
  # # TODO: Find a way to enable that on non-vm build, but which is in fact
  # #       running in a VM.
  # services.openssh.settings.PermitRootLogin = "yes";

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
        "srv"
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
        ".local/state/sandbox"
        ".local/state/zsh"
        ".local/state/nvim"
        ".local/state/nix"
        ".local/share/nix" # repl-history
        ".local/share/home-manager" # news
        ".local/state/tmux" # plugins (resurrect)
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
  # boot.loader.grub.extraConfig
  boot.loader.grub.devices = lib.mkForce [ "nodev" ];
  boot.loader.grub.enable = true;
  # Install GRUB with EFI support
  boot.loader.grub.efiSupport = true;
  # GRUB writes itself to a hardcoded EFI spec location that's always tried
  # first, instead of relying on EFI NVRAM load order.
  boot.loader.grub.efiInstallAsRemovable = true;
  # NOTE: This just makes things easier frankly... however i don't think it's
  #       required for my config
  # NOTE: Moved below
  # FIXME: You know... decouple this giant mess of a system config file
  # boot.initrd.systemd.enable = true;
  
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
  hardware.enableRedistributableFirmware = true;
  # ===

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";

  # Flatpak
  dream.program.flatpak.enable = true;
  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ ];

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

  # Setup VPN
  sops.secrets."wg/umbriel-bfs/private.key" = {};
  networking.wg-quick.interfaces.umbriel-bfs = let
    umbriel-bfs = self.lib.fromJSONIfUnlockedOr (
      lib.warn "Repo is not unlocked! Wireguard will not work." {
        interface = {
          address = [ "10.0.0.2/32" ];
        };
        peer = {
          publicKey = "0000000000000000000000000000000000000000000=";
          endpoint = "127.0.0.1:51820";
          allowedIPs = [ "0.0.0.1/32" "::1/128" ];
          persistentKeepalive = 30;
        };
      })
      "${flake}/sus/${config.system.name}/eval/wg/umbriel-bfs.json";
  in {
    autostart = !self.lib.isLocked;
    privateKeyFile = config.sops.secrets."wg/umbriel-bfs/private.key".path;
    dns = [ "127.0.0.1" ];
    peers = [ umbriel-bfs.peer ];
    inherit (umbriel-bfs.interface) address;
  };

  # Setup zsh
  programs.zsh = {
    enable = true;
  };
  
  # Enable hyprland - brings necessary stuff; main config is in Home Manager
  programs.hyprland.enable = true;

  # Setup Plasma
  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # FIXME: SDDM is broken (something related to themes?) and i need this to
  #        login:
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "nrv";
  # environment.plasma6.excludePackages = with pkgs.kdePackages; [
  #   plasma-browser-integration
  #   #konsole
  #   (lib.getBin qttools) # Expose qdbus in PATH
  #
  #   ark
  #   elisa
  #   gwenview
  #   okular
  #   kate
  #   khelpcenter
  #   print-manager
  # ];
}
