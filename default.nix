# External module dependencies
let
  sources = import ./nix/sources;
  gitignoreSource = sources.gitignore.gitignoreSource;
in
{ config, lib, pkgs, ...}:
with pkgs.stdenv; with lib; with builtins; let
  cfg = config.services.kshaa-landing;
  dockerComposition = import ./docker-compose.nix {
    inherit pkgs;
    ENVIRONMENT_NAME = cfg.environmentName;
    SERVICE_PORT = cfg.internalProxyPort;
    EXTERNAL_URL = cfg.externalUrl;
    DATA_PATH = cfg.stateDir;
    APPLICATION_KEY = cfg.applicationKey;
    ADMIN_GITHUB_USER = cfg.githubAdminUser;
    GITHUB_CLIENT_ID = cfg.githubClientId;
    GITHUB_CLIENT_SECRET = cfg.githubClientSecret;
    POSTGRES_USER = cfg.postgresUser;
    POSTGRES_PASSWORD = cfg.postgresPassword;
    POSTGRES_DATABASE = cfg.postgresDatabase;
    PROJECT_SOURCE_PATH = "${./.}";
    EMAIL_NOTIFICATIONS = cfg.emailNotifications;
    SERVICE_EMAIL = cfg.serviceEmail;
    SERVICE_EMAIL_PASSWORD = cfg.serviceEmailPassword;
    ADMIN_EMAIL = cfg.adminEmail;
    backendImageName = cfg.backendImageName;
    frontendImageName = cfg.frontendImageName;
  };
  dockerCompositionJSON = pkgs.writeText "landing.docker-compose.json" (toJSON dockerComposition);
in
{
  # Options for the service
  options.services.kshaa-landing = {
    # Linux user, group, filesystem, network info
    enable = mkEnableOption "VueJS Landing page";
    user = mkOption { type = types.string; default = "kshaa-landing"; };
    group = mkOption { type = types.string; default = "users"; };
    stateDir = mkOption { type = types.str; default = "/var/kshaa-landing"; };
    
    # Networking
    ## Nginx network configuration
    virtualHostName = mkOption { type = types.nullOr types.str; default = null; };
    virtualHost = mkOption { type = types.attrs; default = {}; };
    acmeSSLEnable = mkOption { type = types.bool; default = false; };
    httpPort = mkOption { type = types.int; default = 80; };
    sslPort = mkOption { type = types.int; default = 443; };
    
    ## Application network configuration
    externalUrl = mkOption { type = types.string; default = "http://127.0.0.1:80"; };
    internalProxyPort = mkOption { type = types.int; default = 3000; };
    # backendPort = mkOption { type = types.int; default = 3001; };
    # frontendPort = mkOption { type = types.int; default = 3002; };
    # postgresPort = mkOption { type = types.int; default = 3003; };

    # Application general config
    environmentName = mkOption { type = types.string; default = "development"; };
    applicationKey = mkOption { type = types.string; default = "1234567890"; };
    githubAdminUser = mkOption { type = types.nullOr types.string; default = null; };
    githubClientId = mkOption { type = types.nullOr types.string; default = null; };
    githubClientSecret = mkOption { type = types.nullOr types.string; default = null; };
    postgresUser = mkOption { type = types.string; default = "postgres"; };
    postgresPassword = mkOption { type = types.string; default = "postgres"; };
    postgresDatabase = mkOption { type = types.string; default = "postgres"; };
    emailNotifications = mkOption { type = types.bool; default = false; };
    serviceEmail = mkOption { type = types.string; default = ""; };
    serviceEmailPassword = mkOption { type = types.string; default = ""; };
    adminEmail = mkOption { type = types.nullOr types.string; default = null; };
    backendImageName = mkOption { type = types.string; default = "docker.io/blokflautijs/landing-backend:v1.0.0"; };
    frontendImageName = mkOption { type = types.string; default = "docker.io/blokflautijs/landing-frontend:v1.0.2"; };
  };

  # Definition of the service
  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.stateDir}' 0750 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.kshaa-landing = {
      enable   = true;
      wantedBy = [ "multi-user.target" ];
      requires = [ "docker.service" ];
      environment = {
        COMPOSE_PROJECT_NAME = "kshaa-landing";
      };
      script = ''
        ${pkgs.docker_compose}/bin/docker-compose -f '${dockerCompositionJSON}' build
        ${pkgs.docker_compose}/bin/docker-compose -f '${dockerCompositionJSON}' up
      '';
      preStop  = "${pkgs.docker_compose}/bin/docker-compose -f '${dockerCompositionJSON}' down";
      serviceConfig = {
        Restart   = "always";
        User      = cfg.user;
        Group     = cfg.group;
        WorkingDirectory = toString cfg.stateDir;
      };
    };

    users.extraUsers."${cfg.user}" = {
      createHome = true;
      isSystemUser = true;
      extraGroups = [ "docker" "${cfg.group}" ];
      shell = pkgs.bashInteractive;
      home = toString cfg.stateDir;
    };

    services.nginx = lib.mkIf (cfg.virtualHostName != null) {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts."${cfg.virtualHostName}" = cfg.virtualHost // {
        listen = [
          { addr = "0.0.0.0"; port = cfg.httpPort; ssl = false; }
          { addr = "[::]"; port = cfg.httpPort; ssl = false; }
        ] ++ optionals cfg.acmeSSLEnable [
          { addr = "0.0.0.0"; port = cfg.sslPort; ssl = true; }
          { addr = "[::]"; port = cfg.sslPort; ssl = true; }
        ];
        enableACME = cfg.acmeSSLEnable;
        forceSSL = cfg.acmeSSLEnable;
        locations."/" = {
          proxyPass = "http://localhost:${toString cfg.internalProxyPort}";
        };
      };
      # # Virtual hosts, when Vue builds are Nix'ified.
      # virtualHosts."${cfg.virtualHostName}" = cfg.virtualHost // {
      #   # Entrypoint
      #   listen = [
      #     { addr = "0.0.0.0"; port = cfg.port; ssl = cfg.acmeSSLEnable; }
      #     { addr = "[::]"; port = cfg.port; ssl = cfg.acmeSSLEnable; }
      #   ];
      #   enableACME = cfg.acmeSSLEnable;
      #   forceSSL = cfg.acmeSSLEnable;
      #   # Frontend
      #   locations."/" = {
      #     # To-do: try_files vue_build
      #   };
      #   # Backend
      #   locations."/api" = {
      #     extraConfig = ''
      #       resolver 127.0.0.11 valid=30s;
      #       set $backend backend:${toString cfg.backendPort};
      #     '';
      #     proxyPass = "http://$backend";
      #   };
      # };
    };
  };
}