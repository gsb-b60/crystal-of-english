import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki/business/Deck.dart';
import 'cardlistscreen.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Decks"),
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.only(right: 60),
            child: IconButton(
              onPressed: 
              () {
                Provider.of<Deckmodel>(context, listen: false).filePicker();
              },
              icon: Icon(Icons.upload_file),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          children: [
            Expanded(
              child: Consumer<Deckmodel>(
                builder: (context, deckModel, child) {
                  return ListView.builder(
                    itemCount: deckModel.deck.length,
                    itemBuilder: (context, index) {
                      final deck = deckModel.deck[index];
                      return ListTile(
                        title: Text(deck.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CardListScreen(deckId: deck.id),
                            ),
                          );
                        },
                        trailing: IconButton(
                          onPressed: () {
                            if (deck.id != null) {
                              deckModel.deleteDeck(deck.id!);
                            }
                          },
                          icon: Icon(Icons.delete),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            CreateNewDeck(),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: deckController,
            decoration: InputDecoration(labelText: "new deck name"),
          ),
        ),
        Consumer<Deckmodel>(
          builder: (context, value, child) {
            return ElevatedButton(
              onPressed: () {
                if (deckController.text.isNotEmpty) {
                  value.insertDeck(deckController.text);
                  deckController.clear();
                }
              },
              child: Text('them deck'),
            );
          },
        ),
      ],
    );
  }
}
