import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mygame/components/DailyLesson/dailyLesson/lessonScreen.dart';
import 'package:mygame/components/DailyLesson/dailyLesson/timerNoti.dart';
import 'package:mygame/components/DailyLesson/screen/endscreen.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/components/Menu/flashcard/business/Deck.dart';
import 'package:mygame/components/Menu/flashcard/screen/decklist/achievement/achievement.dart';
import 'package:provider/provider.dart';

import 'cardlistscreen.dart';
import 'package:mygame/components/Menu/flashcard/business/Flashcard.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  @override
  Widget _buildAnimatedTile(dynamic deck, dynamic deckModel, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColor.darkerCard,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 239, 239).withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          deck.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(Icons.layers, color: Colors.white),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider<Cardmodel>(
                create: (_) => Cardmodel(),
                child: CardListScreen(deckId: deck.id, deckName: deck.name),
              ),
            ),
          );
        },
        trailing: IconButton(
          onPressed: () {
            if (deck.id != null) {
              deckModel.deleteDeck(deck.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.shade800,
                  content: Text('Deck "${deck.name}" deleted'),
                ),
              );
            }
          },
          icon: const Icon(Icons.delete, color: Colors.white70),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.darkSurface,
      appBar: AppBar(
        leading: const Icon(Icons.menu_book, color: Colors.white),
        backgroundColor: AppColor.darkSurface,
        title: const Text(
          "My Decks",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 60),
            child: IconButton(
              onPressed: () {
                Provider.of<Deckmodel>(context, listen: false).filePicker();
              },
              icon: const Icon(Icons.upload_file, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Consumer<Deckmodel>(
                  builder: (context, deckModel, child) {
                    return ListView.builder(
                      itemCount: deckModel.deck.length,
                      itemBuilder: (context, index) {
                        final deck = deckModel.deck[index];
                        return _buildAnimatedTile(deck, deckModel, index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColor.darkSurface,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtomNav(
              value: "Achievement",
              ico: Icons.stars,
              screenBuilder: () => Achievement(),
            ),
            ButtomNav(
              value: "Daily lesson",
              ico: Icons.flash_on_rounded,
              screenBuilder: () => LessonScreen(),
            ),
            ButtomNav(
              value: "Profile
              ",
              ico: Icons.flash_on_rounded,
              screenBuilder: () => LessonScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtomNav extends StatelessWidget {
  ButtomNav({
    super.key,
    required this.value,
    required this.ico,
    required this.screenBuilder,
  });
  final String value;
  final IconData ico;
  final Widget Function() screenBuilder;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenBuilder()),
        );
      },
      child: Container(
        width: 180,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColor.greenPrimary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(ico, color: AppColor.darkSurface, size: 35),
              Text(
                value,
                style: TextStyle(
                  color: AppColor.darkSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateNewDeck extends StatefulWidget {
  const CreateNewDeck({super.key});

  @override
  State<CreateNewDeck> createState() => _CreateNewDeckState();
}

class _CreateNewDeckState extends State<CreateNewDeck> {
  final deckController = TextEditingController();

  void _createDeck(BuildContext context, Deckmodel value) {
    final deckName = deckController.text.trim();
    if (deckName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deck name cannot be empty')));
      return;
    }
    final deckExists = value.deck.any((deck) => deck.name == deckName);
    if (deckExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deck "$deckName" already exists')),
      );
      return;
    }
    value.insertDeck(deckName);
    deckController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Deckmodel>(
      builder: (context, value, child) {
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: deckController,
                decoration: InputDecoration(labelText: "new deck name"),
                onSubmitted: (_) => _createDeck(context, value),
              ),
            ),
            ElevatedButton(
              onPressed: () => _createDeck(context, value),
              child: Text('them deck'),
            ),
          ],
        );
      },
    );
  }
}
