const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');

const PORT = 8000;

const mimeTypes = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.webm': 'video/webm',
  '.mp4': 'video/mp4',
  '.mpeg': 'video/mpeg',
  '.mp3': 'audio/mpeg',
  '.m4a': 'audio/mp4',
  '.wav': 'audio/wav',
  '.otf': 'font/otf',
  '.ttf': 'font/ttf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.glb': 'model/gltf-binary',
  '.gltf': 'model/gltf+json'
};

const server = http.createServer((req, res) => {
  const safeRoot = process.cwd();

  // Decode and normalize the path to prevent directory traversal
  let rawPath = req.url.split('?')[0];
  
  // Decode URL-encoded characters (e.g., %20 -> space)
  try {
    rawPath = decodeURIComponent(rawPath);
  } catch (e) {
    res.writeHead(400, { 'Content-Type': 'text/html' });
    res.end('<h1>400 - Bad Request</h1>', 'utf-8');
    return;
  }
  
  if (rawPath === '/' || rawPath === '') {
    rawPath = '/index.html';
  }

  const resolvedPath = path.resolve(safeRoot, '.' + rawPath);

  // Ensure the resolved path is still inside the project directory
  if (resolvedPath !== safeRoot && !resolvedPath.startsWith(safeRoot + path.sep)) {
    res.writeHead(403, { 'Content-Type': 'text/html' });
    res.end('<h1>403 - Forbidden</h1>', 'utf-8');
    return;
  }

  // Check if path is a directory
  fs.stat(resolvedPath, (statErr, stats) => {
    if (statErr) {
      res.writeHead(404, { 'Content-Type': 'text/html' });
      res.end('<h1>404 - File Not Found</h1>', 'utf-8');
      return;
    }

    // If directory, try to serve index.html
    let filePath = resolvedPath;
    if (stats.isDirectory()) {
      filePath = path.join(resolvedPath, 'index.html');
    }

    const extname = String(path.extname(filePath)).toLowerCase();
    const contentType = mimeTypes[extname] || 'application/octet-stream';

    fs.readFile(filePath, (error, content) => {
      if (error) {
        if (error.code === 'ENOENT') {
          res.writeHead(404, { 'Content-Type': 'text/html' });
          res.end('<h1>404 - File Not Found</h1>', 'utf-8');
        } else {
          res.writeHead(500);
          res.end('Server Error: ' + error.code, 'utf-8');
        }
      } else {
        res.writeHead(200, { 
          'Content-Type': contentType,
          'Access-Control-Allow-Origin': '*'
        });
        res.end(content, 'utf-8');
      }
    });
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log('\n🎮 Game Server is Running!\n');
  console.log('Access from this computer:');
  console.log(`  http://localhost:${PORT}`);
  console.log(`  http://127.0.0.1:${PORT}`);
  console.log('\nAccess from other devices on your network:');
  
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        console.log(`  http://${iface.address}:${PORT}`);
      }
    }
  }
  
  console.log('\n⚠️  If other devices cannot connect, you may need to:');
  console.log('   1. Allow Node.js through Windows Firewall when prompted');
  console.log('   2. Or run this command as Administrator:');
  console.log(`      netsh advfirewall firewall add rule name="Node HTTP Server" dir=in action=allow protocol=TCP localport=${PORT}`);
  console.log('\nPress Ctrl+C to stop the server\n');
});
