const envDescs = {
    "APPLICATION_KEY": "A string used for session data signing",
    "EXTERNAL_URL_PREFIX": "API Gateway external URL prefix e.g. '/api'",
    "EXTERNAL_URL": "API Gateway external URL e.g. 'https://example.com'",
    "GITHUB_CLIENT_ID": "Github OAuth client id",
    "GITHUB_CLIENT_SECRET": "Github OAuth client secret",
    "ADMIN_GITHUB_USER": "Github username of the administrator of this API gateway",
    "POSTGRES_HOST": "Postgres server host e.g. 'localhost'",
    "POSTGRES_PORT": "Postgres server port e.g. '5432'",
    "POSTGRES_USER": "Postgres server user e.g. 'greg'",
    "POSTGRES_PASSWORD": "Postgres server host e.g. '1337hacker'",
    "POSTGRES_DATABASE": "Postgres database name e.g. 'app'",
    "EMAIL_NOTIFICATIONS": "Should email notifications be sent",
    "SERVICE_EMAIL": "What email should be used for sending notifications from this service",
    "SERVICE_EMAIL_PASSWORD": "What's the pasword for the service email",
    "ADMIN_EMAIL": "What email should receive the notifications",
    "NODE_ENV": "Node process environment name e.g. 'development'",
    "DEBUG": "Node debug mode switch e.g. '1' or undefined",
};

function logConfigInfo(envKey, info) {
    console.log(`Config info [${envKey}]:  ${info}`)    
    console.log(`Config definition [${envKey}]: ${envDescs[envKey]}`)    
}

function check() {
    var envs = {}

    // Log if variables aren't declared
    for (let envKey of Object.keys(envDescs)) {
        var envVal = process.env[envKey];
        
        if (envVal === undefined) {
            logConfigInfo(envKey, "Variable not declared") 
        } else {
            envs[envKey] = envVal
        }
    }

    // Extra checks for variables
    if (envs.EXTERNAL_URL.endsWith('/'))
        logConfigInfo("EXTERNAL_URL", "Must not end with trailing slash")

    if (envs.EXTERNAL_URL_PREFIX.endsWith('/'))
        logConfigInfo("EXTERNAL_URL_PREFIX", "Must not end with trailing slash")

    return envs
}

module.exports = {
    check
}