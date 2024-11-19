import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  int score = 0;
  int timeLeft = 60;
  int currentLevel = 1;
  int streak = 0;
  Timer? gameTimer;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final Random _random = Random();

  final List<Map<String, String>> questionKeys = [
    {'question_anxiety': 'remedy_relaxation'},
    {'question_fatigue': 'remedy_snacks'},
    {'question_irritability': 'remedy_exercise'},
    {'question_sadness': 'remedy_socializing'},
    {'question_cramps': 'remedy_heatTherapy'},
    {'question_headache': 'remedy_hydration'},
    {'question_loneliness': 'remedy_connectWithFriends'},
    {'question_stress': 'remedy_meditation'},
    {'question_moodSwings': 'remedy_healthySnacks'},
    {'question_tiredness': 'remedy_mindfulBreathing'},
    {'question_confusion': 'remedy_comfortActivity'},
    {'question_fear': 'remedy_sleepHygiene'},
    {'question_insomnia': 'remedy_mindfulBreathing'},
    {'question_lethargy': 'remedy_movement'},
    {'question_overwhelm': 'remedy_planning'},
    {'question_distraction': 'remedy_focusExercise'},
    {'question_boredom': 'remedy_newActivity'},
    {'question_anger': 'remedy_breathingExercises'},
    {'question_frustration': 'remedy_journaling'},
    {'question_impatience': 'remedy_mindfulness'},
    {'question_restlessness': 'remedy_physicalActivity'},
  ];

  late Map<String, String> emotionToRemedy;
  late Map<String, bool> matched;
  String? wrongMatch;
  late List<String> shuffledRemedies;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    startNewLevel();
  }

  void startNewLevel() {
    setState(() {
      timeLeft = max(20, 60 - (currentLevel - 1) * 5);
      score = 0;
      streak = 0;
      wrongMatch = null;

      emotionToRemedy = Map.fromEntries(
        List.generate(currentLevel + 2, (index) {
          int randomIndex = _random.nextInt(questionKeys.length);
          return questionKeys[randomIndex].entries.first;
        }),
      );

      matched = emotionToRemedy.map((key, value) => MapEntry(key, false));

      // Shuffle the remedies once per level
      shuffledRemedies = emotionToRemedy.values.toList()..shuffle(_random);
    });
    startTimer();
  }

  void startTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          gameTimer?.cancel();
          showGameOverDialog(context, score, AppLocalizations.of(context)!);
        }
      });
    });
  }

  void showGameOverDialog(
      BuildContext context, int score, AppLocalizations localization) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final AnimationController dialogController = AnimationController(
          duration: const Duration(milliseconds: 700),
          vsync: Navigator.of(context),
        );
        final Animation<double> bounceAnimation = CurvedAnimation(
          parent: dialogController,
          curve: Curves.elasticOut,
        );
        dialogController.forward();

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: bounceAnimation,
                  child: const Icon(
                    Icons.sentiment_very_dissatisfied,
                    color: Colors.purple,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localization.gameOver,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${localization.score}: $score',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    dialogController.dispose();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    localization.quit,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void handleMatch(String emotion) {
    setState(() {
      matched[emotion] = true;
      score += (10 + streak * 2);
      streak++;
      _controller.forward(from: 0);

      if (matched.values.every((isMatched) => isMatched)) {
        gameTimer?.cancel();
        showLevelCompleteDialog(
            context, currentLevel, AppLocalizations.of(context)!, nextLevel);
      }
    });
  }

  void showLevelCompleteDialog(BuildContext context, int level,
      AppLocalizations localization, VoidCallback onNextLevel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final AnimationController dialogController = AnimationController(
          duration: const Duration(milliseconds: 700),
          vsync: Navigator.of(context),
        );
        final Animation<double> bounceAnimation = CurvedAnimation(
          parent: dialogController,
          curve: Curves.elasticOut,
        );
        dialogController.forward();

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: bounceAnimation,
                  child: const Icon(
                    Icons.celebration,
                    color: Colors.greenAccent,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localization.congratulations,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localization.completedLevel(level.toString()),
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    dialogController.dispose();
                    Navigator.of(context).pop();
                    onNextLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: Text(
                    localization.nextLevel,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void nextLevel() {
    setState(() {
      currentLevel++;
      startNewLevel();
    });
  }

  String getLocalizedQuestion(String key, AppLocalizations localization) {
    return {
          'question_anxiety': localization.question_anxiety,
          'question_fatigue': localization.question_fatigue,
          'question_irritability': localization.question_irritability,
          'question_sadness': localization.question_sadness,
          'question_cramps': localization.question_cramps,
          'question_headache': localization.question_headache,
          'question_loneliness': localization.question_loneliness,
          'question_stress': localization.question_stress,
          'question_moodSwings': localization.question_moodSwings,
          'question_tiredness': localization.question_tiredness,
          'question_confusion': localization.question_confusion,
          'question_fear': localization.question_fear,
          'question_insomnia': localization.question_insomnia,
          'question_lethargy': localization.question_lethargy,
          'question_overwhelm': localization.question_overwhelm,
          'question_distraction': localization.question_distraction,
          'question_boredom': localization.question_boredom,
          'question_anger': localization.question_anger,
          'question_frustration': localization.question_frustration,
          'question_impatience': localization.question_impatience,
          'question_restlessness': localization.question_restlessness,
        }[key] ??
        '';
  }

  String getLocalizedRemedy(String key, AppLocalizations localization) {
    return {
          'remedy_relaxation': localization.remedy_relaxation,
          'remedy_snacks': localization.remedy_snacks,
          'remedy_exercise': localization.remedy_exercise,
          'remedy_socializing': localization.remedy_socializing,
          'remedy_heatTherapy': localization.remedy_heatTherapy,
          'remedy_hydration': localization.remedy_hydration,
          'remedy_connectWithFriends': localization.remedy_connectWithFriends,
          'remedy_meditation': localization.remedy_meditation,
          'remedy_healthySnacks': localization.remedy_healthySnacks,
          'remedy_mindfulBreathing': localization.remedy_mindfulBreathing,
          'remedy_comfortActivity': localization.remedy_comfortActivity,
          'remedy_sleepHygiene': localization.remedy_sleepHygiene,
          'remedy_movement': localization.remedy_movement,
          'remedy_planning': localization.remedy_planning,
          'remedy_focusExercise': localization.remedy_focusExercise,
          'remedy_newActivity': localization.remedy_newActivity,
          'remedy_breathingExercises': localization.remedy_breathingExercises,
          'remedy_journaling': localization.remedy_journaling,
          'remedy_mindfulness': localization.remedy_mindfulness,
          'remedy_physicalActivity': localization.remedy_physicalActivity,
        }[key] ??
        '';
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${localization.gameTitle} - ${localization.score}: $score',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${localization.score}: $score',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple),
                  ),
                  Text(
                    '${localization.timeLeft}: $timeLeft',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Column for Questions (Emotions)
                  Expanded(
                    child: ListView(
                      children: emotionToRemedy.keys.map((emotionKey) {
                        final emotion =
                            getLocalizedQuestion(emotionKey, localization);
                        return Draggable<String>(
                          data: emotionKey,
                          feedback: EmotionWidget(emotion: emotion),
                          childWhenDragging: Container(),
                          child: matched[emotionKey]!
                              ? Container()
                              : EmotionWidget(emotion: emotion),
                        );
                      }).toList(),
                    ),
                  ),
                  // Column for Remedies
                  Expanded(
                    child: ListView(
                      children: shuffledRemedies.map((remedyKey) {
                        final remedy =
                            getLocalizedRemedy(remedyKey, localization);
                        return DragTarget<String>(
                          onAccept: (emotion) {
                            if (emotionToRemedy[emotion] == remedyKey) {
                              handleMatch(emotion);
                            } else {
                              setState(() => wrongMatch = emotion);
                              HapticFeedback.lightImpact();
                              Future.delayed(const Duration(seconds: 1), () {
                                setState(() => wrongMatch = null);
                              });
                            }
                          },
                          builder: (BuildContext context,
                              List<String?> candidateData,
                              List<dynamic> rejectedData) {
                            return RemedyWidget(
                              remedy: remedy,
                              isHighlighted: candidateData.isNotEmpty,
                              isWrong: wrongMatch != null &&
                                  emotionToRemedy[wrongMatch!] == remedyKey,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            ScaleTransition(
              scale: _scaleAnimation,
              child: matched.values.any((v) => v)
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.check_circle,
                          size: 64, color: Colors.greenAccent),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}

// EmotionWidget for draggable emotions
class EmotionWidget extends StatelessWidget {
  final String emotion;

  const EmotionWidget({Key? key, required this.emotion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 100,
        height: 100,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            emotion,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// RemedyWidget for drop targets
class RemedyWidget extends StatelessWidget {
  final String remedy;
  final bool isHighlighted;
  final bool isWrong;

  const RemedyWidget({
    Key? key,
    required this.remedy,
    required this.isHighlighted,
    this.isWrong = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(
            color: isWrong
                ? Colors.redAccent
                : (isHighlighted ? Colors.greenAccent : Colors.grey),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            remedy,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
