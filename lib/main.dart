import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki/screen/auth/auth_screen.dart';
import 'business/Flashcard.dart';
import 'business/Deck.dart';
import 'package:totoki/screen/deckwelcome.dart';
import "firebase_options.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity
  );
  
  final deckModel = Deckmodel();
  await deckModel.fetchDecks();

  final cardModel = Cardmodel();

  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: deckModel),
        ChangeNotifierProvider.value(value: cardModel),
      ],
      child: const MyApp(),
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
      //AuthScreen()
    );
  }
}
