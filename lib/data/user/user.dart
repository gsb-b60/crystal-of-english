class User {
  int? id;
  String name;
  int level;
  int streak;
  DateTime? lastLoginDate;
  int goal;
  Duration? studiSecond;
  int? TotalLess;
  int? TotalCard;
  int? Rep;
  int? Lapse;
  int? IndayLess;
  int? IndayCard;
  int? IndayRep;
  int? QuestPoint;
  bool? IsRepClaim;
  bool? IsLessClaim;
  bool? IsLearnClaim;
  User({
    this.id,
    required this.name,
    required this.level,
    required this.streak,
    required this.lastLoginDate,
    required this.goal,
    this.studiSecond,
    this.TotalLess,
    this.TotalCard,
    this.Rep,
    this.Lapse,
    this.IndayLess,
    this.IndayRep,
    this.IndayCard,
    this.QuestPoint,
    this.IsRepClaim,
    this.IsLessClaim,
    this.IsLearnClaim,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'streak': streak,
      'studiSecond': studiSecond?.inSeconds ?? 0,
      "lastLoginDate":
          lastLoginDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'TotalLess': TotalLess,
      'TotalCard': TotalCard,
      'Rep': Rep,
      'Lapse': Lapse,
      'IndayLess': IndayLess,
      'IndayCard': IndayCard,
      'IndayRep': IndayRep,
      'QuestPoint': QuestPoint,
      'IsRepClaim': (IsRepClaim ?? false) ? 1 : 0,
      'IsLessClaim': (IsLessClaim ?? false) ? 1 : 0,
      'IsLearnClaim': (IsLearnClaim ?? false) ? 1 : 0,
    };
  }

  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      level: map['level'],
      streak: map['streak'],
      lastLoginDate: map['lastLoginDate'] != null
          ? DateTime.parse(map['lastLoginDate'])
          : DateTime.now(),
      goal: map['goal'] ?? 10,
      studiSecond: Duration(seconds: map['studiSecond'] ?? 0),
      TotalLess: map['TotalLess'] ?? 0,
      TotalCard: map['TotalCard'] ?? 0,
      Rep: map['Rep'] ?? 0,
      Lapse: map['Lapse'] ?? 0,
      IndayLess: map['IndayLess'] ?? 0,
      IndayCard: map['IndayCard'] ?? 0,
      IndayRep: map['IndayRep'] ?? 0,
      QuestPoint: map['QuestPoint'] ?? 0,
      IsRepClaim: map['IsRepClaim'] == 1,
      IsLessClaim: map['IsLessClaim'] == 1,
      IsLearnClaim: map['IsLearnClaim'] == 1,
    );
  }

  @override
  String toString() {
    return '''
User(
  id: $id,
  name: $name,
  level: $level,
  streak: $streak,
  lastLoginDate: ${lastLoginDate?.toIso8601String()},
  goal: $goal,
  studiSecond: ${studiSecond?.inSeconds},
  totalLess: $TotalLess,
  totalCard: $TotalCard,
  rep: $Rep,
  lapse: $Lapse,
  inDayLess: $IndayLess,
  inDayCard: $IndayCard,
  QuestPoint:$QuestPoint,
IsRepClaim:$IsRepClaim,
IsLessClaim:$IsLessClaim,
  IsLearnClaim:$IsLearnClaim,
)''';
  }
}
