import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class QuestDBHelper{
  static Database? _database;
  static final QuestDBHelper _instance=QuestDBHelper._privateConstructor();
  QuestDBHelper._privateConstructor();

  factory QuestDBHelper()
  {
    return _instance;
  }
  // Future<Database> get database async{
  //   if(_database!=null) return _database!;
  //   _database=await _onCreate;
  //   return database;
  // }
  Future<Database> _initDatabase() async{
    String path=join(await getDatabasesPath(),"quest.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  Future<void> _onCreate(Database db, int version)async
  {
    await db.execute('''
  create table quest(
  id integer primary key,
  title text,
  description text,
  target integer,
  currentCount integer
  )
''');
  }
}