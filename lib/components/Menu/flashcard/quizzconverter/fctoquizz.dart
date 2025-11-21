import 'dart:io';

import 'package:mygame/components/Menu/flashcard/business/Flashcard.dart';
import 'package:mygame/components/Menu/flashcard/data/database_helper_io_impl.dart';

class FlachCardCToQuizz {
  static final DatabaseHelper _dbhelper = DatabaseHelper.instance;
  List<Flashcard> _cards = [];
  Map<int, String> mediaMap = {};

  Future<void> fetchCards(int take) async {
    final data = await _dbhelper.getAllCard();
    _cards.clear();
    _cards.addAll(data);
    _cards = _cards
        .where(
          (c) =>
              c.word != null &&
              c.img != null &&
              c.meaning != null &&
              c.sound != null &&
              !(c.word?.contains(" ") ?? true),
        )
        .take(take)
        .toList();
  }

  Future<Map<String, dynamic>> GetJsonFormat(int take, topic) async {
    await fetchCards(take);

    final questions = await GenQuestions();

    return {"topic": topic ?? "no topic", "questions": questions};
  }

  List<String> genOptions(Flashcard card) {
    List<String> oplist = [];
    String answer = card.word ?? "";
    final otherCards = _cards.where((c) => c.word != answer).toList()
      ..shuffle();

    oplist = [answer];
    oplist.addAll(otherCards.take(3).map((c) => c.word!));
    oplist.shuffle();
    return oplist;
  }

  Future<List<Map<String, dynamic>>> GenQuestions() async {
    List<Map<String, dynamic>> result = [];

    for (final card in _cards) {
      final opts = genOptions(card);
      final ans = card.word ?? "";
      final correctIdx = opts.indexOf(ans);

      result.add({
        "id": "${card.id}_text",
        "type": "text",
        "prompt": card.meaning,
        "options": opts,
        "correctIndex": correctIdx,
      });
      final media = await fetchMedia(card);
      final basePath =
          "/data/user/0/com.example.mygame/app_flutter/anki/$media";

      final soundPath = "$basePath/${card.sound}";
      final imagePath = "$basePath/${card.img}";
      result.add({
        "id": "${card.id}_sound",
        "type": "sound",
        "prompt": "What is this?",
        "options": opts,
        "correctIndex": correctIdx,
        "sound": File(soundPath).existsSync() ? soundPath : "",
      });
      result.add({
        "id": "${card.id}_image_sound",
        "type": "image_sound",
        "prompt": "What is this?",
        "options": opts,
        "correctIndex": correctIdx,
        "image": File(imagePath).existsSync() ? imagePath : "",
        "sound": File(soundPath).existsSync() ? soundPath : "",
      });
    }

    return result;
  }

  Future<String> fetchMedia(Flashcard card) async {
    int deck_id = card.deckId;
    if (mediaMap.containsKey(deck_id)) {
      return mediaMap[deck_id]!;
    } else {
      String md = await _dbhelper.getMediaFile(deck_id) ?? "";
      mediaMap[deck_id] = md;
      return md;
    }
  }
}

void testJson() async {
  final mapper = FlachCardCToQuizz();
  final json = await mapper.GetJsonFormat(5, "demo");
  print(json);
}
