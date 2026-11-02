extension TakeString on String {
  /// Kotlin's `String.take(n)`: the first [n] characters.
  String take(int n) => length <= n ? this : substring(0, n);
}

/// yyyy-MM-dd, the date format the API expects.
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String todayIso() => isoDate(DateTime.now());

final _emailPattern = RegExp(
  r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$",
);

bool isValidEmail(String email) => _emailPattern.hasMatch(email.trim());
