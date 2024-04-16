{ ... }:
{ ... }:

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

{
  zramSwap.enable = true;
  zramSwap.priority  = 100;
  zramSwap.memoryMax = null;
  zramSwap.algorithm = "zstd"; # lzo
  #zramSwap.numDevices = 1; # no longer supported
  zramSwap.swapDevices = 2;
  zramSwap.memoryPercent = 50;
}
