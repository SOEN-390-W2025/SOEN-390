import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common_app_bart.dart';

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
    return Scaffold(
      appBar: const CommonAppBar(title: "Contact"),
      body: Semantics(
        label: 'Displays useful contact information.',
        child: ListView(
          padding: const EdgeInsets.all(18.0),
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 20,
                        color: Colors.black,
                      ),
                      SizedBox(width: 6),
                      Text("Central Phone Line",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text("514-848-2424", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text(
                    "Monday to Friday, 9 a.m. - 5 p.m.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "🚨 Emergency (24/7)",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "514-848-3717",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[400]),
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
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _launchURL,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.local_activity,
                          size: 20,
                          color: Colors.black,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Open a ticket",
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 20,
                        color: Colors.black,
                      ),
                      SizedBox(width: 6),
                      Text("514-848-2424, ext. 7613",
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(
                        Icons.mail,
                        size: 20,
                        color: Colors.black,
                      ),
                      SizedBox(width: 6),
                      Text("help@concordia.ca", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[400]),
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
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 20),
                      Text(
                        "Sir George Williams Campus",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("1455 De Maisonneuve Blvd. W."),
                  const SizedBox(height: 4),
                  const Text("Montreal, QC H3G 1M8, CANADA"),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.location_on, size: 20),
                      Text(
                        "Loyola Campus",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("7141 Sherbrooke Street W."),
                  const SizedBox(height: 4),
                  const Text("Montreal, QC H4B 1R6, CANADA"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
