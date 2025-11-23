class ThresholdAcc {
  static const int excellent = 1;
  static const int great = 2;
  static const int good = 4;
  static const int fair = 6;
  static const String exStr = "PERFECT";
  static const String greatStr = "GREAT";
  static const String okStr = "GOOD";
  static const String fairStr = "FAIR";
}

class ThresholdTime {
  static const Duration Super = Duration(seconds: 90);
  static const Duration Quick = Duration(seconds: 180);
  static const Duration Moderate = Duration(seconds: 280);
  static const Duration slow = Duration(seconds: 380);

  static const String SuperStr = "SUPER";
  static const String QuickStr = "QUICK";
  static const String ModerateStr = "MODERATE";
  static const String SlowStr = "SLOW";
}
