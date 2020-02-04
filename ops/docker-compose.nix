{
    system ? builtins.currentSystem,
    pkgs ? import <nixpkgs> { inherit system; },

    # Build & environment configurations
    READ_ONLY_SOURCES_MODE ? false,
    NGINX_DEBUG_MODE ? false,
    # @to-do, implement VUE_COMPILE=true after fixing typescript bugs
    VUE_COMPILE ? false,
    ENVIRONMENT_NAME ? "production",

    # Run-time configurations
    ## Session encryption key
    APPLICATION_KEY ? null,

    ## Github
    ADMIN_GITHUB_USER ? null,
    GITHUB_CLIENT_ID ? null,
    GITHUB_CLIENT_SECRET ? null,

    ## Email notifications
    EMAIL_NOTIFICATIONS ? null,
    SERVICE_EMAIL ? null,
    SERVICE_EMAIL_PASSWORD ? null,
    ADMIN_EMAIL ? null,

    ## Postgres database
    POSTGRES_USER ? "landing",
    POSTGRES_PASSWORD ? "landing",
    POSTGRES_DATABASE ? "landing",

    # Network
    SERVICE_PORT ? 8080,
    POSTGRES_EXPOSED_PORT ? null,
    EXTERNAL_URL ? "http://localhost:${toString SERVICE_PORT}",

    # Filesystem
    PROJECT_SOURCE_PATH ? ./..,
    DATA_PATH ? PROJECT_SOURCE_PATH + /data, # For database storage
}:
let
    inherit (pkgs.lib) optionals optionalString optionalAttrs;

    # Project source data subpaths
    BACKEND_SOURCE_PATH = (toString PROJECT_SOURCE_PATH) + "/backend";
    VUE_APP_SOURCE_PATH = (toString PROJECT_SOURCE_PATH) + "/frontend";
    NGINX_COMPILED_VUE_CONFIG_PATH = (toString PROJECT_SOURCE_PATH) + "/ops/nginx.compiled.vue.conf";
    NGINX_WEBPACK_VUE_CONFIG_PATH = (toString PROJECT_SOURCE_PATH) + "/ops/nginx.webpack.vue.conf";

    # Persistent data subpaths
    BACKEND_DATA_PATH = (toString DATA_PATH) + "/be_data";
    VUE_APP_DATA_PATH = (toString DATA_PATH) + "/fe_data";
    POSTGRES_DATA_PATH = (toString DATA_PATH) + "/db_data";
in
{
  version = "3";

  services = {
    proxy = { 
      image = "nginx:latest";
      
      volumes = [
        # "${NGINX_COMPILED_VUE_CONFIG_PATH}:/etc/nginx/nginx.conf"
        # "vue-share:/var/www/public"
        "${NGINX_WEBPACK_VUE_CONFIG_PATH}:/etc/nginx/nginx.conf"
      ];
      # depends_on = [ "frontend" ];
      ports = [
        "127.0.0.1:${toString SERVICE_PORT}:80"
      ];
      command = optionals NGINX_DEBUG_MODE [
        "nginx-debug"
        "-g"
        "daemon off;"
      ];
    };
    frontend = {
      build = {
        context = VUE_APP_SOURCE_PATH;
        # dockerfile = "Dockerfile.prod";
        dockerfile = "Dockerfile.devprod";
      };
      environment = {
        NODE_ENV = ENVIRONMENT_NAME;
        PORT = "8080";
      };
      expose = [ "8080"];
      # command = "mkdir -p /var/app-compiled;cp -rf /var/app-compiled/* /var/vue-share/;tail -f /dev/null";
      # volumes = [
      #   "vue-share:/var/vue-share"
      # ];
    };
    backend = {
      build = {
        context = BACKEND_SOURCE_PATH;
        # dockerfile = "Dockerfile.prod";
        dockerfile = "Dockerfile.devprod";
      };
      command = "npm run serve";
      environment = {
        inherit APPLICATION_KEY;
        inherit EXTERNAL_URL;
        EXTERNAL_URL_PREFIX = "/api";
        NODE_ENV = ENVIRONMENT_NAME;
        PORT = "8080";
        inherit POSTGRES_DATABASE;
        POSTGRES_HOST = "postgres";
        inherit POSTGRES_PASSWORD;
        inherit POSTGRES_USER;
        inherit EMAIL_NOTIFICATIONS;
        inherit SERVICE_EMAIL;
        inherit SERVICE_EMAIL_PASSWORD;
        inherit ADMIN_EMAIL;
      } // optionalAttrs (ADMIN_GITHUB_USER != null) {
        inherit ADMIN_GITHUB_USER;
      } // optionalAttrs (GITHUB_CLIENT_ID != null) {
        inherit GITHUB_CLIENT_ID;
      } // optionalAttrs (GITHUB_CLIENT_SECRET != null) {
        inherit GITHUB_CLIENT_SECRET;
      };
      expose = [ "8080"];
      depends_on = [ "postgres" ];
    };
    postgres = {
      image = "postgres";
      environment = {
        PGDATA = "/database";
        POSTGRES_DB = POSTGRES_DATABASE;
        inherit POSTGRES_PASSWORD;
        inherit POSTGRES_USER;
      };
        
      volumes = [
        "${toString POSTGRES_DATA_PATH}:/database"
      ];

      ports = optionals (POSTGRES_EXPOSED_PORT != null) [
        "127.0.0.1:${toString POSTGRES_EXPOSED_PORT}:5432"
      ];
    };
  };
  volumes = {
    vue-share = {};
  };
}