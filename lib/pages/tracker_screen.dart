import 'package:flutter/material.dart';
import '../models/period_entry.dart';
import '../widgets/period_form.dart';
import '../widgets/period_list.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class TrackerScreen extends StatefulWidget {
  @override
  _TrackerScreenState createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final List<PeriodEntry> _periodEntries = [];

  void _addPeriodEntry(DateTime startDate, DateTime endDate, String symptoms,
      String mood, int painLevel) {
    setState(() {
      _periodEntries.add(
        PeriodEntry(
          startDate: startDate,
          endDate: endDate,
          symptoms: symptoms,
          mood: mood,
          painLevel: painLevel,
        ),
      );
    });
  }

  void _showAddPeriodForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: PeriodForm(onSubmit: _addPeriodEntry),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tracker')),
      body: Column(
        children: [
          Expanded(
            child: PeriodList(periodEntries: _periodEntries),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        children: [
          SpeedDialChild(
            child: Icon(Icons.calendar_today),
            label: 'Log Period',
            backgroundColor: Colors.red,
            onTap: () => _showAddPeriodForm(context),
          ),
          SpeedDialChild(
            child: Icon(Icons.note_add),
            label: 'Add Note',
            backgroundColor: Colors.green,
            onTap: () {
              // Implement Add Note functionality
            },
          ),
        ],
      ),
    );
  }
}
