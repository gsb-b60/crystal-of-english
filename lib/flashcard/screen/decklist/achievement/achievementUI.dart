import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:mygame/flashcard/screen/decklist/achievement/achievementNoti.dart';
import 'package:provider/provider.dart';

class AchievementUI extends StatefulWidget {
  const AchievementUI({super.key});

  @override
  State<AchievementUI> createState() => _AchievementState();
}

class _AchievementState extends State<AchievementUI> {
  

  @override
  Widget build(BuildContext context) {
    final provider=context.watch<Achievementnoti>();
    final flashcards=provider.getCard();
    return Scaffold(
      backgroundColor: AppColor.darkSurface,
      appBar: AppBar(
        backgroundColor: AppColor.darkSurface,
        title: Text(
          "Achievement",
          style: TextStyle(
            color: AppColor.lightText,
            fontWeight: FontWeight.bold,
            fontSize: 38,
          ),
        ),
        leading: Row(
          children: [
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppColor.darkBorder,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final card = flashcards[index];
          final due = card.due ?? DateTime.now();
          final levelColor;
          final level = card.complexity ?? 1;
          bool Learned = card.reps != null && card.reps! > 0;
          final reps = (card.reps != null && card.reps! >= 0 && card.reps! <= 5)
              ? card.reps
              : 0;
          final path = 'assets/rep/rep$reps.png';

          switch (card.complexity) {
            case 1:
              levelColor = AppColor.bronze;
              break;
            case 2:
              levelColor = AppColor.silver;
              break;
            case 3:
              levelColor = AppColor.gold;
              break;
            case 4:
              levelColor = AppColor.platinum;
              break;
            case 5:
              levelColor = AppColor.diamond;
              break;
            case 6:
              levelColor = AppColor.master;
              break;
            case 7:
              levelColor = AppColor.challenger;
              break;
            default:
              levelColor = Colors.grey;
          }
          //final levelColor=flashcards[index]
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.darkCard, width: 4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Image.asset(path, width: 30, height: 30),
              title: Text(
                card.word!,
                style: TextStyle(
                  color: Learned ? levelColor : AppColor.darkSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  shadows: [
                    Shadow(color: levelColor.withOpacity(0.8), blurRadius: 10),
                    Shadow(color: levelColor.withOpacity(0.6), blurRadius: 20),
                    Shadow(color: levelColor.withOpacity(0.4), blurRadius: 30),
                  ],
                ),
              ),
              subtitle: Text(
                'Due Day: ${due.day}/${due.month}/${due.year}',
                style: TextStyle(
                  color: AppColor.lightText.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              trailing: Text(
                "Level: ${level}",
                style: TextStyle(
                  color: levelColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  shadows: [
                    Shadow(
                      color: levelColor.withOpacity(0.80),
                      blurRadius: 52,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
