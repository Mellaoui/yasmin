import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() => runApp(const BMICalculatorApp());

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const BMIScreen(),
    );
  }
}

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  _BMIScreenState createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  bool isMale = true;
  double height = 170; // in cm
  double weight = 70; // in kg

  double _calculateBMI() {
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  void _navigateToResultScreen(BuildContext context) {
    double bmi = _calculateBMI();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BMIResultScreen(bmi: bmi),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.bmi_calculator_title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gender Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _genderToggleButton(localizations.female, Icons.female, false),
                const SizedBox(width: 16),
                _genderToggleButton(localizations.male, Icons.male, true),
              ],
            ),
            const SizedBox(height: 24),
            // Height Slider
            _buildSliderCard(localizations.height_label, height,
                localizations.cm_unit, 100, 220, (newHeight) {
              setState(() {
                height = newHeight;
              });
            }),
            const SizedBox(height: 24),
            // Weight Slider
            _buildSliderCard(localizations.weight_label, weight,
                localizations.kg_unit, 30, 150, (newWeight) {
              setState(() {
                weight = newWeight;
              });
            }),
            const SizedBox(height: 32),
            // Calculate Button
            ElevatedButton(
              onPressed: () => _navigateToResultScreen(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                localizations.calculate_button,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderToggleButton(String label, IconData icon, bool maleValue) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isMale = maleValue;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isMale == maleValue ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Icon(
              icon,
              color: isMale == maleValue ? Colors.white : Colors.grey,
              size: 36,
            ),
            Text(
              label,
              style: TextStyle(
                color: isMale == maleValue ? Colors.white : Colors.grey,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard(String label, double value, String unit, double min,
      double max, Function(double) onChanged) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ${value.toStringAsFixed(1)} $unit',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.grey[300],
            ),
          ],
        ),
      ),
    );
  }
}

class BMIResultScreen extends StatelessWidget {
  final double bmi;

  const BMIResultScreen({super.key, required this.bmi});

  String _getBMICategory(double bmi, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (bmi < 18.5) return localizations.underweight;
    if (bmi >= 18.5 && bmi < 24.9) return localizations.healthy;
    if (bmi >= 25 && bmi < 29.9) return localizations.overweight;
    if (bmi >= 30 && bmi < 34.9) return localizations.obese;
    if (bmi >= 35 && bmi < 39.9) return localizations.highly_obese;
    return localizations.extremely_obese;
  }

  Color _getCategoryColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi >= 18.5 && bmi < 24.9) return Colors.green;
    if (bmi >= 25 && bmi < 29.9) return Colors.orange;
    if (bmi >= 30 && bmi < 34.9) return Colors.red;
    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    String category = _getBMICategory(bmi, context);
    Color categoryColor = _getCategoryColor(bmi);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localizations.your_bmi_result),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // BMI Value Display
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: categoryColor,
                    width: 12,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        bmi.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        localizations.bmi,
                        style: const TextStyle(
                            fontSize: 24, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // BMI Category Display
              Text(
                category,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
              const SizedBox(height: 32),
              // BMI Categories Reference
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.bmi_categories_label,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildBMICategoryRow(
                      '< 18.5', localizations.underweight, Colors.blue),
                  _buildBMICategoryRow(
                      '18.5 - 24.9', localizations.healthy, Colors.green),
                  _buildBMICategoryRow(
                      '25 - 29.9', localizations.overweight, Colors.orange),
                  _buildBMICategoryRow(
                      '30 - 34.9', localizations.obese, Colors.red),
                  _buildBMICategoryRow('35 - 39.9', localizations.highly_obese,
                      Colors.deepOrange),
                  _buildBMICategoryRow(
                      '> 40', localizations.extremely_obese, Colors.deepPurple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMICategoryRow(String range, String category, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            '$range: $category',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
