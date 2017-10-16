'use strict';

const querystring = require('querystring');

exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;
  const params = querystring.parse(request.querystring);

  if (params.alt === 'rss') {
    request.uri = '/rss.xml'
  }

  callback(null, request);
}