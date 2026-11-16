const path = require('path');
const fs = require('fs');
const envFile = path.join(__dirname, '..', '.env');
if (fs.existsSync(envFile)) {
  for (const line of fs.readFileSync(envFile, 'utf8').split(/\r?\n/)) {
    const match = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*?)\s*$/);
    if (!match || process.env[match[1]] !== undefined) continue;
    let value = match[2];
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) value = value.slice(1, -1);
    process.env[match[1]] = value;
  }
}
const BLOCKED = new Set(['exe','bat','cmd','com','scr','msi','vbs','vbe','ps1','dll','jar','lnk','pif','hta','cpl','reg']);
(process.env.EXTRA_BLOCKED_EXT || '').split(',').map(s => s.trim().toLowerCase().replace(/^\./, '')).filter(Boolean).forEach(e => BLOCKED.add(e));
const positiveInt = (value, fallback) => { const n = Number.parseInt(value, 10); return Number.isSafeInteger(n) && n > 0 ? n : fallback; };
const root = path.join(__dirname, '..');
module.exports = {
  PORT: positiveInt(process.env.PORT, 3000), MAX_FILE_MB: positiveInt(process.env.MAX_FILE_MB, 100),
  MAX_FILES: positiveInt(process.env.MAX_FILES, 20), MAX_CODE_KB: positiveInt(process.env.MAX_CODE_KB, 500),
  EXPIRY_DAYS: [1, 7, 30, 0], BLOCKED,
  DATA_DIR: path.resolve(process.env.DATA_DIR || path.join(root, 'data')),
  UPLOAD_DIR: path.resolve(process.env.UPLOAD_DIR || path.join(root, 'uploads')),
  PUBLIC_DIR: path.join(root, 'public'),
};
