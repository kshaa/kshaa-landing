{
    system ? builtins.currentSystem,
    pkgs ? import <nixpkgs> { inherit system; },

    # Build & environment configurations
    READ_ONLY_SOURCES_MODE ? false,
    BACKEND_NODEMON ? false,
    BACKEND_DEBUG_MODE ? false,
    NGINX_DEBUG_MODE ? false,
    VUE_COMPILE ? false,
    ENVIRONMENT_NAME ? "production",

    # Run-time configurations
    ## Session encryption key
    APPLICATION_KEY ? null,

    ## Github
    ADMIN_GITHUB_USER ? null,
    GITHUB_CLIENT_ID ? null,
    GITHUB_CLIENT_SECRET ? null,
    
    ## Postgres database
    POSTGRES_USER ? "landing",
    POSTGRES_PASSWORD ? "landing",
    POSTGRES_DATABASE ? "landing",

    ## Firebase 
    BACKEND_FIREBASE_DB_URL ? null,
    VUE_APP_FIREBASE_PUBLIC_VAPID_KEY ? null,

    # Network
    SERVICE_PORT ? 8080,
    POSTGRES_EXPOSED_PORT ? null,
    EXTERNAL_URL ? "http://localhost:${toString SERVICE_PORT}",

    # Filesystem
    PROJECT_SOURCE_PATH ? ./..,
    DATA_PATH ? PROJECT_SOURCE_PATH + /data, # For database storage, compiled code, source code copies
    VUE_APP_FIREBASE_WEB_APP_CONFIG_PATH ? PROJECT_SOURCE_PATH + /firebase.webapp.json,
    BACKEND_FIREBASE_SERVICE_ACCOUNT_CONFIG_PATH ? PROJECT_SOURCE_PATH + /firebase.serviceaccount.json,
}:
let
    inherit (pkgs.lib) optionals optionalString optionalAttrs;

    # Project source data subpaths
    BACKEND_SOURCE_PATH = PROJECT_SOURCE_PATH + /backend;
    VUE_APP_SOURCE_PATH = PROJECT_SOURCE_PATH + /frontend;
    NGINX_COMPILED_VUE_CONFIG_PATH = PROJECT_SOURCE_PATH + /ops/nginx.compiled.vue.conf;
    NGINX_WEBPACK_VUE_CONFIG_PATH = PROJECT_SOURCE_PATH + /ops/nginx.webpack.vue.conf;

    # Persistent data subpaths
    BACKEND_DATA_PATH = DATA_PATH + /be_data;
    VUE_APP_DATA_PATH = DATA_PATH + /fe_data;
    POSTGRES_DATA_PATH = DATA_PATH + /db_data;
