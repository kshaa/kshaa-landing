{ config, lib, pkgs, ...}:

with lib;

let
  projectCode = "landing";
  projectLabel = "VueJS Landing page";
  dockerComposeFile = import ./docker-compose.nix {
    SERVICE_PORT = cfg.port;
    EXTERNAL_URL = externalUrl;
    POSTGRES_VOLUME_PATH = "${cfg.dataDir}/pgdata";
    VUE_COMPILE = true;
    APPLICATION_KEY = cfg.applicationKey;
    ADMIN_GITHUB_USER = cfg.githubAdminUser;
    GITHUB_CLIENT_ID = cfg.githubClientId;
    GITHUB_CLIENT_SECRET = cfg.githubClientSecret; 
    POSTGRES_USER = cfg.postgresUser;
    POSTGRES_PASSWORD = cfg.postgresPassword;
    POSTGRES_DATABASE = cfg.postgresDatabase;
  };

  cfg = config.services."${projectCode}";
  externalUrl = "${cfg.proxyProtocol}://${cfg.proxyHostname}:${cfg.proxyPort}";
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
    proxyPort = mkOption { type = types.int; default = 80; };
    port = mkOption { type = types.int; default = 3000; };

    # Application config
    applicationKey = mkOption { type = types.string; };
    githubAdminUser = mkOption { type = types.string; };
    githubClientId = mkOption { type = types.string; };
    githubClientSecret = mkOption { type = types.string; };
    postgresUser = mkOption { type = types.string; };
    postgresPassword = mkOption { type = types.string; };
    postgresDatabase = mkOption { type = types.string; };
  };

  # Definition of the service
  config = mkIf cfg.enable {
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

      serviceConfig = {
        ExecStart = "${pkgs.docker_compose}/bin/docker-compose -f '${dockerComposeFile}' up";
        ExecStop  = "${pkgs.docker_compose}/bin/docker-compose -f '${dockerComposeFile}' down";
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