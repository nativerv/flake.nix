{
  modulesPath ? null,
  ...
}: {
  imports = [
    # modulesPath is provided by `lib.nixosSystem` function
    # it points to whatever nixpkgs repo that function comes from,
    # so you can include it's modules.
    # example: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/digital-ocean-config.nix
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];
}
