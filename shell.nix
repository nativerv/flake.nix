{
  inputs ? null,
  self ? null,
  flake ? null,

  pkgs ? import <nixpkgs>,
  system ? pkgs.system,
}:
let
in pkgs.mkShell {
  name = "dream";

  nativeBuildInputs =
  with pkgs;
  with self.packageGroups.${system}.dream-devtools;
  [
    self.packages.${system}.sops
    with-secrets
  ];
}
