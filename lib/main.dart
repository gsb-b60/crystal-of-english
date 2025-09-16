import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'business/Flashcard.dart';
import 'business/Deck.dart';
import 'package:totoki/screen/deckwelcome.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final deckModel = Deckmodel();
  await deckModel.fetchDecks();

  final cardModel = Cardmodel();
  await cardModel.fetchCards(1);


  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deckModel),
        ChangeNotifierProvider.value(value: cardModel),
      ],
      child: const MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOTOKI FLASH CARD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 231, 183, 49),
        ),
      ),
      home: const DeckListScreen(),
    );
  }
}




