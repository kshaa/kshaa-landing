'use strict';

module.exports = {
  up: (queryInterface) => {
    return Promise.all([
      queryInterface.addConstraint('users', ['username'], {
        type: 'unique',
        name: 'users_username_key'
      }),
      queryInterface.addConstraint('users', ['email'], {
        type: 'unique',
        name: 'users_email_key'
      }),
      queryInterface.addConstraint('users', ['githubId'], {
        type: 'unique',
        name: 'users_githubId_key'
      }),
    ])
  },

  down: (queryInterface) => {
    return Promise.all([
      queryInterface.removeConstraint('users', 'users_username_key'),
      queryInterface.removeConstraint('users', 'users_email_key'),
      queryInterface.removeConstraint('users', 'users_githubId_key')
    ])
  }
};
