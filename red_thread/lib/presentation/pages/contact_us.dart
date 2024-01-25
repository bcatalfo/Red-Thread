import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  static const String routeName = '/contact_us';

  @override
  ContactUsPageState createState() => ContactUsPageState();
}

class ContactUsPageState extends State<ContactUsPage> {
  void _makePhoneCall(String phoneNumber) async {
    // TODO: update AndroidManifest.xml to allow phone calls. See https://pub.dev/packages/url_launcher#configuration
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Handle the situation when the phone call cannot be made
      debugPrint('Could not launch $launchUri');
    }
  }

  void _sendEmail(String emailAddress1, String emailAddress2) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path:
          '$emailAddress1,$emailAddress2', // Separate email addresses with a comma
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Handle the situation when the email cannot be sent
      debugPrint('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text("Contact Us", style: theme.textTheme.displayLarge)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Call us anytime", style: theme.textTheme.headlineLarge),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                  onPressed: () {
                    _makePhoneCall('+1631-560-8030');
                  },
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.phone),
                  ),
                  label: Text("Call Us", style: theme.textTheme.bodyLarge)),
              const SizedBox(height: 40),
              Text("Or send us an email", style: theme.textTheme.headlineLarge),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                  onPressed: () {
                    _sendEmail('ben@catalfotechnologies.com',
                        'sam@catalfotechnologies.com');
                  },
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.email),
                  ),
                  label: Text("Email Us", style: theme.textTheme.bodyLarge))
            ],
          ),
        ),
      ),
    );
  }
}
