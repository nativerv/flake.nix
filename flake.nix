{
  description = "Nrv's personal Nix flake";

  inputs = {
    # Nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-22-11.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-23-11.url = "github:nixos/nixpkgs/nixos-23.11";

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
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Deploy
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs-unstable";

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
    nixpkgs-23-11,
    home-manager,
    deploy-rs,
    ...
  } @ inputs: let
      # Path to the root of this flake
      flake = ./.;
      # Generates outputs for all systems below
      forAllSystems = nixpkgs-unstable.lib.genAttrs systems;
      systems = [
        "x86_64-linux"
        # "aarch64-linux"
        # "x86_64-darwin"
        # "aarch64-darwin"
      ];
    in {
      # Reexport nixpkgs with our overlays applied
      # Acessible on our configurations, and through nix build, shell, run, etc.
      legacyPackages = forAllSystems (system: import nixpkgs-unstable {
        inherit system;
        overlays = [ self.overlays.default ];
        config = self.lib.defaultConfig nixpkgs-unstable;
      });

      lib = import ./lib {
        inherit self inputs flake;
        lib = nixpkgs-unstable.lib;
      };
      overlays = import ./overlay {
        inherit (nixpkgs-unstable) lib;
        inherit flake self inputs;
      };

      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (system: {
        default = self.legacyPackages.${system}.callPackage ./shell.nix {
          inherit inputs;
        };
      });

      nixosModules = self.lib.readModulesRecursive' ./module { inherit flake self inputs; };

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = with self.lib; let 
        mkNixosConfiguration = self.lib.mkNixosConfiguration ./module;
      in builtins.listToAttrs [
        (mkNixosConfiguration nixpkgs-unstable "seht" { system = "x86_64-linux"; })
      ];

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      homeConfigurations = {
        "nrv@seht" = home-manager.lib.homeManagerConfiguration {
          pkgs = self.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
          # > Our main home-manager configuration file <
          modules = [ ./home-manager/home.nix ];
        };
      };
      
      deploy.nodes.seht = let
        name = "seht";
        inherit (self.nixosConfigurations."${name}".config.nixpkgs) system;
        pkgs = self.legacyPackages."${system}";
        # reuse `deploy-rs` package from nixpkgs to utilize cache.nixos.org
        deployPkgs = builtins.foldl' (acc: cur: acc.extend cur) pkgs [
          inputs.deploy-rs.overlay
          (final: prev: {
            deploy-rs = {
              inherit (pkgs) deploy-rs;
              inherit (prev.deploy-rs) lib;
            };
          })
        ];
      in {
        sshOpts = [ "-p" "2222" "-oStrictHostKeyChecking=no" ];
        hostname = self.lib.parseTOMLIfUnlocked ./sus/common/${name}.toml;
        fastConnection = true;
        profilesOrder = [ "system" "home" ];
        profiles.system = {
          sshUser = "root";
          path = deployPkgs.deploy-rs.lib.activate.nixos self.nixosConfigurations."${name}";
          user = "root";
        };
       profiles.home = {
          sshUser = "nrv";
          profilePath = "/nix/var/nix/profiles/per-user/nrv/home";
          path = deployPkgs.deploy-rs.lib.activate.custom
            (self.homeConfigurations."nrv@${name}").activationPackage
            "$PROFILE/activate";
          user = "nrv";
        };
        profiles.hello = {
          sshUser = "nrv";
          path = deployPkgs.deploy-rs.lib.activate.custom
            nixpkgs-unstable.legacyPackages."${system}".hello
            "./bin/hello";
          user = "nrv";
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}

# vim:et:sw=2:ts=2:sts=2
