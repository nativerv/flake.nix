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

    # Home manager
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs =
    { nixpkgs-unstable
    , disko
    , nix-index-database
    , nixpkgs-22-11
      # , home-manager
    , ...
    } @ inputs:
    let
      lib = nixpkgs-unstable.lib;
      # FIXME: Is doing this and passing it directly to imports fine?
      # Modules get `pkgs` automatically.
      pkgs = nixpkgs-unstable.pkgs;
      flake = ./.;
    in
    {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations =
        let
          # FIXME: this looks ugly as hell. Is there some way 
          # to share hostname & stuff cleaner?
          seht =
            import ./module/system/seht.nix { inherit inputs pkgs lib flake; };
        in
        {
          ${seht.networking.hostName} = nixpkgs-unstable.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./module/system/seht.nix ];
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
