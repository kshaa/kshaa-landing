'use strict';

module.exports = (sequelize, DataTypes) => {
  const user = sequelize.define('user', {
    username: { type: DataTypes.STRING, unique: 'users_username_key' },
    name: DataTypes.STRING,
    surname: DataTypes.STRING,
    email: { type: DataTypes.STRING, unique: 'users_username_key' },
    githubId: { type: DataTypes.INTEGER, unique: 'users_username_key' },
    role: DataTypes.STRING,
    saltedPasswordHash: DataTypes.STRING,
  }, {});
  user.associate = function(models) {
    // associations can be defined here
  };
  return user;
};