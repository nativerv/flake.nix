{
  description = "Nrv's personal Nix flake";

  inputs = {
    # Nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-22-11.url = "github:nixos/nixpkgs/nixos-22.11";

    # Disk management
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Nix-index command, with database
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-22-11";

    nixos-shell.url = "github:Mic92/nixos-shell";
    nixos-shell.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Home manager
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";

    # This is here only to be pinned in the registry by
    # `module/archetype/sane.nix`
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs-unstable,
    disko,
    nix-index-database,
    nixpkgs-22-11,
    ...
  } @ inputs:
    let
      system = "x86_64-linux";
      flake = ./.;
      lib = self.lib.mkLib nixpkgs-unstable;
      # FIXME: Is doing this and passing it directly to imports fine?
      # Modules get `pkgs` automatically.
      pkgs = self.lib.mkPkgs nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfreePredicate = lib.unfreeWhiteList (with pkgs; []);
        };
        overlays = [ self.overlays.free ];
      };
    in {
      lib = import ./lib;
      overlays = import ./overlay;
      devShells.${system}.default = import ./shell.nix { inherit pkgs system inputs; };

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations =
        let
          # FIXME: this looks ugly as hell. Is there some way 
          # to share hostname & stuff cleaner?
          seht = import ./module/system/seht.nix {};
          umbriel = import ./module/system/umbriel.nix {};
        in {
          ${seht.networking.hostName} = nixpkgs-unstable.lib.nixosSystem {
            inherit system pkgs lib;
            modules = [ ./module/system/seht.nix ];
            # Pass flake inputs to our config
            specialArgs = { inherit inputs flake; }; 
          };
          ${umbriel.networking.hostName} = nixpkgs-unstable.lib.nixosSystem {
            inherit system pkgs lib;
            modules = [ ./module/system/umbriel.nix ];
            # Pass flake inputs to our config
            specialArgs = { inherit inputs flake; }; 
          };
        };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      # homeConfigurations = {
      #   # FIXME replace with your username@hostname
      #   "your-username@your-hostname" = home-manager.lib.homeManagerConfiguration {
      #     pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
      #     extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to our config
      #     # > Our main home-manager configuration file <
      #     modules = [ ./home-manager/home.nix ];
      #   };
      # };
    };
}

# vim:et:sw=2:ts=2:sts=2
