// One-off Phase 1 bootstrap: publish ../bundle.json to Firestore as
// content/bundle, plus its content/meta sibling — the exact two documents
// PortfolioRemoteDataSource reads. Written to be run once, by hand, by
// Marco; it is not called from the Flutter app and is not part of the
// runtime read/write path described in docs/firebase-migration-plan.md.
//
// Usage (from the tool/ directory):
//   npm install
//   node upload_bundle.js
//
// Requires tool/serviceAccountKey.json — see the console steps in the chat.
// That file is gitignored: it grants full read/write to the whole Firebase
// project, unlike firebase_options.dart or google-services.json, which are
// public client config, not secrets.

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const SERVICE_ACCOUNT_PATH = path.join(__dirname, 'serviceAccountKey.json');
const BUNDLE_PATH = path.join(__dirname, '..', 'bundle.json');

// Mirrors PortfolioBundle.currentSchemaVersion in
// lib/features/portfolio_content/domain/entities/portfolio_bundle.dart.
// Bumped by hand there when the bundle's shape changes; keep this in sync.
const CURRENT_SCHEMA_VERSION = 1;

// Firestore's own hard limit is 1 MiB; this leaves headroom the same way
// bundle_size_test.dart does.
const BUDGET_BYTES = 900 * 1024;

function fail(message) {
  console.error(`\n✗ ${message}\n`);
  process.exit(1);
}

if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
  fail(
    `Missing ${SERVICE_ACCOUNT_PATH}\n` +
      'Download it from Firebase Console → Project settings → Service accounts → ' +
      'Generate new private key, and save it at that exact path.'
  );
}

if (!fs.existsSync(BUNDLE_PATH)) {
  fail(`Missing ${BUNDLE_PATH} — export it from the app's admin FAB first.`);
}

const raw = fs.readFileSync(BUNDLE_PATH, 'utf8');
const bytes = Buffer.byteLength(raw, 'utf8');
let bundle;
try {
  bundle = JSON.parse(raw);
} catch (error) {
  fail(`bundle.json is not valid JSON: ${error.message}`);
}

// The same guards AdminFab's export already showed a warning for — checked
// again here because this script, not the export step, is what actually
// reaches Firestore.
if (bytes >= BUDGET_BYTES) {
  fail(
    `bundle.json is ${(bytes / 1024).toFixed(1)} KB, at or over the ` +
      `${(BUDGET_BYTES / 1024).toFixed(0)} KB budget (Firestore's hard limit is 1024 KB). ` +
      'Run "Reset to seed" in the admin, then Export again, before uploading.'
  );
}
if (raw.includes('"embedded"')) {
  fail(
    'bundle.json still contains an ImageSourceKind.embedded image (base64 ' +
      'inline). Publishing that would blow past Firestore limits fast. Reset ' +
      'to seed and re-export, or pin the image to Cloudinary first.'
  );
}
if (!Array.isArray(bundle.projects) || bundle.projects.length === 0) {
  fail('bundle.json has no projects — does not look like a real export.');
}

admin.initializeApp({
  credential: admin.credential.cert(require(SERVICE_ACCOUNT_PATH)),
});

async function main() {
  const db = admin.firestore();

  const contentVersion =
    typeof bundle.contentVersion === 'number' && bundle.contentVersion > 0
      ? bundle.contentVersion
      : 1;
  const schemaVersion = bundle.schemaVersion || CURRENT_SCHEMA_VERSION;
  const updatedAt = new Date().toISOString();

  const published = { ...bundle, contentVersion, schemaVersion, updatedAt };
  const meta = { contentVersion, schemaVersion, updatedAt };

  // One batch, matching PortfolioRemoteDataSourceImpl.writeBundle: a reader
  // must never see meta advertise a version whose bundle has not landed yet.
  const batch = db.batch();
  batch.set(db.collection('content').doc('bundle'), published);
  batch.set(db.collection('content').doc('meta'), meta);
  await batch.commit();

  console.log('\n✓ Published to Firestore:');
  console.log(`  content/bundle  (${(bytes / 1024).toFixed(1)} KB)`);
  console.log(`  content/meta    ${JSON.stringify(meta)}`);
  console.log(
    '\nNext: run the app (a fresh profile or with storage cleared) and ' +
      'confirm it reads this content — then delete data/seed/.'
  );
}

main().catch((error) => fail(error.message));
