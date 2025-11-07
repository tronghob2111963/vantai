const fs = require(''fs'');
const path = require(''path'');
const iconv = require(''iconv-lite'');

const files = [
  'src/AppLayout.jsx',
  'src/components/module 1/SystemSettingsPage.jsx',
  'src/components/module 1/AdminBranchesPage.jsx',
  'src/components/module 1/AdminCreateUserPage.jsx',
  'src/components/module 1/LoginPage.jsx',
  'src/components/module 1/UserDetailPage.jsx',
  'src/components/module 1/AdminManagersPage.jsx',
];

function convertIfNeeded(file) {
  const p = path.resolve(process.cwd(), file);
  if (!fs.existsSync(p)) return console.log('[skip] not found:', file);
  const buf = fs.readFileSync(p);
  // Heuristic: if UTF-8 decoding contains lots of replacement chars or mojibake patterns,
  // try decoding as cp1258 and write back as utf8.
  const utf8Text = buf.toString(''utf8'');
  const hasMojibake = /�|A�|��|\?\d/.test(utf8Text);
  if (!hasMojibake) {
    console.log('[ok] looks utf8:', file);
    return;
  }
  // Try cp1258, then cp1252
  let decoded = null;
  try { decoded = iconv.decode(buf, ''cp1258''); } catch {}
  if (!decoded || /�/.test(decoded)) {
    try { decoded = iconv.decode(buf, ''windows-1252''); } catch {}
  }
  if (!decoded) {
    console.log('[warn] could not decode:', file);
    return;
  }
  fs.writeFileSync(p, decoded, { encoding: ''utf8'' });
  console.log('[fix] converted to utf8:', file);
}

for (const f of files) convertIfNeeded(f);
