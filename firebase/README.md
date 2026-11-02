# PetNest Firebase backend

PetNest stores its data in Cloud Firestore, files in Cloud Storage and accounts
in Firebase Auth (email/password and Google). There is no server of our own:
the security rules in this folder decide who can read and write what.

| File | Purpose |
| --- | --- |
| `firestore.rules`, `storage.rules` | Who can read and write which data |
| `firestore.indexes.json` | Composite indexes the app's queries need |
| `firebase.json`, `.firebaserc` | Firebase CLI config (project `petnest-df4e9`) |
| `test/rules.test.mjs` | Rule tests against the local emulators |
| `migration/` | One-off copy of the old MySQL data into Firestore |

## Data model

Profile documents use the Firebase Auth UID as their ID.

```
customers/{uid}        firstName, lastName, email, birthDate (yyyy-MM-dd),
                       municipalityId, createdAt
vets/{uid}             firstName, lastName, email, phone, practiceName,
                       municipalityId, status (pending|approved|rejected),
                       certificatePath, createdAt
municipalities/{id}    name, postalCode
pets/{petId}           ownerId (customer UID), vetId (vet UID or null), name,
                       species, birthDate, photoUrl, createdAt
medicalRecords/{petId} weight, teethStatus, bonesStatus, musclesStatus, notes,
                       updatedAt, updatedBy
appointments/{slotId}  petId, petName, customerId, customerName, vetId,
                       vetName, date, time (HH:mm), scheduledAt, type, notes,
                       createdAt
bookedSlots/{slotId}   vetId, date, time
```

Storage:

```
petPhotos/{ownerUid}/{petId}           readable by signed-in users
vetCertificates/{vetUid}/{fileName}    private to the vet (and admins)
```

- **Appointment types** are `checkup`, `vaccination`, `surgery` or `other`.
- **No double booking.** An appointment's ID is its slot,
  `<vetId>_<yyyy-MM-dd>_<HH:mm>`, and `bookedSlots/<same ID>` is written in the
  same batch. The rules deny writing to an existing slot, so each slot can be
  booked only once. `bookedSlots` holds no personal data, so customers can see
  which times are taken without reading other people's appointments.
- **Copied names.** Firestore has no joins, so `petName`, `customerName` and
  `vetName` are stored on each appointment. Renaming a pet does not update its
  old appointments.

## Who can do what

- **Customers** read and write their own profile, pets and appointments, read
  their pets' medical records, and see approved vets.
- **Vets** read their patients (pets with their UID as `vetId`), the
  appointments booked with them, and write those patients' medical records.
- **New vets** start as `pending` and cannot change their own status. Approve
  them in the Firebase console: open `vets/{uid}` and set `status` to
  `approved` (or `rejected`). The app refuses to log in a vet who is not
  approved.
- **Admins** use the Firebase console; the rules don't apply there.

## One-time setup in the Firebase console

1. **Firestore Database**: create it (production mode) in a European region.
2. **Storage**: enable it.
3. **Authentication → Sign-in method**: enable *Email/Password* and *Google*.
4. **Project settings → Your apps → Android app** (`be.brianvannimmen.petnest`):
   add the SHA-1 of the signing key. For the debug key on this PC:
   `15:FF:D9:15:74:C9:98:73:AA:B3:43:46:F9:C1:7E:2F:51:C0:2C:48`.
   Add the release key's SHA-1 too when you publish.
5. Download `google-services.json` again and replace
   `petnest/android/app/google-services.json`. The current file has no OAuth
   client, so Google sign-in fails with a configuration error until it is
   replaced.
6. Deploy the rules and indexes:

   ```sh
   npm install -g firebase-tools   # the Firebase CLI, if not installed yet
   cd firebase
   npm install
   firebase login
   npm run deploy:rules
   ```

## Moving the existing data (once)

`migration/migrate.mjs` reads the old MySQL database and writes everything to
Firestore and Storage. It translates the Dutch values and field names to the
English model above, and uploads pet photos and certificates from
`Petnest_API/uploads/`.

1. Start the old database: `docker compose up petnest_db` (repo root).
2. In the Firebase console, go to *Project settings → Service accounts*,
   generate a private key, and save it outside the repo or as
   `serviceAccount.json` (gitignored).
3. Run:

   ```sh
   cd firebase
   # PowerShell: $env:MYSQL_PASSWORD="..."; $env:GOOGLE_APPLICATION_CREDENTIALS="..."
   export MYSQL_PASSWORD=...                      # from ../.env
   export GOOGLE_APPLICATION_CREDENTIALS=./serviceAccount.json
   npm run migrate -- --dry-run                   # counts and warnings only
   npm run migrate
   ```

Notes:

- **Rows that can't move.** Customers and vets without a `firebase_uid` are
  skipped, along with their pets and appointments. The dry run lists them.
- **Municipalities.** The SQL dumps in this repo contain no municipality rows;
  those only exist in the running database, so run the migration against it.
- **Time zone.** Appointment times are read as local time, so run the
  migration on a machine set to Belgian time.
- **Safe to re-run.** IDs are fixed (pet ID = old ID, profile ID = UID).
- **Optional settings.** `MYSQL_HOST`, `MYSQL_PORT` (default 3307),
  `MYSQL_USER`, `MYSQL_DATABASE`, `API_DIR` and `FIREBASE_STORAGE_BUCKET` can be
  set the same way.

## Tests

```sh
cd firebase
npm install
npm test             # migration transform + rule tests on the emulators
```

The rule tests need the Firebase CLI and Java (for the Firestore emulator).
`npm test` starts and stops the emulators itself.
