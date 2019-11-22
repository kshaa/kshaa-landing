# Kshaa landing
## Docker-compose
```
# Install nix-instantiate
# Install yq
# Rename docker-compose.env.nix.sample
#   to docker-compose.dev.nix
ENVIRONMENT=dev make create
ENVIRONMENT=dev make create
docker-compose -f docker-compose.dev.yml up
```