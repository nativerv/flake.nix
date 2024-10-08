{
  self ? null,
  ...
}:
{
  config ? null,
  lib ? null,
  ...
}:

# Storing Linux 5.9 rc4
# on a compressed zram block device 
# ---------------------------------
# Algorithm 	cp time 	Data 	Compressed 	Total
# lzo         4.571s    1.1G  387.8M      409.8M
# lzo-rle     4.471s    1.1G  388M        410M
# lz4         4.467s    1.1G  403.4M      426.4M
# lz4hc       14.584s   1.1G  362.8M      383.2M
# 842         22.574s   1.1G  538.6M      570.5M
# zstd        7.897s    1.1G  285.3M      298.8M 
# ---------------------------------
# Summary: lzo-rle --- best for speed
#          zstd    --- best for size

with builtins;
with lib;
with self.lib;
let
  cfg = config.dream.subsystem.zram;
in
{
  options.dream.subsystem.zram = {
    enable = mkEnableOption "Enable subsystem.zram - virtual swap by compressing memory";
    algorithm = mkOption {
      type = types.str;
      default = "lz4";
      example = "lzo";
    };
    memoryPercent = mkOption {
      type = types.int;
      default = 100;
      example = 50;
    };
  };
  config = mkIf cfg.enable {
    zramSwap.enable = true;
    zramSwap.priority  = 100;
    zramSwap.memoryMax = null;
    zramSwap.algorithm = mkDefault cfg.algorithm;
    zramSwap.swapDevices = 1;
    zramSwap.memoryPercent = mkDefault 100;
  };
}
