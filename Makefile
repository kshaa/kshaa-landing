create:
	nix-instantiate --eval --json --strict docker-compose.${ENVIRONMENT}.nix | yq -y . > docker-compose.${ENVIRONMENT}.yml