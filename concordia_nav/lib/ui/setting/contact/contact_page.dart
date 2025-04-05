import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/custom_appbar.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  Future<void> _launchURL() async {
    const url = 'https://www.concordia.ca/it/support.html#ticket';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final secondaryTextColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    final dividerColor = Theme.of(context).dividerColor;

    // Use a consistent emergency color that won't blend with the background
    const emergencyColor = Colors.red;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: customAppBar(context, "Contact"),
      body: Semantics(
        label: 'Displays useful contact information.',
        child: ListView(
          padding: const EdgeInsets.all(18.0),
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 20,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text("Central Phone Line",
                          style: TextStyle(fontSize: 16, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("514-848-2424",
                      style: TextStyle(fontSize: 16, color: textColor)),
                  const SizedBox(height: 4),
                  Text(
                    "Monday to Friday, 9 a.m. - 5 p.m.",
                    style: TextStyle(
                        fontSize: 14, color: secondaryTextColor.withAlpha(120)),
                  ),
                  const SizedBox(height: 4),
                  // Emergency info with background for visibility
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: emergencyColor.withAlpha(50),
                      border: Border.all(color: emergencyColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "🚨 Emergency (24/7)",
                          style: TextStyle(fontSize: 16, color: emergencyColor),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "514-848-3717",
                          style: TextStyle(fontSize: 16, color: emergencyColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: dividerColor),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "IT Support",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _launchURL,
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_activity,
                          size: 20,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Open a ticket",
                          style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 20,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text("514-848-2424, ext. 7613",
                          style: TextStyle(fontSize: 16, color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.mail,
                        size: 20,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text("help@concordia.ca",
                          style: TextStyle(fontSize: 16, color: textColor)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: dividerColor),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Campus Addresses",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 20, color: primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        "Sir George Williams Campus",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("1455 De Maisonneuve Blvd. W.",
                      style: TextStyle(color: textColor)),
                  const SizedBox(height: 4),
                  Text("Montreal, QC H3G 1M8, CANADA",
                      style: TextStyle(color: textColor)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 20, color: primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        "Loyola Campus",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("7141 Sherbrooke Street W.",
                      style: TextStyle(color: textColor)),
                  const SizedBox(height: 4),
                  Text("Montreal, QC H4B 1R6, CANADA",
                      style: TextStyle(color: textColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
