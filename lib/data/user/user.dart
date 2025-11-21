class User {
  int? id;
  String name;
  int level;
  int streak;
  DateTime? lastLoginDate;
  int goal;
  Duration? studiSecond;
  User({
    this.id,
    required this.name,
    required this.level,
    required this.streak,
    required this.lastLoginDate,
    required this.goal,
    this.studiSecond,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'streak': streak,
      'studiSecond': studiSecond,
      "lastLoginDate":
          lastLoginDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
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
    );
  }
}
