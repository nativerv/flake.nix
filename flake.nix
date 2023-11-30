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
      # Path to the root of this flake
      flake = ./.;
      # Generates outputs for all systems below
      forAllSystems = nixpkgs-unstable.lib.genAttrs systems;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in {
      # Reexport nixpkgs with our overlays applied
      # Acessible on our configurations, and through nix build, shell, run, etc.
      legacyPackages = forAllSystems (system: self.lib.mkPkgs nixpkgs-unstable system);

      lib = import ./lib {
        inherit self inputs flake;
        lib = nixpkgs-unstable.lib;
      };
      overlays = import ./overlay { lib = nixpkgs-unstable.lib; };

      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (system: {
        default = self.legacyPackages.${system}.callPackage ./shell.nix {
          inherit inputs;
        };
      });

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = builtins.listToAttrs [
        (self.lib.mkNixosConfiguration nixpkgs-unstable "seht" { system = "x86_64-linux"; })
        # (mkNixosConfiguration nixpkgs-unstable "umbriel" { system = "x86_64-linux"; })
      ];

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
