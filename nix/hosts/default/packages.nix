{
  pkgs,
  inputs,
  stable-pkgs,
  ...
}:

let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    cmdLineToolsVersion = "13.0";
    platformToolsVersion = "35.0.2";
    buildToolsVersions = [ "35.0.0" ];
    platformVersions = [ "35" ];
    abiVersions = [ "x86_64" ]; # match your host CPU for KVM accel
    systemImageTypes = [ "google_apis_playstore" ];
    includeSystemImages = true;
    includeEmulator = true;
    includeNDK = false; # set true if you need native builds
    useGoogleAPIs = true;
  };
  androidSdk = androidComposition.androidsdk;
in
{
  environment.sessionVariables = {
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    LD_LIBRARY_PATH = [ "${pkgs.libxcb-cursor}/lib" ];
    JAVA_HOME = "${pkgs.jdk17.home}";
    ANDROID_AVD_HOME = "$HOME/.android/avd";
    QT_QPA_PLAFORM = "wayland";
  };

  environment.systemPackages = with pkgs; [
    # ANDROID DEV
    androidSdk
    pkgs.jdk17
    xwayland-satellite

    # UTILITY / SYSTEM
    vim
    wget
    ghostty
    git
    curl
    stable-pkgs.fish
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
    nh
    libnotify

    (inputs.quickshell.packages.${pkgs.system}.default.withModules [
      pkgs.qt6.qt5compat
      pkgs.qt6.qtwayland
    ])

    # PROGRAMING
    rustup
    rustc
    zig
    zed-editor # unstable
    nodejs # unstable
    gcc
    clang
    mariadb
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

    # GAMING
    gamescope
    wine

    # APPS
    pavucontrol
    vicinae
    obsidian
    cine
    blueman
    spotify
    vesktop
    fastfetch
    komikku
    libreoffice
    papers
    qbittorrent
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    kopuz # unstable
    gnome-calculator
    gnome-clocks
    upscaler
    networkmanagerapplet
    qt6Packages.qt6ct
    yt-dlp
    btop

    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.kio-extras # sftp, fish, etc.
    kdePackages.ffmpegthumbs # video thumbnails
    kdePackages.kdegraphics-thumbnailers
    kdePackages.qtsvg # SVG icon support (needed outside KDE!)
    kdePackages.kimageformats # extra image format previews
    qt6Packages.qt6ct # Qt theming outside Plasma
    kdePackages.gwenview
    qdirstat

    # Screenshots combo
    satty
    grim
    slurp

    qgnomeplatform-qt6
    adwaita-qt6
    cmatrix
    lavat
    localsend
    hyprlock
    pandoc
    hyprpicker
    spicetify-cli
  ];
}
