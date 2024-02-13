{
  config ? null,
  inputs ? null,
  flake ? null,
  lib ? null,
  pkgs ? null,
  self ? null,
  modulesPath ? null,
  ...
}:
{
  imports = [
    #(modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    #self.nixosModules."platform.qemu"

    inputs.sops-nix.nixosModules.sops

    # For nixos-anywhere
    #inputs.disko.nixosModules.disko

    self.nixosModules."archetype.minimal"
    self.nixosModules."archetype.sane"

    #self.nixosModules."bootloader.grub"

    self.nixosModules."subsystem.zram"

    self.nixosModules."server.sshd"

    self.nixosModules."program.sudo"
    self.nixosModules."program.bash"
    self.nixosModules."program.neovim"
    self.nixosModules."program.htop"
    self.nixosModules."program.nix-index"

    self.nixosModules."user.yukkop"
    self.nixosModules."user.snuff"
    self.nixosModules."user.nrv"
    #self.nixosModules."user.pih-pah"
  ];

  # Secrets config
  sops.gnupg.sshKeyPaths = [ ];
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # for deploy-rs (otherwise complains something about package signatures)
  nix.trustedUsers = [ "@wheel" ];

  # The name
  # networking.hostName = "umbriel";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";

  # Docker
  virtualisation.docker.enable = true;

  ### Setup wireguard server

  ###

  # === wireguard ===

  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp1s0";
  networking.nat.internalInterfaces = [ "wg-bfs" ];
  networking.firewall = {
    enable = false;
    allowedUDPPorts = [ 51820 ];
  };

  sops.secrets."wireguard/bfs/private.asc".sopsFile = "${flake}/sus/common/wg.yaml";

  networking.wireguard.interfaces = let                           
    subnet = "10.13.37";                                                                    
    externalInterface = "enp1s0";
  in {                                                                                      
    # "wg-bfs" is the network interface name. You can name the interface arbitrarily.
    wg-bfs = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "${subnet}.1/24" ];
                    
      # The port that WireGuard listens to. Must be accessible by the client.                         
      listenPort = 51820;                                                                                        
                    
      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t 'nat' -A 'POSTROUTING' -s ${subnet}.0/24 -o '${externalInterface}' -j 'MASQUERADE'
      '';
                                                                                                   
      # This undoes the above command
      postShutdown = ''  
        ${pkgs.iptables}/bin/iptables -t 'nat' -D 'POSTROUTING' -s ${subnet}.0/24 -o '${externalInterface}' -j 'MASQUERADE'
      '';
                                                                                    
      # Path to the private key file.                                               
      #                                    
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.                                  
      privateKeyFile = config.sops.secrets."wireguard/bfs/private.asc".path;
                       
      # Generate key at `privateKeyFile` if not exists
      generatePrivateKeyFile = true;                                  

      # List of allowed peers.
      # (increment the last octet when adding peers e.g. '.2' -> '.3')
      peers = [                                                      
        # nrv                               
        {      
          publicKey = "3dVzf1jxnVVTkLAyxedW+kRQBexZDzYDwpaLIcTrLjc=";
          allowedIPs = [ "${subnet}.2/32" ];
        }                                
        # nrv                               
        {      
          publicKey = "Kk2d0ncj24rO0qbuKh4V4t1OLnmVYbeaYvuEnL2OPFM=";
          allowedIPs = [ "${subnet}.3/32" ];
        }                                
      ];                                          
    };                                            
  };   

  ###

   # systemd.services.pih-pah-server = {
   #   enable = true;
   #   description = "pih-pah server";
   #   serviceConfig = {
   #     Type = "exec";
   #     User = "pih-pah";
   #     Group = "pih-pah";
   #     ExecStart = "/srv/pih-pah/pih-pah-server 127.0.0.1:5010";
   #     Restart = "on-failure";
   #   };
   #   wantedBy = [ "default.target" ];
   # };

  environment = {
    systemPackages = with pkgs; [
      git
      tmux
    ];
  };  

  # Generated by nixos-infect
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/87F9-1AE9";
    fsType = "vfat";
  };
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };


  # # Config for nixos-anywhere
  # # Was in example nixos-anywhere config.
  # boot.loader.grub = {
  #   # no need to set devices, disko will add all devices that have a EF02 partition to the list already
  #   # devices = [ ];
  #   efiSupport = true;
  #   efiInstallAsRemovable = true;
  # };
  #
  # # Apparantly needed for nixos-anywhere to work?
  # # Otherwise getting 'ssh: ... no route to host' mid-install
  users.users.root.openssh.authorizedKeys.keyFiles = self.lib.ifUnlocked "${flake}/sus/ssh/nrv";
  #
  # # Disk partitions - will only run when installing.
  # disko.devices = let
  #   volumeGroupName = "umbriel";
  # in {
  #   disk.disk1 = {
  #     device = lib.mkDefault "/dev/sda";
  #     type = "disk";
  #     content = {
  #       type = "gpt";
  #       partitions = {
  #         boot = {
  #           name = "boot";
  #           size = "1M";
  #           type = "EF02";
  #         };
  #         esp = {
  #           name = "ESP";
  #           size = "500M";
  #           type = "EF00";
  #           content = {
  #             type = "filesystem";
  #             format = "vfat";
  #             mountpoint = "/boot";
  #           };
  #         };
  #         root = {
  #           name = "root";
  #           size = "100%";
  #           content = {
  #             type = "lvm_pv";
  #             vg = "${volumeGroupName}";
  #           };
  #         };
  #       };
  #     };
  #   };
  #   lvm_vg = {
  #     ${volumeGroupName} = {
  #       type = "lvm_vg";
  #       lvs = {
  #         root = {
  #           size = "100%FREE";
  #           content = {
  #             type = "filesystem";
  #             format = "ext4";
  #             mountpoint = "/";
  #             mountOptions = [
  #               "defaults"
  #             ];
  #           };
  #         };
  #       };
  #     };
  #   };
  # };
}
