import 'package:flutter/material.dart';
import 'package:mygame/components/Menu/Theme/color.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';
import 'package:mygame/flashcard/screen/blankfill/blankwordscreen.dart';
import 'package:mygame/flashcard/screen/studymode/echofuse/echofuse.dart';
import 'package:mygame/flashcard/screen/studymode/echomatch/echomath.dart';
import 'package:mygame/flashcard/screen/studymode/echospell/echospell.dart';
import 'package:mygame/flashcard/screen/studymode/flashcard/newwayreview.dart';
import 'package:mygame/flashcard/screen/studymode/mindfield/mindfeild.dart';
import 'package:mygame/flashcard/screen/studymode/neuropick/neuropick.dart';
import 'package:mygame/flashcard/screen/studymode/phonemix/phonemix.dart';
import 'package:mygame/flashcard/screen/studymode/sound&sight/sound&sight.dart';
import 'package:mygame/flashcard/screen/studymode/speechword/speechword.dart';
import 'package:mygame/flashcard/screen/studymode/synonymfield/synonymfield.dart';
import 'package:mygame/flashcard/screen/studymode/synonympick/synonympick.dart';
import 'package:mygame/flashcard/screen/studymode/wordpulse/wordpulse.dart';
import 'package:mygame/flashcard/screen/studymode/wordsnap/wordsnap.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:mygame/state/player_profile.dart';

final AudioPlayer audio = AudioPlayer();

class CardListScreen extends StatefulWidget {
  final int? deckId;
  final String? deckName;
  const CardListScreen({
    super.key,
    required this.deckId,
    required this.deckName,
  });

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  bool menu = false;
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
    super.dispose();
  }

  Widget _NavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LearnMode(deckID: widget.deckId!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardModel = Provider.of<Cardmodel>(context);

    if (widget.deckId != null && cardModel.card.isNotEmpty) {
      final complexities = cardModel.card
          .map((c) => c.complexity ?? 1)
          .toList();
      if (complexities.isNotEmpty) {
        final avg = (complexities.reduce((a, b) => a + b) / complexities.length)
            .round();

        Future.microtask(
          () => PlayerProfile.instance.setPreferredDeckLevel(avg),
        );
      }
    }
    final List<Widget> cardWidgets = cardModel.card.map((card) {
      return FlashCardItem(card: card, media: cardModel.media);
    }).toList();
    return Scaffold(
      backgroundColor: AppColor.darkSurface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: AppColor.lightText),
        ),
        title: Text(
          widget.deckName ?? "My Deck",
          style: TextStyle(color: AppColor.lightText, fontSize: 27),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                menu = !menu;
              });
            },
            icon: Icon(Icons.menu, color: AppColor.greenPrimary),
          ),
        ],
        backgroundColor: AppColor.darkSurface,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cardWidgets.length,
                  itemBuilder: (context, index) {
                    return cardWidgets[index];
                  },
                ),
              ),
              //_NavBar(context),
            ],
          ),
          if (menu)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 300,
                height: double.infinity,
                color: AppColor.darkSurface,
                child: LearnMode(deckID: widget.deckId!),
              ),
            ),
        ],
      ),
    );
  }
}

class LearnMode extends StatelessWidget {
  const LearnMode({super.key, required this.deckID});

  final int deckID;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NavPageBtn(
            label: "review",
            screenBuilder: () => Newwayreview(deckId: deckID),
          ),
          NavPageBtn(
            label: "blank word",
            screenBuilder: () => BlankWordScreen(deck_id: deckID),
          ),
          NavPageBtn(
            label: "Mind Field",
            screenBuilder: () => MindFeild(deckID: deckID),
          ),
          NavPageBtn(
            label: "Word Snap",
            screenBuilder: () => WordSnap(deck_id: deckID),
          ),
          NavPageBtn(
            label: "Phoneme Mix",
            screenBuilder: () => PhoneMix(deckID: deckID),
          ),
          NavPageBtn(
            label: "Synonym Feild",
            screenBuilder: () => Synonymfield(deckID: deckID),
          ),
          NavPageBtn(
            label: "Echo Spell",
            screenBuilder: () => Echospell(deck_id: deckID),
          ),
          NavPageBtn(
            label: "Echo Match",
            screenBuilder: () => EchoMatch(deck_id: deckID),
          ),
          NavPageBtn(
            label: "Echo Fuse",
            screenBuilder: () => EchoFuse(deck_id: deckID),
          ),
          NavPageBtn(
            label: "Sound - Sight",
            screenBuilder: () => SoundNSight(deck_id: deckID),
          ),
          NavPageBtn(
            label: "Neuro Pick",
            screenBuilder: () => NeuroPick(deckID: deckID),
          ),

          NavPageBtn(
            label: "Word Pulse",
            screenBuilder: () => WordPulse(deck_id: deckID),
          ),
          NavPageBtn(
            label: "Synonym Pick",
            screenBuilder: () => Synonympick(deckID: deckID),
          ),
          NavPageBtn(
            label: "Speech Word",
            screenBuilder: () => Speechword(deck_id: deckID),
          ),
        ],
      ),
    );
  }
}

class NavPageBtn extends StatelessWidget {
  final String label;
  final Widget Function() screenBuilder;

