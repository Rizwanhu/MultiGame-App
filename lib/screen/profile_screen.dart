import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:app/components/Bottombar.dart';
import 'package:app/screen/Ads_screen.dart';
import 'package:app/screen/Leaderboard.dart';
import 'package:app/screen/login_signup.dart';
import 'package:app/screen/main_screen.dart';
import 'package:app/screen/privacy_policy_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String? username;
  String? email;
  int? score;
  String? photoUrl;
  File? localImageFile;
  bool isLoading = true;
  int currentIndex = 3;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    loadLocalImage();
  }

  Future<void> fetchUserData() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        username = data['username'];
        email = data['email'];
        score = data['score'];
        photoUrl = data['photoUrl'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text("Choose image source"),
        children: [
          SimpleDialogOption(
            child: const Text("Camera"),
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          SimpleDialogOption(
            child: const Text("Gallery"),
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    );
    if (source == null) return;

    final XFile? picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/profile_image.jpg';
    final savedImage = await File(picked.path).copy(path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localImagePath', savedImage.path);

    setState(() {
      localImageFile = savedImage;
    });
  }

  Future<void> loadLocalImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('localImagePath');
    if (path != null && File(path).existsSync()) {
      setState(() {
        localImageFile = File(path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is enabled
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Colors based on theme
    final primaryColor = isDarkMode ? const Color(0xFF158FAD) : const Color(0xFF0B7996);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimaryColor = isDarkMode ? Colors.white : Colors.black87;
    final textSecondaryColor = isDarkMode ? Colors.white70 : Colors.black54;
    final dividerColor = isDarkMode ? Colors.white24 : Colors.grey.shade300;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF0A1A1F) : primaryColor;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: isDarkMode ? Colors.white : Colors.white)),
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile card section
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: localImageFile != null
                                ? FileImage(localImageFile!)
                                : (photoUrl != null
                                    ? NetworkImage(photoUrl!)
                                    : const AssetImage('assets/images/default_profile.png') as ImageProvider),
                            child: localImageFile == null && photoUrl == null
                                ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          username ?? "Your name",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Color(0xFF2A2A2A) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            email ?? "youremail@gmail.com",
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        // Optional: Display score if needed
                        if (score != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primaryColor.withOpacity(isDarkMode ? 0.4 : 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "$score points",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Menu items
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Privacy Policy Item
                        MenuItemTile(
                          icon: Icons.privacy_tip,
                          title: "Privacy Policy",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
                            );
                          },
                          isDarkMode: isDarkMode,
                        ),
                        
                        const Divider(height: 1, thickness: 0.5, color: Colors.white24),
                        
                        // Log Out Item
                        MenuItemTile(
                          icon: Icons.logout,
                          title: "Log Out",
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => LoginPage()),
                              (route) => false,
                            );
                          },
                          textColor: primaryColor,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LeaderboardPage()),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdsScreen()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

// Custom menu item widget
class MenuItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showChevron;
  final Color? textColor;

  final bool isDarkMode;

  const MenuItemTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.showChevron = false,
    this.textColor,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? (isDarkMode ? Colors.white70 : Colors.grey.shade700)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? (isDarkMode ? Colors.white : Colors.black87),
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (showChevron) Icon(Icons.chevron_right, color: isDarkMode ? Colors.white30 : Colors.grey),
          ],
        ),
      ),
    );
  }
}