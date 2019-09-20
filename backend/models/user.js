'use strict';

module.exports = (sequelize, DataTypes) => {
  const user = sequelize.define('user', {
    username: DataTypes.STRING,
    name: DataTypes.STRING,
    surname: DataTypes.STRING,
    email: DataTypes.STRING,
    githubId: DataTypes.INTEGER,
    role: DataTypes.STRING,
  }, {});
  user.associate = function(models) {
    // associations can be defined here
  };
  return user;
};