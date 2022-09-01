{ pkgs, config, ...}:
{

  users.users."nixos" = {
    isNormalUser = true;
    #hashedPassword = "$6$r0ZcYzqI6A.8MvQj$SxK4ltqq3Ek4XfMacWojzjJvlLmG1i6oCi4fp92Krx4YnpwINg5BHPUcvU76HWC20cHUlPRATFEOnVmF.rVcC/";
    password = "1234";
    #hashedPassword = "$6$mUMOL9Q9R746jX3m$b5uOnxMu2HEBEISQFDPePOTxVE6nNhU/7RVrgVHmZq8aH6CUzwzBBxCcf3yxYqdsHsNt1bQKlbBjiSxb4GdRR/";
    #openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwOvMlnEB1Qk2Aj/R7CcCSnzu3LlBrS6eh75IZzFEe4 auros"
      #];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Asia/Seoul";

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    trustedUsers = [ "root" "@admin" "@wheel" ];
  };

  networking = {
    hostName = "master";
    networkmanager.enable = true;
  };

  # 한글 및 폰트
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "kime";
      kime.config = {
        indicator.icon_color = "black";
        };
      };
    };

  #noto-fonts added
  fonts.enableFontDir = true;
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    inter
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;


  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;


  #   users.mutableUsers = false;
  #   users.users.nixos = {
  #     isNormalUser = true;
  #     uid = 1000;
  #     home = "/home/nixos";
  #     extraGroups = [ "wheel" "networkmanager" ];
  #   # to generate : nix-shell -p mkpasswd --run 'mkpasswd -m sha-512'
  #     hashedPassword = "$6$4eILJE5YFY$RDB8ra1mdoFaPscoDnEgoQBI83StsUEVhwUp2mAWK0b082ocZ44hdLBlRTPt.6IayLqr/6wuwRCTpxAacfE56.";
  #     openssh.authorizedKeys.keys = [
  #     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwOvMlnEB1Qk2Aj/R7CcCSnzu3LlBrS6eh75IZzFEe4 auros"
  #   ];
  # };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
    environment.systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      brave
      firefox
      git
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "22.05"; # Did you read the comment?

}

