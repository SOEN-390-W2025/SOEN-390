import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String message;

  const ErrorPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              Text(
                "Whoops! Something went wrong.",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Error: $message",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/HomePage',
                  (Route<dynamic> route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(146, 35, 56, 1),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Go back to Home Page"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
