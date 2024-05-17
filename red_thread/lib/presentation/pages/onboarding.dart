import 'package:introduction_screen/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'package:red_thread/presentation/theme.dart';
import 'package:red_thread/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnBoardingPage extends ConsumerStatefulWidget {
  const OnBoardingPage({Key? key}) : super(key: key);

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends ConsumerState<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    ref.read(needsWelcomingProvider.notifier).state = false;
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    var pageDecoration = PageDecoration(
      titleTextStyle:
          const TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: globalLightScheme.surface,
      imagePadding: const EdgeInsets.only(top: 120),
    );

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: globalLightScheme.surface,
      allowImplicitScrolling: true,
      autoScrollDuration: 3000,
      globalHeader: SafeArea(
        top: true,
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: globalLightScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Red Thread',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: globalLightScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
      globalFooter: SizedBox(
        width: double.infinity,
        height: 80,
        child: ElevatedButton(
          child: const Text(
            'Start Dating Now',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          onPressed: () => _onIntroEnd(context),
        ),
      ),
      pages: [
        PageViewModel(
          title: "Red Thread",
          body:
              "Welcome to Red Thread! The dating app that actually gets you dating.",
          image: _buildImage('IMG_3490.webp'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Queue Up",
          body:
              "The queue is where you'll find your next date. When you're ready, just tap the button and we'll find you a match.",
          image: _buildImage('heart.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "No Profile Needed",
          body:
              "All you need to do is show up. No swiping, no profiles, just dates.",
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Verification",
          body:
              "Before you enter the queue we need you to take a selfie. Other users will see this photo when you're matched.",
          image: _buildImage('IMG_3490.webp'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: ShapeDecoration(
        color: globalLightScheme.surfaceBright,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}
