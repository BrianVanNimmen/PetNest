import 'package:flutter_test/flutter_test.dart';
import 'package:petnest/model/appointment_type.dart';
import 'package:petnest/network/account.dart';
import 'package:petnest/network/appointment.dart';
import 'package:petnest/network/json.dart';
import 'package:petnest/network/medical_record.dart';
import 'package:petnest/network/petnest_api.dart';
import 'package:petnest/util/text.dart';

void main() {
  group('decodeLenient', () {
    test('skips a PHP notice before the JSON', () {
      const body = '<br />\n<b>Notice</b>: Undefined index\n{"status":200}';
      expect(decodeLenient(body), {'status': 200});
    });

    test('returns null for an empty body', () {
      expect(decodeLenient('  \n'), isNull);
    });

    test('throws for a non-JSON body', () {
      expect(() => decodeLenient('Fatal error'), throwsFormatException);
    });
  });

  test('asInt accepts numeric strings like Gson did', () {
    expect(asInt('5'), 5);
    expect(asInt(7), 7);
    expect(asInt('fail'), isNull);
  });

  test('ApiResponse treats a non-numeric status as absent', () {
    final response = ApiResponse.fromBody(200, {
      'status': 'fail',
      'error': 'no rows affected',
    });
    expect(response.status, isNull);
    expect(response.message, 'no rows affected');
  });

  test('LoginResponse parses a vet login', () {
    final login = LoginResponse.fromJson({
      'type': 'arts',
      'dierenarts_id': 3,
      'data': {'id': '3', 'voornaam': 'Eva', 'achternaam': 'Peeters'},
    });
    expect(login.type, 'arts');
    expect(login.vetId, 3);
    expect(login.data?.id, 3);
    expect(login.data?.firstName, 'Eva');
  });

  test('AppointmentApiItem falls back to "naam" for the pet name', () {
    final item = AppointmentApiItem.fromJson({
      'id': 1,
      'naam': 'Rex',
      'type': 'controle',
      'geplande_datumtijd': '2026-05-26 09:00:00',
    });
    expect(item.petName, 'Rex');
    expect(item.scheduledDateTime.split(' ')[1].take(5), '09:00');
  });

  test('MedicalRecord parses the nested pet', () {
    final record = MedicalRecord.fromJson({
      'id': 1,
      'dier_id': 4,
      'gewicht': 5.3,
      'pet': {'id': 4, 'naam': 'Mia', 'foto_url': 'uploads/mia.jpg'},
    });
    expect(record.weight, '5.3');
    expect(record.pet?.name, 'Mia');
  });

  test('imageUrl resolves relative upload paths', () {
    expect(
      PetNestApi.imageUrl('uploads/a.jpg'),
      '${PetNestApi.baseUrl}uploads/a.jpg',
    );
    expect(PetNestApi.imageUrl('https://x/y.png'), 'https://x/y.png');
    expect(PetNestApi.imageUrl(''), isNull);
  });

  test('appointment types keep their Dutch API values', () {
    expect(AppointmentType.fromApi('Operatie'), AppointmentType.surgery);
    expect(AppointmentType.labelFor('vaccinatie'), 'Vaccination');
    expect(AppointmentType.labelFor('something'), 'something');
    expect(AppointmentType.checkup.apiValue, 'controle');
  });

  test('isoDate and isValidEmail', () {
    expect(isoDate(DateTime(2026, 3, 7)), '2026-03-07');
    expect(isValidEmail(' john@doe.com '), isTrue);
    expect(isValidEmail('john@doe'), isFalse);
  });
}
