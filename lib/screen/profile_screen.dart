import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;

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
  String? photoBase64;
  bool isLoading = true;
  int currentIndex = 3;
  bool isUploading = false;
  final defaultImagePath = 'assets/images/default_profile.png';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user == null) return;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
          
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          username = data['username'] ?? 'No name';
          email = data['email'];
          score = data['score'] ?? 0;
          photoBase64 = data['photoBase64'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile data')),
      );
    }
  }

  Future<String> _getDefaultImageBase64() async {
    final byteData = await rootBundle.load(defaultImagePath);
    final bytes = byteData.buffer.asUint8List();
    return base64Encode(bytes);
  }

  Future<void> pickImage({required ImageSource source}) async {
    if (isUploading) return;
    
    final picker = ImagePicker();
    try {
      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 500,
      );
      if (picked == null) return;

      setState(() => isUploading = true);
      
      // Convert image to base64
      final bytes = await File(picked.path).readAsBytes();
      final base64String = base64Encode(bytes);

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'photoBase64': base64String,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      setState(() {
        photoBase64 = base64String;
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );

    } catch (e) {
      print('Error uploading image: $e');
      setState(() => isUploading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Image Source"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                pickImage(source: ImageSource.camera);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.green),
              title: Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickImage(source: ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider getProfileImage() {
    if (photoBase64 != null && photoBase64!.isNotEmpty) {
      return MemoryImage(base64Decode(photoBase64!));
    }
    return AssetImage(defaultImagePath);
  }

  String? getBadgeImagePath(int score) {
  if (score >= 10000) return 'assets/images/badges/diamond.png';
  if (score >= 6000) return 'assets/images/badges/gold.png';
  if (score >= 2000) return 'assets/images/badges/silver.png';
  if (score >= 750) return 'assets/images/badges/bronze.png';
  return null; // No badge
}

String getBadgeName(int score) {
  if (score >= 10000) return "Diamond";
    if (score >= 8000) return "Gold I";
    if (score >= 7000) return "Gold II";
    if (score >= 6000) return "Gold III";
    if (score >= 4000) return "Silver I";
    if (score >= 3000) return "Silver II";
    if (score >= 2000) return "Silver III";
    if (score >= 1500) return "Bronze I";
    if (score >= 1000) return "Bronze II";
    if (score >= 750) return "Bronze III";
    return "No Badge";
}



  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? const Color(0xFF158FAD) : const Color(0xFF0B7996);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimaryColor = isDarkMode ? Colors.white : Colors.black87;
    final dividerColor = isDarkMode ? Colors.white24 : Colors.grey.shade300;
    final scaffoldBackgroundColor = isDarkMode ? const Color(0xFF0A1A1F) : primaryColor;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: getProfileImage(),
                              ),
                              if (isUploading)
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          username ?? "Your name",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        if (score != null) ...[
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDarkMode ? primaryColor.withOpacity(0.2) : primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primaryColor.withOpacity(isDarkMode ? 0.4 : 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, color: primaryColor, size: 20),
                                SizedBox(width: 6),
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
                          SizedBox(height: 10),
                          if (getBadgeImagePath(score!) != null) ...[
                            Image.asset(
                              getBadgeImagePath(score!)!,
                              height: 60,
                            ),
                            SizedBox(height: 6),
                            Text(
                              getBadgeName(score!),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textPrimaryColor,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
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
                        Divider(height: 1, thickness: 0.5, color: dividerColor),
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
                  SizedBox(height: 20),
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
          } else {
            setState(() {
              currentIndex = index;
            });
          }
        },
      ),
    );
  }
}

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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? (isDarkMode ? Colors.white70 : Colors.grey.shade700)),
            SizedBox(width: 16),
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