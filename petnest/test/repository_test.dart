import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petnest/data/models/pet.dart';
import 'package:petnest/data/models/profiles.dart';
import 'package:petnest/data/petnest_repository.dart';
import 'package:petnest/model/appointment_type.dart';
import 'package:petnest/util/text.dart';

void main() {
  late FakeFirebaseFirestore db;
  late PetNestRepository repository;

  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final tomorrowIso = isoDate(tomorrow);

  Future<void> book({
    String petId = 'rex',
    String customerId = 'alice',
    String time = '09:00',
  }) => repository.createAppointment(
    petId: petId,
    petName: 'Rex',
    customerId: customerId,
    customerName: 'Alice Doe',
    vetId: 'drVet',
    vetName: 'Eva Peeters',
    date: tomorrowIso,
    time: time,
    type: AppointmentType.checkup.value,
  );

  setUp(() {
    db = FakeFirebaseFirestore();
    repository = PetNestRepository(firestore: db);
  });

  test('customer profiles round-trip by UID', () async {
    await repository.createCustomer(
      const Customer(
        id: 'alice',
        firstName: 'Alice',
        lastName: 'Doe',
        email: 'alice@example.com',
        birthDate: '1990-01-02',
        municipalityId: '1',
      ),
    );
    final customer = await repository.getCustomer('alice');
    expect(customer?.fullName, 'Alice Doe');
    expect(await repository.getCustomer('nobody'), isNull);
    expect(await repository.getVet('alice'), isNull);
  });

  test('only approved vets are offered, sorted by name', () async {
    Map<String, dynamic> vet(String first, String status) => {
      'firstName': first,
      'lastName': 'Vet',
      'status': status,
    };
    await db.doc('vets/a').set(vet('Zoe', 'approved'));
    await db.doc('vets/b').set(vet('Adam', 'approved'));
    await db.doc('vets/c').set(vet('Pending', 'pending'));

    final vets = await repository.getApprovedVets();
    expect(vets.map((v) => v.firstName), ['Adam', 'Zoe']);
    expect(vets.first.status, VetStatus.approved);
  });

  test('municipalities are sorted by name', () async {
    await db.doc('municipalities/2').set({
      'name': 'Gent',
      'postalCode': '9000',
    });
    await db.doc('municipalities/1').set({
      'name': 'Antwerpen',
      'postalCode': '2000',
    });
    final municipalities = await repository.getMunicipalities();
    expect(municipalities.map((m) => m.id), ['1', '2']);
  });

  test('pets are listed per owner and per vet', () async {
    await repository.createPet(
      ownerId: 'alice',
      name: 'rex',
      species: 'Dog',
      vetId: 'drVet',
    );
    await repository.createPet(ownerId: 'alice', name: 'Mia', species: 'Cat');
    await repository.createPet(ownerId: 'bob', name: 'Bo', species: 'Fish');

    final pets = await repository.getPetsForOwner('alice');
    expect(pets.map((p) => p.name), ['Mia', 'rex']);
    expect(pets.last.photoUrl, isNull);

    final patients = await repository.getPetsForVet('drVet');
    expect(patients.single.name, 'rex');
  });

  test('updating a pet keeps its owner', () async {
    await repository.createPet(ownerId: 'alice', name: 'Rex', species: 'Dog');
    final pet = (await repository.getPetsForOwner('alice')).single;

    await repository.updatePet(
      Pet(
        id: pet.id,
        ownerId: pet.ownerId,
        name: 'Rexie',
        species: 'Dog',
        vetId: 'drVet',
        birthDate: '2020-05-01',
      ),
    );
    final updated = await repository.getPet(pet.id);
    expect(updated?.name, 'Rexie');
    expect(updated?.ownerId, 'alice');
    expect(updated?.vetId, 'drVet');
  });

  test('medical records are null until saved', () async {
    expect(await repository.getMedicalRecord('rex'), isNull);
    await repository.saveMedicalRecord(
      'rex',
      const MedicalRecord(weight: '5.3', teethStatus: 'good'),
      vetId: 'drVet',
    );
    final record = await repository.getMedicalRecord('rex');
    expect(record?.weight, '5.3');
    expect(record?.teethStatus, 'good');
    expect(
      (await db.doc('medicalRecords/rex').get()).data()?['updatedBy'],
      'drVet',
    );
  });

  group('appointments', () {
    test('booking stores the appointment and its slot under one ID', () async {
      await book();
      final id = 'drVet_${tomorrowIso}_09:00';
      expect((await db.doc('appointments/$id').get()).exists, isTrue);
      expect((await db.doc('bookedSlots/$id').get()).data(), {
        'vetId': 'drVet',
        'date': tomorrowIso,
        'time': '09:00',
      });
      expect(await repository.getBookedTimes('drVet', tomorrowIso), {'09:00'});
    });

    test('a taken slot cannot be booked again', () async {
      await book();
      expect(
        () => book(petId: 'mia', customerId: 'bob'),
        throwsA(isA<SlotTakenException>()),
      );
    });

    test('customers see their upcoming appointments only', () async {
      await book(time: '10:00');
      await book(time: '09:00');
      await book(customerId: 'bob', time: '11:00');
      await db.doc('appointments/past').set({
        'customerId': 'alice',
        'scheduledAt': Timestamp.fromDate(DateTime(2020)),
      });

      final appointments = await repository.getCustomerAppointments('alice');
      expect(appointments.map((a) => a.time), ['09:00', '10:00']);
      expect(appointments.first.vetName, 'Eva Peeters');
    });

    test('vets see one day of appointments', () async {
      await book(time: '09:00');
      await book(customerId: 'bob', time: '14:00');

      final day = await repository.getVetAppointmentsForDay('drVet', tomorrow);
      expect(day.map((a) => a.time), ['09:00', '14:00']);
      final today = await repository.getVetAppointmentsForDay(
        'drVet',
        DateTime.now(),
      );
      expect(today, isEmpty);
    });

    test('cancelling frees the slot', () async {
      await book();
      final appointment = (await repository.getCustomerAppointments('alice'))
          .single;

      await repository.cancelAppointment(appointment);
      expect(await repository.getCustomerAppointments('alice'), isEmpty);
      expect(await repository.getBookedTimes('drVet', tomorrowIso), isEmpty);
      await book(customerId: 'bob'); // free again
    });
  });

  test('appointment types are stored in English', () {
    expect(AppointmentType.fromValue('surgery'), AppointmentType.surgery);
    expect(AppointmentType.labelFor('vaccination'), 'Vaccination');
    expect(AppointmentType.labelFor('unknown'), 'unknown');
  });

  test('PickedUpload content types', () {
    PickedUpload upload(String name) =>
        PickedUpload(name: name, bytes: Uint8List(0));
    expect(upload('cert.PDF').contentType, 'application/pdf');
    expect(upload('photo.jpeg').contentType, 'image/jpeg');
  });

  test('isoDate and isValidEmail', () {
    expect(isoDate(DateTime(2026, 3, 7)), '2026-03-07');
    expect(isValidEmail(' john@doe.com '), isTrue);
    expect(isValidEmail('john@doe'), isFalse);
  });
}
