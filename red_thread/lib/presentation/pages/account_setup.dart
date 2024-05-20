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
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
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

  bool _isCurrentStepValid() {
    switch (_currentStep) {
      case 0:
        return _agreedToTerms;
      case 1:
        return _displayNameController.text.isNotEmpty;
      case 2:
        return _birthdayController.text.isNotEmpty;
      case 3:
        return _selectedGender != null;
      case 4:
        return _lookingForGender != null;
      default:
        return true;
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[0],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome to Red Thread!",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                const Text(
                    "Welcome to Red Thread! [Insert cool slogan here - This is a blind dating app focused on really going on dates]."),
                const SizedBox(height: 20),
                const Text("Community Guidelines:",
                    style: TextStyle(fontSize: 18)),
                const Text("- Safety is our number one priority.",
                    style: TextStyle(fontSize: 16)),
                const Text("- We emphasize safety and privacy.",
                    style: TextStyle(fontSize: 16)),
                const Text(
                    "- Our AI will find you your perfect match. It's fate!",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                CheckboxListTile(
                  title: const Text("I agree to the terms and conditions",
                      style: TextStyle(fontSize: 16)),
                  value: _agreedToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreedToTerms = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
            Positioned(
              bottom: 128,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[1],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Enter your display name",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(labelText: "Display Name"),
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
              bottom: 128,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[2],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Enter your birthday",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _birthdayController,
                  readOnly: true,
                  onTap: () async {
                    DateTime initialDate =
                        DateTime.now().subtract(const Duration(days: 365 * 20));
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _birthdayController.text =
                            "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}";
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'MM/DD/YYYY',
                    labelText: "Birthday",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your birthday';
                    }
                    return null;
                  },
                ),
              ],
            ),
            Positioned(
              bottom: 128,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[3],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Enter your gender",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                RadioListTile<Gender>(
                  title: const Text('Male', style: TextStyle(fontSize: 16)),
                  value: Gender.male,
                  groupValue: _selectedGender,
                  onChanged: (Gender? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                RadioListTile<Gender>(
                  title: const Text('Female', style: TextStyle(fontSize: 16)),
                  value: Gender.female,
                  groupValue: _selectedGender,
                  onChanged: (Gender? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                RadioListTile<Gender>(
                  title: const Text('Other', style: TextStyle(fontSize: 16)),
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
              bottom: 128,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[4],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Enter the gender of the person you're looking for",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                RadioListTile<String>(
                  title: const Text('Male', style: TextStyle(fontSize: 16)),
                  value: "Male",
                  groupValue: _lookingForGender,
                  onChanged: (String? value) {
                    setState(() {
                      _lookingForGender = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Female', style: TextStyle(fontSize: 16)),
                  value: "Female",
                  groupValue: _lookingForGender,
                  onChanged: (String? value) {
                    setState(() {
                      _lookingForGender = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Both', style: TextStyle(fontSize: 16)),
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
              bottom: 128,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[5],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Set max distance for match",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                Text("Current distance: ${_maxDistance.round()} miles",
                    style: const TextStyle(fontSize: 16)),
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
              bottom: 128,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[6],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Set age range for match",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                Text(
                    "Current age range: ${_ageRange.start.round()} - ${_ageRange.end.round()}",
                    style: const TextStyle(fontSize: 16)),
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
              bottom: 128,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[7],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Share your location information",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Logic to request location permissions
                    },
                    child: const Text("Share Location"),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 128,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[8],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Turn push notifications on",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Logic to request push notifications permissions
                    },
                    child: const Text("Enable Notifications"),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 128,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeys[9],
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Invite your contacts to Red Thread",
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Logic to request contacts permissions
                    },
                    child: const Text("Invite Contacts"),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 128,
              left: 0,
              right: 0,
              child: _buildNavigationButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: _isCurrentStepValid() ? _nextStep : null,
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
