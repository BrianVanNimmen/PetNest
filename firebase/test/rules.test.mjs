// Security rule tests. Run with `npm run test:rules` (starts the emulators).
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import firebase from 'firebase/compat/app';
import 'firebase/compat/firestore';
import 'firebase/compat/storage';

const { serverTimestamp } = firebase.firestore.FieldValue;
const { Timestamp } = firebase.firestore;

let env;

// `firebase emulators:exec` sets these; the defaults match firebase.json.
function emulator(variable, fallback) {
  const [host, port] = (process.env[variable] ?? fallback).split(':');
  return { host, port: Number(port) };
}

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-petnest',
    firestore: {
      rules: readFileSync('firestore.rules', 'utf8'),
      ...emulator('FIRESTORE_EMULATOR_HOST', '127.0.0.1:8085'),
    },
    storage: {
      rules: readFileSync('storage.rules', 'utf8'),
      ...emulator('FIREBASE_STORAGE_EMULATOR_HOST', '127.0.0.1:9199'),
    },
  });
});

after(async () => {
  await env?.cleanup();
});

const tomorrow = new Date(Date.now() + 24 * 60 * 60 * 1000);
const tomorrowDate = tomorrow.toISOString().slice(0, 10);

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const created = Timestamp.now();
    await db.doc('municipalities/1').set({ name: 'Antwerpen', postalCode: '2000' });
    for (const uid of ['alice', 'bob']) {
      await db.doc(`customers/${uid}`).set({
        firstName: uid,
        lastName: 'Doe',
        email: `${uid}@example.com`,
        birthDate: '1990-01-01',
        municipalityId: '1',
        createdAt: created,
      });
    }
    const vet = (status) => ({
      firstName: 'Eva',
      lastName: 'Peeters',
      email: 'eva@example.com',
      phone: '0470 99 99 99',
      practiceName: 'Animoo',
      municipalityId: '1',
      status,
      certificatePath: 'vetCertificates/x/cert.pdf',
      createdAt: created,
    });
    await db.doc('vets/drVet').set(vet('approved'));
    await db.doc('vets/drPending').set(vet('pending'));
    await db.doc('pets/rex').set({
      ownerId: 'alice', vetId: 'drVet', name: 'Rex', species: 'Dog',
      birthDate: '2020-05-01', photoUrl: null, createdAt: created,
    });
    await db.doc('pets/mia').set({
      ownerId: 'bob', vetId: null, name: 'Mia', species: 'Cat',
      birthDate: null, photoUrl: null, createdAt: created,
    });
  });
});

const db = (uid) => (uid ? env.authenticatedContext(uid) : env.unauthenticatedContext()).firestore();

function appointment(overrides = {}) {
  const data = {
    petId: 'rex',
    petName: 'Rex',
    customerId: 'alice',
    customerName: 'alice Doe',
    vetId: 'drVet',
    vetName: 'Eva Peeters',
    date: tomorrowDate,
    time: '09:00',
    scheduledAt: Timestamp.fromDate(tomorrow),
    type: 'checkup',
    notes: null,
    createdAt: serverTimestamp(),
    ...overrides,
  };
  return { id: `${data.vetId}_${data.date}_${data.time}`, data };
}

function book(firestore, { id, data }, { withSlot = true } = {}) {
  const batch = firestore.batch();
  batch.set(firestore.doc(`appointments/${id}`), data);
  if (withSlot) {
    batch.set(firestore.doc(`bookedSlots/${id}`), { vetId: data.vetId, date: data.date, time: data.time });
  }
  return batch.commit();
}

describe('municipalities', () => {
  test('anyone can read, nobody can write', async () => {
    await assertSucceeds(db(null).doc('municipalities/1').get());
    await assertFails(db('alice').doc('municipalities/2').set({ name: 'Gent' }));
  });
});

