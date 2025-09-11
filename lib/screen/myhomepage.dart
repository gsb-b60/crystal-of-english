import 'package:flutter/material.dart';
import 'package:totoki/Deck.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: TestDatabase());
  }
}

class TestDatabase extends StatefulWidget {
  const TestDatabase({super.key});

  @override
  State<TestDatabase> createState() => _TestDatabaseState();
}

class _TestDatabaseState extends State<TestDatabase> {
  final _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            child: Expanded(
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final deck = Provider.of<Deckmodel>(
                        context,
                        listen: false,
                      );
                      if (_nameController.text.isNotEmpty) {
                        deck.insertDeck(_nameController.text);
                        _nameController.clear();
                      }
                    },
                    child: Text('ADD'),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: "add new deck"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<Deckmodel>(
              builder: (context, value, child) {
                return ListView.builder(
                  itemCount: value.deck.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Row(
                        children: [
                          Text(value.deck[index].id.toString()),
                          Spacer(flex: 1),
                          Text(value.deck[index].name),
                          IconButton(
                            onPressed: () {
                              if (value.deck[index].id != null) {
                                value.deleteDeck(value.deck[index].id!);
                              }
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              
            ),
          ),
        ],
      ),
    );
  }
}

