import "dart:async";
import "package:dropdown_search/dropdown_search.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_database/firebase_database.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:red_thread/providers.dart";

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _currentStep = 0;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final List<Map<String, String>> _countryCodes = [
    {'name': 'US', 'code': '+1'},
    {'name': 'Canada', 'code': '+1'},
    {'name': 'Japan', 'code': '+81'},
    // Add more country codes and names as needed
  ];
  Map<String, String> _selectedCountryCode = {'name': 'US', 'code': '+1'};
  String newVerificationId = '';

  final _formKeys =
      List<GlobalKey<FormState>>.generate(2, (index) => GlobalKey<FormState>());

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
    _phoneNumberController.dispose();
    _smsCodeController.dispose();
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
      } else {}
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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
                        _formKeys.length,
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
      _buildEnterPhoneNumberPage(context),
      _buildEnterSMSCodePage(context),
    ];
  }

  Future<void> _verifySMSCode() async {
    debugPrint(_smsCodeController.text.replaceAll(' ', ''));

    debugPrint(newVerificationId);
    final completer = Completer<void>();
    final credential = PhoneAuthProvider.credential(
      verificationId: newVerificationId,
      smsCode: _smsCodeController.text.replaceAll(' ', ''),
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
      var userRef = FirebaseDatabase.instance
          .ref('users/${FirebaseAuth.instance.currentUser!.uid}');
      var event = await userRef.once();

      if (event.snapshot.value == null) {
        await FirebaseAuth.instance.signOut();
      } else {
        completer.complete();
        // Since a new user is signed in let's invalidate all the providers
        ref.invalidate(myThemeProvider);
        ref.invalidate(surveyDueProvider);
        ref.invalidate(queueProvider);
        // TODO: invalidate date providers
        ref.invalidate(selectedGendersProvider);
        ref.invalidate(ageRangeProvider);
        ref.invalidate(maxDistanceProvider);
        ref.invalidate(showAdProvider);
        ref.invalidate(adInfoProvider);
        ref.invalidate(myNameProvider);
        ref.invalidate(chatIdProvider);
        ref.invalidate(matchNameProvider);
        ref.invalidate(matchAgeProvider);
        ref.invalidate(matchDistanceProvider);
      }
    }).catchError((error) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Verification Failed'),
              content: Text(error.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });
      completer.completeError(error);
    });
    return completer.future;
  }

  Future<void> _phoneVerification() async {
    final completer = Completer<void>();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _selectedCountryCode['code']! + _phoneNumberController.text,
      verificationCompleted: (PhoneAuthCredential credential) {
        completer.complete();

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Verification Completed'),
              content: Text('Phone number automatically verified'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Verification Failed'),
              content: Text(e.message ?? 'An unknown error occurred'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete();
        newVerificationId = verificationId;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Verification Code Sent'),
              content: Text('A verification code has been sent to your phone'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        completer.completeError('Verification timed out');
      },
    );
    return completer.future;
  }

  Widget _buildEnterPhoneNumberPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[0], // Ensure correct key index
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Please enter your phone number",
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownSearch<Map<String, String>>(
                        items: _countryCodes,
                        itemAsString: (Map<String, String> country) =>
                            "${country['name']} ${country['code']}",
                        selectedItem: _selectedCountryCode,
                        dropdownBuilder:
                            (_, Map<String, String>? selectedItem) {
                          return Text(selectedItem != null
                              ? "${selectedItem['name']} ${selectedItem['code']}"
                              : "Select Country Code");
                        },
                        popupProps: PopupProps.modalBottomSheet(
                          showSearchBox: true,
                          searchFieldProps: const TextFieldProps(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Search Country',
                            ),
                          ),
                          fit: FlexFit.tight,
                          itemBuilder: (context, item, isSelected) {
                            return ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['name']!),
                                  Text(item['code']!),
                                ],
                              ),
                            );
                          },
                        ),
                        onChanged: (Map<String, String>? value) {
                          setState(() {
                            _selectedCountryCode = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _phoneNumberController,
                        decoration:
                            const InputDecoration(labelText: "Phone Number"),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                              12), // Maximum 12 characters including hyphens
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final text = newValue.text;
                            final digitsOnly =
                                text.replaceAll(RegExp(r'\D'), '');
                            if (digitsOnly.length > 10) {
                              return oldValue;
                            }
                            final buffer = StringBuffer();
                            for (int i = 0; i < digitsOnly.length; i++) {
                              if (i == 3 || i == 6) buffer.write('-');
                              buffer.write(digitsOnly[i]);
                            }
                            return TextEditingValue(
                              text: buffer.toString(),
                              selection: TextSelection.collapsed(
                                  offset: buffer.length),
                            );
                          }),
                        ],
                        validator: (value) {
                          final digitsOnly =
                              value?.replaceAll(RegExp(r'\D'), '');
                          if (digitsOnly == null || digitsOnly.length != 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(
                              () {}); // Trigger rebuild to update button state
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "To verify your identity, we will send a code via SMS. Message and data rates may apply. Please be aware.",
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child:
                  _buildNavigationButtons(context, onNext: _phoneVerification),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnterSMSCodePage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[1], // Ensure correct key index
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Please enter the SMS code",
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _smsCodeController,
                  decoration: const InputDecoration(
                    labelText: "SMS Code",
                    hintText: "_ _ _ _ _ _",
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        11), // Maximum 11 characters (6 digits + 5 spaces)
                    FilteringTextInputFormatter.digitsOnly,
                    SmsCodeInputFormatter(),
                  ],
                  validator: (value) {
                    final digitsOnly = value?.replaceAll(' ', '');
                    if (digitsOnly == null || digitsOnly.length != 6) {
                      return 'Please enter a valid 6-digit code';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {}); // Trigger rebuild to update button state
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context, onNext: _verifySMSCode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context,
      {Future<void> Function()? onNext}) {
    bool isValid = _formKeys[_currentStep].currentState?.validate() ?? false;

    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: isValid ? () => _nextStep(onNext: onNext) : null,
          style: ElevatedButton.styleFrom(
            minimumSize:
                const Size.fromHeight(50), // Set minimum height for button
            textStyle: const TextStyle(fontSize: 20), // Set font size
          ),
          child: Text(_currentStep < _formKeys.length - 1 ? 'Next' : 'Finish'),
        ),
      ],
    );
  }
}

class SmsCodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text =
        newValue.text.replaceAll(' ', ''); // Remove any existing spaces
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 1 == 0 && i < 6) {
        buffer.write(' '); // Insert space after every digit
      }
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
