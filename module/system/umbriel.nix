{
  config ? null,
  inputs ? null,
  flake ? null,
  lib ? null,
  pkgs ? null,
  modulesPath ? null,
  ...
}:
{
  imports =
    lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix
    ++ [
      # modulesPath is provided by `lib.nixosSystem` function
      # it points to whatever nixpkgs repo that function comes from,
      # so you can include it's modules.
      # example: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/digital-ocean-config.nix
      (modulesPath + "/virtualisation/digital-ocean-config.nix")

      inputs.sops-nix.nixosModules.sops

      (flake + /module/platform/x86_64.nix)

      (flake + /module/archetype/minimal.nix)
      (flake + /module/archetype/sane.nix)

      #(flake + /module/bootloader/grub.nix)

      #(flake + /module/subsystem/zram.nix)

      (flake + /module/server/sshd.nix)

      (flake + /module/program/sudo.nix)
      (flake + /module/program/bash.nix)
      (flake + /module/program/neovim.nix)
      (flake + /module/program/htop.nix)
      (flake + /module/program/nix-index.nix)

      (flake + /module/user/yukkop.nix)
      (flake + /module/user/snuff.nix)
      (flake + /module/user/nrv.nix)
      (flake + /module/user/pih-pah.nix)
    ];

  # The name
  networking.hostName = "umbriel";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

  # Docker
  virtualisation.docker.enable = true;

  ### Setup wireguard server

  ###

  # === wireguard ===

  # enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg-bfs" ];
  networking.firewall = {
    #enable = false;
    allowedUDPPorts = [ 51820 ];
  };
  sops.secrets."wireguard/bfs/private.asc".sopsFile = "${flake}/sus/common/wg.yaml";
  networking.wireguard.interfaces = let                           
    subnet = "10.13.37";                                                                    
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
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${subnet}.0/24 -o eth0 -j MASQUERADE
      '';                                 
                                                                                                   
      # This undoes the above command
      postShutdown = ''  
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${subnet}.0/24 -o eth0 -j MASQUERADE
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
      ];                                          
    };                                            
  };   

  ###

   systemd.services.pih-pah-server = {
     enable = true;
     description = "pih-pah server";
     serviceConfig = {
       Type = "exec";
       User = "pih-pah";
       Group = "pih-pah";
       ExecStart = "/srv/pih-pah/pih-pah-server 127.0.0.1:5010";
       Restart = "on-failure";
     };
     wantedBy = [ "default.target" ];
   };

  environment = {
    systemPackages = with pkgs; [
      alsaLib
      chafa
      cmake
      docker
      docker-compose
      git
      jq
      nginx
      shellcheck
      tmux
      zsh
    ];
  };  
}
