{
  ...
}:
{
  pkgs ? null,
  ...
}:
{
  nix.package = pkgs.nixVersions.git;
}
