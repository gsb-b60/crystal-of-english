import 'package:mygame/data/user/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._privateConstructor();
  static Database? _database;

  UserDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      level INTEGER NOT NULL,
      streak INTEGER NOT NULL,
      lastLoginDate TEXT,
      goal INTEGER,
      studiSecond integer,
      TotalLess integer,
      TotalCard integer,
      Rep integer,
      Lapse integer,
      IndayLess integer,
      IndayCard integer,
      IndayRep integer,
      QuestPoint integer,
      IsRepClaim bool,
      IsLessClaim bool,
      IsLearnClaim bool
    )
    ''');
  }

  //update
  Future<void> UpdateLogDaySuper() async {
    User u = await getUser(1);
    print("yes i do");
    DateTime now = DateTime.now();
    if (!(u.lastLoginDate!.day == now.day &&
        u.lastLoginDate!.month == now.month &&
        u.lastLoginDate!.year == now.year)) {
      u.lastLoginDate = now;
      u.IndayCard = 0;
      u.IndayLess = 0;
      u.IndayRep=0;
      u.Lapse = 0;
      u.Rep = 0;
      u.IsRepClaim = false;
      u.IsLessClaim = false;
      u.IsLearnClaim = false;
      u.studiSecond = Duration(seconds: 0);
      await update(u);
    }
  }

  Future<void> UpdateQuestPoint() async {
    User u = await getUser(1);
    u.QuestPoint =(u.QuestPoint??0)+1;
    print(u);
    print("add quest point");
    await update(u);
  }

  Future<void> UpdateClaimLess() async {
    User u = await getUser(1);
    u.IsLessClaim = true;
    print(u);
    print("less claim");
    await update(u);
  }

  Future<void> UpdateClaimLearn() async {
    User u = await getUser(1);
    u.IsLearnClaim = true;
    await update(u);
  }

  Future<void> UpdateClaimRep() async {
    User u = await getUser(1);
    u.IsRepClaim = true;
    await update(u);
  }

  Future<void> UpdateLess() async {
    User u = await getUser(1);
    u.TotalLess = (u.TotalLess ?? 0) + 1;
    u.IndayLess = (u.IndayLess ?? 0) + 1;
    await update(u);
  }

  Future<void> UpdateRep(int rep) async {
    User u = await getUser(1);
    u.Rep = (u.Rep ?? 0) + rep;
    await update(u);
  }

  Future<void> UpdateLapse(int lapse) async {
    User u = await getUser(1);
    u.Lapse = (u.Lapse ?? 0) + lapse;
    await update(u);
  }

  Future<void> UpdateNoCard(int cq) async {
    User u = await getUser(1);
    u.IndayCard = (u.IndayCard ?? 0) + cq;
    u.TotalCard = (u.TotalCard ?? 0) + cq;
    await update(u);
  }

  Future<void> UpdateLogDay() async {
    final db = await UserDatabase.instance.database;
    await db.update(
      'users',
      {'lastLoginDate': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> UpdateTime(Duration studyTime) async {
    final db = await UserDatabase.instance.database;
    await db.update(
      'users',
      {'studiSecond': studyTime.inSeconds},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> UpdateStreak(int streak) async {
    final db = await UserDatabase.instance.database;

    await db.update(
      'users',
      {'streak': streak},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> UpdateGoal(int newGoal) async {
    final db = await UserDatabase.instance.database;
    await db.update(
      'users',
      {'goal': newGoal},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  //add -create
  Future<int> create(User user) async {
    final db = await UserDatabase.instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<List<User>> readAllUsers() async {
    final db = await UserDatabase.instance.database;
    final result = await db.query('users');
    return result.map((e) => User.fromMap(e)).toList();
  }

  Future<int> update(User user) async {
    final db = await UserDatabase.instance.database;
    print("in update ${user}");
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await UserDatabase.instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<User> getUser(int id) async {
    
    final db = await UserDatabase.instance.database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    } else {
      print("no user");
      final defaultUser = User(
        id: id,
        name: "Dinh Hieu",
        level: 1,
        streak: 5,
        goal: 15,
        lastLoginDate: DateTime.now(),
        TotalLess: 0,
        TotalCard: 0,
        Rep: 0,
        Lapse: 0,
        IndayLess: 0,
        IndayCard: 0,
        QuestPoint: 0,
        studiSecond: Duration(seconds: 0),
      );
      try {
        await db.insert('users', defaultUser.toMap());
      } catch (e) {
        print("Error creating default user: $e");
      }
      return defaultUser;
    }
  }

  Future<void> updateStreak() async {
    final db = await UserDatabase.instance.database;
    final now = DateTime.now();
    final user = await getUser(1);
    final lastLogin = user.lastLoginDate;
    int newStreak = user.streak;
    if (lastLogin != null) {
      final difference = now.difference(lastLogin).inDays;
      if (difference == 0) {
        return;
      } else if (difference == 1) {
        newStreak += 1;
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }
    final updatedUser = User(
      id: user.id,
      name: user.name,
      level: user.level,
      streak: newStreak,
      lastLoginDate: now,
      goal: user.goal,
    );
    await db.update(
      'users',
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
