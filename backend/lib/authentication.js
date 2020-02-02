const passwordHashAndSalt = require('password-hash-and-salt')
const models = require('../models')
const user = models.user

function createPassport(config) {
  const passport = require('koa-passport')

  /**
   * User serialization
   */
  passport.serializeUser(function(user, done) {
    done(null, user.id);
  });
  
  passport.deserializeUser(async function(userId, done) {
    let registeredUser = await user.findByPk(userId);
    let registeredUserData = registeredUser ? registeredUser.get() : {};
    done(null, registeredUserData);
  });
  
  /**
   * GitHub authentication
   */
  var GitHubStrategy = require('passport-github').Strategy
  const isDevelopment = config.environmentName === 'development';
  const isGithubConfigured = config.githubClientSecret && config.githubClientId &&
    config.externalURL && config.githubCallbackPath; 
  // In development GitHub auth can be left empty
  if (!isDevelopment || (isDevelopment && isGithubConfigured)) {
    passport.use(new GitHubStrategy({
      clientID: config.githubClientId,
      clientSecret: config.githubClientSecret,
      callbackURL: config.externalURL + config.githubCallbackPath
    }, async function(accessToken, refreshToken, profile, strategyResolve) {
      let githubUsername = profile.username
      let adminGithubUsername = config.githubAdminUser
      let isAdmin = adminGithubUsername && githubUsername == adminGithubUsername

      let registeredUserResult = await user.findOrCreate({
        where: {
          githubId: profile.id
        },
        defaults: {
          name: profile.displayName,
          role: isAdmin ? 'admin' : 'regular',
        }
      })

      // Reference for 0th element of Sequelize findOrCreate result:
      // https://sequelize.org/master/manual/models-usage.html#-code-findorcreate--code----search-for-a-specific-element-or-create-it-if-not-available
      let registeredUser = registeredUserResult[0].get();

      return strategyResolve(null, registeredUser);
    }))
  } else if (isDevelopment && !isGithubConfigured && process.env.DEBUG) {
    console.log("Github authentication isn't configured in development, continuing.")
  }
  
  /**
   * Local authentication
   */
  var LocalStrategy = require('passport-local').Strategy
  passport.use(new LocalStrategy(
    function(username, password, done) {
      user.findOne({
        where: { username }
      }).then(function(userResult) {
        if (!userResult) {
          done("User doesn't exist", false)
        } else {
          let user = userResult.get();
          passwordHashAndSalt(password).verifyAgainst(user.saltedPasswordHash, function(error, verified) {
            if (error) {
              done(error);
            } else if (!verified) {
              done("Password is incorrect", false);
            } else {
              done(null, user)
            }
          });  
        }
      }).catch(function(error) {
        done(error)
      })
    }
  ));  

  return passport
}

function isUsernameUnique(username) {
  return user.findOne({ where: { username } })
    // A user with that username doesn't exist 
    .then(username => username === null)
}

function isUserEmailUnique(email) {
  return user.findOne({ where: { email } })
    // A user with that email doesn't exist 
    .then(email => email === null)
}

async function registerUser(username, password, email, name, surname) {
  return new Promise(async (resolve, reject) => {
    // Is all data present?
    if (!username) { reject(new Error("Username can't be empty")); return; }
    if (!password) { reject(new Error("Password can't be empty")); return; }

    // Is email present and valid?
    if (email && !email.match(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/)) {
      reject(new Error("Email doesn't seem valid"))
      return;
    }

    // Is user unique?
    if (!(await isUsernameUnique(username))) {
      reject(new Error("User with the provided username already exists!"));
      return;
    }

    if (email && !(await isUserEmailUnique(email))) {
      reject(new Error("User with the provided email already exists!"));
      return;
    }

    // Create new salted password hash for user
    passwordHashAndSalt(password).hash(function(error, hash) {
      if (error) {
        reject(new Error("Failed to encrypt user data, cancelling!"))
        return;
      };
      
      // Create new user
      user.build({
        username,
        saltedPasswordHash: hash,
        name,
        surname,
        email,
        role: 'regular',
      })
      .save()
      .then(() => {
        resolve();
        return;
      })
      .catch((error) => {
        reject(new Error("Failed to save user to database! Reason: " + error.message))
        return;
      })
    })
  })
}

module.exports = {
  createPassport,
  registerUser
}