in
{
  version = "3";

  services = {
    proxy = { 
      image = "nginx:latest";

      volumes = if VUE_COMPILE && READ_ONLY_SOURCES_MODE then [
        "${toString NGINX_COMPILED_VUE_CONFIG_PATH}:/etc/nginx/nginx.conf"
        "${toString VUE_APP_DATA_PATH}:/var/www/public"
        "${toString VUE_APP_FIREBASE_WEB_APP_CONFIG_PATH}:/var/www_rw/firebase.config.json"
      ] else if VUE_COMPILE && !READ_ONLY_SOURCES_MODE then [
        "${toString NGINX_COMPILED_VUE_CONFIG_PATH}:/etc/nginx/nginx.conf"
        "${toString VUE_APP_SOURCE_PATH}:/var/www/public"
        "${toString VUE_APP_FIREBASE_WEB_APP_CONFIG_PATH}:/var/www_rw/firebase.config.json"
      ] else [
        "${toString NGINX_WEBPACK_VUE_CONFIG_PATH}:/etc/nginx/nginx.conf"
      ];
      depends_on = optionals VUE_COMPILE [ "frontend" ];
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
      image = "node:12.10.0-alpine";
      working_dir = "/var/www_rw";
      environment = {
        PORT = 8080;
        NODE_ENV = ENVIRONMENT_NAME;
        VUE_APP_FIREBASE_PUBLIC_VAPID_KEY = VUE_APP_FIREBASE_PUBLIC_VAPID_KEY;
        VUE_APP_FIREBASE_WEB_APP_CONFIG_PATH = "/var/www_rw/firebase.webapp.json";
      } // optionalAttrs VUE_COMPILE {
        OUTPUT_DIR = "/var/www_rw/dist";
      };

      volumes = [
        # Firebase web app config - No data written
        "${toString VUE_APP_FIREBASE_WEB_APP_CONFIG_PATH}:/var/www_rw/firebase.webapp.json"
      ] ++ (if VUE_COMPILE && READ_ONLY_SOURCES_MODE then [
        # Compiled Vue w/ READ_ONLY_SOURCES_MODE - First copy, then compile
        "${toString VUE_APP_SOURCE_PATH}:/var/www_ro"
        "${toString VUE_APP_DATA_PATH}:/var/www_rw"
      ] else [
        # VUE_COMPILE && !READ_ONLY_SOURCES_MODE - Write directly to source
        # !VUE_COMPILE - No data written
        "${toString VUE_APP_SOURCE_PATH}:/var/www_rw"
      ]);

      command = if VUE_COMPILE then [
        "sh"
        "-c"
        ''
          ${optionalString (VUE_COMPILE && READ_ONLY_SOURCES_MODE) "cp -a /var/www_ro/* /var/www_rw/"}
          npm install
          # Remove NPM cache which can cache builds
          rm -rf ./node_modules/.cache/
          npm run build
          echo "The build is at '$''${OUTPUT_DIR}'"
          ls $''${OUTPUT_DIR}
          ls $''${OUTPUT_DIR}/js
        '' 
      ] else [
        "sh"
        "-c"
        ''
          npm run serve
        ''
      ];
    };
    backend = {
      image = "node:12.10.0-alpine";
      working_dir = "/var/www_rw";
      volumes = if READ_ONLY_SOURCES_MODE then [
        "${toString PROJECT_SOURCE_PATH}/backend:/var/www_ro"
        "${toString BACKEND_DATA_PATH}:/var/www_rw"
      ] else [
        "${toString PROJECT_SOURCE_PATH}/backend:/var/www_rw"
      ];
      command = [
        "/bin/sh"
        "-c"
        ''
          ${optionalString READ_ONLY_SOURCES_MODE "cp -a /var/www_ro/* /var/www_rw/"}
          echo '(-/3) Installing NPM packages' && \
          npm install
          echo '(1/3) Creating database if needed' && \
          npx sequelize db:create || true && \
          echo '(2/3) Running database migrations if needed' && \
          npx sequelize db:migrate && \
          echo '(3/3) Running backend server' && \
          ${optionalString BACKEND_DEBUG_MODE "DEBUG=1"} ${if BACKEND_NODEMON then "npx nodemon" else "node"} server.js
        ''
      ];
      environment = {
        PORT = 8080;
        EXTERNAL_URL_PREFIX = "/api";
        POSTGRES_HOST = "postgres";
        NODE_ENV = ENVIRONMENT_NAME;
        inherit EXTERNAL_URL;
        inherit APPLICATION_KEY;
        BACKEND_FIREBASE_SERVICE_ACCOUNT_CONFIG_PATH = toString BACKEND_FIREBASE_SERVICE_ACCOUNT_CONFIG_PATH;
        inherit BACKEND_FIREBASE_DB_URL;
        inherit POSTGRES_USER POSTGRES_PASSWORD;
        inherit POSTGRES_DATABASE;
      } // optionalAttrs (ADMIN_GITHUB_USER != null) {
        inherit ADMIN_GITHUB_USER;
      } // optionalAttrs (GITHUB_CLIENT_ID != null) {
        inherit GITHUB_CLIENT_ID;
      } // optionalAttrs (GITHUB_CLIENT_SECRET != null) {
        inherit GITHUB_CLIENT_SECRET;
      };

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
}