describe('customers', () => {
  const profile = {
    firstName: 'Carl', lastName: 'Doe', email: 'carl@example.com',
    birthDate: '1985-02-03', municipalityId: '1',
  };

  test('a user creates only their own profile', async () => {
    await assertSucceeds(db('carl').doc('customers/carl').set({ ...profile, createdAt: serverTimestamp() }));
    await assertFails(db('carl').doc('customers/dave').set({ ...profile, createdAt: serverTimestamp() }));
  });

  test('unknown fields and bad dates are rejected', async () => {
    await assertFails(db('carl').doc('customers/carl').set({ ...profile, createdAt: serverTimestamp(), role: 'admin' }));
    await assertFails(db('carl').doc('customers/carl').set({ ...profile, birthDate: '03/02/1985', createdAt: serverTimestamp() }));
  });

  test('customers cannot read each other', async () => {
    await assertSucceeds(db('alice').doc('customers/alice').get());
    await assertFails(db('bob').doc('customers/alice').get());
  });
});

describe('vets', () => {
  const profile = {
    firstName: 'Tom', lastName: 'Vet', email: 'tom@example.com', phone: '0470',
    practiceName: 'Paws', municipalityId: '1', certificatePath: 'vetCertificates/tom/cert.pdf',
  };

  test('new vets must start as pending', async () => {
    await assertFails(db('tom').doc('vets/tom').set({ ...profile, status: 'approved', createdAt: serverTimestamp() }));
    await assertSucceeds(db('tom').doc('vets/tom').set({ ...profile, status: 'pending', createdAt: serverTimestamp() }));
  });

  test('a vet cannot approve themselves', async () => {
    await assertFails(db('drPending').doc('vets/drPending').update({ status: 'approved' }));
  });

  test('signed-in users can list approved vets only', async () => {
    await assertSucceeds(db('alice').collection('vets').where('status', '==', 'approved').get());
    await assertFails(db('alice').collection('vets').get());
    await assertFails(db(null).collection('vets').where('status', '==', 'approved').get());
  });

  test('a pending vet can read their own profile', async () => {
    await assertSucceeds(db('drPending').doc('vets/drPending').get());
    await assertFails(db('alice').doc('vets/drPending').get());
  });
});

describe('pets', () => {
  test('owner and the pet\'s vet can read, others cannot', async () => {
    await assertSucceeds(db('alice').doc('pets/rex').get());
    await assertSucceeds(db('drVet').doc('pets/rex').get());
    await assertFails(db('bob').doc('pets/rex').get());
  });

  test('queries must be limited to the user\'s own pets', async () => {
    await assertSucceeds(db('alice').collection('pets').where('ownerId', '==', 'alice').get());
    await assertSucceeds(db('drVet').collection('pets').where('vetId', '==', 'drVet').get());
    await assertFails(db('alice').collection('pets').get());
  });

  test('a customer creates pets for themselves with an approved vet', async () => {
    const pet = { name: 'Max', species: 'Dog', birthDate: null, photoUrl: null, createdAt: serverTimestamp() };
    await assertSucceeds(db('alice').collection('pets').add({ ...pet, ownerId: 'alice', vetId: 'drVet' }));
    await assertSucceeds(db('alice').collection('pets').add({ ...pet, ownerId: 'alice', vetId: null }));
    await assertFails(db('alice').collection('pets').add({ ...pet, ownerId: 'bob', vetId: null }));
    await assertFails(db('alice').collection('pets').add({ ...pet, ownerId: 'alice', vetId: 'drPending' }));
    await assertFails(db('drVet').collection('pets').add({ ...pet, ownerId: 'drVet', vetId: null }));
  });

  test('only the owner updates, and cannot hand the pet to someone else', async () => {
    await assertSucceeds(db('alice').doc('pets/rex').update({ name: 'Rexie' }));
    await assertFails(db('alice').doc('pets/rex').update({ ownerId: 'bob' }));
    await assertFails(db('bob').doc('pets/rex').update({ name: 'Mine' }));
    await assertFails(db('drVet').doc('pets/rex').update({ name: 'Patient' }));
  });
});

