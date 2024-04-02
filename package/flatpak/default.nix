{ flatpak, ... }: flatpak.overrideAttrs (o: {
  patches = (o.patches or []) ++ [ ./debug-bwrap-args.patch ];
})
