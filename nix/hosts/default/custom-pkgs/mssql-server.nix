{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mssql-server;
in
{
  options.services.mssql-server = {
    enable = lib.mkEnableOption "Microsoft SQL Server (repackaged upstream binaries)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.mssql-server;
      defaultText = lib.literalExpression "pkgs.mssql-server";
      description = "The mssql-server package to run.";
    };

    acceptEula = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Accept the SQL Server license terms
        (https://www.microsoft.com/licensing/product-licensing/sql-server).
        The service refuses to be enabled until this is set to true.
      '';
    };

    edition = lib.mkOption {
      type = lib.types.str;
      default = "Developer";
      example = "Express";
      description = ''
        Value of MSSQL_PID: Developer, Express, Standard, Enterprise, Web, or a
        product key. Developer is free but not licensed for production use.
        It is only applied on the first start, when the system databases are
        created; changing it later has no effect.
      '';
    };

    saPasswordFile = lib.mkOption {
      type = lib.types.str;
      example = "/var/lib/mssql-sa-password";
      description = ''
        Absolute path to a file containing the `sa` password, kept out of the
        Nix store. It is only used on the very first start, when the system
        databases are created. The file is read by systemd as root and passed
        to the service as a credential, so it may be root-owned and mode 0600.

        It must satisfy the SQL Server policy: at least 8 characters, from
        three of: uppercase, lowercase, digits, symbols.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open TCP port 1433 in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.acceptEula;
        message = "services.mssql-server.acceptEula must be set to true to run SQL Server.";
      }
      {
        assertion = lib.hasPrefix "/" cfg.saPasswordFile;
        message = "services.mssql-server.saPasswordFile must be an absolute path.";
      }
      {
        assertion = !lib.hasPrefix "${builtins.storeDir}/" cfg.saPasswordFile;
        message = "services.mssql-server.saPasswordFile must not point into the Nix store (a path literal such as ./secret is copied there; use a string instead).";
      }
    ];

    users.users.mssql = {
      isSystemUser = true;
      group = "mssql";
      home = "/var/opt/mssql";
      description = "Microsoft SQL Server";
    };
    users.groups.mssql = { };

    # SQL Server hardcodes /opt/mssql and /var/opt/mssql.
    # Restart the service after a rebuild that changes the package so it picks
    # up the retargeted symlink.
    systemd.tmpfiles.rules = [
      "d /opt 0755 root root - -"
      "d /var/opt 0755 root root - -"
      "d /var/opt/mssql 0750 mssql mssql - -"
      "L+ /opt/mssql - - - - ${cfg.package}/opt/mssql"
    ];

    environment.systemPackages = [ cfg.package ];

    # NixOS already ships vm.max_map_count = 1048576, well above Microsoft's
    # recommended minimum of 262144, so there is nothing to set here.

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 1433 ];

    systemd.services.mssql-server = {
      description = "Microsoft SQL Server Database Engine";
      documentation = [ "https://learn.microsoft.com/en-us/sql/linux/" ];
      after = [
        "network.target"
        "systemd-tmpfiles-setup.service"
      ];
      wantedBy = [ "multi-user.target" ];

      unitConfig = {
        # Same restart policy as the unit shipped by Microsoft.
        StartLimitIntervalSec = 120;
        StartLimitBurst = 3;
      };

      environment = {
        ACCEPT_EULA = "Y";
        MSSQL_PID = cfg.edition;
      };

      # Same approach as the official container image: no `mssql-conf setup`,
      # sqlservr reads the env vars on first start and creates the system
      # databases itself. The image only adds a permissions notice and an
      # optional post-start "custom setup" step, neither of which is needed.
      script = ''
        MSSQL_SA_PASSWORD="$(< "$CREDENTIALS_DIRECTORY/sa-password")"
        export MSSQL_SA_PASSWORD
        exec /opt/mssql/bin/sqlservr
      '';

      serviceConfig = {
        User = "mssql";
        Group = "mssql";
        LoadCredential = "sa-password:${cfg.saPasswordFile}";
        WorkingDirectory = "/var/opt/mssql";
        Restart = "on-failure";
        RestartSec = 5;

        # Mirrors Microsoft's mssql-server.service. SQL Server spawns helper
        # processes, hence KillMode=process.
        KillMode = "process";
        TimeoutSec = "30min";
        LimitNPROC = "infinity";
        LimitNOFILE = 1048576;
        TasksMax = "infinity";
        UMask = "007";
      };
    };
  };
}
