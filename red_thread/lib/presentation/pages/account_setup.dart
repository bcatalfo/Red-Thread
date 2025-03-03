import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

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
  final Set<Gender> _selectedGenders = {};
  double latitude = 0.0;
  double longitude = 0.0;
  double _maxDistance = 50;
  RangeValues _ageRange = const RangeValues(18, 30);
  String newVerificationId = '';
  List<Contact> contacts = [];
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final List<Map<String, String>> _countryCodes = [
    {'name': 'US', 'code': '+1'},
    {'name': 'Canada', 'code': '+1'},
    {'name': 'Japan', 'code': '+81'},
    // Add more country codes and names as needed
  ];
  Map<String, String> _selectedCountryCode = {'name': 'US', 'code': '+1'};

  bool _agreedToTerms = false;

  final _formKeys = List<GlobalKey<FormState>>.generate(
      12, (index) => GlobalKey<FormState>());

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
    _phoneNumberController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  Future<void> _nextStep({Future<bool> Function()? onNext}) async {
    if (onNext != null) {
      var success = await onNext();
      if (!success) return;
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
        FirebaseDatabase database = FirebaseDatabase.instance;
        DatabaseReference dbref = database.ref();
        final fcmToken = await FirebaseMessaging.instance.getToken();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          var userRef = FirebaseDatabase.instance
              .ref('users/${FirebaseAuth.instance.currentUser!.uid}');
          var event = await userRef.once();

          if (event.snapshot.value == null) {
            final random = Random();
            final number = 1 +
                random.nextInt(4); // Generates a random number between 1 and 4
            if (number == 1) {
              dbref.child('users').child(user.uid).set({
                //TODO: Add the new providers!
                'displayName': _displayNameController.text,
                'birthday': _birthdayController.text,
                'phoneNumber':
                    _selectedCountryCode['code']! + _phoneNumberController.text,
                'ageRange': {
                  'start': _ageRange.start.round(),
                  'end': _ageRange.end.round(),
                },
                'maxDistance': _maxDistance.round(),
                'gender': _selectedGender.toString(),
                'lookingFor': _selectedGenders
                    .map((gender) => gender.toString())
                    .toList(),
                'location': {
                  'latitude': latitude,
                  'longitude': longitude,
                },
                'fcmToken': fcmToken,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'contacts': contacts.map((contact) {
                  return {
                    'name': contact.displayName,
                    'phoneNumbers':
                        contact.phones.map((phone) => phone.number).toList(),
                  };
                }).toList(),
                'adInfo': {
                  'showAd': false,
                  'price': 4.99,
                  'isLifetime': false,
                },
              });
            }
            if (number == 2) {
              dbref.child('users').child(user.uid).set({
                'displayName': _displayNameController.text,
                'birthday': _birthdayController.text,
                'phoneNumber':
                    _selectedCountryCode['code']! + _phoneNumberController.text,
                'ageRange': {
                  'start': _ageRange.start.round(),
                  'end': _ageRange.end.round(),
                },
                'maxDistance': _maxDistance.round(),
                'gender': _selectedGender.toString(),
                'lookingFor': _selectedGenders
                    .map((gender) => gender.toString())
                    .toList(),
                'location': {
                  'latitude': latitude,
                  'longitude': longitude,
                },
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'fcmToken': fcmToken,
                'contacts': contacts.map((contact) {
                  return {
                    'name': contact.displayName,
                    'phoneNumbers':
                        contact.phones.map((phone) => phone.number).toList(),
                  };
                }).toList(),
                'adInfo': {
                  'showAd': false,
                  'price': 9.99,
                  'isLifetime': false,
                },
              });
            }
            if (number == 3) {
              dbref.child('users').child(user.uid).set({
                'displayName': _displayNameController.text,
                'birthday': _birthdayController.text,
                'phoneNumber':
                    _selectedCountryCode['code']! + _phoneNumberController.text,
                'ageRange': {
                  'start': _ageRange.start.round(),
                  'end': _ageRange.end.round(),
                },
                'maxDistance': _maxDistance.round(),
                'gender': _selectedGender.toString(),
                'lookingFor': _selectedGenders
                    .map((gender) => gender.toString())
                    .toList(),
                'location': {
                  'latitude': latitude,
                  'longitude': longitude,
                },
                'fcmToken': fcmToken,
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'contacts': contacts.map((contact) {
                  return {
                    'name': contact.displayName,
                    'phoneNumbers':
                        contact.phones.map((phone) => phone.number).toList(),
                  };
                }).toList(),
                'adInfo': {
                  'showAd': false,
                  'price': 19.99,
                  'isLifetime': false,
                },
              });
            }
            if (number == 4) {
              dbref.child('users').child(user.uid).set({
                'displayName': _displayNameController.text,
                'birthday': _birthdayController.text,
                'phoneNumber':
                    _selectedCountryCode['code']! + _phoneNumberController.text,
                'ageRange': {
                  'start': _ageRange.start.round(),
                  'end': _ageRange.end.round(),
                },
                'maxDistance': _maxDistance.round(),
                'gender': _selectedGender.toString(),
                'lookingFor': _selectedGenders
                    .map((gender) => gender.toString())
                    .toList(),
                'location': {
                  'latitude': latitude,
                  'longitude': longitude,
                },
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'fcmToken': fcmToken,
                'contacts': contacts.map((contact) {
                  return {
                    'name': contact.displayName,
                    'phoneNumbers':
                        contact.phones.map((phone) => phone.number).toList(),
                  };
                }).toList(),
                'adInfo': {
                  'showAd': false,
                  'price': 99.99,
                  'isLifetime': true,
                },
              });
            }
          }
        }
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
      _buildEnterPhoneNumberPage(context),
      _buildEnterSMSCodePage(context),
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
                      return 'Please enter your name';
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
                      if (text.isNotEmpty) {
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
                    if (parts.length != 3) {
                      return 'Enter date in MM / DD / YYYY format';
                    }
                    final month = int.tryParse(parts[0]);
                    final day = int.tryParse(parts[1]);
                    final year = int.tryParse(parts[2]);
                    if (month == null || day == null || year == null) {
                      return 'Invalid date';
                    }
                    if (month < 1 || month > 12) {
                      return 'Month must be between 01 and 12';
                    }
                    if (day < 1 || day > 31) {
                      return 'Day must be between 01 and 31';
                    }
                    if (year.toString().length != 4) {
                      return 'Year must be four digits';
                    }
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
                FormField<Gender>(
                  validator: (value) {
                    if (_selectedGender == null) {
                      return "Please select a gender";
                    }
                    return null;
                  },
                  builder: (formFieldState) {
                    return Column(
                      children: [
                        RadioListTile<Gender>(
                          title: Text('Male', style: textTheme.headlineSmall),
                          value: Gender.male,
                          groupValue: _selectedGender,
                          onChanged: (Gender? value) {
                            setState(() {
                              _selectedGender = value;
                              formFieldState.didChange(value);
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
                              formFieldState.didChange(value);
                            });
                          },
                        ),
                        RadioListTile<Gender>(
                          title: Text('Non-binary',
                              style: textTheme.headlineSmall),
                          value: Gender.nonBinary,
                          groupValue: _selectedGender,
                          onChanged: (Gender? value) {
                            setState(() {
                              _selectedGender = value;
                              formFieldState.didChange(value);
                            });
                          },
                        ),
                        if (formFieldState.hasError)
                          Text(
                            formFieldState.errorText!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
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
                Text("Select the gender(s) you're interested in",
                    style: textTheme.headlineMedium),
                const SizedBox(height: 20),
                FormField<Set<Gender>>(
                  validator: (value) {
                    if (_selectedGenders.isEmpty) {
                      return "Please select at least one gender";
                    }
                    return null;
                  },
                  builder: (formFieldState) {
                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text('Male', style: textTheme.headlineSmall),
                          value: _selectedGenders.contains(Gender.male),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedGenders.add(Gender.male);
                              } else {
                                _selectedGenders.remove(Gender.male);
                              }
                              formFieldState.didChange(_selectedGenders);
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Female', style: textTheme.headlineSmall),
                          value: _selectedGenders.contains(Gender.female),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedGenders.add(Gender.female);
                              } else {
                                _selectedGenders.remove(Gender.female);
                              }
                              formFieldState.didChange(_selectedGenders);
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Non-binary',
                              style: textTheme.headlineSmall),
                          value: _selectedGenders.contains(Gender.nonBinary),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedGenders.add(Gender.nonBinary);
                              } else {
                                _selectedGenders.remove(Gender.nonBinary);
                              }
                              formFieldState.didChange(_selectedGenders);
                            });
                          },
                        ),
                        if (formFieldState.hasError)
                          Text(
                            formFieldState.errorText!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
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
                  inactiveColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.24),
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
              child: _buildNavigationButtons(context, onNext: _getLocation),
            ),
            Align(
              alignment: const FractionalOffset(0.5, 0.333),
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
              child: _buildNavigationButtons(context,
                  onNext: _askForNotifications),
            ),
            Align(
              alignment: const FractionalOffset(0.5, 0.333),
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
                Text(
                  "Don't match with people you know",
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  "By sharing your contacts with us, we can make sure that you don't match with people you already know.",
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context, onNext: _getContacts),
            ),
            Align(
              alignment: const FractionalOffset(0.5, 0.333),
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

  Widget _buildEnterPhoneNumberPage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[10],
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
        key: _formKeys[11],
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

  Future<bool> _phoneVerification() async {
    final completer = Completer<bool>();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _selectedCountryCode['code']! + _phoneNumberController.text,
      verificationCompleted: (PhoneAuthCredential credential) {
        completer.complete(true);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Verification Completed'),
              content: const Text('Phone number automatically verified'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.complete(false);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Verification Failed'),
              content: Text(e.message ?? 'An unknown error occurred'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(true);
        newVerificationId = verificationId;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Verification Code Sent'),
              content:
                  const Text('A verification code has been sent to your phone'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
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

  Future<bool> _getContacts() async {
    //TODO: upload contacts to firebase

    final completer = Completer<bool>();
    if (await FlutterContacts.requestPermission()) {
      // Get all contacts (lightly fetched)
      //List<Contact> contacts = await FlutterContacts.getContacts();

      // Get all contacts (fully fetched)
      contacts = await FlutterContacts.getContacts(
          withProperties: true, withPhoto: false);
      completer.complete(true);
    } else {
      completer.complete(true);
    }

    return completer.future;
  }

  Widget _buildNavigationButtons(BuildContext context,
      {Future<bool> Function()? onNext}) {
    bool isValid = _formKeys[_currentStep].currentState?.validate() ?? false;

    if (_currentStep == 5 ||
        _currentStep == 6 ||
        _currentStep == 7 ||
        _currentStep == 8 ||
        _currentStep == 9) {
      // Always be valid for distance, age range, location, notifications, and contacts
      isValid = true;
    }

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

  Future<bool> _verifySMSCode() async {
    debugPrint(_smsCodeController.text.replaceAll(' ', ''));

    debugPrint(newVerificationId);
    final completer = Completer<bool>();
    final credential = PhoneAuthProvider.credential(
      verificationId: newVerificationId,
      smsCode: _smsCodeController.text.replaceAll(' ', ''),
    );
    FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      completer.complete(true);
    }).catchError((error) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Verification Failed'),
              content: Text(error.toString()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
      completer.complete(false);
    });
    return completer.future;
  }

  Future<bool> _getLocation() async {
    final completer = Completer<bool>();
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled.
      completer.complete(false);
      return completer.future;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied.
        completer.complete(false);
        return completer.future;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      completer.complete(false);
      return completer.future;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      latitude = position.latitude;
      longitude = position.longitude;
      completer.complete(true);
    } catch (e) {
      // Handle error, e.g., user denied permissions
      completer.complete(false);
    }

    return completer.future;
  }
}

Future<bool> _askForNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final completer = Completer<bool>();

  try {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      completer
          .complete(true); // Notify the Completer that the operation is done
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      completer
          .complete(true); // Notify the Completer that the operation is done
      debugPrint('User granted provisional permission');
    } else {
      completer.complete(true); // Notify the Completer with an error
    }
  } catch (e) {
    completer.completeError(e); // Notify the Completer with an error
  }

  return completer.future;
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
