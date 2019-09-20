import ./docker-compose.nix {
    APPLICATION_KEY = "abcdefg";
    SERVICE_PORT = 8080; 

    VUE_COMPILE = false;
    NGINX_DEBUG_MODE = true;
    BACKEND_DEBUG_MODE = true;
}