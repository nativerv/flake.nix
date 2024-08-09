{
  self,
}:
final:
prev: {
  wrapPackages = self.lib.wrapPackages prev;
}
