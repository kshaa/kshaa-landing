# Kshaa landing
## Generate docker compositions
### Development docker-compose
```
nix-instantiate --eval docker-compose.nix \
    --arg APPLICATION_KEY '"abcd"' \
    --arg SERVICE_PORT '8083' \
    --arg VUE_COMPILE 'false' \
    --arg NGINX_DEBUG_MODE 'true' \
    --arg BACKEND_DEBUG_MODE 'true' \
    | jq -r '.' \
    > docker-compose.dev.yml
```

or 

```
nix eval --raw -f docker-compose.dev.nix '' > docker-compose.dev.yml
```

### Production docker-compose
```
nix-instantiate --eval docker-compose.nix \
    --arg APPLICATION_KEY '"abcd"' \
    --arg VUE_COMPILE 'true' \
    --arg SERVICE_PORT '8084' \
    | jq -r '.' \
    > docker-compose.prod.yml
```

or 

```
nix eval --raw -f docker-compose.prod.nix '' > docker-compose.prod.yml
```
