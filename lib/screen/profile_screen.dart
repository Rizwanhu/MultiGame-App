// import 'package:app/screen/login_signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/Bottombar.dart';
import 'main_screen.dart';
import 'Leaderboard.dart';
import 'ads_screen.dart';
import '../../theme/theme_provider.dart';
import 'privacy_policy_screen.dart';
import 'login_signup.dart'; 

class ProfileScreen extends StatefulWidget {
  final int initialIndex;
  const ProfileScreen({this.initialIndex = 3, Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey.shade100,
        appBar: AppBar(
          title: const Text("Profile"),
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: isDarkMode ? Colors.grey[850] : null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: isDarkMode ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Username
              Text(
                "Muhammad Musadiq ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),

              // Email
              Text(
                "musadiqmusadiq@gmail.com",
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              // Static card with GIF
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                shadowColor: isDarkMode ? Colors.black : Colors.black45,
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.asset(
                        'assets/images/coin.gif',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        repeat: ImageRepeat.repeat,
                        gaplessPlayback: true,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        color: Colors.black.withOpacity(0.6),
                        child: const Text(
                          "Earn Coins by Playing!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Logout button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) =>  LoginPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.red[700] : Colors.red,
                ),
              ),
              const SizedBox(height: 10),

              // Privacy Policy button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                  );
                },
                icon: const Icon(Icons.privacy_tip),
                label: const Text("Privacy Policy"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDarkMode ? Colors.white : Colors.black,
                  side: BorderSide(
                    color: isDarkMode ? Colors.white54 : Colors.black54,
                  ),
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
      ),
    );
  }
}
