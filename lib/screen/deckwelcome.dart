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
            padding: EdgeInsets.only(right: 60), // FIXED
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
        padding: EdgeInsets.all(16), // FIXED
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Deck "${deck.name}" deleted')),
                              );
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

  void _createDeck(BuildContext context, Deckmodel value) {
    final deckName = deckController.text.trim();
    if (deckName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deck name cannot be empty')),
      );
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
                onSubmitted: (_) => _createDeck(context, value), // ADDED
              ),
            ),
            ElevatedButton(
              onPressed: () => _createDeck(context, value), // UPDATED
              child: Text('them deck'),
            ),
          ],
        );
      },
    );
  }
}
