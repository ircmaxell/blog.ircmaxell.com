
const fs = require('hexo-fs');
const UglifyJS = require("uglify-js");


const build = "" + Date.now();

const buildCachePathJS = (path) => {
  return path.replace(/\.js$/, '_' + build + '.js');
}

const buildCachePathCSS = (path) => {
  return path.replace(/\.css$/, '_' + build + '.css');
}

const condense = (data) => {
  if (data.length === 0) {
    return '';
  }
  if (Buffer.isBuffer(data[0])) {
    return Buffer.concat(data).toString();
  }
  return data.join('');
};

const streamToString = (stream) => {
  return new Promise((resolve, reject) => {
    let chunks = [];
    stream.on('data', (chunk) => {
      chunks.push(chunk);
    });
    stream.on('end', () => {
      resolve(condense(chunks));
    });
    stream.on('error', (e) => {
      console.log("ERROR", e);
      reject(e);
    });
  });
}


hexo.extend.helper.register('js', function(path) {
  return '<script type="text/javascript" src="' + buildCachePathJS(path) + '"></script>';
});

hexo.extend.helper.register('css', function(path) {
  return '<link rel="stylesheet" href="' + buildCachePathCSS(path) + '"></link>';
});

hexo.extend.filter.register('after_generate', function() {
  hexo.route.list().map((path) => {
    if (path.match(/\.js$/)) {
      // copy to build file
      const stream = hexo.route.get(path);
      const buffer = streamToString(stream);
      const code = buffer.then((data) => {
        let result = UglifyJS.minify(data);
        if (result.error) {
          console.error("Error with path " + path, result.error);
        }
        return result.code;
      });
      hexo.route.set(path, () => { return code; });
      hexo.route.set(buildCachePathJS(path), () => { return code; });
    } else if (path.match(/\.css$/)) {
      // copy to build file
      const stream = hexo.route.get(path);
      const buffer = streamToString(stream);
      hexo.route.set(path, () => { return buffer; });
      hexo.route.set(buildCachePathCSS(path), () => { return buffer; });
    }
  });
})

