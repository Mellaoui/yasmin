import 'package:flutter/material.dart';

class PeriodForm extends StatefulWidget {
  final Function(DateTime, DateTime, String, String, int) onSubmit;

  PeriodForm({required this.onSubmit});

  @override
  _PeriodFormState createState() => _PeriodFormState();
}

class _PeriodFormState extends State<PeriodForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  final _symptomsController = TextEditingController();
  final List<String> _moodOptions = [
    '😀 Happy',
    '😢 Sad',
    '😠 Angry',
    '😴 Tired',
    '😕 Confused',
    '😌 Relaxed'
  ];
  String? _selectedMood;
  int _painLevel = 1;

  void _submitForm() {
    if (_formKey.currentState!.validate() &&
        _startDate != null &&
        _endDate != null &&
        _selectedMood != null) {
      widget.onSubmit(
        _startDate!,
        _endDate!,
        _symptomsController.text,
        _selectedMood!,
        _painLevel,
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      hintText: _startDate != null
                          ? _startDate.toString()
                          : 'Select start date',
                    ),
                    validator: (value) {
                      if (_startDate == null) {
                        return 'Please select a start date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      hintText: _endDate != null
                          ? _endDate.toString()
                          : 'Select end date',
                    ),
                    validator: (value) {
                      if (_endDate == null) {
                        return 'Please select an end date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              TextFormField(
                controller: _symptomsController,
                decoration: InputDecoration(labelText: 'Symptoms'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter symptoms';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedMood,
                decoration: InputDecoration(labelText: 'Mood'),
                items: _moodOptions.map((String mood) {
                  return DropdownMenuItem<String>(
                    value: mood,
                    child: Text(mood),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMood = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a mood';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _painLevel,
                decoration: InputDecoration(labelText: 'Pain Level'),
                items: List.generate(10, (index) => index + 1)
                    .map((level) => DropdownMenuItem<int>(
                          value: level,
                          child: Text(level.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _painLevel = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Log Period'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
