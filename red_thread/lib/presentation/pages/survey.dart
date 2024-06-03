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
        'Did you go on the date?',
        [
          _buildAnswerButton('Yes 😊', _nextStep),
          _buildAnswerButton('No 😢', _showFinalPage),
        ],
      ),
      buildSurveyPage(
        context,
        1,
        'Did the other person show up?',
        [
          _buildAnswerButton('Yes 🙌', _nextStep),
          _buildAnswerButton('No 😞', _showFinalPage),
        ],
      ),
      buildSurveyPage(
        context,
        2,
        'How much did you enjoy the date?',
        [
          _buildAnswerButton('Loved it! 😍', _nextStep),
          _buildAnswerButton('It was okay 🤔', _nextStep),
          _buildAnswerButton('Didn\'t enjoy 😒', _nextStep),
        ],
      ),
      buildSurveyPage(
        context,
        3,
        'Did you find your date attractive?',
        [
          _buildAnswerButton('Yes 😍', _nextStep),
          _buildAnswerButton('No 😕', _nextStep),
        ],
      ),
      buildSurveyPage(
        context,
        4,
        'Would you like to go on another date?',
        [
          _buildAnswerButton('Yes! 😃', _nextStep),
          _buildAnswerButton('No 😔', _nextStep),
        ],
      ),
      buildSurveyPage(
        context,
        5,
        'Thanks for taking our survey!\nYour survey responses help make Red Thread better for everyone.',
        [
          _buildAnswerButton('Finish', () {
            // TODO: Handle survey completion, e.g., navigate to another page, save results, etc.
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
