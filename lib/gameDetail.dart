import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme_provider.dart';
import 'Games/CardFlipper/CardFlipper.dart';  // Add this import
import 'Games/SnakeGame/SnakeGame.dart';  // Add this import
// import 'Games/SnakeGame/game.dart';

class GameDetailScreen extends StatelessWidget {
  final String gameName;
  final String gameImage;

  const GameDetailScreen({
    super.key,
    required this.gameName,
    required this.gameImage,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFDFF3FF),
      body: Stack(
        children: [
          // Background image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              gameImage,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.35,
            ),
          ),

          // Main rounded container
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    gameName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Move the paddle with your finger to keep the balls in play.\nIf you miss, your opponent scores a point.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: isDarkMode ? Colors.grey[300] : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // HOW TO PLAY (YouTube)
                  ElevatedButton.icon(
                    
                    onPressed: () async {
                      const youtubeUrl = 'https://www.youtube.com'; 
                      if (await canLaunchUrl(Uri.parse(youtubeUrl))) {
                        await launchUrl(Uri.parse(youtubeUrl), mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open YouTube link')),
                        );
                      // if (gameName == "Card Flipper") {
                      //   final result = await Navigator.push(
                      //     context,
                      //     PageRouteBuilder(
                      //       pageBuilder: (context, animation, secondaryAnimation) => CardFlipperGame(),
                      //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      //         return SlideTransition(
                      //           position: Tween<Offset>(
                      //             begin: const Offset(1.0, 0.0),
                      //             end: Offset.zero,
                      //           ).animate(animation),
                      //           child: child,
                      //         );
                      //       },
                      //     ),
                      //   );
                      //   if (result != null) {
                      //     print('Game Score: $result');
                      //   }
                      // }
                      }
                    },
                    icon: Icon(Icons.ondemand_video, color: Colors.white),
                    label: Text(
                      "HOW TO PLAY",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PLAY GAME Button
                  _buildOptionButton(
                    icon: Icons.videogame_asset,
                    label: "PLAY\nGAME",
                    onTap: () {
                      if (gameName == "Card Flipper") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CardFlipperGame()),
                        );
                      }
                    },
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 30),

                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 100,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(0xFFDD8558),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent.shade100.withOpacity(isDarkMode ? 0.5 : 1),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          )
                        ],
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.orange.shade700,
                            width: 2,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isDarkMode ? Color(0xFF0D47A1) : Color(0xFF1E88E5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(isDarkMode ? 0.3 : 1),
              blurRadius: 8,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
