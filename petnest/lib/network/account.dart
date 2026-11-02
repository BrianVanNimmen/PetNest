import 'json.dart';

class Municipality {
  const Municipality({required this.id, required this.name});

  factory Municipality.fromJson(Map<String, dynamic> json) => Municipality(
    id: asInt(json['id']) ?? 0,
    name: asString(json['naam']) ?? '',
  );

  final int id;
  final String name;
}

class Vet {
  const Vet({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory Vet.fromJson(Map<String, dynamic> json) => Vet(
    id: asInt(json['id']) ?? 0,
    firstName: asString(json['voornaam']) ?? '',
    lastName: asString(json['achternaam']) ?? '',
  );

  final int id;
  final String firstName;
  final String lastName;

  String get fullName => '$firstName $lastName';
}

class CustomerRegisterRequest {
  const CustomerRegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.firebaseUid,
    required this.birthDate,
    required this.municipalityId,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String firebaseUid;
  final String? birthDate;
  final int? municipalityId;

  Map<String, dynamic> toJson() => {
    'voornaam': firstName,
    'achternaam': lastName,
    'email': email,
    'firebase_uid': firebaseUid,
    'geboortedatum': birthDate,
    'gemeente_id': municipalityId,
  };
}

class LoginUserData {
  const LoginUserData({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.firebaseUid,
    this.status,
  });

  factory LoginUserData.fromJson(Map<String, dynamic> json) => LoginUserData(
    id: asInt(json['id']),
    firstName: asString(json['voornaam']),
    lastName: asString(json['achternaam']),
    email: asString(json['email']),
    firebaseUid: asString(json['firebase_uid']),
    status: asString(json['status']),
  );

  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? firebaseUid;
  final String? status;
}

class LoginResponse {
  const LoginResponse({
    this.type,
    this.customerId,
    this.firstName,
    this.lastName,
    this.vetId,
    this.data,
    this.error,
    this.status,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = asMap(json['data']);
    return LoginResponse(
      type: asString(json['type']),
      customerId: asInt(json['klant_id']),
      firstName: asString(json['voornaam']),
      lastName: asString(json['achternaam']),
      vetId: asInt(json['dierenarts_id']),
      data: data == null ? null : LoginUserData.fromJson(data),
      error: asString(json['error']),
      status: asString(json['status']),
    );
  }

  /// "klant" (customer) or "arts" (vet), as returned by login.php.
  final String? type;
  final int? customerId;
  final String? firstName;
  final String? lastName;
  final int? vetId;
  final LoginUserData? data;
  final String? error;
  final String? status;
}

/// Generic `{status, message}` API response.
class ApiResponse {
  const ApiResponse({
    required this.httpStatus,
    this.status,
    this.message,
    this.id,
  });

  factory ApiResponse.fromBody(int httpStatus, dynamic body) {
    final json = asMap(body) ?? const <String, dynamic>{};
    return ApiResponse(
      httpStatus: httpStatus,
      status: asInt(json['status']),
      message: asString(json['message']) ?? asString(json['error']),
      id: asInt(json['id']),
    );
  }

  final int httpStatus;

  /// The "status" field in the body. Null when absent or not numeric
  /// (the API sometimes sends "fail").
  final int? status;
  final String? message;
  final int? id;

  bool get isSuccessful => httpStatus >= 200 && httpStatus < 300;
}
