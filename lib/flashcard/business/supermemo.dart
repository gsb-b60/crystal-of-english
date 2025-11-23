import 'dart:math';

import 'package:mygame/data/flashcard/database_helper_io_impl.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';

Flashcard updateCardReview(Flashcard card, int feed) {
  double easeChange;
  switch (feed) {
    case 1:
      easeChange = -0.3;
      break; // forgot
    case 2:
      easeChange = -0.15;
      break; // hard
    case 3:
      easeChange = 0.0;
      break; // good
    case 4:
      easeChange = 0.1;
      break; // easy
    case 5:
      easeChange = 0.25;
      break; // very easy
    default:
      easeChange = 0;
      break;
  }

  final random = Random();
  final jitter = 0.95 + random.nextDouble() * 0.1;

  double newEase = (card.easeFactor??1.5 + easeChange - 0.005).clamp(1.3, 2.3);
  int nowLapse = card.lapses??0;
  int nowRep = card.reps??0;
  int newInterval = card.interval==0?1:card.interval!;
  Duration addDue;

  if (feed < 3) {
    nowLapse++;
    nowRep = 0;
    newInterval = (newInterval * 0.5).round().clamp(1, 2);
    addDue = Duration(days: newInterval);
  } else {
    nowRep++;
    newInterval = (newInterval * newEase * jitter).round().clamp(1, 9999);
    addDue = (nowRep) < 3
        ? Duration(minutes: (newInterval) * (nowRep)+5)
        : Duration(days: newInterval);
  }
  return card.copyWith(
    reps: nowRep,
    lapses: nowLapse,
    interval: newInterval,
    easeFactor: newEase,
    lastReview: DateTime.now(),
    due: DateTime.now().add(addDue),
  );
}
class SMNoti {
  static final _db = DatabaseHelper.instance;
   Future<void> updateCardAfterReview(Flashcard card,int rate) async {
    final c= updateCardReview(card, rate);
    _db.updateCard(c);
  }
}
