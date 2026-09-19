const fs = require('fs');
const path = require('path');

const srcDir = path.join(__dirname, '..', 'chelav_app', 'build', 'web');
const destDir = path.join(__dirname, '..', 'public');

function copyRecursiveSync(src, dest) {
  const exists = fs.existsSync(src);
  const stats = exists && fs.statSync(src);
  const isDirectory = exists && stats.isDirectory();
  if (isDirectory) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, { recursive: true });
    }
    fs.readdirSync(src).forEach((childItemName) => {
      copyRecursiveSync(
        path.join(src, childItemName),
        path.join(dest, childItemName)
      );
    });
  } else {
    fs.copyFileSync(src, dest);
  }
}

console.log('[CheLav Deployment] Preparing static public directory for Vercel...');

if (!fs.existsSync(srcDir)) {
  console.error(`Error: Source directory ${srcDir} does not exist. Run "flutter build web --release" first.`);
  process.exit(1);
}

if (fs.existsSync(destDir)) {
  fs.rmSync(destDir, { recursive: true, force: true });
}
fs.mkdirSync(destDir, { recursive: true });

copyRecursiveSync(srcDir, destDir);
console.log(`[CheLav Deployment] Successfully copied Flutter Web build to ${destDir}!`);
