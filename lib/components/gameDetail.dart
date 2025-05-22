import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../theme/theme_provider.dart';
import '../Games/CardFlipper/CardFlipper.dart';
import '../Games/SnakeGame/SnakeGame.dart';
import '../Games/TicTacToe_AI/TicTacToe.dart' as tictactoe;
import '../Games/2048_Game/2048.dart' as game2048;
import 'package:app/audio_service.dart';

class GameDetailScreen extends StatefulWidget {
  final String gameName;
  final String gameImage;

  const GameDetailScreen({
    super.key,
    required this.gameName,
    required this.gameImage,
  });

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  VideoPlayerController? _videoController;

  String get _videoAsset {
    // You can map video files based on game name
    switch (widget.gameName) {
      case "Card Flipper":
        return 'assets/videos/cf.mp4';
      case "Snake Game":
        return 'assets/videos/snake.mp4';
      case "Tic Tac Toe":
        return 'assets/videos/tic-tac-toe.mp4';
      case "2048":
        return 'assets/videos/2048.mp4';
      default:
        return 'assets/videos/default.mp4';
    }
  }

  Future<void> _showHowToPlayDialog() async {
  AudioService().playClickSound();

  _videoController = VideoPlayerController.asset(_videoAsset);
  await _videoController!.initialize();
  _videoController!.play();

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('How to Play'),
        content: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _videoController?.pause();
              Navigator.pop(dialogContext); // ✅ closes only the dialog
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
  ).then((_) {
    _videoController?.dispose();
    _videoController = null;
  });
}


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF121212) : Color(0xFFDFF3FF),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              widget.gameImage,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.35,
            ),
          ),
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
                    widget.gameName,
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

                  // ✅ HOW TO PLAY (now opens local video)
                  ElevatedButton.icon(
                    onPressed: _showHowToPlayDialog,
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

                  // ✅ PLAY GAME button
                  _buildOptionButton(
                    icon: Icons.videogame_asset,
                    label: "PLAY\nGAME",
                    onTap: () {
                      AudioService().playClickSound();
                      if (widget.gameName == "Card Flipper") {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CardFlipperGame()));
                      } else if (widget.gameName == "Snake Game") {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GamePage()));
                      } else if (widget.gameName == "Tic Tac Toe") {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => tictactoe.MyApp()));
                      } else if (widget.gameName == "2048") {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => game2048.MyApp()));
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Game Unavailable"),
                            content: Text("This game is not available currently."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK"),
                              )
                            ],
                          ),
                        );
                      }
                    },
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 30),

                  // ✅ Back button
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
