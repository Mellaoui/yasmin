import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SymptomTracker extends StatefulWidget {
  final Function(List<String>) onSave; // Change Set<String> to List<String>

  const SymptomTracker({super.key, required this.onSave});

  @override
  _SymptomTrackerState createState() => _SymptomTrackerState();
}

class _SymptomTrackerState extends State<SymptomTracker> {
  final Set<String> _selectedSymptoms = {}; // Track selected symptoms as a Set

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)?.trackSymptoms ?? 'Track Symptoms',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Mood Category
            _buildCategoryTitle(AppLocalizations.of(context)?.mood ?? 'Mood'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEmojiButton(
                    '😃', AppLocalizations.of(context)?.happy ?? 'Happy'),
                _buildEmojiButton(
                    '😟', AppLocalizations.of(context)?.sad ?? 'Sad'),
                _buildEmojiButton(
                    '😖', AppLocalizations.of(context)?.cramp ?? 'Cramp'),
                _buildEmojiButton(
                    '😴', AppLocalizations.of(context)?.tired ?? 'Tired'),
              ],
            ),
            const SizedBox(height: 20),

            // Bleeding Category
            _buildCategoryTitle(
                AppLocalizations.of(context)?.bleeding ?? 'Bleeding'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEmojiButton(
                    '🩸',
                    AppLocalizations.of(context)?.lightBleeding ??
                        'Light Bleeding'),
                _buildEmojiButton(
                    '🩸🩸',
                    AppLocalizations.of(context)?.heavyBleeding ??
                        'Heavy Bleeding'),
              ],
            ),
            const SizedBox(height: 20),

            // Symptoms Category
            _buildCategoryTitle(
                AppLocalizations.of(context)?.symptoms ?? 'Symptoms'),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                _buildEmojiButton(
                    '🤢', AppLocalizations.of(context)?.nausea ?? 'Nausea'),
                _buildEmojiButton(
                    '🤕', AppLocalizations.of(context)?.headache ?? 'Headache'),
                _buildEmojiButton(
                    '😣', AppLocalizations.of(context)?.bloating ?? 'Bloating'),
                _buildEmojiButton(
                    '🍫', AppLocalizations.of(context)?.cravings ?? 'Cravings'),
                _buildEmojiButton(
                    '🤕',
                    AppLocalizations.of(context)?.breastsHurting ??
                        'Breasts Hurting'),
                _buildEmojiButton(
                    '🤕',
                    AppLocalizations.of(context)?.lowerBackPain ??
                        'Lower Back Pain'),
              ],
            ),
            const SizedBox(height: 20),

            // Sex Category
            _buildCategoryTitle(AppLocalizations.of(context)?.sex ?? 'Sex'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEmojiButton(
                    '🔒',
                    AppLocalizations.of(context)?.protectedSex ??
                        'Protected Sex'),
                _buildEmojiButton(
                    '🔓',
                    AppLocalizations.of(context)?.unprotectedSex ??
                        'Unprotected Sex'),
              ],
            ),
            const SizedBox(height: 20),

            // Pregnancy Test Category
            _buildCategoryTitle(AppLocalizations.of(context)?.pregnancyTest ??
                'Pregnancy Test'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEmojiButton(
                    '✅',
                    AppLocalizations.of(context)?.positiveTest ??
                        'Positive Test'),
                _buildEmojiButton(
                    '❌',
                    AppLocalizations.of(context)?.negativeTest ??
                        'Negative Test'),
              ],
            ),
            const SizedBox(height: 20),

            // Save button
            ElevatedButton(
              onPressed: () {
                // Convert Set to List before passing to onSave
                widget.onSave(_selectedSymptoms.toList());
                Navigator.pop(context); // Close modal
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4081),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)?.save ?? 'Save',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build category title
  Widget _buildCategoryTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  // Helper method to build emoji button for symptom tracking
  Widget _buildEmojiButton(String emoji, String label) {
    final bool isSelected = _selectedSymptoms.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSymptoms.remove(label);
          } else {
            _selectedSymptoms.add(label);
          }
        });
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.pink.shade100 : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.pink : Colors.grey.shade400,
                width: 2.0,
              ),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.pink : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
