import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:red_thread/providers.dart';

class AccountSetupPage extends ConsumerStatefulWidget {
  const AccountSetupPage({Key? key}) : super(key: key);

  @override
  AccountSetupPageState createState() => AccountSetupPageState();
}

class AccountSetupPageState extends ConsumerState<AccountSetupPage> {
  int _currentStep = 0;
  Gender? _selectedGender;
  Gender? _lookingForGender;
  double _maxDistance = 50;
  RangeValues _ageRange = const RangeValues(18, 30);
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  bool _agreedToTerms = false;

  final _formKeys = List<GlobalKey<FormState>>.generate(
      10, (index) => GlobalKey<FormState>());
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Setup"),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    if (_currentStep > 0) _currentStep--;
                    _scrollToCurrentStep();
                  });
                },
              )
            : null,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          physics: const ClampingScrollPhysics(),
          onStepContinue: _validateAndProceed,
          onStepCancel: _currentStep > 0
              ? () {
                  setState(() {
                    _currentStep--;
                    _scrollToCurrentStep();
                  });
                }
              : null,
          steps: _buildSteps(context),
          controlsBuilder: (BuildContext context, ControlsDetails controls) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed:
                        _isCurrentStepValid() ? controls.onStepContinue : null,
                    child: Text(
                      _currentStep < _formKeys.length - 1 ? 'Next' : 'Finish',
                    ),
                  ),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: controls.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _validateAndProceed() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      setState(() {
        if (_currentStep < _formKeys.length - 1) {
          _currentStep++;
          _scrollToCurrentStep();
        } else {
          ref.read(isAccountSetupCompleteProvider.notifier).state = true;
        }
      });
    }
  }

  void _scrollToCurrentStep() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final position = _scrollController.position.maxScrollExtent *
            (_currentStep / (_formKeys.length - 1));
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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

  List<Step> _buildSteps(BuildContext context) {
    return [
      Step(
        title: const Text("Terms"),
        content: Form(
          key: _formKeys[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome to Red Thread!",
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              const Text(
                  "Welcome to Red Thread! [Insert cool slogan here - This is a blind dating app focused on really going on dates]."),
              const SizedBox(height: 10),
              const Text("Community Guidelines:"),
              const Text("- Safety is our number one priority."),
              const Text("- We emphasize safety and privacy."),
              const Text(
                  "- Our AI will find you your perfect match. It's fate!"),
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text("I agree to the terms and conditions"),
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
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Name"),
        content: Form(
          key: _formKeys[1],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter your display name",
                  style: Theme.of(context).textTheme.titleLarge),
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
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Birthday"),
        content: Form(
          key: _formKeys[2],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter your birthday",
                  style: Theme.of(context).textTheme.titleLarge),
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
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Gender"),
        content: Form(
          key: _formKeys[3],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter your gender",
                  style: Theme.of(context).textTheme.titleLarge),
              RadioListTile<Gender>(
                title: const Text('Male'),
                value: Gender.male,
                groupValue: _selectedGender,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              RadioListTile<Gender>(
                title: const Text('Female'),
                value: Gender.female,
                groupValue: _selectedGender,
                onChanged: (Gender? value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              RadioListTile<Gender>(
                title: const Text('Other'),
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
        ),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Looking For"),
        content: Form(
          key: _formKeys[4],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter the gender of the person you're looking for",
                  style: Theme.of(context).textTheme.titleLarge),
              RadioListTile<Gender>(
                title: const Text('Man'),
                value: Gender.male,
                groupValue: _lookingForGender,
                onChanged: (Gender? value) {
                  setState(() {
                    _lookingForGender = value;
                  });
                },
              ),
              RadioListTile<Gender>(
                title: const Text('Woman'),
                value: Gender.female,
                groupValue: _lookingForGender,
                onChanged: (Gender? value) {
                  setState(() {
                    _lookingForGender = value;
                  });
                },
              ),
              RadioListTile<Gender>(
                title: const Text('Either'),
                value: Gender.other,
                groupValue: _lookingForGender,
                onChanged: (Gender? value) {
                  setState(() {
                    _lookingForGender = value;
                  });
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Distance"),
        content: Form(
          key: _formKeys[5],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Set max distance for match",
                  style: Theme.of(context).textTheme.titleLarge),
              Text("Current distance: ${_maxDistance.round()} miles"),
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
        ),
        isActive: _currentStep >= 5,
        state: _currentStep > 5 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Age Range"),
        content: Form(
          key: _formKeys[6],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Set age range for match",
                  style: Theme.of(context).textTheme.titleLarge),
              Text(
                  "Current age range: ${_ageRange.start.round()} - ${_ageRange.end.round()}"),
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
        ),
        isActive: _currentStep >= 6,
        state: _currentStep > 6 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Location"),
        content: Form(
          key: _formKeys[7],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Share your location information",
                  style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton(
                onPressed: () {
                  // Logic to request location permissions
                },
                child: const Text("Share Location"),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 7,
        state: _currentStep > 7 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Notifications"),
        content: Form(
          key: _formKeys[8],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Turn push notifications on",
                  style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton(
                onPressed: () {
                  // Logic to request push notifications permissions
                },
                child: const Text("Enable Notifications"),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 8,
        state: _currentStep > 8 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text("Contacts"),
        content: Form(
          key: _formKeys[9],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Invite your contacts to Red Thread",
                  style: Theme.of(context).textTheme.titleLarge),
              ElevatedButton(
                onPressed: () {
                  // Logic to request contacts permissions
                },
                child: const Text("Invite Contacts"),
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 9,
        state: _currentStep > 9 ? StepState.complete : StepState.indexed,
      ),
    ];
  }
}
