import 'package:flutter/material.dart';
import 'package:mygame/flashcard/screen/decklist/achievement/achievementNoti.dart';
import 'package:mygame/flashcard/screen/decklist/achievement/achievementUI.dart';
import 'package:provider/provider.dart';

class Achievement extends StatefulWidget {
  const Achievement({super.key});

  @override
  State<Achievement> createState() => _AchievementState();
}

class _AchievementState extends State<Achievement> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => Achievementnoti()..fetchCard(),
      child: Consumer<Achievementnoti>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return AchievementUI();
        },
      ),
    );
  }
}