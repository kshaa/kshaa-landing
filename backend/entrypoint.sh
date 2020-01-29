#!/usr/bin/env sh

echo '(1/3) Creating database if needed'
npx sequelize db:create || true

echo '(2/3) Running database migrations if needed'
npx sequelize db:migrate

echo '(3/3) Running command passed to container'
sh -c "$*"
