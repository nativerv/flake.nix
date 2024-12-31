{ direnv, ... }: direnv.overrideAttrs (o: {
  patches = (o.patches or []) ++ [ ./direnv-xdg-state-dir.patch ];
})
