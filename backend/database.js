const models = require('./models')
const sequelize = models.sequelize
const user = models.user

if (process.env.DEBUG)
    require('./lib/processEnvironment').check()

sequelize
  .authenticate()
  .then(async () => {
    console.log('Connection has been established successfully.');
    // console.log('Synchronizing all models')
    // await sequelize.sync()
    console.log('Creating a test user model and querying it.')
    var testUser = await user.findOrCreate({
      where: { username: 'test' },
      defaults: {
        name: "John",
        surname: "Doe",
        email: "test@gmail.com",
        role: "admin",
      }
    });

    console.log(testUser)
  })
  .catch(err => {
    console.error('Unable to connect to the database:', err);
  });
