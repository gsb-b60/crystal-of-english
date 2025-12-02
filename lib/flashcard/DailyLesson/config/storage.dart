import 'package:mygame/flashcard/DailyLesson/config/threshold.dart';
import 'package:mygame/flashcard/business/Flashcard.dart';

enum StudyMode {
  meanfuse, //meaning - fuse
  wordsnap, //meaning - other letters
  mindField, //meaning - shuffle word

  echoSpell, //ipa+sound - fuse,
  echoMatch, //ipa+sound - shuffle word
  echofuse, //ipa+sound - other letters

  neuropick, //picture - fuse
  wordpulse, //picture - shuffle word
  soundAndSight, //picture - arrange letters

  synonympick, // synonym - shuffle word
  synonymfeild, // synonym - other word

  speechword, //speak with word and ipa

  phonemix, //4 ipa
  reviewcard,

  EndScreen,
  StartScreen,
}

enum FetchMode { SM2, testing }

class WordIPA {
  final String word;
  final String ipa;
  WordIPA({required this.word, required this.ipa});
}

enum LearnMode { daily, all, sm, shuffle }

class lessonNotiHelper {
  static String getAccLine(int acc) {
    if (acc <= ThresholdAcc.excellent) {
      return ThresholdAcc.exStr;
    } else if (acc <= ThresholdAcc.great) {
      return ThresholdAcc.greatStr;
    } else if (acc <= ThresholdAcc.good) {
      return ThresholdAcc.okStr;
    } else if (acc <= ThresholdAcc.fair) {
      return ThresholdAcc.fairStr;
    } else {
      return "POOR"; // optional: điểm quá thấp
    }
  }

  static List<String> genOptionsShuffleHelp(
    List<Flashcard> _cards,
    int cardIdx,
  ) {
    List<String> re = [];
    final answer = _cards[cardIdx].word!;

    final otherCards = _cards.where((c) => c.word != answer).toList()
      ..shuffle();

    re = [answer];
    re.addAll(otherCards.take(3 - 1).map((c) => c.word!));

    re.shuffle();

    return re;
  }

  static List<Map<String, dynamic>> createListForLevel(int count, StudyMode st) {
    return List.generate(count, (i) => {"cIdx": i, "mode": st});
  }

  List<Map<String, dynamic>> SetUpLessonList = [
    {"cIdx": 0, "mode": StudyMode.phonemix},
    {"cIdx": 0, "mode": StudyMode.meanfuse},
    {"cIdx": 0, "mode": StudyMode.mindField},
    {"cIdx": 0, "mode": StudyMode.wordsnap},
    {"cIdx": 1, "mode": StudyMode.echoSpell},
    {"cIdx": 1, "mode": StudyMode.echofuse},
    {"cIdx": 1, "mode": StudyMode.echoMatch},
    {"cIdx": 2, "mode": StudyMode.soundAndSight},
    {"cIdx": 2, "mode": StudyMode.neuropick},
    {"cIdx": 2, "mode": StudyMode.wordpulse},
    {"cIdx": 3, "mode": StudyMode.wordsnap},
    {"cIdx": 3, "mode": StudyMode.echoMatch},
    {"cIdx": 3, "mode": StudyMode.meanfuse},
    {"cIdx": 4, "mode": StudyMode.phonemix},
    {"cIdx": 4, "mode": StudyMode.EndScreen},
  ];
  static List<Map<String, dynamic>> allMode = [
    {"cIdx": 0, "mode": StudyMode.StartScreen},

    {"cIdx": 0, "mode": StudyMode.meanfuse},
    {"cIdx": 1, "mode": StudyMode.wordsnap},
    {"cIdx": 2, "mode": StudyMode.mindField},

    {"cIdx": 3, "mode": StudyMode.echoSpell},
    {"cIdx": 4, "mode": StudyMode.echofuse},
    {"cIdx": 5, "mode": StudyMode.echoMatch},

    {"cIdx": 6, "mode": StudyMode.soundAndSight},
    {"cIdx": 7, "mode": StudyMode.neuropick},
    {"cIdx": 8, "mode": StudyMode.wordpulse},

    {"cIdx": 9, "mode": StudyMode.speechword},
    {"cIdx": 10, "mode": StudyMode.speechword},
    {"cIdx": 11, "mode": StudyMode.speechword},

    {"cIdx": 12, "mode": StudyMode.synonympick},
    {"cIdx": 13, "mode": StudyMode.synonympick},
    {"cIdx": 14, "mode": StudyMode.synonymfeild},

    {"cIdx": 14, "mode": StudyMode.phonemix},

    {"cIdx": 4, "mode": StudyMode.reviewcard},

    {"cIdx": 4, "mode": StudyMode.EndScreen},
  ];
  static List<Map<String, dynamic>> sm2 = [
    {"cIdx": 0, "mode": StudyMode.StartScreen},

    {"cIdx": 0, "mode": StudyMode.meanfuse},
    {"cIdx": 1, "mode": StudyMode.wordsnap},
    {"cIdx": 2, "mode": StudyMode.mindField},
    {"cIdx": 4, "mode": StudyMode.wordsnap},
    {"cIdx": 3, "mode": StudyMode.mindField},

    {"cIdx": 3, "mode": StudyMode.echoMatch},
    {"cIdx": 1, "mode": StudyMode.echoSpell},
    {"cIdx": 2, "mode": StudyMode.echofuse},
    {"cIdx": 0, "mode": StudyMode.echoMatch},
    {"cIdx": 4, "mode": StudyMode.echofuse},

    {"cIdx": 2, "mode": StudyMode.soundAndSight},
    {"cIdx": 4, "mode": StudyMode.wordpulse},
    {"cIdx": 1, "mode": StudyMode.neuropick},
    {"cIdx": 0, "mode": StudyMode.wordpulse},
    {"cIdx": 3, "mode": StudyMode.soundAndSight},

    {"cIdx": 0, "mode": StudyMode.speechword},
    {"cIdx": 1, "mode": StudyMode.speechword},
    {"cIdx": 2, "mode": StudyMode.speechword},
    {"cIdx": 3, "mode": StudyMode.speechword},
    {"cIdx": 4, "mode": StudyMode.speechword},

    {"cIdx": 1, "mode": StudyMode.synonympick},
    {"cIdx": 3, "mode": StudyMode.synonympick},
    {"cIdx": 0, "mode": StudyMode.synonympick},
    {"cIdx": 4, "mode": StudyMode.synonympick},
    {"cIdx": 2, "mode": StudyMode.synonymfeild},

    {"cIdx": 4, "mode": StudyMode.phonemix},
    {"cIdx": 4, "mode": StudyMode.phonemix},

    {"cIdx": 4, "mode": StudyMode.reviewcard},

    {"cIdx": 4, "mode": StudyMode.EndScreen},
  ];
}
