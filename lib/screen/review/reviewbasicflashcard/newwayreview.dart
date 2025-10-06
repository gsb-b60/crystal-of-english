import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:totoki/business/Flashcard.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flip_card/flip_card.dart';
import 'front.dart';
import "back.dart";
import 'dart:math';

//audio player instance
final AudioPlayer audio = AudioPlayer();

//scafford
class Newwayreview extends StatefulWidget {
  final int deckId;
  const Newwayreview({super.key, required this.deckId});

  @override
  State<Newwayreview> createState() => _Newwayreview();
}

class _Newwayreview extends State<Newwayreview> {
  List<Flashcard> _dueCards = [];
  String media = "";
  List<Widget>? cardWidgets;

  Future<void> _loadDueCard() async {
    final cardModel = Provider.of<Cardmodel>(context, listen: false);
    _dueCards = await cardModel.getDueCards(widget.deckId);
    media = cardModel.media ?? "";
    cardWidgets = _dueCards.map((card) {
      return FlashCardItem(card: card, media: cardModel.media);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadDueCard();
  }

  final controller = SwipableStackController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Cards')),
      body: FutureBuilder(
        future: _loadDueCard(),
        builder: (context, snapshot) => Column(
          children: [
            Expanded(
              child: Container(
                width: 411,
                child: Center(
                  child: Swipeder(
                    controller: controller,
                    cardWidgets: cardWidgets,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//chaange this to swipable stack
class Swipeder extends StatefulWidget {
  const Swipeder({
    super.key,
    required this.controller,
    required this.cardWidgets,
  });

  final SwipableStackController controller;
  final List<Widget>? cardWidgets;

  @override
  State<Swipeder> createState() => _SwipederState();
}

class _SwipederState extends State<Swipeder> {
  bool right = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SwipableStack(
          controller: widget.controller,
          horizontalSwipeThreshold: 0.1,
          verticalSwipeThreshold: 0.3,
          detectableSwipeDirections: const {
            SwipeDirection.right,
            SwipeDirection.left,
          },
          swipeAssistDuration: Duration(milliseconds: 100),
          stackClipBehaviour: Clip.none,
          swipeAnchor: SwipeAnchor.bottom,
          overlayBuilder: (context, properties) {
            final opacity = min(properties.swipeProgress, 1.0);

            switch (properties.direction) {
              case SwipeDirection.right:
                return Opacity(
                  opacity: opacity,
                  child: CardLabel(
                    color: Colors.redAccent,
                    right: true,
                    value: "Hard",
                  ),
                );
              case SwipeDirection.left:
                return Opacity(
                  opacity: opacity,
                  child: CardLabel(
                    color: Colors.teal,
                    right: false,
                    value: "easy",
                  ),
                );
              default:
                return Text("data");
            }
          },
          builder: (context, properties) {
            if (widget.cardWidgets == null || widget.cardWidgets!.isEmpty) {
              return SizedBox();
            }
            final itemIndex = (properties.index) % widget.cardWidgets!.length;
            return Stack(
              children: [Card(child: widget.cardWidgets?[itemIndex])],
            );
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.controller.next(swipeDirection: SwipeDirection.left);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.all(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      Text(
                        "Easy",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.controller.rewind();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.all(20),
                    shadowColor: Colors.blueGrey
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.replay, color: Colors.teal, size: 30),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.controller.next(
                      swipeDirection: SwipeDirection.right,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.all(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.whatshot, color: Colors.white, size: 30),
                      Text(
                        "Hard",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CardLabel extends StatelessWidget {
  final Color color;
  final bool right;
  final String value;
  const CardLabel({
    super.key,
    required this.color,
    required this.right,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: right ? Alignment.topLeft : Alignment.topRight,
      child: Transform.rotate(
        angle: right ? -pi / 8 : pi / 8,
        child: Container(
          margin: EdgeInsets.all(50.0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

//flip card item
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
    final backKey = GlobalKey<BackSideState>();
    return Card(
      elevation: 0.0,
      color: Color.fromARGB(0, 255, 1, 1),
      child: FlipCard(
        front: FrontSide(widget: widget),
        back: BackSide(key: backKey, card: widget.card!, media: widget.media),
        onFlipDone: (isFront) {
          if (isFront) {
            backKey.currentState?.playSound(
              widget.media!,
              widget.card?.sound ?? '',
            );
          }
        },
      ),
    );
  }
}
