import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki/Flashcard.dart';
import 'package:totoki/testdb/reviewscreen.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer audio = AudioPlayer();

class CardListScreen extends StatefulWidget {
  final int? deckId;
  const CardListScreen({super.key, required this.deckId});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final frontController = TextEditingController();
  final backcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.deckId != null) {
        final cardModel = Provider.of<Cardmodel>(context, listen: false);
        cardModel.fetchCards(widget.deckId!);
        
      }
      
    });
  }

  @override
  void dispose() {
    frontController.dispose();
    backcontroller.dispose();
    super.dispose();
  }

  Widget _buildAddCardForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: frontController,
            decoration: InputDecoration(labelText: 'Front'),
          ),
          TextField(
            controller: backcontroller,
            decoration: InputDecoration(labelText: 'Back'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewSreen(deckId: widget.deckId!),
                    ),
                  );
                },
                child: const Text('Learn this deck'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (frontController.text.isNotEmpty &&
                      backcontroller.text.isNotEmpty) {
                    final cardModel = Provider.of<Cardmodel>(
                      context,
                      listen: false,
                    );
                    Flashcard newFlashCard = Flashcard(
                      meaning: backcontroller.text,
                      deckId: widget.deckId!,
                      word: frontController.text,
                      due: DateTime.now(),
                    );
                    cardModel.addCard(newFlashCard);
                    frontController.clear();
                    backcontroller.clear();
                  }
                },
                child: Text('Add Card'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardModel = Provider.of<Cardmodel>(context);
    //final media= cardModel.MediaFile(deckId)
    final List<Widget> cardWidgets = cardModel.card.map((card) {
      return FlashCardItem(card: card,media:cardModel.media);
    }).toList();
    final List<Widget> allWidgets = [
      _buildAddCardForm(context),
      ...cardWidgets,
    ];
    return Scaffold(
      appBar: AppBar(title: Text('My Deck')),
      body: ListView.builder(
        itemCount: allWidgets.length,
        itemBuilder: (context, index) {
          return allWidgets[index];
        },
      ),
    );
  }
}

class FlashCardItem extends StatelessWidget {
  final Flashcard card;
  final String? media;
  const FlashCardItem({super.key, required this.card,required this.media});
  

  @override
  Widget build(BuildContext context) {
    final dir='/data/user/0/com.example.totoki/app_flutter/anki/${media!}';
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            //Hình ảnh nếu có
            if (card.img != null)
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(
                      File(
                        '$dir/${card.img}',
                      ),
                    ), // hoặc AssetImage
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Word + IPA
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.word ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (card.ipa != null)
                        Flexible(
                          child: Text(
                            "/${card.ipa!}/",
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              overflow: TextOverflow.ellipsis,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Meaning
                  if (card.meaning != null)
                    Text(card.meaning!, style: const TextStyle(fontSize: 15)),
                  Text(card.example ?? 'no example'),
                  Text(card.img ?? "no image"),
                  Text(card.sound ?? "no image"),
                  Text(card.defSound ?? "no image"),
                  Text(card.usageSound ?? "no image"),
                  const SizedBox(height: 6),
                  // Review info: interval / reps / due date
                  Row(
                    children: [
                      if (card.interval == null)
                        Chip(
                          label: Text('Interval: ${card.interval}'),
                          backgroundColor: Colors.blue[50],
                        ),
                      if (card.reps == null)
                        Chip(
                          label: Text('Reps: ${card.reps}'),
                          backgroundColor: Colors.green[50],
                        ),
                      if (card.due == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            'Due: ${DateFormat('MM/dd').format(card.due!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Optional: sound button
            Column(
              children: [
                if (card.sound != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () async {
                      await audio.play(

                        DeviceFileSource(
                          '${dir}/${card.sound}',
                        ),
                      );
                    },
                  ),
                if (card.usageSound != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () async {
                      await audio.play(
                        DeviceFileSource(
                          '${dir}/${card.usageSound}',
                        ),
                      );
                    },
                  ),
                if (card.defSound != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () async {
                      await audio.play(
                        DeviceFileSource(
                          '${dir}/${card.defSound}',
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
