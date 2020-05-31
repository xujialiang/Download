'use strict';

const Controller = require('egg').Controller;
const CryptoJS = require('crypto-js');

class HomeController extends Controller {
  async index() {
    const { ctx } = this;
    ctx.body = 'XDownload Server Running!';
  }

  async report() {
    const { ctx } = this;
    var md5 = CryptoJS.MD5(ctx.request.body.link).toString()
    await ctx.app.redis.set('Xdownload/nodownloadlink/' + md5, JSON.stringify(ctx.request.body));
    ctx.body = JSON.stringify({
      code: 0,
      data: null,
      msg: 'success'
    });
  }

  async check() {
    const { ctx } = this;
    var md5 = CryptoJS.MD5(ctx.request.body.link).toString()
    let ret = await await ctx.app.redis.get('Xdownload/nodownloadlink/' + md5);
    ctx.body = JSON.stringify({
      code: 0,
      data: ret ? true : false
    });
  }

  async feedback() {
    const { ctx } = this;
    await ctx.app.redis.set('Xdownload/feedback/' + new Date().getTime(), ctx.request.body.content);
    ctx.body = JSON.stringify({
      code: 0,
      data: null,
      msg: 'success'
    });
  }

}

module.exports = HomeController;
