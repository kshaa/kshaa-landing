import ./ops/docker-compose.nix {
    APPLICATION_KEY = "abcdefg";
    SERVICE_PORT = 8085; 

    BACKEND_NODEMON = false;
    VUE_COMPILE = true;
    NGINX_DEBUG_MODE = false;
    BACKEND_DEBUG_MODE = false;
    READ_ONLY_SOURCES_MODE = true;
}