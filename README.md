# Kshaa landing
## Docker-compose
```
# Install nix-instantiate
# Install yq
ENVIRONMENT=dev make create
ENVIRONMENT=prod make create
```

```
docker-compose -f docker-compose.dev.yml up
docker-compose -f docker-compose.prod.yml up
```