import '../strings.dart';

/// Appointment types. [apiValue] matches the `bezoeken.type` enum in the
/// database and is what gets sent to / received from the API.
enum AppointmentType {
  checkup('controle', Strings.appointmentTypeCheckup),
  vaccination('vaccinatie', Strings.appointmentTypeVaccination),
  surgery('operatie', Strings.appointmentTypeSurgery),
  other('overig', Strings.appointmentTypeOther);

  const AppointmentType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  /// Types a customer can book.
  static const bookable = [checkup, vaccination, surgery];

  static AppointmentType? fromApi(String value) {
    final lower = value.toLowerCase();
    for (final type in values) {
      if (type.apiValue == lower) return type;
    }
    return null;
  }

  /// Display label for a raw API value; falls back to the raw value.
  static String labelFor(String apiValue) =>
      fromApi(apiValue)?.label ?? apiValue;
}
