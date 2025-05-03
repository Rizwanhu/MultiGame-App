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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 60,
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
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Username: $username", style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Email: $email", style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Score: $score", style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.red[700] : Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()),
                      );
                    },
                    icon: const Icon(Icons.privacy_tip),
                    label: const Text("Privacy Policy"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDarkMode ? Colors.white : Colors.black,
                      side: BorderSide(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
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
