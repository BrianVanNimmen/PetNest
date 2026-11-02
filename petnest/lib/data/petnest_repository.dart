import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../strings.dart';
import 'models/appointment.dart';
import 'models/pet.dart';
import 'models/profiles.dart';

/// Thrown when someone else booked the slot first.
class SlotTakenException implements Exception {
  const SlotTakenException();

  @override
  String toString() => Strings.slotTaken;
}

/// A readable message for errors from Firebase and this repository.
String describeError(Object error) => switch (error) {
  SlotTakenException() => Strings.slotTaken,
  FirebaseException(:final message, :final code) => message ?? code,
  GoogleSignInException(:final description, :final code) =>
    description ?? code.name,
  _ => '$error',
};

/// All Firestore, Cloud Storage and Firebase Auth access. The data model is
/// documented in firebase/README.md at the repository root.
class PetNestRepository {
  PetNestRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _firestoreOverride = firestore,
       _authOverride = auth,
       _storageOverride = storage;

  static final instance = PetNestRepository();

  /// Optional: the web OAuth client ID from the Firebase console. Not needed
  /// when google-services.json contains the web client.
  static const _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  final FirebaseFirestore? _firestoreOverride;
  final FirebaseAuth? _authOverride;
  final FirebaseStorage? _storageOverride;

  // Resolved lazily, so tests only need the services they use
  FirebaseFirestore get _db => _firestoreOverride ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseStorage get _storage => _storageOverride ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _customers =>
      _db.collection('customers');
  CollectionReference<Map<String, dynamic>> get _vets => _db.collection('vets');
  CollectionReference<Map<String, dynamic>> get _municipalities =>
      _db.collection('municipalities');
  CollectionReference<Map<String, dynamic>> get _pets => _db.collection('pets');
  CollectionReference<Map<String, dynamic>> get _medicalRecords =>
      _db.collection('medicalRecords');
  CollectionReference<Map<String, dynamic>> get _appointments =>
      _db.collection('appointments');
  CollectionReference<Map<String, dynamic>> get _bookedSlots =>
      _db.collection('bookedSlots');

  // ── Authentication ─────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;

