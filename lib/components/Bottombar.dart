import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<IconData> icons;
  final List<String> labels;

  CustomBottomBar({
    required this.currentIndex,
    required this.onTap,
    this.icons = const [Icons.home, Icons.bar_chart, Icons.monetization_on, Icons.person],
    this.labels = const ["Home", "Leaderboard", "Ads", "Profile"],
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return SizedBox(
      height: 65,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 65),
            painter: NavBarPainter(
              selectedIndex: currentIndex,
              totalItems: icons.length,
              backgroundColor: isDarkMode ? Colors.grey[850]! : Colors.white,
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(icons.length, (index) {
                bool isSelected = index == currentIndex;
                return Expanded(
                  child: InkWell( // Wrap Icon+Text together
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(50),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: isSelected ? 0 : 5),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: isSelected ? 40 : 30,
                          width: isSelected ? 40 : 30,
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: isDarkMode ? Colors.grey[800]! : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode ? Colors.black26 : Colors.black12,
                                      blurRadius: 8,
                                    )
                                  ],
                                )
                              : null,
                          child: Icon(
                            icons[index],
                            color: isSelected
                                ? isDarkMode
                                    ? Colors.blue[200]!
                                    : Colors.purple
                                : isDarkMode
                                    ? Colors.grey[500]!
                                    : Colors.grey,
                            size: isSelected ? 25 : 22,
                          ),
                        ),
                        SizedBox(height: 2),
                        Container(
                          height: 15,
                          child: Text(
                            labels[index],
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? isDarkMode
                                      ? Colors.blue[200]!
                                      : Colors.purple
                                  : isDarkMode
                                      ? Colors.grey[500]!
                                      : Colors.grey,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarPainter extends CustomPainter {
  final int selectedIndex;
  final int totalItems;
  final Color backgroundColor;

  NavBarPainter({
    required this.selectedIndex,
    required this.totalItems,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final itemWidth = size.width / totalItems;
    final centerX = (itemWidth * selectedIndex) + (itemWidth / 2) - 30;

    path.moveTo(0, 0);
    path.lineTo(centerX - 40, 0);

    // Left Curve
    path.quadraticBezierTo(
      centerX - 10, 0,
      centerX, 30,
    );

    // Circle Cutout
    path.arcToPoint(
      Offset(centerX + 60, 30),
      radius: Radius.circular(55),
      clockwise: false,
    );

    // Right Curve
    path.quadraticBezierTo(
      centerX + 70, 0,
      centerX + 100, 0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(
      path,
      Colors.black.withOpacity(0.2),
      10,
      true,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
