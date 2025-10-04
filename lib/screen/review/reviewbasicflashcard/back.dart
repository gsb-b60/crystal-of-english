import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:totoki/business/Flashcard.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flip_card/flip_card.dart';
import 'newwayreview.dart';
class BackSide extends StatefulWidget {
  final Flashcard card;
  final String? media;
  const BackSide({super.key, required this.card, required this.media});

  @override
  State<BackSide> createState() => BackSideState();
}

class BackSideState extends State<BackSide> {
  void playSound(String media,String path) async {
    String soundPath = '/data/user/0/com.example.totoki/app_flutter/anki/$media/$path';
    await audio.play(DeviceFileSource(soundPath));
  }

  @override
  void initState() {
    super.initState();
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
