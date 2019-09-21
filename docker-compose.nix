{
    system ? builtins.currentSystem,
    pkgs ? import <nixpkgs> { inherit system; },

    APPLICATION_KEY,
    SERVICE_PORT ? 8080,
    DATA_DIR ? "./data",
    EXTERNAL_URL ? "http://localhost:${toString SERVICE_PORT}",
    ADMIN_GITHUB_USER ? null,
    GITHUB_CLIENT_ID ? null,
    GITHUB_CLIENT_SECRET ? null,
    POSTGRES_USER ? "landing",
    POSTGRES_PASSWORD ? "landing",
    POSTGRES_DATABASE ? "landing",
    POSTGRES_VOLUME_PATH ? "${DATA_DIR}/db_data",
    BACKEND_DEBUG_MODE ? false,
    NGINX_DEBUG_MODE ? false,
    NGINX_CONFIG_PATH ? "./nginx.conf",
    NPM_INSTALL ? false,
    VUE_COMPILE ? false,
    BE_VOLUME_PATH ? "${DATA_DIR}/be_data",
    FE_VOLUME_PATH ? "${DATA_DIR}/fe_data",
    PROJECT_FILE_PATH ? "."
}:
let
    optionalString = pkgs.lib.optionalString;
in
''
version: '3'

services:
  proxy: 
    image: nginx:latest
    ${if VUE_COMPILE then "
    volumes:
      - ${PROJECT_FILE_PATH}/nginx.compiledvue.conf:/etc/nginx/nginx.conf
      - ${FE_VOLUME_PATH}:/var/www/public
    depends_on:
      - frontend
    " else "
    volumes:
      - ${PROJECT_FILE_PATH}/nginx.webpackdevserver.conf:/etc/nginx/nginx.conf
    "}
    ports:
    - 127.0.0.1:${toString SERVICE_PORT}:80
    ${optionalString NGINX_DEBUG_MODE "
    command: 
      - nginx-debug
      - '-g'
      - 'daemon off;'
    "}
  frontend:
    image: node:12.10.0-alpine
    ${if VUE_COMPILE then "
    working_dir: /var/www_rw
    volumes:
      # ${PROJECT_FILE_PATH}/frontend in production will be read-only
      - ${PROJECT_FILE_PATH}/frontend:/var/www_ro
      # '${FE_VOLUME_PATH}' in production will be read-write
      - ${FE_VOLUME_PATH}:/var/www_rw
    command: 
      - /bin/sh
      - -c 
      - |
        cp -a /var/www_ro/* /var/www_rw/
        ${optionalString NPM_INSTALL "
        npm install
        "}
        # Remove NPM cache which can cache builds
        rm -rf ./node_modules/.cache/
        npm run build
        echo \"The build is at '\$\${OUTPUT_DIR}'\"
        ls \$\${OUTPUT_DIR}
        ls \$\${OUTPUT_DIR}/js
    environment:
      - PORT=8080
      - OUTPUT_DIR=/var/www_rw/dist
    " else "
    working_dir: /var/www_rw
    volumes:
      - ${PROJECT_FILE_PATH}/frontend:/var/www_ro
      - ${FE_VOLUME_PATH}/frontend:/var/www_rw
    command:
      - sh
      - -c
      - |
        cp -a /var/www_ro/* /var/www_rw/
        npm run serve
    environment:
      - PORT=8080
    "}
  backend:
    image: node:12.10.0-alpine
    working_dir: /var/www_rw
    volumes:
      - ${PROJECT_FILE_PATH}/backend:/var/www_ro
      - ${BE_VOLUME_PATH}:/var/www_rw
    command:
      - /bin/sh
      - -c 
      - |
          cp -a /var/www_ro/* /var/www_rw/
          ${optionalString NPM_INSTALL "
          echo '(-/3) Installing NPM packages' && \
          npm install
          "}
          echo '(1/3) Creating database if needed' && \
          npx sequelize db:create || true && \
          echo '(2/3) Running database migrations if needed' && \
          npx sequelize db:migrate && \
          echo '(3/3) Running backend server' && \
          ${optionalString BACKEND_DEBUG_MODE "DEBUG=1"} node server.js
    environment:
      - PORT=8080
      - APPLICATION_KEY=${APPLICATION_KEY}
      - EXTERNAL_URL_PREFIX=/api
      - EXTERNAL_URL=${EXTERNAL_URL}
      ${optionalString (ADMIN_GITHUB_USER != null) "
      - ADMIN_GITHUB_USER=${ADMIN_GITHUB_USER}
      "}
      ${optionalString (GITHUB_CLIENT_ID != null) "
      - GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID}
      "}
      ${optionalString (GITHUB_CLIENT_SECRET != null) "
      - GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET}
      "}
      - POSTGRES_HOST=postgres
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DATABASE=${POSTGRES_DATABASE}
    depends_on:
      - postgres
  postgres:
    image: postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DATABASE}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_USER: ${POSTGRES_USER}
      PGDATA: /database
    volumes:
      - ${POSTGRES_VOLUME_PATH}:/database
''