'use strict';

/**
 * @param {Egg.Application} app - egg application
 */
module.exports = app => {
  const { router, controller } = app;
  router.get('/status', controller.home.index);
  router.post('/report', controller.home.report);
  router.post('/check', controller.home.check);
  router.post('/feedback', controller.home.feedback);
};
