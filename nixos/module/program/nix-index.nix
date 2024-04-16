{
  inputs ? null,
  ...
}:
{ ... }:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  # programs.nix-index.enable = true;
  # programs.nix-index.package = ;
  programs.command-not-found.enable = false;
  programs.nix-index.enableBashIntegration = false;
  programs.nix-index.enableZshIntegration = false;
  programs.nix-index.enableFishIntegration = false;
}
