import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image or illustration
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue[50],
              ),
              child: Center(
                child: Icon(
                  Icons.security,
                  size: 80,
                  color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with decorative element
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.blue[300] : Colors.blue[700],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Privacy Policy",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Introduction text
                  Text(
                    "We value your privacy and are committed to protecting your personal information. This policy explains how we collect, use, and safeguard your data.",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Privacy policy points with icons
                  _buildPolicyPoint(
                    context,
                    Icons.check_circle_outline,
                    "Data Collection",
                    "We respect your privacy and do not collect any personal data without your explicit consent.",
                    isDarkMode,
                  ),
                  
                  _buildPolicyPoint(
                    context,
                    Icons.analytics_outlined,
                    "Usage Statistics",
                    "This app may collect anonymous usage statistics for the purpose of improving your experience.",
                    isDarkMode,
                  ),
                  
                  _buildPolicyPoint(
                    context,
                    Icons.security,
                    "Data Storage",
                    "Any information you voluntarily provide (e.g. through sign-up or feedback) will be stored securely.",
                    isDarkMode,
                  ),
                  
                  _buildPolicyPoint(
                    context,
                    Icons.share_outlined,
                    "Third Parties",
                    "We do not share your data with any third-party services without your permission.",
                    isDarkMode,
                  ),
                  
                  _buildPolicyPoint(
                    context,
                    Icons.delete_outline,
                    "Data Deletion",
                    "You may request to have your data deleted at any time by contacting us.",
                    isDarkMode,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Contact section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDarkMode
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Contact Us",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "For any privacy concerns or questions, please reach out to us at:",
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "privacy@example.com",
                          style: TextStyle(
                            color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Last updated
                  const SizedBox(height: 32),
                  Text(
                    "Last updated: May 2025",
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPolicyPoint(BuildContext context, IconData icon, String title, String description, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    height: 1.5,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}