{
  config,
  lib,
  pkgs,
  inputs,
  stable-pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./packages.nix
    inputs.spicetify-nix.nixosModules.default
    inputs.monique.nixosModules.default
  ];

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true; # if not already implied by enableAllFirmware

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableAllFirmware = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libxcb-cursor
      xorg.libxcb
    ];
  };
  boot.loader.systemd-boot.configurationLimit = 6;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Zram swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024; # 16GB
    }
  ];

  time.timeZone = "Africa/Lome";
  console.keyMap = "fr";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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

  nixpkgs.config = {
    allowUnfree = true;

    permittedInsecurePackages = [
      "electron-40.10.5"
    ];
  };

  users.users.credo = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      # android
      "adbusers"
      "kvm"
    ];
  };

  fonts.packages = with pkgs; [
    inter
    inputs.apple-fonts.packages.${pkgs.system}.sf-pro
    inputs.apple-fonts.packages.${pkgs.system}.sf-mono
    inputs.apple-fonts.packages.${pkgs.system}.ny
  ];

  programs.firefox.enable = true;
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


  # DB for key-value gnome and gtk config
  programs.dconf.enable = true;

  # To allow using plg from /usr/bin/  ex : for shebang
  services.envfs.enable = true;

  services.upower.enable = true;

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ]; # applies to all keyboards
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

  systemd.services.fix-huawei-speaker-mixer = {
    description = "Unmute ES8336 ACP speaker routing + master output gate";
    wantedBy = [ "multi-user.target" ];
    after = [ "sound.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "unmute-es8336" ''
        AMIXER="${pkgs.alsa-utils}/bin/amixer -c acp3xes83xx"
        $AMIXER set 'Left Headphone Mixer Left DAC' unmute
        $AMIXER set 'Right Headphone Mixer Right DAC' unmute
        $AMIXER set 'Left Headphone Mixer LLIN' unmute
        $AMIXER set 'Right Headphone Mixer RLIN' unmute
        $AMIXER set 'Headphone' unmute
      '';
    };
  };

  # ANDROID DEV SETUP
  nixpkgs.config.android_sdk.accept_license = true;

  programs.monique.enable = true;
  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle # shuffle+ (special characters are sanitized out of extension names)
      ];
      enabledCustomApps = with spicePkgs.apps; [
        newReleases
        ncsVisualizer
        marketplace
      ];
    };

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    environmentFile = "/home/credo/.searxng.env";
    settings.server = {
      bind_address = "::1";
      port = 8087;

      ui = {
        static_use_hash = true;
        query_in_title = true;
        infinite_scroll = false;
        center_alignment = true;
        default_theme = "simple";
        theme_args.simple_style = "auto";
        search_on_category_select = false;
        hotkeys = "vim";
      };
      # WARNING: setting secret_key here might expose it to the nix cache
      # see below for the sops or environment file instructions to prevent this
      # secret_key = "Your secret key.";
    };

  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Remote access config
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # "client" suffit ici, "both" seulement si tu veux exposer des sous-réseaux
  };

  # Permet au firewall NixOS de laisser passer le trafic Tailscale
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose"; # nécessaire pour éviter des soucis de routing sur l'interface tailscale
  };
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.credo.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBxUvER9WbiDVlLIpgZdLlF17vBI1laOobL2PkPjZ9X credo@work-to-home"
  ];
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
