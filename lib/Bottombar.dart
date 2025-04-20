import 'package:flutter/material.dart';
import 'ads_screen.dart';

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
    return SizedBox(
      height: 65,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 65),
            painter: NavBarPainter(
              selectedIndex: currentIndex,
              totalItems: icons.length,
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(icons.length, (index) {
                bool isSelected = index == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: isSelected ? 0 : 5),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: isSelected ? 40 : 30,
                          width: isSelected ? 40 : 30,
                          decoration: isSelected ? BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                              )
                            ],
                          ) : null,
                          child: Icon(
                            icons[index],
                            color: isSelected ? Colors.purple : Colors.grey,
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
                              color: isSelected ? Colors.purple : Colors.grey,
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

  NavBarPainter({
    required this.selectedIndex,
    required this.totalItems,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final itemWidth = size.width / totalItems;
    final centerX = (itemWidth * selectedIndex) + (itemWidth / 2) - 30; // Moved left by 30
    
    path.moveTo(0, 0);
    path.lineTo(centerX - 40, 0);

    // Left Curve
    path.quadraticBezierTo(
      centerX - 10, 0,
      centerX, 30, // Increased depth from 20 to 30
    );

    // Circle Cutout
    path.arcToPoint(
      Offset(centerX + 60, 30), // Increased depth from 20 to 30
      radius: Radius.circular(55), // Increased radius for deeper curve
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

    canvas.drawShadow(path, Colors.black12, 10, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
