// Turns the MySQL rows of the old PHP backend into Firestore documents and
// Storage uploads. Pure: no database or network access, so it can be tested.

const VET_STATUS = {
  goedgekeurd: 'approved',
  geweigerd: 'rejected',
  'in afwachting': 'pending',
};

const APPOINTMENT_TYPE = {
  controle: 'checkup',
  vaccinatie: 'vaccination',
  operatie: 'surgery',
  overig: 'other',
};

// The PHP API stored this placeholder when no photo was uploaded.
const DEFAULT_PET_PHOTO = 'uploads/default-dier.png';

const CONTENT_TYPES = {
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  png: 'image/png',
  gif: 'image/gif',
  webp: 'image/webp',
  pdf: 'application/pdf',
};

export function contentTypeFor(fileName) {
  const extension = fileName.split('.').pop()?.toLowerCase() ?? '';
  return CONTENT_TYPES[extension] ?? 'application/octet-stream';
}

const fullName = (row) => `${row.voornaam} ${row.achternaam}`.trim();
const id = (value) => String(value);
const orNull = (value) => (value === undefined || value === '' ? null : value);

/**
 * @param {object} rows  Rows per table, with DATE/DATETIME columns as strings
 *   ("2026-05-26", "2026-05-26 09:00:00"): gemeente, klanten, dierenartsen,
 *   dieren, medisch_dossier, bezoeken.
 * @param {object} options
 * @param {Date} options.now  Used for createdAt/updatedAt.
 * @param {(relativePath: string) => boolean} options.fileExists  Whether an
 *   upload from the old API (e.g. "uploads/x.jpg") exists on disk.
 * @returns {{documents: {path: string, data: object}[],
 *   uploads: {localPath: string, storagePath: string, contentType: string,
 *     setField?: {path: string, field: string}}[],
 *   warnings: string[]}}
 */
