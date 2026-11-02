import '../strings.dart';
import 'models/profiles.dart';

enum UserRole { customer, vet }

/// The logged-in user's profile, filled in by the login flow.
abstract final class UserSession {
  /// Firebase Auth UID.
  static String? uid;
  static UserRole? role;
  static String? firstName;
  static String? lastName;

  static bool get isCustomer => role == UserRole.customer;
  static bool get isVet => role == UserRole.vet;

  static String get fullName {
    final name = [firstName, lastName]
        .map((part) => part?.trim() ?? '')
        .where((part) => part.isNotEmpty)
        .join(' ');
    return name.isEmpty ? Strings.guest : name;
  }

  static void setCustomer(Customer customer) {
    uid = customer.id;
    role = UserRole.customer;
    firstName = customer.firstName;
    lastName = customer.lastName;
  }

  static void setVet(Vet vet) {
    uid = vet.id;
    role = UserRole.vet;
    firstName = vet.firstName;
    lastName = vet.lastName;
  }

  static void clear() {
    uid = null;
    role = null;
    firstName = null;
    lastName = null;
  }
}
