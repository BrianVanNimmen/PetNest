import '../strings.dart';

/// The logged-in user, filled in by the login flow.
abstract final class UserSession {
  static int? id;
  static int? vetId;
  static String? firstName;
  static String? lastName;

  /// "klant" (customer) or "arts" (vet).
  static String? type;

  static bool get isCustomer => type == 'klant';
  static bool get isVet => type == 'arts';

  static String get fullName {
    final name = [firstName, lastName]
        .map((part) => part?.trim() ?? '')
        .where((part) => part.isNotEmpty)
        .join(' ');
    return name.isEmpty ? Strings.guest : name;
  }

  static void clear() {
    id = null;
    vetId = null;
    firstName = null;
    lastName = null;
    type = null;
  }
}
