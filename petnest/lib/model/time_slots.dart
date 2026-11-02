class TimeSlot {
  const TimeSlot(this.start, this.end);

  final String start;
  final String end;

  @override
  String toString() => '$start - $end';
}

const timeSlots = [
  TimeSlot('08:00', '09:00'),
  TimeSlot('09:00', '10:00'),
  TimeSlot('10:00', '11:00'),
  TimeSlot('11:00', '12:00'),
  TimeSlot('13:00', '14:00'),
  TimeSlot('14:00', '15:00'),
  TimeSlot('15:00', '16:00'),
  TimeSlot('16:00', '17:00'),
  TimeSlot('17:00', '18:00'),
];
