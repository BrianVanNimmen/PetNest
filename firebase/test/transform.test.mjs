import assert from 'node:assert/strict';
import { test } from 'node:test';

import { contentTypeFor, transform } from '../migration/transform.mjs';

const now = new Date('2026-11-02T12:00:00Z');

const rows = {
  gemeente: [{ id: 1, postcode: '2000', naam: 'Antwerpen' }],
  klanten: [
    { id: 1, voornaam: 'Jan', achternaam: 'Janssens', geboortedatum: '1990-01-02', gemeente_id: 1, email: 'jan@x.be', firebase_uid: 'uidJan' },
    { id: 2, voornaam: 'No', achternaam: 'Uid', geboortedatum: '1990-01-02', gemeente_id: 1, email: 'no@x.be', firebase_uid: null },
  ],
  dierenartsen: [
    { id: 7, voornaam: 'Eva', achternaam: 'Peeters', email: 'eva@x.be', firebase_uid: 'uidEva', status: 'goedgekeurd', certificaat_url: 'uploads/certificaten/c.pdf', telefoon: '0470', praktijknaam: 'Animoo', gemeente_id: 1 },
    { id: 8, voornaam: 'Tom', achternaam: 'Wacht', email: 'tom@x.be', firebase_uid: 'uidTom', status: 'in afwachting', certificaat_url: null, telefoon: null, praktijknaam: null, gemeente_id: null },
  ],
  dieren: [
    { id: 10, naam: 'Rex', klant_id: 1, dierenarts_id: 7, foto_url: 'uploads/rex.jpg', geboortedatum: '2020-05-01', soort: 'Hond' },
    { id: 11, naam: 'Mia', klant_id: 1, dierenarts_id: null, foto_url: 'uploads/default-dier.png', geboortedatum: null, soort: 'Kat' },
    { id: 12, naam: 'Orphan', klant_id: 2, dierenarts_id: null, foto_url: null, geboortedatum: null, soort: 'Vis' },
  ],
  medisch_dossier: [
    { id: 1, dier_id: 10, gewicht: '5.30', gebit_status: 'goed', botten_status: 'normaal', spieren_status: 'sterk', opmerking: '' },
  ],
  bezoeken: [
    { id: 100, dier_id: 10, klant_id: 1, dierenarts_id: 7, geplande_datumtijd: '2026-12-01 09:00:00', type: 'controle', notities: null },
    { id: 101, dier_id: 11, klant_id: 1, dierenarts_id: 7, geplande_datumtijd: '2026-12-01 09:00:00', type: 'operatie', notities: 'x' },
    { id: 102, dier_id: 11, klant_id: 1, dierenarts_id: null, geplande_datumtijd: '2026-12-02 10:00:00', type: 'vaccinatie', notities: null },
  ],
};

const result = transform(rows, { now, fileExists: (path) => path !== 'uploads/missing.jpg' });
const doc = (path) => result.documents.find((d) => d.path === path)?.data;

test('profiles are keyed by Firebase UID, rows without one are skipped', () => {
  assert.deepEqual(doc('customers/uidJan'), {
    firstName: 'Jan', lastName: 'Janssens', email: 'jan@x.be',
    birthDate: '1990-01-02', municipalityId: '1', createdAt: now,
  });
  assert.equal(result.documents.filter((d) => d.path.startsWith('customers/')).length, 1);
  assert.ok(result.warnings.some((w) => w.includes('Customer 2')));
  assert.ok(result.warnings.some((w) => w.includes('Pet 12')));
});

test('vet status and certificate are translated', () => {
  assert.equal(doc('vets/uidEva').status, 'approved');
  assert.equal(doc('vets/uidEva').certificatePath, 'vetCertificates/uidEva/c.pdf');
  assert.equal(doc('vets/uidTom').status, 'pending');
  assert.equal(doc('vets/uidTom').certificatePath, null);
});

test('pets get their owner and vet UIDs; default photos are dropped', () => {
  assert.equal(doc('pets/10').ownerId, 'uidJan');
  assert.equal(doc('pets/10').vetId, 'uidEva');
  assert.equal(doc('pets/11').vetId, null);
  const photos = result.uploads.filter((u) => u.storagePath.startsWith('petPhotos/'));
  assert.deepEqual(photos, [{
    localPath: 'uploads/rex.jpg',
    storagePath: 'petPhotos/uidJan/10',
    contentType: 'image/jpeg',
    setField: { path: 'pets/10', field: 'photoUrl' },
  }]);
});

test('medical records use the pet ID', () => {
  assert.equal(doc('medicalRecords/10').weight, '5.3');
  assert.equal(doc('medicalRecords/10').notes, null);
});

test('appointments are keyed by slot, with English types', () => {
  const first = doc('appointments/uidEva_2026-12-01_09:00');
  assert.equal(first.type, 'checkup');
  assert.equal(first.petName, 'Rex');
  assert.equal(first.vetName, 'Eva Peeters');
  assert.deepEqual(doc('bookedSlots/uidEva_2026-12-01_09:00'), { vetId: 'uidEva', date: '2026-12-01', time: '09:00' });

  // Same slot as the first: kept, but without a slot reservation
  assert.equal(doc('appointments/legacy-101').type, 'surgery');
  // No vet: no slot
  assert.equal(doc('appointments/legacy-102').vetId, '');
  assert.equal(result.documents.filter((d) => d.path.startsWith('bookedSlots/')).length, 1);
});

test('content types by extension', () => {
  assert.equal(contentTypeFor('a.PDF'), 'application/pdf');
  assert.equal(contentTypeFor('b.webp'), 'image/webp');
  assert.equal(contentTypeFor('noext'), 'application/octet-stream');
});
