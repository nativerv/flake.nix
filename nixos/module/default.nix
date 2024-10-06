{
  flake,
  self,
  inputs,
}:
with builtins;
with inputs.nixpkgs-24-05.lib;
with self.lib;
let
  # Combine dream modules into one
  dream.imports = attrValues (readModulesRecursive'
    ./dream
    { inherit flake self inputs; });
  # Read generic modules seperately
  generic = readModulesRecursive'
    ./generic
    { inherit flake self inputs; };
in generic // { inherit dream; }
