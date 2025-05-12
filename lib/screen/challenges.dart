import 'package:flutter/material.dart';

class ChallengesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dailyMissions = [
    {"task": "Play 1 Game", "reward": 50},
    {"task": "Win 2 Matches", "reward": 100},
    {"task": "Watch 1 Ad", "reward": 30},
    {"task": "Login Today", "reward": 20},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Challenges"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: dailyMissions.length,
        itemBuilder: (context, index) {
          final mission = dailyMissions[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.deepPurple),
              title: Text(mission['task']),
              trailing: Text("+${mission['reward']} pts",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                // You can handle challenge completion logic here
              },
            ),
          );
        },
      ),
    );
  }
}
