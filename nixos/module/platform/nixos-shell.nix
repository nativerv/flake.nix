{
  inputs ? null,
  ...
}:
{ ... }:
{
  imports = [
    inputs.nixos-shell.nixosModules.nixos-shell
  ];
  nixos-shell.mounts = {
    mountHome = false;
    mountNixProfile = false;
    cache = "none"; # default is "loose"
  };
}
