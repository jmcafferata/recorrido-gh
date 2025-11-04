#!/usr/bin/env node
/*
  Optimize JPG/PNG assets in-place using sharp.
  - Recompress large JPGs as progressive JPEG (quality 78 by default)
  - Cap max dimension to MAX_SIZE if image is huge (default 4096px)
  - Optimize PNGs with palette + compression
  - Optionally emit WebP/AVIF siblings (disabled by default to avoid code changes)
*/
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');

const ROOTS = [
  path.resolve(__dirname, '..', '..', 'assets'),
  path.resolve(__dirname, '..', '..', 'game-assets')
];

const MAX_SIZE = parseInt(process.env.IMG_MAX_SIZE || '4096', 10);
const JPG_QUALITY = parseInt(process.env.JPG_QUALITY || '78', 10);
const PNG_THRESHOLD = parseInt(process.env.PNG_THRESHOLD_MB || '1', 10) * 1024 * 1024; // 1MB
const JPG_THRESHOLD = parseInt(process.env.JPG_THRESHOLD_MB || '2', 10) * 1024 * 1024; // 2MB
const DRY_RUN = process.env.DRY_RUN === '1';

const exts = new Set(['.jpg', '.jpeg', '.png']);

function* walk(dir) {
  let entries;
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch { return; }
  for (const e of entries) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) {
      // Skip .git, node_modules, tools
      if (e.name.startsWith('.git') || e.name === 'node_modules' || e.name === 'tools') continue;
      yield* walk(p);
    } else {
      yield p;
    }
  }
}

async function optimizeImage(file) {
  const ext = path.extname(file).toLowerCase();
  if (!exts.has(ext)) return null;

  const statBefore = fs.statSync(file);
  const sizeBefore = statBefore.size;

  // Heuristic: only process if above thresholds
  const threshold = ext === '.png' ? PNG_THRESHOLD : JPG_THRESHOLD;
  if (sizeBefore < threshold) {
    return { file, skipped: true, reason: 'below-threshold', before: sizeBefore, after: sizeBefore };
  }

  const img = sharp(file, { failOn: 'none' });
  const meta = await img.metadata();
  let pipeline = img;

  // Resize if very large
  if (meta.width && meta.height && (meta.width > MAX_SIZE || meta.height > MAX_SIZE)) {
    const fit = meta.width > meta.height ? { width: MAX_SIZE } : { height: MAX_SIZE };
    pipeline = pipeline.resize({ ...fit, withoutEnlargement: true });
  }

  const tmp = file + '.opt';
  if (ext === '.png') {
    pipeline = pipeline.png({ compressionLevel: 9, palette: true, effort: 10 });
  } else {
    // Progressive JPEG with reasonable quality
    pipeline = pipeline.jpeg({ quality: JPG_QUALITY, mozjpeg: true, progressive: true });
  }

  if (DRY_RUN) {
    // Estimate: write to tmp and compare
    await pipeline.toFile(tmp);
  } else {
    await pipeline.toFile(tmp);
  }

  const sizeAfter = fs.statSync(tmp).size;
  const improvement = sizeAfter < sizeBefore && ((sizeBefore - sizeAfter) / sizeBefore) > 0.05; // >5%

  if (improvement && !DRY_RUN) {
    fs.copyFileSync(tmp, file);
  }
  fs.unlinkSync(tmp);

  return { file, before: sizeBefore, after: improvement ? sizeAfter : sizeBefore, improved: improvement };
}

(async () => {
  const files = [];
  for (const root of ROOTS) {
    if (!fs.existsSync(root)) continue;
    for (const p of walk(root)) {
      const ext = path.extname(p).toLowerCase();
      if (exts.has(ext)) files.push(p);
    }
  }

  console.log(`[optimize-images] Found ${files.length} candidate images`);
  let improved = 0, skipped = 0, bytesSaved = 0;

  for (const file of files) {
    try {
      const res = await optimizeImage(file);
      if (!res) continue;
      if (res.skipped) { skipped++; continue; }
      if (res.improved) { improved++; bytesSaved += (res.before - res.after); }
      console.log(`${res.improved ? '✔' : '→'} ${path.relative(process.cwd(), file)}  ${(res.before/1e6).toFixed(2)}MB -> ${(res.after/1e6).toFixed(2)}MB`);
    } catch (e) {
      console.warn(`Failed to optimize ${file}:`, e.message);
    }
  }

  console.log(`[optimize-images] Improved ${improved} files. Saved ${(bytesSaved/1e6).toFixed(2)} MB`);
})();
