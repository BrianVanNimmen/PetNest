// One-off migration from the MySQL database of the PHP API to Firestore and
// Cloud Storage. See ../README.md for how to run it.
//
//   node migration/migrate.mjs --dry-run   # only report what would happen
//   node migration/migrate.mjs             # write to Firebase
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';

import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getDownloadURL, getStorage } from 'firebase-admin/storage';
import mysql from 'mysql2/promise';

import { transform } from './transform.mjs';

const dryRun = process.argv.includes('--dry-run');

const config = {
  mysql: {
    host: process.env.MYSQL_HOST ?? '127.0.0.1',
    port: Number(process.env.MYSQL_PORT ?? 3307), // docker-compose maps 3307
    user: process.env.MYSQL_USER ?? 'root',
    password: process.env.MYSQL_PASSWORD,
    database: process.env.MYSQL_DATABASE ?? 'petnest_home',
    // Keep DATE/DATETIME as strings: no time zone conversion
    dateStrings: true,
  },
  // Folder that contains the API's "uploads/" directory
  apiDir: resolve(process.env.API_DIR ?? '../Petnest_API'),
  projectId: process.env.FIREBASE_PROJECT_ID ?? 'petnest-df4e9',
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET ?? 'petnest-df4e9.firebasestorage.app',
};

const TABLES = ['gemeente', 'klanten', 'dierenartsen', 'dieren', 'medisch_dossier', 'bezoeken'];

async function loadRows() {
  if (config.mysql.password === undefined) {
    throw new Error('Set MYSQL_PASSWORD (see .env in the repo root).');
  }
  const connection = await mysql.createConnection(config.mysql);
  try {
    const rows = {};
    for (const table of TABLES) {
      [rows[table]] = await connection.query(`SELECT * FROM \`${table}\``);
    }
    return rows;
  } finally {
    await connection.end();
  }
}

async function writeDocuments(db, documents) {
  // Firestore batches hold at most 500 writes
  for (let i = 0; i < documents.length; i += 400) {
    const batch = db.batch();
    for (const { path, data } of documents.slice(i, i + 400)) {
      batch.set(db.doc(path), data);
    }
    await batch.commit();
  }
}

async function uploadFiles(db, bucket, uploads) {
  for (const upload of uploads) {
    const file = bucket.file(upload.storagePath);
    await bucket.upload(resolve(config.apiDir, upload.localPath), {
      destination: upload.storagePath,
      contentType: upload.contentType,
    });
    if (upload.setField) {
      const url = await getDownloadURL(file);
      await db.doc(upload.setField.path).update({ [upload.setField.field]: url });
    }
    console.log(`  uploaded ${upload.localPath} -> ${upload.storagePath}`);
  }
}

async function main() {
  const rows = await loadRows();
  const { documents, uploads, warnings } = transform(rows, {
    now: new Date(),
    fileExists: (relativePath) => existsSync(resolve(config.apiDir, relativePath)),
  });

  const counts = {};
  for (const { path } of documents) {
    const collection = path.split('/')[0];
    counts[collection] = (counts[collection] ?? 0) + 1;
  }
  console.log('Documents:', counts);
  console.log('Files to upload:', uploads.length);
  for (const warning of warnings) console.warn(`! ${warning}`);

  if (dryRun) {
    console.log('Dry run: nothing written.');
    return;
  }

  // Uses GOOGLE_APPLICATION_CREDENTIALS (a service account key), or the
  // emulators when FIRESTORE_EMULATOR_HOST / FIREBASE_STORAGE_EMULATOR_HOST
  // are set.
  const app = initializeApp({
    credential: applicationDefault(),
    projectId: config.projectId,
    storageBucket: config.storageBucket,
  });
  const db = getFirestore(app);
  await writeDocuments(db, documents);
  console.log(`Wrote ${documents.length} documents.`);
  await uploadFiles(db, getStorage(app).bucket(), uploads);
  console.log('Done.');
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
