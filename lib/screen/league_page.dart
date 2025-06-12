import 'dart:ui';
import 'package:flutter/material.dart';

class LeaguePage extends StatelessWidget {
  final List<Map<String, String>> badgeTiers = [
    {'name': 'Bronze III', 'score': '750+', 'image': 'assets/images/badges/bronze.png'},
    {'name': 'Bronze II', 'score': '1000+', 'image': 'assets/images/badges/bronze.png'},
    {'name': 'Bronze I', 'score': '1500+', 'image': 'assets/images/badges/bronze.png'},
    {'name': 'Silver III', 'score': '2000+', 'image': 'assets/images/badges/silver.png'},
    {'name': 'Silver II', 'score': '3000+', 'image': 'assets/images/badges/silver.png'},
    {'name': 'Silver I', 'score': '4500+', 'image': 'assets/images/badges/silver.png'},
    {'name': 'Gold III', 'score': '6000+', 'image': 'assets/images/badges/gold.png'},
    {'name': 'Gold II', 'score': '7500+', 'image': 'assets/images/badges/gold.png'},
    {'name': 'Gold I', 'score': '10000+', 'image': 'assets/images/badges/gold.png'},
    {'name': 'Diamond', 'score': '15000+', 'image': 'assets/images/badges/diamond.png'},
  ];

  Color getCategoryColor(String name) {
    if (name.contains('Bronze')) return Colors.brown.shade200.withOpacity(0.8);
    if (name.contains('Silver')) return Colors.grey.shade300.withOpacity(0.8);
    if (name.contains('Gold')) return Colors.amber.shade200.withOpacity(0.8);
    if (name.contains('Diamond')) return Colors.blue.shade100.withOpacity(0.8);
    return Colors.white.withOpacity(0.7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('League & Badges'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background image with blur
          Container(
            decoration: const BoxDecoration(
  image: DecorationImage(
    image: AssetImage('assets/images/leaderboard.jpg'),
    fit: BoxFit.cover,
  ),
),

            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

          // Badge list in scrollable container
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Badge Tiers',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const Divider(color: Colors.white70),
                  Expanded(
                    child: ListView.builder(
                      itemCount: badgeTiers.length,
                      itemBuilder: (context, index) {
                        final badge = badgeTiers[index];
                        final bgColor = getCategoryColor(badge['name']!);
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Image.asset(badge['image']!, width: 36, height: 36),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  badge['name']!,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                badge['score']!,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
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
}
