
const fs = require('hexo-fs');
var pathFn = require('path');

const gravatar = require('hexo/lib/plugins/helper/gravatar');
var nunjucks = require('nunjucks');
var env = new nunjucks.Environment();

env.addFilter('uriencode', function(str) {
  return encodeURI(str);
});

env.addFilter('noControlChars', function(str) {
  return str.replace(/[\x00-\x1F\x7F]/g, '');
});

const tmplSource = pathFn.join(__dirname, '../themes/rss.xml');
const tmpl = nunjucks.compile(fs.readFileSync(tmplSource), env);


hexo.extend.generator.register('feed', function(locals) {
  let config = this.config;

  let posts = locals.posts.sort('-date').filter(function(post) {
    console.log(post.tags)
    return post.draft !== true;
  }).limit(10);
  
  var url = config.url;
  if (url[url.length - 1] !== '/') url += '/';

  var icon;
  if (config.email) icon = gravatar(config.email);


  let xml = tmpl.render({
    config: config,
    posts: posts,
    url: url,
    tags: locals.tags
  });

  return {
    path: '/rss.xml',
    data: xml
  };
});
