{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.limine.enable = true;
  boot.loader.limine.secureBoot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Helsinki";

  i18n.defaultLocale = "en_IE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IE.UTF-8";
    LC_IDENTIFICATION = "en_IE.UTF-8";
    LC_MEASUREMENT = "en_IE.UTF-8";
    LC_MONETARY = "en_IE.UTF-8";
    LC_NAME = "en_IE.UTF-8";
    LC_NUMERIC = "en_IE.UTF-8";
    LC_PAPER = "en_IE.UTF-8";
    LC_TELEPHONE = "en_IE.UTF-8";
    LC_TIME = "en_IE.UTF-8";
  };

  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.hyprland = {
    enable = true;
    package = pkgs.hyprland.overrideAttrs (previousAttrs: {
      postInstall = (previousAttrs.postInstall or "") + ''
        unlink $out/share/hypr/wall1.png
        ln -s /home/vagrant/Pictures/background.png $out/share/hypr/wall1.png
      '';
    });
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.vagrant = {
    isNormalUser = true;
    description = "vagrant";
    initialPassword = "vagrant";
    extraGroups = [
      "networkmanager"
      "wheel"
      "wireshark"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDG1RxSv4/jqqoE8LHgWpmUB1KsnjWYATn7ytFGD/Agh"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7LBeZiV+t8zdZMPMEnAO7x6t2bDLncdL6TGJctxYQ7"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "vagrant" ];
      commands = [
        {
          command = "ALL";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
      ];
    }
  ];

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "vagrant" ];
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  programs.firefox.enable = true;
  programs.thunderbird.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty
    bat
    ctags
    curl
    diff-so-fancy
    fd
    fzf
    gcc
    gdb
    ghidra
    ghostty
    git
    gnome-tweaks
    gnumake
    htop
    hyprlock
    killall
    mokutil
    neovim
    nixfmt-rfc-style
    ripgrep
    sbctl
    strace
    tmux
    tree
    vim
    wget
    wireshark
    wl-clipboard
    xxd
  ];

  programs.wireshark.enable = true;
  programs.fish.enable = true;
  users.users.vagrant.shell = pkgs.fish;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  system.stateVersion = "25.05";

}
