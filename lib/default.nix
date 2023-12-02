{ self, inputs, flake, lib, ... }: rec {
  /* Create pkgs from supplied nixpkgs with default overlays and config of this flake.
     `system` specifies architecture as usual.
     If you want the config separately you can access it from the result of this
     function under `config` attribute.
  */
  mkPkgs = nixpkgs: system: import nixpkgs {
    inherit system;
    overlays = [ self.overlays.default ];
    config = {
      allowUnfreePredicate = unfreeWhiteList (with nixpkgs; []);
    };
  };

  /* Make a whitelist predicate for allowUnfreePredicate
     Useful because package 'names' and actual package names in `nixpkgs.pkgs` can differ
  */
  unfreeWhiteList = list: pkg: builtins.elem (lib.getName pkg) (map lib.getName list);

  /* For knowing if the repo is locked */
  isLocked = !(builtins.readFile ../locked == "0");
  ifUnlocked = lib.optional (!isLocked);

  /* Default nixpkgs config */
  defaultConfig = nixpkgs: {
    allowUnfreePredicate = unfreeWhiteList (with nixpkgs; [
    ]);
  };

  /* Utility for NisOS configuration creation with sane defaults.

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

     ```nix
     mkNixosConfiguration inputs.nixpkgs-23-05 "my-system-custom" {
       system = "x86_64-linux"; 
       overlays = [ foo bar baz ];
       config = { allowUnfree = true; };
       specialArgs = { inherit a b c; }
     }
     ```
       => an `aarch64-linux` system with configuration called
       "my-system-custom" at `module/system/my-system-custom.nix`, with pkgs
       from `inputs.nixpkgs-23-05`, lib from `inputs.nixpkgs-23-05`, hostname
       'my-system-hostname', overlays foo, bar and baz, nixpkgs config with
       unfree software enabled and a, b and c passed as special args to
       modules.
       NOTE: if you pass pkgs or lib directly it will not use overlays and
       config provided.

     Type:
       Options :: {
         system :: String;        # system architecture
         config :: AttrSet;       # see docs on `nixpkgs.config`
         overlays :: [OverlayFn]; # see the docs on nixpkgs overlays
         pkgs :: AttrSet;         # package set
         lib :: AttrSet;          # nixpkgs library attrset
         specialArgs :: AttrSet;  # custom arguments to pass to modules
       }
       mkNixosConfiguration :: Nixpkgs -> String -> Options -> { name :: String; value :: NixosSystem; }
  */
  mkNixosConfiguration =
  with builtins;
  nixpkgs:
  name:
  options@{
    config ? defaultConfig nixpkgs,
    overlays ? [ self.overlays.default ],
    ...
  }: {
    inherit name;
    value = let
      args = removeAttrs options [ "config" "overlays" ];
      pkgs = import nixpkgs {
        inherit (args) system;
        inherit overlays config;
      };
      lib = pkgs.lib;
      systemModulePath = ../module/system/${name}.nix;
      systemModule = filter pathExists [ systemModulePath ];
    in nixpkgs.lib.nixosSystem (args // {
      pkgs = args.pkgs or pkgs;
      lib = args.lib or lib;
      modules = args.modules or [
        ({ networking.hostName = name; })
      ]
      ++ lib.warnIf (systemModule == [] && !(args ? modules))
        "Module '${toString systemModulePath}' does not exist and you haven't provided your own modules. Default NixOS system will be built."
        systemModule;
      specialArgs = args.specialArgs or { inherit self inputs flake; }; # Pass flake inputs to our config
    });
  };

  /* Supplied a directory, reads it's recursive structure into NixOS modules, so
     that provided a `./module` dir with `module/foo/bar.nix` in it it outputs
     ```nix
     {
       foo.bar = import ./module/foo/bar.nix
     }
    ```
  */
  readModulesRecursive = path:
    lib.mapAttrs' (
      name: value: let
        name' = builtins.replaceStrings [".nix"] [""] name;
      in
        if value == "regular"
        then {
          name = name';
          value = import "${path}/${name}";
        }
        else {
          inherit name;
          value = readModulesRecursive "${path}/${name}";
        }
    ) (builtins.readDir path);

  # Like readModulesRecursive, but reads module structure as a one-level keys,
  # so that it is suited for `nix flake show`
  # ```nix
  # {
  #   "foo.bar" = import ./module/foo/bar.nix
  # }
  # ```
  readModulesRecursive' = path:
    with lib;
    with builtins; let
      paths = pipe "${path}" [
        (filesystem.listFilesRecursive)
        (filter (hasSuffix ".nix"))
      ];
      pathToName = flip pipe [
        (removePrefix "${path}/")
        (replaceStrings ["/" ".nix"] ["." ""])
        (removeSuffix ".nix")
      ];
      attrList =
        map (path': {
          name = pathToName (unsafeDiscardStringContext path');
          value = import path';
        })
        paths;
    in
      listToAttrs attrList;
}
