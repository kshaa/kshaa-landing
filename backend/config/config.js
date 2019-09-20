const postgresConfig = {
  "username": process.env.POSTGRES_USER,
  "password": process.env.POSTGRES_PASSWORD,
  "database": process.env.POSTGRES_DATABASE,
  "host": process.env.POSTGRES_HOST,
  "port": process.env.POSTGRES_PORT,
  "dialect": "postgres"
}

module.exports = {
  "development": postgresConfig,
  "staging": postgresConfig,
  "production": postgresConfig
}
