'use strict';
module.exports = (sequelize, DataTypes) => {
  const guestbook = sequelize.define('guestbook', {
    message: DataTypes.STRING,
    userId: DataTypes.INTEGER,
    ipAddress: DataTypes.STRING,
    userAgent: DataTypes.STRING
  }, {});
  guestbook.associate = function(models) {
    // associations can be defined here
  };
  return guestbook;
};