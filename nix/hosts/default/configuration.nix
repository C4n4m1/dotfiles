# Edit this configuration file to define what should be installed on

# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, unstable-pkgs, node-pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

    nixpkgs.config.permittedInsecurePackages = [
      "pnpm-10.29.2"
    ];
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;  # if not already implied by enableAllFirmware

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableAllFirmware = true;
  programs.nix-ld.enable = true;
  boot.loader.systemd-boot.configurationLimit = 6;

  networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Zram swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Local / TimeZone
  time.timeZone = "Africa/Lome";
  # i18n.defaultLocale = "fr_FR.UTF-8";
  console.keyMap = "fr";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Wayland / Niri
  programs.niri.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  nixpkgs.config.allowUnfree = true;
  users.users.credo = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["wheel" "networkmanager" "video" "audio" ];
  };

  # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = with pkgs; [
      # UTILITY / SYSTEM
      vim
      wget
      ghostty
      git
      curl
      fish
      neovim
      nautilus
      eza
      zoxide
      fzf
      keyd
      awww
      vivid
      starship
      brightnessctl
      fd
      bat
      dysk
      gowall
      ntfs3g
      stow

      (inputs.quickshell.packages.${pkgs.system}.default.withModules [
        pkgs.qt6.qt5compat
        pkgs.qt6.qtwayland
      ])

      # PROGRAMING
      rustup
      rustc
      zig
      zed-editor
      node-pkgs.nodejs
      gcc
      clang
      mariadb
      sqlite
      sqlitebrowser
      php
      opencode
      jq
      unstable-pkgs.herdr

      # GAMING
      gamescope
      wine

      # APPS
      pavucontrol
      chromium
      # obsidian
      cine
      blueman
      spotify
      # vesktop
      fastfetch
      komikku
      libreoffice
      papers
      qbittorrent
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      unstable-pkgs.kopuz
      gnome-calculator
      gnome-clocks
      upscaler
      networkmanagerapplet
      qt6Packages.qt6ct
      yt-dlp
      btop
      kdePackages.dolphin
      kdePackages.gwenview

      # Screenshots combo
      satty
      grim
      slurp

      qgnomeplatform-qt6
      adwaita-qt6
    ];

    fonts.packages = with pkgs; [
      inter
      inputs.apple-fonts.packages.${pkgs.system}.sf-pro
      inputs.apple-fonts.packages.${pkgs.system}.sf-mono
      inputs.apple-fonts.packages.${pkgs.system}.ny
    ];

  # environment.variables = {
  #   XCURSOR_THEME = "Bibata-Modern-Classic";
  #   XCURSOR_SIZE = "24";
  # };

  programs.firefox.enable = true;

  # fish as default shell
  programs.fish.enable = true;

  # Home manager
  home-manager = {
     extraSpecialArgs = { inherit inputs; };
     users = {
       "credo" = import ./home.nix;
    };
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # SERVICES

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # DB for key-value gnome and gtk config
  programs.dconf.enable = true;

  # To allow using plg from /usr/bin/  ex : for shebang
  services.envfs.enable = true;

  services.upower.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];  # applies to all keyboards
        settings = {
          main = {
            escape = "capslock";
            capslock = "overload(control, escape)";
            enter = "overload(meta, enter)";
          };
        };
      };
    };
  };

  # USB auto mount
  services.gvfs.enable = true;
  services.udisks2.enable = true;


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
