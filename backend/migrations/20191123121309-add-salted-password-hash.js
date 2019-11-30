'use strict';

module.exports = {
  up: (queryInterface, Sequelize) => {
    return queryInterface.addColumn('users', 'saltedPasswordHash', Sequelize.TEXT)
  },

  down: (queryInterface) => {
    return queryInterface.removeColumn('users', 'saltedPasswordHash')
  }
};
