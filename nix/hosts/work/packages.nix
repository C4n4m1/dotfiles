{
  pkgs,
  inputs,
  stable-pkgs,
  ...
}:

let
  hayase = pkgs.callPackage ./custom-pkgs/hayase.nix { };
in
{
  environment.sessionVariables = {
    DICPATH = "/run/current-system/sw/share/hunspell";
    QT_QPA_PLAFORM = "wayland";
  };

  environment.systemPackages = with pkgs; [
    # ANDROID DEV
    xwayland-satellite

    # UTILITY / SYSTEM
    vim
    wget
    ghostty
    git
    curl
    stable-pkgs.fish
    stable-pkgs.neovim
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
    nh
    libnotify

    (inputs.quickshell.packages.${pkgs.system}.default.withModules [
      pkgs.qt6.qt5compat
      pkgs.qt6.qtwayland
    ])

    # PROGRAMING
    zed-editor
    opencode
    jq
    nixd
    nil
    pnpm
    kdePackages.qtdeclarative # for qmlls

    # wine
    wine64

    # APPS
    pavucontrol
    vicinae
    obsidian
    cine
    blueman
    vesktop
    fastfetch
    papers
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    gnome-calculator
    gnome-clocks
    upscaler
    networkmanagerapplet
    qt6Packages.qt6ct
    yt-dlp
    btop
    spotify
    kdePackages.gwenview
    hayase

    qdirstat

    # Screenshots combo
    satty
    grim
    slurp

    qgnomeplatform-qt6
    adwaita-qt6
    localsend
    hyprlock
    pandoc
    hyprpicker
    code-cursor
    love
    unzip
    dig
    tunnelto
    imagemagick
    cava
    drawio
    libreoffice-qt-fresh
    obs-studio
    proton-pass
    dysk
    gnome-disk-utility
    hyphenDicts.fr_FR
    hunspellDicts.fr-moderne
    hunspell
    scrcpy
    ddcutil
  ];
}