export function transform(rows, { now, fileExists }) {
  const documents = [];
  const uploads = [];
  const warnings = [];

  // ── Municipalities ──────────────────────────────────────────────────────
  for (const row of rows.gemeente ?? []) {
    documents.push({
      path: `municipalities/${id(row.id)}`,
      data: { name: row.naam, postalCode: row.postcode },
    });
  }

  // ── Customers (keyed by Firebase UID) ───────────────────────────────────
  const customerUid = new Map();
  const customerName = new Map();
  for (const row of rows.klanten ?? []) {
    if (!row.firebase_uid) {
      warnings.push(`Customer ${row.id} (${row.email}) has no firebase_uid; skipped with their pets and appointments.`);
      continue;
    }
    customerUid.set(row.id, row.firebase_uid);
    customerName.set(row.id, fullName(row));
    documents.push({
      path: `customers/${row.firebase_uid}`,
      data: {
        firstName: row.voornaam,
        lastName: row.achternaam,
        email: row.email,
        birthDate: row.geboortedatum,
        municipalityId: id(row.gemeente_id),
        createdAt: now,
      },
    });
  }

  // ── Vets (keyed by Firebase UID) ────────────────────────────────────────
  const vetUid = new Map();
  const vetName = new Map();
  for (const row of rows.dierenartsen ?? []) {
    if (!row.firebase_uid) {
      warnings.push(`Vet ${row.id} (${row.email}) has no firebase_uid; skipped.`);
      continue;
    }
    vetUid.set(row.id, row.firebase_uid);
    vetName.set(row.id, fullName(row));

    let certificatePath = null;
    if (row.certificaat_url) {
      if (fileExists(row.certificaat_url)) {
        const fileName = row.certificaat_url.split('/').pop();
        certificatePath = `vetCertificates/${row.firebase_uid}/${fileName}`;
        uploads.push({
          localPath: row.certificaat_url,
          storagePath: certificatePath,
          contentType: contentTypeFor(fileName),
        });
      } else {
        warnings.push(`Certificate of vet ${row.id} not found on disk: ${row.certificaat_url}`);
      }
    }

    documents.push({
      path: `vets/${row.firebase_uid}`,
      data: {
        firstName: row.voornaam,
        lastName: row.achternaam,
        email: row.email,
        phone: row.telefoon ?? '',
        practiceName: row.praktijknaam ?? '',
        municipalityId: row.gemeente_id == null ? '' : id(row.gemeente_id),
        status: VET_STATUS[row.status] ?? 'pending',
        certificatePath,
        createdAt: now,
      },
    });
  }

  // ── Pets (document ID = old numeric ID) ─────────────────────────────────
  const pets = new Map();
  for (const row of rows.dieren ?? []) {
    const ownerId = customerUid.get(row.klant_id);
    if (!ownerId) {
      warnings.push(`Pet ${row.id} (${row.naam}) has no migrated owner; skipped.`);
      continue;
    }
    const petId = id(row.id);
    const vetId = row.dierenarts_id == null ? null : vetUid.get(row.dierenarts_id) ?? null;
    if (row.dierenarts_id != null && !vetId) {
      warnings.push(`Pet ${row.id}: vet ${row.dierenarts_id} was not migrated; vet left empty.`);
    }
    pets.set(row.id, { petId, ownerId, name: row.naam });

    const path = `pets/${petId}`;
    documents.push({
      path,
      data: {
        ownerId,
        vetId,
        name: row.naam,
        species: row.soort ?? '',
        birthDate: orNull(row.geboortedatum),
        photoUrl: null,
        createdAt: now,
      },
    });

    const photo = row.foto_url;
    if (photo && photo !== DEFAULT_PET_PHOTO) {
      if (fileExists(photo)) {
        uploads.push({
          localPath: photo,
          storagePath: `petPhotos/${ownerId}/${petId}`,
          contentType: contentTypeFor(photo),
          // The download URL is only known after uploading
          setField: { path, field: 'photoUrl' },
        });
      } else {
        warnings.push(`Photo of pet ${row.id} not found on disk: ${photo}`);
      }
    }
  }

  // ── Medical records (document ID = pet ID) ──────────────────────────────
  for (const row of rows.medisch_dossier ?? []) {
    const pet = pets.get(row.dier_id);
    if (!pet) {
      warnings.push(`Medical record ${row.id}: pet ${row.dier_id} was not migrated; skipped.`);
      continue;
    }
    documents.push({
      path: `medicalRecords/${pet.petId}`,
      data: {
        weight: row.gewicht == null ? null : String(Number(row.gewicht)),
        teethStatus: row.gebit_status ?? '',
        bonesStatus: row.botten_status ?? '',
        musclesStatus: row.spieren_status ?? '',
        notes: orNull(row.opmerking),
        updatedAt: now,
        updatedBy: 'migration',
      },
    });
  }

  // ── Appointments (document ID = "<vetId>_<date>_<HH:mm>") ───────────────
  const takenSlots = new Set();
  for (const row of rows.bezoeken ?? []) {
    const pet = pets.get(row.dier_id);
    const customerId = customerUid.get(row.klant_id);
    if (!pet || !customerId) {
      warnings.push(`Appointment ${row.id}: pet or customer was not migrated; skipped.`);
      continue;
    }
    const vetId = row.dierenarts_id == null ? null : vetUid.get(row.dierenarts_id) ?? null;
    const [date, clock = '00:00:00'] = String(row.geplande_datumtijd).split(' ');
    const time = clock.slice(0, 5);

    // Without a vet, or when two old appointments share a slot, there is no
    // slot to reserve; keep the appointment under a legacy ID.
    const slotId = vetId ? `${vetId}_${date}_${time}` : null;
    const hasSlot = slotId !== null && !takenSlots.has(slotId);
    if (slotId && !hasSlot) {
      warnings.push(`Appointment ${row.id} shares slot ${slotId} with another appointment; kept without a slot.`);
    }
    const appointmentId = hasSlot ? slotId : `legacy-${row.id}`;
    if (hasSlot) takenSlots.add(slotId);

    documents.push({
      path: `appointments/${appointmentId}`,
      data: {
        petId: pet.petId,
        petName: pet.name,
        customerId,
        customerName: customerName.get(row.klant_id),
        vetId: vetId ?? '',
        vetName: vetId ? vetName.get(row.dierenarts_id) : '',
        date,
        time,
        // Local time of the machine running the migration (Belgium)
        scheduledAt: new Date(`${date}T${clock}`),
        type: APPOINTMENT_TYPE[row.type] ?? 'other',
        notes: orNull(row.notities),
        createdAt: now,
      },
    });
    if (hasSlot) {
      documents.push({ path: `bookedSlots/${slotId}`, data: { vetId, date, time } });
    }
  }

  return { documents, uploads, warnings };
}
