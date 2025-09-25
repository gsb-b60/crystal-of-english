import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki/business/Flashcard.dart';
import 'package:totoki/screen/newwayreview.dart';
import 'package:totoki/screen/reviewscreen.dart';
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Newwayreview(
                        deckId: widget.deckId!,
                        key: ValueKey(widget.deckId),
                      ),
                    ),
                  );
                },
                child: const Text('Review'),
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
      return FlashCardItem(card: card, media: cardModel.media);
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
  const FlashCardItem({super.key, required this.card, required this.media});

  @override
  Widget build(BuildContext context) {
    final dir = '/data/user/0/com.example.totoki/app_flutter/anki/${media!}';
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (card.img != null)
              Container(
                width: 400,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  // Bọc trong ClipRRect để làm tròn góc ảnh
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File('$dir/${card.img}'),
                    fit: BoxFit.fitWidth, // Đảm bảo hình ảnh vừa với chiều rộng
                  ),
                ),
              ),
            Row(
              children: [
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
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 167, 14, 77),
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
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Meaning: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              TextSpan(
                                text: card.meaning ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      if (card.example != null)
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Example: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              TextSpan(
                                text: card.example ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      if (card.img != null)
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Image: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              TextSpan(
                                text: card.img ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      if (card.sound != null)
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Sound: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              TextSpan(
                                text: card.sound ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),

                      if (card.defSound != null)
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Definition Sound: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              TextSpan(
                                text: card.defSound ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),

                      if (card.usageSound != null)
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Usage Sound: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              TextSpan(
                                text: card.usageSound ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 6),
                      // Review info: interval / reps / due date
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (card.interval != null)
                                Chip(
                                  label: Text('Interval: ${card.interval}'),
                                  backgroundColor: Colors.blue[50],
                                ),
                              if (card.reps != null)
                                Chip(
                                  label: Text('Reps: ${card.reps}'),
                                  backgroundColor: Colors.green[50],
                                ),
                              Complexity(card: card),
                            ],
                          ),
                          Row(
                            children: [
                              if (card.due != null)
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
                              if (card.complexity != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(
                                    'complexity: ${card.complexity}',
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
                    ],
                  ),
                ),
                // Optional: sound button
                Column(
                  children: [
                    if (card.sound != null)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () async {
                              await audio.play(
                                DeviceFileSource('$dir/${card.sound}'),
                              );
                            },
                          ),
                          Text("sound"),
                        ],
                      ),
                    if (card.usageSound != null)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () async {
                              await audio.play(
                                DeviceFileSource('$dir/${card.usageSound}'),
                              );
                            },
                          ),
                          Text("u sound"),
                        ],
                      ),
                    if (card.defSound != null)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () async {
                              await audio.play(
                                DeviceFileSource('$dir/${card.defSound}'),
                              );
                            },
                          ),
                          Text("defsound"),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            if (card.synonyms != null)
              Container(
                width: 400,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  // Bọc trong ClipRRect để làm tròn góc ảnh
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File('$dir/${card.synonyms}'),
                    fit: BoxFit.fitWidth, // Đảm bảo hình ảnh vừa với chiều rộng
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Complexity extends StatelessWidget {
  const Complexity({super.key, required this.card});

  final Flashcard card;
  Color _getChipColor(int complexity) {
    if (complexity == 1) {
      return const Color.fromARGB(
        255,
        0,
        168,
        6,
      ); // Mức độ dễ (xanh lá cây nhạt)
    } else if (complexity == 2) {
      return const Color.fromARGB(
        255,
        0,
        97,
        73,
      ); // Mức độ dễ vừa (xanh lá cây sáng hơn)
    } else if (complexity == 3) {
      return const Color.fromARGB(
        255,
        0,
        59,
        94,
      ); // Mức độ trung bình (vàng nhạt)
    } else if (complexity == 4) {
      return const Color.fromARGB(
        255,
        141,
        3,
        106,
      ); // Mức độ khó vừa (cam nhạt)
    } else if (complexity == 5) {
      return const Color.fromARGB(255, 138, 3, 16); // Mức độ khó (đỏ nhạt)
    } else {
      // Mặc định hoặc giá trị không xác định
      return Colors.grey[100]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getChipColor(card.complexity ?? 0);
    return Chip(
      label: Text(
        'level: ${card.complexity}',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}
