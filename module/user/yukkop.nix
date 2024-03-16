{ ... }:
{ ... }:
let
  name = "yukkop";
in {
  users.users = {
    ${name} = {
      initialPassword = "kk";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDlU/9+sOZeGpF09gjKbfgtKUP98ZQAB2UKhINjGeXjjZ8BW/3NOdL2MLwZWQtNJRSIGONMiCN9v+1gJQ0Zr3jBALubSV4oei+GlpktOrLAvjp5aeBib5TXE1McghHtSxSlVl5PCnez7+4l26EDIY9dzOyxazO/2D1uIhxI2/msJ8avIxWaONK3Qgb7YhBqYRxQLh6Z3UtOjuSTy8xuqt+uHAHucOaW+pkM9J2xcWNERZCQb8vszktOvzk271FprdJXC6zDoHfAc8tjB1jixkzRSCWbn3MCHvtxb2KNNTqkSqgM/cZSYd9BmQB1UukHfhDlUN3hW4+wKhRzr1GXsw3jDCtKSS5Ff1WyWTzhg3wM+ILgUQztaCaWNw6f5xskN/+hB6/W5m/askpQN3Yf5lwuk1gVS7/gNM9BO2wrqohVledpLEVBhETJqhesXQjh90Wo2HvBL3ueiFuCZgNec4XLMmsJjwBDQW6sjdb/QDvRCKmkZB/74z1r7MVN5oeLk/E="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC19D4ueaD+VfoEqwIDk4r6pfYz8POyk1fokTicBrE9F7OmsuvP/NahImuSRMsPszLx1n07vwh9WNEVFmU3YOikBsn/oOn0qXTyW3rKpHjfQ2ACgLfCL0LZwmiE/lTzvYyFz+9deRk8KutiCkgKCqMi7d17SWtJGwtHvRwpUnvHYTL9/u/mugbcnFk24wt+rhBWVnH+M4kHvTaImUwjlZ7fBW6F7XDrcF9TYdOrFo8NTPHsDq4z4iHtMuXS+OvjtMcIN2vrG9hc8Z1SAWZwJJFaMjbvd4Wh/dxnTUYY1+k/CPIwxLDzjGvGiCvZTEloppzX2GnR8VBzDX1My3VLuEz+GmiPSU6THhHv/F2vSjzxzm+y99OG8QYvy0B4zqX6VeErzfI2Ofg7ObYfduVVPhZMDB8pXWY3+tzsx3MU2z0AtnvdKLMs11JIhXC9vWFwiotUaIgjVr82TkkJOxfSbDVohpkfsNO63b7m0cr45KF4iz9cLnePu4noZrd6aciVj38="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiz0LNCel14SPwmKm2KGbG+95kMHAzrK5WEcNaIApfy5IciRQhuCv2otDRPcp5DbRqLslim5awUcWnGstYfTL785felbMStmLQ2wiYDktZU04JNfeiUqKLV/CdIMe1hw4eExQYYY3pprX8cbMQnjcmyFPGADNxOTEsf2eTLTqGlhZmxy0xbYEu205hCcx/5VbmY23AHC0s7E95hMnu6R6bPvNXp/oQWH941mCwowAqa5asMw10MDOoDPGAYBMdk+oOiabmfssTZXaiyzStvcxLAR1DAV56TrLPsZb3rjt19W2Gew1jF+aTDKrhQ2oMJWhE3Lj+T/T9aYeUHle3EZNQpAfqRnuTGN3OjXrvcZmxkxg6uzePXsl9Mv6UodIGFlygVsQgP76g0rha817minAJEyAGKgkIVaudJTqmosIm7urXoO7+8c9iuC1PfftM7KBrLYoJ+ItWZbb5SgsL6VULag+eX6Jjtz4qCeqBzzs3Vioc9HeHzVV2KmVA9wXyJO8="
      ]; 
      extraGroups = [ "wheel" ];
    };
  };
}
