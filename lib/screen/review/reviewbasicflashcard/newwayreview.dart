import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:totoki/business/Flashcard.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flip_card/flip_card.dart';
import 'front.dart';
import "back.dart";

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
        builder: (context, snapshot) => Center(
          child: SizedBox(
            width: 370,
            height: 700,
            child: Swipeder(controller: controller, cardWidgets: cardWidgets),
          ),
        ),
      ),
    );
  }
}

//chaange this to swipable stack
class Swipeder extends StatelessWidget {
  const Swipeder({
    super.key,
    required this.controller,
    required this.cardWidgets,
  });

  final SwipableStackController controller;
  final List<Widget>? cardWidgets;

  @override
  Widget build(BuildContext context) {
    return SwipableStack(
      controller: controller,
      detectableSwipeDirections: const {
        SwipeDirection.right,
        SwipeDirection.left,
      },
      onSwipeCompleted: (index, direction) {},
      builder: (context, properties) {
        if (cardWidgets == null || cardWidgets!.isEmpty) {
          return SizedBox();
        }
        final itemIndex = (properties.index) % cardWidgets!.length;
        return Card(child: cardWidgets?[itemIndex]);
      },
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
