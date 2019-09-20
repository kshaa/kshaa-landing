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
    let registeredUser = (await user.findByPk(userId)).get()
    done(null, registeredUser);
  });
  
  /**
   * GitHub authentication
   */
  var GitHubStrategy = require('passport-github').Strategy
  passport.use(new GitHubStrategy({
      clientID: config.githubClientId,
      clientSecret: config.githubClientSecret,
      callbackURL: config.externalURL + config.githubCallbackPath
    },
    async function(accessToken, refreshToken, profile, strategyResolve) {
      let githubUsername = profile.username
      let adminGithubUsername = process.env.ADMIN_GITHUB_USER
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
    }
  ))

  return passport
}

module.exports = {
  createPassport
}