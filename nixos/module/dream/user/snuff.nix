{
  self ? null,
  ...
}:
{
  config ? null,
  lib ? null,
  ...
}:
with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.user.snuff;
  name = "snuff";
in {
  options.dream.user.snuff = {
    enable = mkEnableOption "Enable user.snuff";
  };
  config = mkIf cfg.enable {
    users.users = {
      ${name} = {
        initialPassword = "123";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCudwg8NGJElcgwsiQcnxWkLpN8VvsEZo7Wf9e7MJNeDL1dMU5kLM/KdIa9FLW6ljzgw/uaah7ZpidYn0t0zUqiZSlytB/thAlke/IyWr3EbvOWUN8MtcAYnqRWDMMxNR5VzYgKDdxJmvEOuEDjTAtpSWRGJ87tPwZezORNrILYJLR6/pLmqL6NMfPcRPBM3DIUNXJS03Wx1b94NoMYh/QK8NUIW8H1fCRdiQBWTkgCbl5urnktPlFS4BPDl7IuNUbILy49IAS7OquCRIK2EyccXFEs6xk/IP+YvdTiZubi6B6zkj02bABAaWHMQdtKm4+9bAOWX2Pc80wI8ZcxL1XQoVVMUdDL2qg6JETqL0jPU1wKXNmjBl+Xc2WjfO6V9s0/H23QR8dtskON6JwZ41x6QaOxfRm/NNc3gqz+nWvyE2uEDLhzd6Y9OCu4d4F+9vzFIYiVfc2irfkA0a/l+86U/IBdD4GGmAvVwZmRNHbDmzhsmIkgZfHCVzT6Nvwf71c="
        ];
        extraGroups = [ "wheel" ];
      };
    };
  };
}

