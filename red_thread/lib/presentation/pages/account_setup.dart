import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';

class AccountSetupPage extends ConsumerStatefulWidget {
  const AccountSetupPage({Key? key}) : super(key: key);

  @override
  AccountSetupPageState createState() => AccountSetupPageState();
}

class AccountSetupPageState extends ConsumerState<AccountSetupPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _currentStep = 0;
  Gender? _selectedGender;
  String? _lookingForGender;
  double _maxDistance = 50;
  RangeValues _ageRange = const RangeValues(18, 30);
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  bool _agreedToTerms = false;

  final _formKeys = List<GlobalKey<FormState>>.generate(
      10, (index) => GlobalKey<FormState>());

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
    _birthdayController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Dismiss the keyboard
      if (_currentStep < _formKeys.length - 1) {
        setState(() {
          _currentStep++;
        });
        _animationController.forward(from: 0.0);
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        ref.read(isAccountSetupCompleteProvider.notifier).state = true;
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
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Setup"),
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
      _buildTermsPage(context),
      _buildDisplayNamePage(context),
      _buildBirthdayPage(context),
      _buildGenderPage(context),
      _buildLookingForPage(context),
      _buildDistancePage(context),
      _buildAgeRangePage(context),
      _buildLocationPage(context),
      _buildNotificationsPage(context),
      _buildContactsPage(context),
    ];
  }

  Widget _buildTermsPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[0],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Community Guidelines:",
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  "- Your safety is our utmost priority.",
                  style: textTheme.bodyLarge,
                ),
                Text(
                  "- We are committed to protecting your privacy at all times.",
                  style: textTheme.bodyLarge,
                ),
                Text(
                  "- Respect and kindness are essential in our community.",
                  style: textTheme.bodyLarge,
                ),
                Text(
                  "- Please report any violations of our guidelines.",
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                FormField<bool>(
                  initialValue: _agreedToTerms,
                  validator: (value) {
                    if (value != true) {
                      return 'You must agree to the terms and conditions';
                    }
                    return null;
                  },
                  builder: (formFieldState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: Text(
                            "I agree to the terms and conditions",
                            style: textTheme.bodyLarge,
                          ),
                          value: formFieldState.value,
                          onChanged: (bool? value) {
                            formFieldState.didChange(value);
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (formFieldState.hasError)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              formFieldState.errorText ?? '',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayNamePage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[1],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Enter your name", style: textTheme.headlineMedium),
                Text("This is how others will see you on Red Thread.",
                    style: textTheme.bodyLarge),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _displayNameController,
                  decoration:
                      const InputDecoration(labelText: "Enter your name here"),
                  style: textTheme.headlineSmall,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.singleLineFormatter,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;
                      final textLength = text.length;
                      if (textLength == 0) return newValue.copyWith(text: text);
                      return newValue.copyWith(
                        text: text[0].toUpperCase() + text.substring(1),
                        selection: TextSelection.fromPosition(
                          TextPosition(offset: newValue.selection.baseOffset),
                        ),
                      );
                    }),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your display name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdayPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[2],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Enter your birthday", style: textTheme.headlineMedium),
                Text(
                  "You must be 18 years or older to use Red Thread. Your age will be shared with your matches.",
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _birthdayController,
                  decoration: const InputDecoration(
                    hintText: 'MM / DD / YYYY',
                    labelText: "Birthday",
                  ),
                  style: textTheme.headlineSmall,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;
                      StringBuffer newText = StringBuffer();
                      if (text.length >= 1) {
                        newText.write(text.substring(0, 1));
                      }
                      if (text.length >= 2) {
                        newText.write(text.substring(1, 2));
                      }
                      if (text.length >= 3) {
                        newText.write('/');
                        newText.write(text.substring(2, 3));
                      }
                      if (text.length >= 4) {
                        newText.write(text.substring(3, 4));
                      }
                      if (text.length >= 5) {
                        newText.write('/');
                        newText.write(text.substring(4, 5));
                      }
                      if (text.length >= 6) {
                        newText.write(text.substring(5, 6));
                      }
                      if (text.length >= 7) {
                        newText.write(text.substring(6, 7));
                      }
                      if (text.length >= 8) {
                        newText.write(text.substring(7, 8));
                      }
                      return newValue.copyWith(
                        text: newText.toString(),
                        selection:
                            TextSelection.collapsed(offset: newText.length),
                      );
                    }),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your birthday';
                    }
                    final parts = value.split('/');
                    if (parts.length != 3)
                      return 'Enter date in MM / DD / YYYY format';
                    final month = int.tryParse(parts[0]);
                    final day = int.tryParse(parts[1]);
                    final year = int.tryParse(parts[2]);
                    if (month == null || day == null || year == null)
                      return 'Invalid date';
                    if (month < 1 || month > 12)
                      return 'Month must be between 01 and 12';
                    if (day < 1 || day > 31)
                      return 'Day must be between 01 and 31';
                    if (year.toString().length != 4)
                      return 'Year must be four digits';
                    final birthday = DateTime(year, month, day);
                    final now = DateTime.now();
                    final age = now.year -
                        birthday.year -
                        (now.month < birthday.month ||
                                (now.month == birthday.month &&
                                    now.day < birthday.day)
                            ? 1
                            : 0);
                    if (age < 18) return 'You must be 18 years or older';
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
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[3],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Enter your gender", style: textTheme.headlineMedium),
                const SizedBox(height: 20),
                RadioListTile<Gender>(
                  title: Text('Male', style: textTheme.headlineSmall),
                  value: Gender.male,
                  groupValue: _selectedGender,
                  onChanged: (Gender? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                RadioListTile<Gender>(
                  title: Text('Female', style: textTheme.headlineSmall),
                  value: Gender.female,
                  groupValue: _selectedGender,
                  onChanged: (Gender? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                RadioListTile<Gender>(
                  title: Text('Other', style: textTheme.headlineSmall),
                  value: Gender.other,
                  groupValue: _selectedGender,
                  onChanged: (Gender? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLookingForPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[4],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Enter the gender you want to match with",
                    style: textTheme.headlineMedium),
                const SizedBox(height: 20),
                RadioListTile<String>(
                  title: Text('Male', style: textTheme.headlineSmall),
                  value: "Male",
                  groupValue: _lookingForGender,
                  onChanged: (String? value) {
                    setState(() {
                      _lookingForGender = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('Female', style: textTheme.headlineSmall),
                  value: "Female",
                  groupValue: _lookingForGender,
                  onChanged: (String? value) {
                    setState(() {
                      _lookingForGender = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text('Both', style: textTheme.headlineSmall),
                  value: "Both",
                  groupValue: _lookingForGender,
                  onChanged: (String? value) {
                    setState(() {
                      _lookingForGender = value;
                    });
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistancePage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[5],
        autovalidateMode: AutovalidateMode.disabled,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Set max distance for match",
                    style: textTheme.headlineMedium),
                Text("This is how far your matches can be from you.",
                    style: textTheme.bodyLarge),
                const SizedBox(height: 20),
                Text("Current distance: ${_maxDistance.round()} miles",
                    style: textTheme.headlineSmall),
                const SizedBox(height: 20),
                Slider(
                  value: _maxDistance,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: "${_maxDistance.round()} miles",
                  onChanged: (double value) {
                    setState(() {
                      _maxDistance = value;
                    });
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeRangePage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[6],
        autovalidateMode: AutovalidateMode.disabled,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Set age range for match",
                    style: textTheme.headlineMedium),
                Text("You will only match with people in this age range",
                    style: textTheme.bodyLarge),
                const SizedBox(height: 20),
                Text(
                    "Current age range: ${_ageRange.start.round()} - ${_ageRange.end.round()}",
                    style: textTheme.headlineSmall),
                const SizedBox(height: 20),
                RangeSlider(
                  values: _ageRange,
                  min: 18,
                  max: 100,
                  divisions: 82,
                  labels: RangeLabels(
                    "${_ageRange.start.round()}",
                    "${_ageRange.end.round()}",
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _ageRange = values;
                    });
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[7],
        autovalidateMode: AutovalidateMode.always,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Share your location information",
                    style: textTheme.headlineMedium),
                const SizedBox(height: 20),
                Text('This will help us find matches near you.',
                    style: textTheme.bodyLarge),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
            Align(
              alignment: FractionalOffset(0.5, 0.333),
              child: Icon(
                Icons.location_on,
                size: 128,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[8],
        autovalidateMode: AutovalidateMode.disabled,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Turn push notifications on",
                    style: textTheme.headlineMedium),
                const SizedBox(height: 20),
                Text("Get notified when you have a new match.",
                    style: textTheme.bodyLarge),
              ],
            ),
            Positioned(
              bottom: 64,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
            Align(
              alignment: FractionalOffset(0.5, 0.333),
              child: Icon(
                Icons.notifications,
                size: 128,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[9],
        autovalidateMode: AutovalidateMode.disabled,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Invite your contacts to Red Thread",
                    style: textTheme.headlineMedium),
                const SizedBox(height: 20),
                Text("Invite your friends to join Red Thread.",
                    style: textTheme.bodyLarge),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
            Align(
              alignment: FractionalOffset(0.5, 0.333),
              child: Icon(
                Icons.contact_mail,
                size: 128,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    bool isValid = _formKeys[_currentStep].currentState?.validate() ?? false;

    if (_currentStep >= 5) {
      isValid = true;
    }

    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: isValid ? _nextStep : null,
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