  const NavPageBtn({
    super.key,
    required this.label,
    required this.screenBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final cardModel = Provider.of<Cardmodel>(context, listen: false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<Cardmodel>.value(
              value: cardModel,
              child: screenBuilder(),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(),
        child: Text(
          label,
          style: TextStyle(
            color: AppColor.lightText,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
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
    final String? dir = (media != null && media!.isNotEmpty)
        ? '/data/user/0/com.example.mygame/app_flutter/anki/${media!}'
        : null;
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColor.darkerCard,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                IPAandWord(card: card),
                SoundTitle(
                  title: "sound",
                  value: (dir != null && card.sound != null)
                      ? '$dir/${card.sound}'
                      : '',
                  icon: const Icon(Icons.volume_up),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [CardInformation(card: card, dir: dir)],
                ),
                SizedBox(width: 20,),
                PictureHolder(
                  w: 350,
                  h: 210,
                  path: (dir != null && card.img != null)
                      ? '$dir/${card.img}'
                      : null,
                ),
              ],
            ),
            SizedBox(height: 20,),
            PictureHolder(
              w: 760,
              h: 200,
              path: (dir != null && card.synonyms != null)
                  ? '$dir/${card.synonyms}'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class IPAandWord extends StatelessWidget {
  const IPAandWord({super.key, required this.card});

  final Flashcard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.word ?? '',
            style: const TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.bold,
              color: AppColor.lightText,
            ),
            overflow: TextOverflow.fade,
          ),
          if (card.ipa != null)
            Text(
              "/${card.ipa!}/",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                overflow: TextOverflow.ellipsis,
                color: AppColor.lightText,
                fontFamily: "roboto",
              ),
            ),
        ],
      ),
    );
  }
}

class CardInformation extends StatelessWidget {
  const CardInformation({super.key, required this.card, required this.dir});

  final Flashcard card;
  final String? dir;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                TitleAndValue(title: "Meaning", value: card.meaning ?? ''),
                TitleAndValue(title: "Example", value: card.example ?? ''),
                TitleAndValue(title: "Image", value: card.img ?? ''),
                TitleAndValue(title: "Sound", value: card.sound ?? ''),
                TitleAndValue(
                  title: "Definition Sound",
                  value: card.defSound ?? '',
                ),
                TitleAndValue(
                  title: "Usage Sound",
                  value: card.usageSound ?? '',
                ),
                if (card.due != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      'Due: ${DateFormat('MM/dd').format(card.due!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.pinkPrimary,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChipTitle(
                      title: "Interval",
                      value: card.interval.toString(),
                      color: AppColor.greenDeep,
                    ),
                    ChipTitle(
                      title: "Reps",
                      value: card.reps.toString(),
                      color: AppColor.greenDeep,
                    ),
                    Complexity(card: card),
                  ],
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SoundTitle(
                title: "u sound",
                value: (dir != null && card.usageSound != null)
                    ? '$dir/${card.usageSound}'
                    : '',
                icon: const Icon(Icons.volume_up),
              ),
              SoundTitle(
                title: "def sound",
                value: (dir != null && card.defSound != null)
                    ? '$dir/${card.defSound}'
                    : '',
                icon: const Icon(Icons.volume_up),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PictureHolder extends StatelessWidget {
  final String? path;
  final double w;
  final double h;
  const PictureHolder({
    super.key,
    required this.path,
    required this.w,
    required this.h,
  });

  @override
  Widget build(BuildContext context) {
    if (path != null) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(path!), fit: BoxFit.fitWidth),
        ),
      );
    } else {
      return Text("synonyms");
    }
  }
}

class SoundTitle extends StatelessWidget {
  final String title;
  final String value;
  final Icon icon;
  const SoundTitle({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (value != '' || value.isNotEmpty) {
      return Column(
        children: [
          IconButton(
            icon: icon,
            onPressed: () async {
              await audio.play(DeviceFileSource(value));
            },
            color: AppColor.lightText,
          ),
          Text(title, style: TextStyle(color: AppColor.lightText)),
        ],
      );
    } else {
      return SizedBox();
    }
  }
}

class ChipTitle extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const ChipTitle({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        '$title: $value',
        style: TextStyle(
          color: AppColor.lightText,
          fontWeight: FontWeight.bold,
        ),
      ),
      side: BorderSide(color: AppColor.darkBorder),
      backgroundColor: color,
    );
  }
}

class TitleAndValue extends StatelessWidget {
  final String title;
  final String value;

  const TitleAndValue({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value != '') {
      return Container(
        width: 400,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$title: ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(fontSize: 15, color: AppColor.lightText),
              ),
            ],
          ),
        ),
      );
    } else {
      return SizedBox();
    }
  }
}

class Complexity extends StatelessWidget {
  const Complexity({super.key, required this.card});

  final Flashcard card;
  Color _getChipColor(int complexity) {
    if (complexity == 1) {
      return const Color.fromARGB(255, 0, 168, 6);
    } else if (complexity == 2) {
      return const Color.fromARGB(255, 0, 97, 73);
    } else if (complexity == 3) {
      return const Color.fromARGB(255, 0, 59, 94);
    } else if (complexity == 4) {
      return const Color.fromARGB(255, 141, 3, 106);
    } else if (complexity == 5) {
      return const Color.fromARGB(255, 138, 3, 16);
    } else {
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
