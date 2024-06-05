import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';

class SurveyPage extends ConsumerStatefulWidget {
  const SurveyPage({Key? key}) : super(key: key);

  @override
  SurveyPageState createState() => SurveyPageState();
}

class SurveyPageState extends ConsumerState<SurveyPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _currentStep = 0;

  final _formKeys =
      List<GlobalKey<FormState>>.generate(6, (index) => GlobalKey<FormState>());

  // List to store questions and answers
  final List<Map<String, String?>> _surveyResponses = [
    {'question': 'Did you go on the date?', 'answer': null},
    {'question': 'Did the other person show up?', 'answer': null},
    {'question': 'How much did you enjoy the date?', 'answer': null},
    {'question': 'Did you find your date attractive?', 'answer': null},
    {'question': 'Would you like to go on another date?', 'answer': null},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextStep({Future<void> Function()? onNext}) async {
    if (onNext != null) {
      await onNext();
    }
    if (_formKeys[_currentStep].currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Dismiss the keyboard
      if (_currentStep < _formKeys.length - 1) {
        setState(() {
          _currentStep++;
        });
        _animationController.forward(from: 0.0);
        _pageController
            .animateToPage(
              _currentStep,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            )
            .then((value) => setState(() {}));
      } else {
        // Navigate to the final screen
        _showFinalPage();
      }
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus(); // Dismiss the keyboard
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.forward(from: 0.0);
      _pageController
          .animateToPage(
            _currentStep,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          )
          .then((value) => setState(() {}));
    }
  }

  void _showFinalPage() {
    setState(() {
      _currentStep = _formKeys.length - 1;
    });
    _animationController.forward(from: 0.0);
    _pageController
        .animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        )
        .then((value) => setState(() {}));
  }

  // Function to record answers to Firebase Analytics
  Future<void> _recordAnswers() async {
    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    Map<String, String> answers = {};
    for (int i = 0; i < _surveyResponses.length; i++) {
      answers['question${i + 1}'] = _surveyResponses[i]['question']!;
      answers['answer${i + 1}'] =
          _surveyResponses[i]['answer'] ?? 'Not answered';
    }
    await analytics.logEvent(
      name: 'survey_completed',
      parameters: answers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Survey"),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return SizedBox(
                  height:
                      10.0, // Increase the height to make it more noticeable
                  child: LinearProgressIndicator(
                    value: (_currentStep - 1 + _progressAnimation.value) /
                        (_formKeys.length - 1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                    backgroundColor: Colors.grey[300],
                    minHeight: 8, // Ensuring the increased height
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _buildPages(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPages(BuildContext context) {
    return [
      buildSurveyPage(
        context,
        0,
        _surveyResponses[0]['question']!,
        [
          _buildAnswerButton('Yes 😊', () {
            setState(() {
              _surveyResponses[0]['answer'] = 'Yes 😊';
            });
            _nextStep();
          }),
          _buildAnswerButton('No 😢', () {
            setState(() {
              _surveyResponses[0]['answer'] = 'No 😢';
            });
            _showFinalPage();
          }),
        ],
      ),
      buildSurveyPage(
        context,
        1,
        _surveyResponses[1]['question']!,
        [
          _buildAnswerButton('Yes 🙌', () {
            setState(() {
              _surveyResponses[1]['answer'] = 'Yes 🙌';
            });
            _nextStep();
          }),
          _buildAnswerButton('No 😞', () {
            setState(() {
              _surveyResponses[1]['answer'] = 'No 😞';
            });
            _showFinalPage();
          }),
        ],
      ),
      buildSurveyPage(
        context,
        2,
        _surveyResponses[2]['question']!,
        [
          _buildAnswerButton('Loved it! 😍', () {
            setState(() {
              _surveyResponses[2]['answer'] = 'Loved it! 😍';
            });
            _nextStep();
          }),
          _buildAnswerButton('It was okay 🤔', () {
            setState(() {
              _surveyResponses[2]['answer'] = 'It was okay 🤔';
            });
            _nextStep();
          }),
          _buildAnswerButton('Didn\'t enjoy 😒', () {
            setState(() {
              _surveyResponses[2]['answer'] = 'Didn\'t enjoy 😒';
            });
            _nextStep();
          }),
        ],
      ),
      buildSurveyPage(
        context,
        3,
        _surveyResponses[3]['question']!,
        [
          _buildAnswerButton('Yes 😍', () {
            setState(() {
              _surveyResponses[3]['answer'] = 'Yes 😍';
            });
            _nextStep();
          }),
          _buildAnswerButton('No 😕', () {
            setState(() {
              _surveyResponses[3]['answer'] = 'No 😕';
            });
            _nextStep();
          }),
        ],
      ),
      buildSurveyPage(
        context,
        4,
        _surveyResponses[4]['question']!,
        [
          _buildAnswerButton('Yes! 😃', () {
            setState(() {
              _surveyResponses[4]['answer'] = 'Yes! 😃';
            });
            _nextStep();
          }),
          _buildAnswerButton('No 😔', () {
            setState(() {
              _surveyResponses[4]['answer'] = 'No 😔';
            });
            _nextStep();
          }),
        ],
      ),
      buildSurveyPage(
        context,
        5,
        'Thanks for taking our survey!\nYour survey responses help make Red Thread better for everyone.',
        [
          _buildAnswerButton('Finish', () async {
            // Record answers to Firebase Analytics
            await _recordAnswers();
            // Handle survey completion, e.g., navigate to another page, save results, etc.
            ref.read(isDayAfterDateProvider.notifier).state = false;
          }),
        ],
      ),
    ];
  }

  Widget buildSurveyPage(
    BuildContext context,
    int questionNumber,
    String questionText,
    List<Widget> answerButtons,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[questionNumber],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60), // Add more space at the top
            Text(
              questionText,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 2),
            ...answerButtons.expand((button) => [button, Spacer()]),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String text, Function onPressed) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(300, 100), // Big button
        textStyle: const TextStyle(fontSize: 24), // Big text
      ),
      child: Text(text),
    );
  }
}
