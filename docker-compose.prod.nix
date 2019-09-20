import ./docker-compose.nix {
    APPLICATION_KEY = "abcdefg";
    SERVICE_PORT = 8084; 

    NPM_INSTALL = true;
    VUE_COMPILE = true;
    NGINX_DEBUG_MODE = true;
    BACKEND_DEBUG_MODE = true;
}