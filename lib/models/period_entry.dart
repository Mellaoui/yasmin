class PeriodEntry {
  final DateTime startDate;
  final DateTime endDate;
  final String symptoms;
  final String mood;
  final int painLevel;

  PeriodEntry({
    required this.startDate,
    required this.endDate,
    required this.symptoms,
    required this.mood,
    required this.painLevel,
  });
}
