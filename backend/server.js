const Koa = require('koa');
const Router = require('koa-router');
const session = require('koa-session')
const bodyParser = require('koa-bodyparser')
const userAgent = require('koa-useragent')
const authentication = require('./lib/authentication')
const models = require('./models')
const user = models.user
const guestbook = models.guestbook

const apiPrefix = process.env.EXTERNAL_URL_PREFIX || '';
var app = new Koa();
var router = new Router();
router.prefix(apiPrefix)

if (process.env.DEBUG)
    require('./lib/processEnvironment').check()

/**
 * Middlewares
 */
// Trust reverse proxy headers (X-Forwarded-For $ipAddress)
app.proxy = true

// Cookie-based user sessions
app.keys = [process.env.APPLICATION_KEY]
app.use(session({
  key: 'landing:session'
}, app))

// Add support for json, form and text request body types 
app.use(bodyParser())

// User agent parser
app.use(userAgent);

// Authentication middleware
const passport = authentication.createPassport({
    environmentName: process.env.NODE_ENV,
    externalURL: process.env.EXTERNAL_URL + apiPrefix,
    githubClientId: process.env.GITHUB_CLIENT_ID,
    githubClientSecret: process.env.GITHUB_CLIENT_SECRET,
    githubCallbackPath: '/auth/github/callback',
    githubAdminUser: process.env.ADMIN_GITHUB_USER
});

// # Local user
router.post('/auth/local/login', async (ctx, next) => {
  await passport.authenticate('local', async function(err, user, info) {
    if (err) {
      ctx.body = {
        success: false,
        errorMessage: err
      }  
    } else if (!user) {
      if (info.message) {
        ctx.body = {
          success: false,
          errorMessage: info.message
        }
      } else {
        ctx.body = {
          success: false,
          errorMessage: "Unknown error occured [#A]"
        }
      }
    } else {
      ctx.logIn(user, function(err) {
        if (err) {
          ctx.body = {
            success: false,
            errorMessage: "Unknown error occured [#B]"
          }
        } else {
          ctx.body = {
            success: true
          }
        }
      })
    }
  })(ctx, next);

  return await next();
});

router.post('/auth/local/register', async (ctx, next) => {
  const { username, password, email, name, surname } = ctx.request.body;
  await authentication.registerUser(
    username, password, email, name, surname
  ).then(() => {
    ctx.body = {
      success: true
    }
  }).catch(error => {
    ctx.body = {
      success: false,
      errorMessage: error.message
    }  
  });

  return await next();
});

// # Github
router.get('/auth/github', passport.authenticate('github'));
router.get('/auth/github/callback', passport.authenticate('github', {
  successRedirect: '/',
  failureRedirect: apiPrefix + '/login?msg=Unexpected%20error'
}));

// # Logout
router.get('/auth/logout', async (ctx, next) => {
  ctx.logout();
  ctx.redirect('/') 

  return await next()
});

// # Status
router.get('/auth', async (ctx, next) => {
  if (ctx.isAuthenticated()) {
    ctx.body = {
      isAuthenticated: true,
      isAdmin: ctx.req.user.role === "admin", 
      roleCode: ctx.req.user.role,
      name: ctx.req.user.name
    }
  } else {
    ctx.body = {
      isAuthenticated: false,
      isAdmin: false
    }
  }

  return await next()
});

app.use(passport.initialize())
app.use(passport.session())

/**
 * API endpoints
 */
router.get('/', async (ctx, next) => {
  ctx.body = "Hi, you've reached an API gateway, feel free to interface!"

  return await next()
});

router.post('/guestbook/write', async (ctx, next) => {
  let userId = ctx.req.user ?
    ctx.req.user.id : null;
  let message = ctx.request.body.message || null;
  let ipAddress = ctx.request.ip || null;
  let userAgent = ctx.userAgent.source || null;
  let guestbookEntry = guestbook.build({
    userId,
    message: message.trim(),
    ipAddress,
    userAgent
  })

  try {
    await guestbookEntry.save();
    ctx.body = {
      success: true,
    }
  } catch (error) {
    ctx.body = {
      success: false,
    }
  }

  return await next()
});

router.get('/guestbook/read', async (ctx, next) => {
  let pageSize = 10;
  let pageNumber = ctx.request.page ?
    Number(ctx.request.page) : 1;

  if (ctx.isAuthenticated() && ctx.req.user.role == 'admin') {
    let pageEntries = await guestbook.findAll({
      offset: (pageNumber - 1) * pageSize,
      limit: pageSize,
      order: [['updatedAt', 'DESC']]
    })

    ctx.body = {
      pageNumber,
      pageSize,
      pageEntries
    }
  } else {
    ctx.throw(401, "You must be logged in as an administrator")
  }


  return await next()
});

// Attach the routes to the server
app
  .use(router.routes())
  .use(router.allowedMethods());

// Bind the server on port (e.g 3000)
const port = process.env.PORT || 3000
app.listen(port);
console.log("Server listening on port " + port)
