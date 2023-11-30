{ self, inputs, flake, lib, ... }: rec {
  # Create pkgs from supplied nixpkgs with default overlays and config of this flake.
  # `system` specifies architecture as usual.
  # If you want the config separately you can access it from the result of this
  # function under `config` attribute.
  mkPkgs = nixpkgs: system: import nixpkgs {
    inherit system;
    overlays = [ self.overlays.default ];
    config = {
      allowUnfreePredicate = unfreeWhiteList (with nixpkgs; []);
    };
  };

  # Make a whitelist predicate for allowUnfreePredicate
  # Useful because package 'names' and actual package names in `nixpkgs.pkgs` can differ
  unfreeWhiteList = list: pkg: builtins.elem (lib.getName pkg) (map lib.getName list);

  # For knowing if the repo is locked
  isLocked = !(builtins.readFile ../locked == "0");
  ifUnlocked = lib.optional (!isLocked);

  /*
    Utility for NisOS configuration creation with sane defaults.

    Example:
     ```nix
     mkNixosConfiguration inputs.nixpkgs-unstable "my-system" { system = "x86_64-linux"; }
     ```
       => an `x86_64-linux` system with configuration at
       `module/system/my-system.nix`, pkgs from `inputs.nixpkgs-unstable` with
       default overlay of this flake, hostname 'my-system', and this flake,
       this flake's inputs and this flake's root path passed as special args to
       modules.

     ```nix
     mkNixosConfiguration inputs.nixpkgs-23-05 "my-system-custom" {
       system = "aarch64-linux"; 
       pkgs = mypkgs;
       lib = mypkgs.lib;
       modules = [
         ./path/to/configuration.nix
         ({ networking.hostName = "my-system-hostname" })
       ];
       specialArgs = { inherit foo bar baz; }
     }
     ```
       => an `aarch64-linux` system with configuration called
       "my-system-custom" at `module/system/my-system-custom.nix`, with pkgs
       `mypkgs`, lib `mypkgs.lib`, hostname 'my-system-hostname', and foo, bar
       and baz passed as special args to modules.
       Any omitted args will be substituted with defaults. This function is
       less usable if you don't want the defaults of this flake.

    Type:
      mkNixosConfiguration :: Any -> String -> Any -> { name :: String; value :: Any; }
  */
  mkNixosConfiguration = nixpkgs: name: args: {
    inherit name;
    value = let
      system = args.system;
      pkgs = mkPkgs nixpkgs system;
      lib = pkgs.lib;
    in nixpkgs.lib.nixosSystem (args // {
      inherit system;
      pkgs = args.pkgs or pkgs;
      lib = args.lib or lib;
      modules = args.modules or [
        ../module/system/${name}.nix
        ({ networking.hostName = name; })
      ];
      specialArgs = args.specialArgs or { inherit self inputs flake; }; # Pass flake inputs to our config
    });
  };
}
