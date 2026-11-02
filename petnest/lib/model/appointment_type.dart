import '../strings.dart';

/// Appointment types. [value] is what is stored in Firestore.
enum AppointmentType {
  checkup('checkup', Strings.appointmentTypeCheckup),
  vaccination('vaccination', Strings.appointmentTypeVaccination),
  surgery('surgery', Strings.appointmentTypeSurgery),
  other('other', Strings.appointmentTypeOther);

  const AppointmentType(this.value, this.label);

  final String value;
  final String label;

  /// Types a customer can book.
  static const bookable = [checkup, vaccination, surgery];

  static AppointmentType? fromValue(String value) {
    final lower = value.toLowerCase();
    for (final type in values) {
      if (type.value == lower) return type;
    }
    return null;
  }

  /// Display label for a stored value; falls back to the value itself.
  static String labelFor(String value) => fromValue(value)?.label ?? value;
}
