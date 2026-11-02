import 'dart:convert';

import 'package:http/http.dart' as http;

import 'account.dart';
import 'appointment.dart';
import 'json.dart';
import 'medical_record.dart';
import 'patient.dart';
import 'pet.dart';

/// Thrown when the server answers with a non-2xx status where the caller
/// needs to know about it.
class HttpStatusException implements Exception {
  const HttpStatusException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'HTTP $statusCode';
}

typedef _JsonResponse = ({int status, dynamic body});

/// Client for the PetNest PHP API.
///
/// Override the base URL with `--dart-define=API_BASE_URL=http://host:port/`;
/// the default points at the host machine from the Android emulator.
class PetNestApi {
  PetNestApi._();

  static final instance = PetNestApi._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/',
  );

  /// Photo paths from the API are relative ("uploads/x.jpg").
  static String? imageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return raw.startsWith('http') ? raw : baseUrl + raw;
  }

  final _client = http.Client();

  Uri _uri(String path, [Map<String, Object>? query]) =>
      Uri.parse(baseUrl + path)
          .replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));

  Future<_JsonResponse> _read(Future<http.BaseResponse> request) async {
    final response = await request;
    final body = response is http.Response
        ? response.body
        : await (response as http.StreamedResponse).stream.bytesToString();
    return (status: response.statusCode, body: decodeLenient(body));
  }

  Future<_JsonResponse> _get(String path, [Map<String, Object>? query]) =>
      _read(_client.get(_uri(path, query)));

  Future<_JsonResponse> _sendJson(String method, String path, Object body) {
    final request = http.Request(method, _uri(path))
      ..headers['Content-Type'] = 'application/json; charset=utf-8'
      ..body = jsonEncode(body);
    return _read(_client.send(request));
  }

  Future<_JsonResponse> _sendMultipart(
    String path,
    Map<String, String> fields,
    String fileField,
    PickedUpload? file,
  ) {
    final request = http.MultipartRequest('POST', _uri(path))
      ..fields.addAll(fields);
    if (file != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          file.bytes,
          filename: file.name,
        ),
      );
    }
    return _read(_client.send(request));
  }

  // ── Accounts ───────────────────────────────────────────────────────────────

  Future<LoginResponse> login(String firebaseUid) async {
    final res = await _get('login.php', {'firebase_uid': firebaseUid});
    return LoginResponse.fromJson(asMap(res.body) ?? const {});
  }

  Future<List<Municipality>> getMunicipalities() async {
    final res = await _get('gemeentes.php');
    if (res.status < 200 || res.status >= 300) {
      throw HttpStatusException(res.status);
    }
    return asMapList(asMap(res.body)?['data'])
        .map(Municipality.fromJson)
        .toList();
  }

  Future<ApiResponse> registerCustomer(CustomerRegisterRequest request) async {
    final res = await _sendJson('POST', 'klanten.php', request.toJson());
    return ApiResponse.fromBody(res.status, res.body);
  }

  Future<ApiResponse> registerVet({
    required String firstName,
    required String lastName,
    required String email,
    required String firebaseUid,
    required String phone,
    required String practiceName,
    required int municipalityId,
    required PickedUpload certificate,
  }) async {
    final res = await _sendMultipart(
      'artsen.php',
      {
        'voornaam': firstName,
        'achternaam': lastName,
        'email': email,
        'firebase_uid': firebaseUid,
        'telefoon': phone,
        'praktijknaam': practiceName,
        'gemeente_id': '$municipalityId',
      },
      'certificaat',
      certificate,
    );
    return ApiResponse.fromBody(res.status, res.body);
  }

  Future<List<Vet>> getVets() async {
    final res = await _get('artsen.php');
    return asMapList(asMap(res.body)?['data']).map(Vet.fromJson).toList();
  }

  // ── Appointments ───────────────────────────────────────────────────────────

  Future<List<AppointmentApiItem>> getVetAppointments({
    required int vetId,
    required String from,
    required String to,
    required int limit,
  }) async {
    final res = await _get('afspraken.php', {
      'action': 'get',
      'dierenarts_id': vetId,
      'from': from,
      'to': to,
      'limit': limit,
    });
    if (res.status < 200 || res.status >= 300) {
      throw HttpStatusException(res.status);
    }
    return _appointments(res.body);
  }

  Future<List<AppointmentApiItem>> getCustomerAppointments({
    required int customerId,
    required int limit,
  }) async {
    final res = await _get('afspraken.php', {
      'action': 'get',
      'klant_id': customerId,
      'limit': limit,
    });
    if (res.status < 200 || res.status >= 300) {
      throw HttpStatusException(res.status);
    }
    return _appointments(res.body);
  }

  List<AppointmentApiItem> _appointments(dynamic body) =>
      asMapList(asMap(body)?['data']).map(AppointmentApiItem.fromJson).toList();

  Future<ApiResponse> createAppointment(
    AppointmentCreateRequest request,
  ) async {
    final res = await _sendJson('POST', 'afspraken.php', request.toJson());
    return ApiResponse.fromBody(res.status, res.body);
  }

  Future<ApiResponse> deleteAppointment(int id) async {
    final res = await _sendJson('DELETE', 'afspraken.php', {'id': id});
    return ApiResponse.fromBody(res.status, res.body);
  }

  // ── Pets / patients ────────────────────────────────────────────────────────

  Future<List<Pet>> getPets(int customerId) async {
    final res = await _get('dieren.php', {'klant_id': customerId});
    if (res.status < 200 || res.status >= 300 || res.body == null) {
      throw HttpStatusException(res.status);
    }
    return asMapList(asMap(res.body)?['data']).map(Pet.fromJson).toList();
  }

  Future<List<Patient>> getPatientsForVet(int vetId) async {
    final res = await _get('dieren.php', {'dierenarts_id': vetId});
    return asMapList(asMap(res.body)?['data']).map(Patient.fromJson).toList();
  }

  Future<ApiResponse> createPet({
    required String name,
    required String species,
    required String birthDate,
    required int customerId,
    required int vetId,
    PickedUpload? photo,
  }) async {
    final res = await _sendMultipart(
      'dieren.php',
      {
        'naam': name,
        'soort': species,
        'geboortedatum': birthDate,
        'klant_id': '$customerId',
        'dierenarts_id': '$vetId',
      },
      'foto',
      photo,
    );
    return ApiResponse.fromBody(res.status, res.body);
  }

  Future<ApiResponse> updatePet(PetUpdateRequest request) async {
    final res = await _sendJson('PUT', 'dieren.php', request.toJson());
    return ApiResponse.fromBody(res.status, res.body);
  }

  // ── Medical record ─────────────────────────────────────────────────────────

  /// Returns null when the pet has no record yet (the API then sends
  /// `"data": []`).
  Future<MedicalRecord?> getMedicalRecord(int petId) async {
    final res = await _get('dossier.php', {'dier_id': petId});
    final data = asMap(asMap(res.body)?['data']);
    return data == null ? null : MedicalRecord.fromJson(data);
  }

  Future<ApiResponse> saveMedicalRecord(
    MedicalRecordUpdateRequest request,
  ) async {
    final res = await _sendJson('PUT', 'dossier.php', request.toJson());
    return ApiResponse.fromBody(res.status, res.body);
  }
}
