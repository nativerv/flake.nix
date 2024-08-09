{
  description = "Nrv's personal Nix flake";

  # Other Flakes that is used to build this one
  inputs = {
    # Nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-22-11.url = "github:nixos/nixpkgs/nixos-22.11";
    nixpkgs-23-11.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-24-05.url = "github:nixos/nixpkgs/nixos-24.05";
    
    # Sandboxing
    nixpak.url = "github:nixpak/nixpak";
    nixpak.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Disk management & partitioning
    disko.url = "github:nativerv/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Ephemeral/Impermanent root utility
    impermanence.url = "github:nix-community/impermanence";

    # Command for searching files in nixpkgs, with per-built database
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Secret management framework
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs-24-05";

    # NixOS VM helper - `nixos-shell`
    nixos-shell.url = "github:Mic92/nixos-shell";
    nixos-shell.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # NixOS VM helper - `microvm`
    # microvm.url = "github:astro/microvm.nix";
    # microvm.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Deployment tool
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Pre-built configs for various hardware (cpus, gpus, laptops, etc.)
    hardware.url = "github:nixos/nixos-hardware";

    # Don't remember from where i stole my initial config but this was there
    # maybe i'll use it later
    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    #nix-colors.url = "github:misterio77/nix-colors";

    # This is here only to be pinned in the registry by
    # `nixos/module/archetype/sane.nix`
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.follows = "nixpkgs-unstable";
  };

  # Outputs of this Flake
  outputs = {
    self,
    nixpkgs-unstable,
    disko,
    nix-index-database,
    nixpkgs-22-11,
    nixpkgs-23-11,
    nixpkgs-24-05,
    home-manager,
    deploy-rs,
    nixpak,
    hardware,
    #microvm,
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
      # Reexport nixpkgs with this flake's default overlays and config applied
      # Available through `nix run .#package-name`
      legacyPackages = forAllSystems (system: import nixpkgs-unstable {
        inherit system;
        overlays = [
          (final: prev: { nixpkgs-flake = nixpkgs-unstable; })
          self.overlays.default
        ];
        config = self.config.nixpkgs;
      });
      # Overlays are a pluggable middleware between the original `nixpkgs` and
      # `nixpkgs` that is being used. They change or add packages and other
      # stuff to `nixpkgs` once plugged in.
      overlays = import ./overlay {
        inherit (nixpkgs-unstable) lib;
        inherit flake self inputs;
      };

      # Functions in Nix language to help in defining this flake.
      # May be usable in other flakes
      lib = import ./lib {
        inherit (nixpkgs-unstable) lib;
        inherit flake self inputs;
      };
      # This is a custom attribute where i store common configurations specific
      # to this flake and stuff defined in it which don't fit into `lib`
      config = import ./config {
        inherit (nixpkgs-unstable) lib;
        inherit flake self inputs;
      };

      # Packages defined in this flake. Include sandbox wrappers of some `legacyPackages`
      # Declared in ./package/NAME
      # Available through `nix run .#package-name`
      packages = forAllSystems (system: self.lib.readPackages
        self.legacyPackages.${system}.callPackage
        ./package
        { inherit flake self inputs; }
      );
      apps = forAllSystems (system: {
        disko-adamantia-image.type = "app";
        disko-adamantia-image.program = "${self.nixosConfigurations.adamantia.config.system.build.diskoImagesScript}";
        disko-adamantia-post.type = "app";
        disko-adamantia-post.program = "${self.legacyPackages.${system}.callPackage ./nixos/system/adamantia/postAllMountsHook.nix { zpool-name = "mythos"; rootMountPoint = "/"; }}/bin/disko-post-all-mounts";
      });
      
      # Configuration modules for NixOS systems
      # Declared in ./nixos/module/TYPE/NAME
      # Available through `self.nixosModules."module-type.module-name"`
      nixosModules = self.lib.readModulesRecursive'
        ./nixos/module
        { inherit flake self inputs; };

      # NixOS systems
      # Declared in ./nixos/system/NAME
      # Available through `nixos-install --impure --flake .#system-name`
      # Available through `nixos-rebuild switch --flake .#system-name`
      nixosConfigurations = self.lib.readPackages
        (import)
        ./nixos/system
        { inherit flake self inputs; };

      # User home directory configurations (Home Manager)
      # Declared in ./home-manager/user/NAME
      # Available through `nix run dream#home-manager -- switch --flake .#user-name` (initial)
      # Available through `home-manager switch --flake .#user-name` (afterwards)
      homeConfigurations = self.lib.readPackages
        (import)
        ./home-manager/user
        { inherit flake self inputs; };

      # The devshell
      # Available through `nix develop` or `nix-shell` (legacy)
      # devShells = forAllSystems (system: {
      #   default = self.legacyPackages.${system}.callPackage ./shell.nix {
      #     inherit inputs;
      #   };
      # });
      
      # Deployments
      # Available through `deploy .#deployment-name.profile-name`
      deploy.nodes.seht = let
        name = "seht";
        inherit (self.nixosConfigurations."${name}".config.nixpkgs.pkgs) system;
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
        profiles.home = rec {
          sshUser = "nrv";
          profilePath = "/home/${user}/.local/state/nix/profiles/home-manager";
          path = deployPkgs.deploy-rs.lib.activate.custom
            (self.homeConfigurations."${sshUser}").activationPackage
            "$PROFILE/activate";
          user = "${sshUser}";
        };
        profiles.hello = {
          sshUser = "nrv";
          path = deployPkgs.deploy-rs.lib.activate.custom
            self.legacyPackages."${system}".hello
            "./bin/hello";
          user = "nrv";
        };
      };

      # Additional checks/tests for this flake validity
      # Available through `nix flake check`
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}

# vim:et:sw=2:ts=2:sts=2
