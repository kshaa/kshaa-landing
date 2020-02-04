{ config, lib, pkgs, ...}:

with lib;

let
  projectCode = "landing";
  projectLabel = "VueJS Landing page";
  projectFiles = (import ./project-files.nix {}).derivation;
  dockerComposeSet = (import ./docker-compose.nix {
    SERVICE_PORT = cfg.port;
    EXTERNAL_URL = externalUrl;
    DATA_PATH = cfg.dataDir;
    APPLICATION_KEY = cfg.applicationKey;
    ADMIN_GITHUB_USER = cfg.githubAdminUser;
    GITHUB_CLIENT_ID = cfg.githubClientId;
    GITHUB_CLIENT_SECRET = cfg.githubClientSecret; 
    POSTGRES_USER = cfg.postgresUser;
    POSTGRES_PASSWORD = cfg.postgresPassword;
    POSTGRES_DATABASE = cfg.postgresDatabase;
    PROJECT_SOURCE_PATH = toString projectFiles;
    EMAIL_NOTIFICATIONS = cfg.emailNotifications;
    SERVICE_EMAIL = cfg.serviceEmail;
    SERVICE_EMAIL_PASSWORD = cfg.serviceEmailPassword;
    ADMIN_EMAIL = cfg.adminEmail;
  });
  dockerComposeFile = pkgs.writeText "landing.docker-compose.yml" (builtins.toJSON dockerComposeSet);

  cfg = config.services."${projectCode}";
  externalUrl = "${cfg.proxyProtocol}://${cfg.proxyHostname}";
in
{
  # Options for the service
  options.services."${projectCode}" = {
    # Linux user, group, filesystem info
    enable = mkEnableOption projectLabel;
    user = mkOption { type = types.string; default = projectCode; };
    group = mkOption { type = types.string; default = "users"; };
    dataDir = mkOption { type = types.str; default = "/srv/${projectCode}"; };

    # Network config
    proxyProtocol = mkOption { type = types.string; default = "http"; };
    proxyHostname = mkOption { type = types.string; default = "${projectCode}.local"; };
    port = mkOption { type = types.int; default = 3000; };

    # Application config
    applicationKey = mkOption { type = types.string; };
    githubAdminUser = mkOption { type = types.string; };
    githubClientId = mkOption { type = types.string; };
    githubClientSecret = mkOption { type = types.string; };
    postgresUser = mkOption { type = types.string; };
    postgresPassword = mkOption { type = types.string; };
    postgresDatabase = mkOption { type = types.string; };
    emailNotifications = mkOption { type = types.string; };
    serviceEmail = mkOption { type = types.string; };
    serviceEmailPassword = mkOption { type = types.string; };
    adminEmail = mkOption { type = types.string; };
  };

  # Definition of the service
  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
    };

    systemd.services."${projectCode}-workdir" = import ./lib/directoryService {
      inherit (cfg) user group;
      directory = cfg.dataDir;
      dependantServices = [ "${projectCode}.service" ];
    };

    systemd.services."${projectCode}" = {
      enable   = true;
      wantedBy = [ "multi-user.target" ];
      requires = [ "docker.service" ];
      environment = {
        COMPOSE_PROJECT_NAME = projectCode;
      };
      script = ''
        ${pkgs.docker_compose}/bin/docker-compose -f '${dockerComposeFile}' build
        ${pkgs.docker_compose}/bin/docker-compose -f '${dockerComposeFile}' up
      '';
      preStop  = "${pkgs.docker_compose}/bin/docker-compose -f '${dockerComposeFile}' down";
      serviceConfig = {
        Restart   = "always";
        User      = cfg.user;
        WorkingDirectory = cfg.dataDir;
      };
    };

    users.extraUsers."${cfg.user}" = {
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      extraGroups = [ "docker" ];
      shell = pkgs.bashInteractive;
    };
  };
}