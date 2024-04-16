{
  self,
  ...
}: {
  /* Default nixpkgs config */
  nixpkgs = pkgs: {
    allowUnfreePredicate = self.lib.unfreeWhiteList (with pkgs; [
      #hello-unfree
    ]);
  };
}