  Future<User> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user!;
  }

  Future<User> createAccount(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user!;
  }

  static Future<void>? _googleInitialization;

  Future<void> _initializeGoogleSignIn() =>
      _googleInitialization ??= GoogleSignIn.instance.initialize(
        serverClientId: _googleServerClientId.isEmpty
            ? null
            : _googleServerClientId,
      );

  /// Google sign-in (OAuth) through Firebase Auth. Returns null when the
  /// user cancels.
  Future<User?> signInWithGoogle() async {
    await _initializeGoogleSignIn();
    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<void> signOut() async {
    if (_googleInitialization != null) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  /// Removes a just-created account when its profile could not be saved.
  Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }

  // ── Profiles ───────────────────────────────────────────────────────────────

  Future<Customer?> getCustomer(String uid) async {
    final doc = await _customers.doc(uid).get();
    return doc.exists ? Customer.fromFirestore(doc) : null;
  }

  Future<Vet?> getVet(String uid) async {
    final doc = await _vets.doc(uid).get();
    return doc.exists ? Vet.fromFirestore(doc) : null;
  }

  Future<void> createCustomer(Customer customer) =>
      _customers.doc(customer.id).set(customer.toNewDocument());

  /// Uploads the certificate, then creates the (pending) vet profile.
  Future<void> createVet(Vet vet, PickedUpload certificate) async {
    final path = 'vetCertificates/${vet.id}/${certificate.name}';
    await _storage
        .ref(path)
        .putData(
          certificate.bytes,
          SettableMetadata(contentType: certificate.contentType),
        );
    final withCertificate = Vet(
      id: vet.id,
      firstName: vet.firstName,
      lastName: vet.lastName,
      email: vet.email,
      phone: vet.phone,
      practiceName: vet.practiceName,
      municipalityId: vet.municipalityId,
      status: VetStatus.pending,
      certificatePath: path,
    );
    await _vets.doc(vet.id).set(withCertificate.toNewDocument());
  }

  Future<List<Municipality>> getMunicipalities() async {
    final snapshot = await _municipalities.orderBy('name').get();
    return snapshot.docs.map(Municipality.fromFirestore).toList();
  }

  Future<List<Vet>> getApprovedVets() async {
    final snapshot = await _vets
        .where('status', isEqualTo: VetStatus.approved.name)
        .get();
    return snapshot.docs.map(Vet.fromFirestore).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  // ── Pets ───────────────────────────────────────────────────────────────────

  Future<List<Pet>> getPetsForOwner(String ownerId) =>
      _petsWhere('ownerId', ownerId);

  /// The vet's patients.
  Future<List<Pet>> getPetsForVet(String vetId) => _petsWhere('vetId', vetId);

  Future<List<Pet>> _petsWhere(String field, String uid) async {
    final snapshot = await _pets.where(field, isEqualTo: uid).get();
    return snapshot.docs.map(Pet.fromFirestore).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<Pet?> getPet(String petId) async {
    final doc = await _pets.doc(petId).get();
    return doc.exists ? Pet.fromFirestore(doc) : null;
  }

  Future<String> _uploadPetPhoto(
    String ownerId,
    String petId,
    PickedUpload photo,
  ) async {
    final ref = _storage.ref('petPhotos/$ownerId/$petId');
    await ref.putData(
      photo.bytes,
      SettableMetadata(contentType: photo.contentType),
    );
    return ref.getDownloadURL();
  }

  Future<void> createPet({
    required String ownerId,
    required String name,
    required String species,
    String? birthDate,
    String? vetId,
    PickedUpload? photo,
  }) async {
    final ref = _pets.doc();
    final photoUrl = photo == null
        ? null
        : await _uploadPetPhoto(ownerId, ref.id, photo);
    await ref.set({
      'ownerId': ownerId,
      'vetId': vetId,
      'name': name,
      'species': species,
      'birthDate': birthDate,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePet(Pet pet, {PickedUpload? photo}) async {
    final photoUrl = photo == null
        ? pet.photoUrl
        : await _uploadPetPhoto(pet.ownerId, pet.id, photo);
    await _pets.doc(pet.id).update({
      'vetId': pet.vetId,
      'name': pet.name,
      'species': pet.species,
      'birthDate': pet.birthDate,
      'photoUrl': photoUrl,
    });
  }

  // ── Medical records ────────────────────────────────────────────────────────

  /// Null when the vet has not filled in a record yet.
  Future<MedicalRecord?> getMedicalRecord(String petId) async {
    final doc = await _medicalRecords.doc(petId).get();
    return doc.exists ? MedicalRecord.fromFirestore(doc) : null;
  }

  Future<void> saveMedicalRecord(
    String petId,
    MedicalRecord record, {
    required String vetId,
  }) => _medicalRecords.doc(petId).set({
    'weight': record.weight,
    'teethStatus': record.teethStatus,
    'bonesStatus': record.bonesStatus,
    'musclesStatus': record.musclesStatus,
    'notes': record.notes,
    'updatedAt': FieldValue.serverTimestamp(),
    'updatedBy': vetId,
  });

  // ── Appointments ───────────────────────────────────────────────────────────

  /// Upcoming appointments of a customer, soonest first.
  Future<List<Appointment>> getCustomerAppointments(
    String customerId, {
    int limit = 50,
  }) async {
    final snapshot = await _appointments
        .where('customerId', isEqualTo: customerId)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('scheduledAt')
        .limit(limit)
        .get();
    return snapshot.docs.map(Appointment.fromFirestore).toList();
  }

  Future<List<Appointment>> getVetAppointmentsForDay(
    String vetId,
    DateTime day,
  ) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await _appointments
        .where('vetId', isEqualTo: vetId)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('scheduledAt')
        .get();
    return snapshot.docs.map(Appointment.fromFirestore).toList();
  }

  /// Times ("HH:mm") already booked with a vet on a date.
  Future<Set<String>> getBookedTimes(String vetId, String date) async {
    final snapshot = await _bookedSlots
        .where('vetId', isEqualTo: vetId)
        .where('date', isEqualTo: date)
        .get();
    return {for (final doc in snapshot.docs) doc.data()['time'] as String};
  }

  /// Books a slot. Throws [SlotTakenException] when it was taken meanwhile.
  Future<void> createAppointment({
    required String petId,
    required String petName,
    required String customerId,
    required String customerName,
    required String vetId,
    required String vetName,
    required String date,
    required String time,
    required String type,
  }) async {
    final slotId = Appointment.slotId(vetId, date, time);
    final slotRef = _bookedSlots.doc(slotId);
    await _db.runTransaction((transaction) async {
      if ((await transaction.get(slotRef)).exists) {
        throw const SlotTakenException();
      }
      transaction.set(_appointments.doc(slotId), {
        'petId': petId,
        'petName': petName,
        'customerId': customerId,
        'customerName': customerName,
        'vetId': vetId,
        'vetName': vetName,
        'date': date,
        'time': time,
        'scheduledAt': Timestamp.fromDate(DateTime.parse('${date}T$time:00')),
        'type': type,
        'notes': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      transaction.set(slotRef, {'vetId': vetId, 'date': date, 'time': time});
    });
  }

  /// Deletes the appointment and frees its slot.
  Future<void> cancelAppointment(Appointment appointment) async {
    final batch = _db.batch()
      ..delete(_appointments.doc(appointment.id))
      ..delete(_bookedSlots.doc(appointment.id));
    await batch.commit();
  }
}
