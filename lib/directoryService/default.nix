{ directory, user, group, dependantServices }: {
  description = "'${directory}' directory bootstrap service";

  requiredBy = dependantServices;
  before = dependantServices;

  serviceConfig.Type = "oneshot";
  serviceConfig.RemainAfterExit = true;

  preStart = (import ./createServiceDir.nix) {
    inherit user group directory;
  };
  script = ''
    echo "Attempted bootstrapping '${directory}'"
    ls -la ${directory}
  '';
  preStop = ''
    echo "Stopping";
  '';
}