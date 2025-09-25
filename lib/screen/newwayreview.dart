import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totoki/business/Flashcard.dart';
import 'package:totoki/screen/newwayreview.dart';
import 'package:totoki/screen/reviewscreen.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flip_card/flip_card.dart';

final AudioPlayer audio = AudioPlayer();

class Newwayreview extends StatefulWidget {
  final int deckId;
  const Newwayreview({super.key, required this.deckId});

  @override
  State<Newwayreview> createState() => _Newwayreview();
}

class _Newwayreview extends State<Newwayreview> {
  List<Flashcard> _dueCards = [];
  String media = "";
  Flashcard? card;
  List<Widget>? cardWidgets;
  Future<void> _loadDueCard() async {
    final cardModel = Provider.of<Cardmodel>(context, listen: false);
    _dueCards = await cardModel.getDueCards(widget.deckId);
    media = cardModel.media ?? "";
    card = _dueCards.isNotEmpty ? _dueCards[0] : null;
    cardWidgets = _dueCards.map((card) {
      return FlashCardItem(card: card, media: cardModel.media);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadDueCard();
  }

  @override
  void didUpdateWidget(covariant Newwayreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deckId != widget.deckId) {
      _loadDueCard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Cards')),
      body: FutureBuilder(
        future: _loadDueCard(),
        builder: (context, snapshot) => Center(
          child: PageView(children: cardWidgets ?? [const Text("No Cards")]),
        ),
      ),
    );
  }
}

class FlashCardItem extends StatefulWidget {
  final Flashcard? card;
  final String? media;
  const FlashCardItem({super.key, required this.card, required this.media});

  @override
  State<FlashCardItem> createState() => _FlashCardItemState();
}

class _FlashCardItemState extends State<FlashCardItem> {
  @override
  Widget build(BuildContext context) {
    final backKey = GlobalKey<_BackSideState>();
    return Card(
      elevation: 0.0,
      margin: EdgeInsets.only(left: 32.0, right: 32.0, top: 20.0, bottom: 30.0),
      color: Color.fromARGB(0, 255, 1, 1),
      child: FlipCard(
        front: FrontSide(widget: widget),
        back: BackSide(key: backKey, card: widget.card!, media: widget.media),
        onFlipDone: (isFront) {
          if (isFront) {
            backKey.currentState?._playSound(
              "/data/user/0/com.example.totoki/app_flutter/anki/${widget.media!}/${widget.card?.sound}",
            );
          }
        },
      ),
    );
  }
}

class FrontSide extends StatelessWidget {
  const FrontSide({super.key, required this.widget});

  final FlashCardItem widget;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.yellow[70],
      child: Center(
        child: Text(
          widget.card?.word ?? '',
          style: const TextStyle(
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 167, 14, 77),
          ),
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }
}

class BackSide extends StatefulWidget {
  final Flashcard card;
  final String? media;
  const BackSide({super.key, required this.card, required this.media});

  @override
  State<BackSide> createState() => _BackSideState();
}

class _BackSideState extends State<BackSide> {
  void _playSound(String soundPath) async {
    await audio.play(DeviceFileSource(soundPath));
    print("something");
  }

  void doSomething() {
    print("Logic back chạy khi được gọi từ FlipCard");
  }

  @override
  void initState() {
    super.initState();
    // _playSound("/data/user/0/com.example.totoki/app_flutter/anki/${widget.media!}/${widget.card.sound}");
  }

  @override
  Widget build(BuildContext context) {
    final dir =
        '/data/user/0/com.example.totoki/app_flutter/anki/${widget.media!}';
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.yellow[70],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (widget.card.img != null)
              Container(
                height: 200,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  // Bọc trong ClipRRect để làm tròn góc ảnh
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File('$dir/${widget.card.img}'),
                    fit: BoxFit.fitHeight,
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Text(
                              widget.card.word ?? '',
                              style: const TextStyle(
                                fontSize: 29,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 167, 14, 77),
                              ),
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          if (widget.card.ipa != null)
                            Flexible(
                              child: Text(
                                "/${widget.card.ipa!}/",
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
                      if (widget.card.meaning != null)
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
                                text: widget.card.meaning ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      if (widget.card.example != null &&
                          widget.card.example != "")
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
                                text: widget.card.example ?? '',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Optional: sound button
                Column(
                  children: [
                    if (widget.card.sound != null)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () async {
                              await audio.play(
                                DeviceFileSource('$dir/${widget.card.sound}'),
                              );
                            },
                          ),
                          Text("sound"),
                        ],
                      ),
                    if (widget.card.usageSound != null)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () async {
                              await audio.play(
                                DeviceFileSource(
                                  '$dir/${widget.card.usageSound}',
                                ),
                              );
                            },
                          ),
                          Text("u sound"),
                        ],
                      ),
                    if (widget.card.defSound != null)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: () async {
                              // await audio.play(
                              //   DeviceFileSource('$dir/${card.defSound}'),
                              // );
                            },
                          ),
                          Text("defsound"),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            if (widget.card.synonyms != null)
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
                    File('$dir/${widget.card.synonyms}'),
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

//oldway(widget: widget);
class oldway extends StatelessWidget {
  const oldway({super.key, required this.widget});

  final FlashCardItem widget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => {print("tapped")},
        child: Card(
          child: SizedBox(
            width: 300,
            height: 100,
            child: Text(
              widget.card?.word ?? "No Card",
              style: TextStyle(fontSize: 39),
            ),
          ),
        ),
      ),
    );
  }
}

class Review extends StatelessWidget {
  const Review({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('New Way Review Screen'));
  }
}
