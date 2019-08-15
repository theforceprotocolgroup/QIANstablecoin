var http = require('http');
var fs = require('fs');

var server = new http.Server();
server.listen(8080);

const webHomePrefix = "/Users/new/Developer/tokenbridge/web";

server.on('request', function (request, response) {
  const url = require('url').parse(request.url);
  //console.log("request url: ", url);

  let filename = url.pathname;

    if (url.pathname == '/') {
      filename = "/index.html";
    }
    
    filename = webHomePrefix + filename;
    console.log("request filename: ", filename);

    let type;
    switch(filename.substring(filename.lastIndexOf('.') + 1))  {
      case 'html':
      case 'htm':      type = 'text/html; charset=UTF-8'; break;
      case 'js':       type = 'application/javascript; charset=UTF-8'; break;
      case 'css':      type = 'text/css; charset=UTF-8'; break;
      case 'txt' :     type = 'text/plain; charset=UTF-8'; break;
      case 'manifest': type = 'text/cache-manifest; charset=UTF-8'; break;
      default:         type = 'application/octet-stream'; break;
    }
    console.log("response file: ", filename);
    
    fs.readFile(filename, function (err, content) {
      if (err) {
        response.writeHead(404, {
          'Content-Type': 'text/plain; charset=UTF-8'});
        response.write(err.message);
        response.end();
      } else {
        response.writeHead(200, {'Content-Type': type});
        response.write(content);
        response.end();
      }
    });
});