describe('medical records', () => {
  const record = () => ({
    weight: '5.3', teethStatus: 'good', bonesStatus: 'normal', musclesStatus: 'strong',
    notes: null, updatedAt: serverTimestamp(),
  });

  test('only the pet\'s vet writes the record', async () => {
    await assertSucceeds(db('drVet').doc('medicalRecords/rex').set({ ...record(), updatedBy: 'drVet' }));
    await assertFails(db('alice').doc('medicalRecords/rex').set({ ...record(), updatedBy: 'alice' }));
    await assertFails(db('drPending').doc('medicalRecords/rex').set({ ...record(), updatedBy: 'drPending' }));
  });

  test('owner and vet read, others cannot', async () => {
    await assertSucceeds(db('alice').doc('medicalRecords/rex').get());
    await assertSucceeds(db('drVet').doc('medicalRecords/rex').get());
    await assertFails(db('bob').doc('medicalRecords/rex').get());
  });
});

describe('appointments', () => {
  test('a customer books a free slot for their own pet', async () => {
    await assertSucceeds(book(db('alice'), appointment()));
  });

  test('a slot cannot be booked twice', async () => {
    await assertSucceeds(book(db('alice'), appointment()));
    await assertFails(book(db('bob'), appointment({ petId: 'mia', petName: 'Mia', customerId: 'bob' })));
  });

  test('booking without the slot document is rejected', async () => {
    await assertFails(book(db('alice'), appointment(), { withSlot: false }));
  });

  test('invalid bookings are rejected', async () => {
    await assertFails(book(db('alice'), appointment({ vetId: 'drPending' })));
    await assertFails(book(db('alice'), appointment({ petId: 'mia' })));
    await assertFails(book(db('alice'), appointment({ type: 'controle' })));
    await assertFails(book(db('alice'), appointment({ scheduledAt: Timestamp.fromDate(new Date('2020-01-01')) })));
    await assertFails(book(db('drVet'), appointment({ customerId: 'drVet' })));
  });

  test('others see that a slot is taken, but not the appointment', async () => {
    const booking = appointment();
    await book(db('alice'), booking);
    await assertSucceeds(db('bob').collection('bookedSlots').where('vetId', '==', 'drVet').where('date', '==', tomorrowDate).get());
    await assertFails(db('bob').doc(`appointments/${booking.id}`).get());
    await assertSucceeds(db('drVet').doc(`appointments/${booking.id}`).get());
    await assertSucceeds(db('alice').collection('appointments').where('customerId', '==', 'alice').get());
  });

  test('cancelling deletes the appointment and frees the slot together', async () => {
    const { id } = appointment();
    await book(db('alice'), appointment());
    await assertFails(db('alice').doc(`appointments/${id}`).delete());
    await assertFails(db('alice').doc(`bookedSlots/${id}`).delete());

    const firestore = db('alice');
    const batch = firestore.batch();
    batch.delete(firestore.doc(`appointments/${id}`));
    batch.delete(firestore.doc(`bookedSlots/${id}`));
    await assertSucceeds(batch.commit());
  });

  test('appointments cannot be edited', async () => {
    const booking = appointment();
    await book(db('alice'), booking);
    await assertFails(db('alice').doc(`appointments/${booking.id}`).update({ type: 'surgery' }));
  });
});

describe('storage', () => {
  const storage = (uid) => env.authenticatedContext(uid).storage();
  const image = new Uint8Array([0x89, 0x50, 0x4e, 0x47]);

  test('owners upload images for their own pets only', async () => {
    await assertSucceeds(storage('alice').ref('petPhotos/alice/rex').put(image, { contentType: 'image/png' }));
    await assertFails(storage('alice').ref('petPhotos/bob/mia').put(image, { contentType: 'image/png' }));
    await assertFails(storage('alice').ref('petPhotos/alice/rex').put(image, { contentType: 'text/html' }));
  });

  test('certificates are private to the vet', async () => {
    await assertSucceeds(storage('tom').ref('vetCertificates/tom/cert.pdf').put(image, { contentType: 'application/pdf' }));
    await assertSucceeds(storage('tom').ref('vetCertificates/tom/cert.pdf').getMetadata());
    await assertFails(storage('alice').ref('vetCertificates/tom/cert.pdf').getMetadata());
  });
});
