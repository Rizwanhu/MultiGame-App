import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: isDarkMode ? Colors.grey[850] : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "1. We respect your privacy and do not collect any personal data without your consent.\n\n"
              "2. This app may collect usage statistics for the purpose of improving the experience.\n\n"
              "3. Any information you voluntarily provide (e.g. through sign-up or feedback) will be stored securely.\n\n"
              "4. We do not share your data with any third-party services without permission.\n\n"
              "5. You may request to have your data deleted at any time.\n\n"
              "6. For any concerns, contact us at: privacy@example.com",
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey[300] : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
