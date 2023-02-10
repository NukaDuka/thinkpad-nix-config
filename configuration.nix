# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./work-vars.nix
      (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.supportedFilesystems = ["zfs"];
  boot.supportedFilesystems = ["zfs" "ntfs" ];
  services.udev.extraRules = ''
  ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
''; 

  networking.hostId = "0905a491";
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #networking.wireless.userControlled.enable = true;
  #networking.wireless.userControlled.group = "wheel";
  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  networking.networkmanager = {
    enable = true;
  };
  networking.wireless.interfaces = ["wlp0s20f3"];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.vscode-server.enable = true;
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    videoDrivers = [ "displaylink" "modesetting" ];
  };

  services.displayManager.sddm.enable = true;

  # Enable the Plasma 5 Desktop Environment

  services.jenkins = {
    enable = false;
    withCLI = true;
    extraOptions = [
      "--debug=5"
    ];
    extraJavaOptions = [
      "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true"
    ];
    extraGroups = [
      "docker"
    ];
  };

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  networking.firewall.allowedTCPPorts = [ 3389 8080 ];
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  services.blueman.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nukaduka1 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "docker" "libvirtd"];
  };

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio"];
  };

  users.users.sandbox = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "docker" ];
    #packages = [];
  };

  security.sudo.extraRules = [
    {  
      users = [ "nukaduka1" "admin" "sandbox" ];
      commands = [
        {
           command = "ALL" ;
           options= [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    osu-lazer
    cmatrix
    vim
    arandr
    awscli
    btop
    git
    wget
    element-desktop
    firefox
    google-chrome
    google-cloud-sdk
    gnumake
    htop
    insomnia
    spotify
    wpa_supplicant_gui
    jq
    killall
    kubectl
    kustomize
    #kpt # TODO: update upstream kpt to >1.0.0
    openvpn
    vscode
    virt-manager
    tmux
    tmux-cssh
    tree
    screen
    python3
    (pass.withExtensions (exts: [ exts.pass-otp ]))
    mosh
    ncdu
    nix-prefetch-github
    nix-tree
    dig
    file
    rsync
    remmina
    pavucontrol
    pinentry-qt
    #perlPackages.AppClusterSSH
    pciutils
    prismlauncher
    unzip
    vault
    wireguard-tools
  ];
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
#    pinentryPackage = pkgs.qt;
  };
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };
  virtualisation.libvirtd.enable = true;

  nix.extraOptions = ''
    experimental-features = flakes nix-command
  '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

