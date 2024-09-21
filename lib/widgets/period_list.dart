import 'package:flutter/material.dart';
import '../models/period_entry.dart';

class PeriodList extends StatelessWidget {
  final List<PeriodEntry> periodEntries;

  const PeriodList({super.key, required this.periodEntries});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: periodEntries.length,
      itemBuilder: (ctx, index) {
        final entry = periodEntries[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(
              '${entry.startDate.toLocal().toShortDateString()} - ${entry.endDate.toLocal().toShortDateString()}',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Symptoms: ${entry.symptoms}'),
                Text('Mood: ${entry.mood}'),
                Text('Pain Level: ${entry.painLevel}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension DateOnlyCompare on DateTime {
  String toShortDateString() {
    return '${this.year}-${this.month}-${this.day}';
  }
}
