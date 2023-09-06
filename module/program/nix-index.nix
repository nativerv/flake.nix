{ inputs, ... }:
{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  # programs.nix-index.enable = true;
  # programs.nix-index.package = ;
  programs.nix-index.enableBashIntegration = false;
  programs.nix-index.enableZshIntegration = false;
  programs.nix-index.enableFishIntegration = false;
}
