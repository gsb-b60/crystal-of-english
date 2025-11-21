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
      studiSecond integer
    )
    ''');
  }


  //update
  Future<void> UpdateLogDay() async {
    final db = await database;
    await db.update(
      'users',
      {'lastLoginDate': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
  Future<void> UpdateTime(Duration studyTime) async {
    final db = await database;
    await db.update(
      'users',
      {'studiSecond': studyTime.inSeconds},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
  Future<void> UpdateStreak(int streak) async {
    final db = await database;
    
    await db.update(
      'users',
      {'streak': streak},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
  

  Future<void> UpdateGoal(int newGoal) async {
    final db = await instance.database;
    await db.update(
      'users',
      {'goal': newGoal},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  //add -create
  Future<int> create(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }



  
  Future<List<User>> readAllUsers() async {
    final db = await instance.database;
    final result = await db.query('users');
    return result.map((e) => User.fromMap(e)).toList();
  }

  Future<int> update(User user) async {
    final db = await instance.database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<User> getUser(int id) async {
    final db = await instance.database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    } else {
      final defaultUser = User(
        id: id,
        name: "Dinh Hieu",
        level: 1,
        streak: 5,
        goal: 15,
        lastLoginDate: DateTime.now(),
      );
      try
      {
        await db.insert('users', defaultUser.toMap());
      }
      catch(e)
      {
        print("Error creating default user: $e");
      }
      return defaultUser;
    }
  }

  Future<void> updateStreak() async {
    final db = await instance.database;
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
