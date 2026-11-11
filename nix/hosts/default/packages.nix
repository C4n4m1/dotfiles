{
  pkgs,
  inputs,
  stable-pkgs,
  ...
}:

let
  # androidComposition = pkgs.androidenv.composeAndroidPackages {
  #   # cmdLineToolsVersion = "13.0";
  #   # platformToolsVersion = "36.0.2";
  #   # buildToolsVersions = [ "36.0.0" ];
  #   # 37.1 only ships a "google_apis_playstore_ps16k" image, so pin 37.0 to get
  #   # the regular google_apis_playstore image that avdmanager expects.
  #   platformVersions = [ "37.0" ];
  #   abiVersions = [ "x86_64" ]; # match your host CPU for KVM accel
  #   systemImageTypes = [ "google_apis_playstore" ];
  #   includeSystemImages = true;
  #   includeEmulator = true;
  #   includeNDK = false; # set true if you need native builds
  #   useGoogleAPIs = true;
  # };
  # androidSdk = androidComposition.androidsdk;
  hayase = pkgs.callPackage ./custom-pkgs/hayase.nix { };
  tusk = pkgs.callPackage ./custom-pkgs/tusk.nix { };
in
{
  environment.sessionVariables = {
    # ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    # ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    # ANDROID_AVD_HOME = "$HOME/.android/avd";
    LD_LIBRARY_PATH = [ "${pkgs.libxcb-cursor}/lib" ];
    # JAVA_HOME = "${pkgs.jdk17.home}";
    DICPATH = "/run/current-system/sw/share/hunspell";
    QT_QPA_PLAFORM = "wayland";
    SQLITE_CLIB_PATH = "${stable-pkgs.sqlite.out}/lib/libsqlite3.so";
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
  };

  environment.systemPackages = with pkgs; [
    # ANDROID DEV
    # androidSdk
    # pkgs.jdk17
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
    ripgrep

    (inputs.quickshell.packages.${pkgs.system}.default.withModules [
      pkgs.qt6.qt5compat
      pkgs.qt6.qtwayland
    ])

    # PROGRAMING
    cargo
    rustc
    rustfmt
    clippy
    rust-analyzer
    zig
    zed-editor # unstable
    nodejs # unstable
    gcc
    clang
    sqlite
    sqlitebrowser
    php
    opencode
    jq
    herdr # unstable
    # LSP
    nixd
    nil
    pnpm
    kdePackages.qtdeclarative # for qmlls

    # GAMING
    gamescope
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
    komikku
    papers
    qbittorrent
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

    # kdePackages.dolphin
    # kdePackages.dolphin-plugins
    # kdePackages.kio-extras # sftp, fish, etc.
    # kdePackages.ffmpegthumbs # video thumbnails
    # kdePackages.kdegraphics-thumbnailers
    # kdePackages.qtsvg # SVG icon support (needed outside KDE!)
    # kdePackages.kimageformats # extra image format previews
    # qt6Packages.qt6ct # Qt theming outside Plasma
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
    love
    unzip
    dig
    tunnelto
    krita
    imagemagick
    cava
    drawio
    libreoffice-qt-fresh
    obs-studio
    nicotine-plus
    proton-pass
    dysk
    gnome-disk-utility
    hyphenDicts.fr_FR
    hunspellDicts.fr-moderne
    hunspell
    scrcpy
    ddcutil
    # anytype
    proton-vpn
    helium
    nnn
    penpot-desktop
    inputs.amane.packages.x86_64-linux.default
    devenv
    helix
    python3
    jetbrains.idea
    tusk
    dbeaver-bin
    qgis
  ];
}
