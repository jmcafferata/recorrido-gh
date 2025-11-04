#!/usr/bin/env node
/*
  Optimize WEBM/MP4 videos using ffmpeg (must be installed in PATH on runner).
  - WEBM: VP9 constant quality (CRF env var, default 32), Opus audio 96k
  - MP4: H.264 CRF 28 preset veryslow, AAC 128k
  Replaces source if new file is at least 5% smaller. Skips tiny clips (<256KB).
*/
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const ROOTS = [
  path.resolve(__dirname, '..', '..', 'assets'),
  path.resolve(__dirname, '..', '..', 'game-assets')
];

const MIN_SIZE = 256 * 1024; // Skip tiny files
const CRF_VP9 = process.env.CRF_VP9 || '32';
const CRF_X264 = process.env.CRF_X264 || '28';
const THREADS = process.env.FFMPEG_THREADS || '4';
const DRY_RUN = process.env.DRY_RUN === '1';

const videoExts = new Set(['.webm', '.mp4']);

function* walk(dir) {
  let entries;
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch { return; }
  for (const e of entries) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (e.name.startsWith('.git') || e.name === 'node_modules' || e.name === 'tools') continue;
      yield* walk(p);
    } else {
      yield p;
    }
  }
}

function runFfmpeg(args) {
  return new Promise((resolve, reject) => {
    const proc = spawn('ffmpeg', ['-y', ...args], { stdio: 'ignore' });
    proc.on('error', reject);
    proc.on('close', (code) => code === 0 ? resolve() : reject(new Error(`ffmpeg exited ${code}`)));
  });
}

async function optimizeVideo(file) {
  const ext = path.extname(file).toLowerCase();
  if (!videoExts.has(ext)) return null;
  const statBefore = fs.statSync(file);
  const sizeBefore = statBefore.size;
  if (sizeBefore < MIN_SIZE) return { file, skipped: true, reason: 'tiny' };

  const tmp = file + '.opt' + ext;
  let args;
  if (ext === '.webm') {
    args = ['-i', file, '-c:v', 'libvpx-vp9', '-crf', CRF_VP9, '-b:v', '0', '-row-mt', '1', '-threads', THREADS,
            '-c:a', 'libopus', '-b:a', '96k', tmp];
  } else {
    args = ['-i', file, '-c:v', 'libx264', '-crf', CRF_X264, '-preset', 'veryslow', '-c:a', 'aac', '-b:a', '128k', tmp];
  }

  if (!DRY_RUN) await runFfmpeg(args);
  const sizeAfter = fs.existsSync(tmp) ? fs.statSync(tmp).size : sizeBefore;
  const improvement = sizeAfter < sizeBefore && ((sizeBefore - sizeAfter) / sizeBefore) > 0.05;

  if (improvement && !DRY_RUN) {
    fs.copyFileSync(tmp, file);
  }
  if (fs.existsSync(tmp)) fs.unlinkSync(tmp);

  return { file, before: sizeBefore, after: improvement ? sizeAfter : sizeBefore, improved: improvement };
}

(async () => {
  const files = [];
  for (const root of ROOTS) {
    if (!fs.existsSync(root)) continue;
    for (const p of walk(root)) {
      const ext = path.extname(p).toLowerCase();
      if (videoExts.has(ext)) files.push(p);
    }
  }

  console.log(`[optimize-videos] Found ${files.length} candidate videos`);
  let improved = 0, bytesSaved = 0;

  for (const file of files) {
    try {
      const res = await optimizeVideo(file);
      if (!res || res.skipped) continue;
      if (res.improved) { improved++; bytesSaved += (res.before - res.after); }
      console.log(`${res.improved ? '✔' : '→'} ${path.relative(process.cwd(), file)}  ${(res.before/1e6).toFixed(2)}MB -> ${(res.after/1e6).toFixed(2)}MB`);
    } catch (e) {
      console.warn(`Failed to optimize ${file}:`, e.message);
    }
  }

  console.log(`[optimize-videos] Improved ${improved} files. Saved ${(bytesSaved/1e6).toFixed(2)} MB`);
})();
