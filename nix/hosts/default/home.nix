{
  config,
  inputs,
  pkgs,
  node-pkgs,
  ...
}:

{
  home.username = "credo";
  home.homeDirectory = "/home/credo";

  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    sqlite
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };
  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.sqlite.out}/lib:$LD_LIBRARY_PATH";
  };
  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/credo/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    size = 24;
    package = pkgs.bibata-cursors;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    colorScheme = "dark";
    iconTheme = {
      name = "Colloid-Dark";
      package = pkgs.colloid-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    # style.name = "adwaita-dark";
    # style.package = pkgs.adwaita-qt6;
    qt6ctSettings = {
      Appearance = {
        icon_theme = "Colloid-Dark";
        standard_dialogs = "xdgdesktopportal";
        style = "adwaita-dark";
      };
      Fonts = {
        fixed = "\"Inter ,12\"";
        general = "\"Inter ,12\"";
      };
    };
  };

  # programs.vicinae = {
  #   enable = true; # default: false
  #   package = inputs.vicinae.packages.${pkgs.system}.default.override {
  #     nodejs = node-pkgs.nodejs;
  #   };
  #   systemd = {
  #     enable = false; # default: false
  #     autoStart = true; # default: false
  #   };
  # };

  xdg.configFile."dolphinrc".text = ''
    [General]
    Version=202

    [MainWindow]
    MenuBar=Disabled
    ToolBarsMovable=Disabled

    [PlacesPanel]
    Width=180
  '';

  xdg.configFile."kdeglobals".text = ''
    [General]
    TerminalApplication=ghostty
    TerminalService=ghostty.desktop

    [Icons]
    Theme=colloid-dark

    [Colors:View]
    BackgroundNormal=30,30,46
    ForegroundNormal=205,214,244
  '';

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
