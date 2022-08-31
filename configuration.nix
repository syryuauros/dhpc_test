{ pkgs, config, ...}:
{

users.users."nixos" = {
  isNormalUser = true;
  #hashedPassword = "$6$r0ZcYzqI6A.8MvQj$SxK4ltqq3Ek4XfMacWojzjJvlLmG1i6oCi4fp92Krx4YnpwINg5BHPUcvU76HWC20cHUlPRATFEOnVmF.rVcC/";
  password = "auros1";
  #hashedPassword = "$6$mUMOL9Q9R746jX3m$b5uOnxMu2HEBEISQFDPePOTxVE6nNhU/7RVrgVHmZq8aH6CUzwzBBxCcf3yxYqdsHsNt1bQKlbBjiSxb4GdRR/";
  #openssh.authorizedKeys.keys = [
   #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwOvMlnEB1Qk2Aj/R7CcCSnzu3LlBrS6eh75IZzFEe4 auros"
    #];
};
}
