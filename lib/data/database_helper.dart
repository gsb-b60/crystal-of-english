import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:totoki/business/Deck.dart';
import 'package:totoki/business/Flashcard.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:archive/archive.dart' as archive;
import 'package:flutter_archive/flutter_archive.dart';
//import 'package:flutter_archive/flutter_archive.dart' as flutter_archive;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = await getDatabasesPath();
    String databasePath = join(path, 'learning_card.db');
    return await openDatabase(databasePath, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      create table decks (
        id integer primary key,
        name text not null,
        description text,
        created_at integer,
        updated_at integer,
        media text
      )
''');

    await db.execute('''
      create table cards(
        id integer primary key,
        created_at integer,
        updated_at integer,
        deck_id integer,
        word text,
        meaning text,
        img text,
        sound text,
        defSound text,
        usageSound text,
        example text,
        ipa text,
        meida text,
        interval integer,
        reps integer,
        due integer,
        last_review integer,
        lapses integer,
        ease_factor real,
        foreign key (deck_id) references decks (id) on delete cascade
      )
''');
  }

  Future<int> insertDeck(Deck deck) async {
    final db = await database;
    return await db.insert(
      'decks',
      deck.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Deck>> getDecks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('decks');
    return List.generate(maps.length, (i) {
      return Deck.fromMap(maps[i]);
    });
  }

  Future<void> deleteDeck(int id) async {
    final db = await database;
    await db.delete('decks', where: 'id=?', whereArgs: [id]);
    await db.delete('cards', where: 'deck_id=?', whereArgs: [id]);
  }

  Future<List<Flashcard>> getCardForDeck(int deckId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'deck_id=?',
      whereArgs: [deckId],
    );
    return List.generate(maps.length, (i) {
      return Flashcard.fromMap(maps[i]);
    });
  }

  Future<void> updateCard(Flashcard card) async {
    final db = await database;
    await db.update(
      'cards',
      {
        'due_date': card.due!.toIso8601String(),
        //'review_count': card.reviewCount,
      },
      where: 'id=?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(int cardId) async {
    final db = await database;
    await db.delete('cards', where: 'id=?', whereArgs: [cardId]);
  }

  Future<int> insertCard(Flashcard card) async {
    final db = await database;
    return await db.insert(
      'cards',
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> pickApkgFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apkg'],
    );
    if (result != null) {
      return result.files.single.path;
    } else {
      return null;
    }
  }

  Future<String?> pickAndCopyFile() async {
    final pickedFile = await pickApkgFile();
    if (pickedFile == null) return '';

    final appDir = await getApplicationDocumentsDirectory();
    final savedPath = join(appDir.path, basename(pickedFile));
    await File(pickedFile).copy(savedPath);
    return savedPath; // path writable
  }

  Future<String?> unzipApkgFile(String apkgFilePath) async {
    final file = File(apkgFilePath);
    final bytes = await file.readAsBytes();

    final zipArchive = archive.ZipDecoder().decodeBytes(bytes);

    //temp direc
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;

    //------------------------------
    final outputDir = await CreateUnZipFolder();

    try {
      await ZipFile.extractToDirectory(
        zipFile: file,
        destinationDir: outputDir,
        onExtracting: (zipEntry, progress) {
          print('name: ${zipEntry.name}');
          // print('progress: ${progress.toStringAsFixed(1)}%');
          // print('isDirectory: ${zipEntry.isDirectory}');
          // print('uncompressedSize: ${zipEntry.uncompressedSize}');
          // print('compressedSize: ${zipEntry.compressedSize}');
          // print('compressionMethod: ${zipEntry.compressionMethod}');
          // print('crc: ${zipEntry.crc}');
          return ZipFileOperation.includeItem;
        },
      );
    } catch (e) {
      print(e);
    }

    //------------------------------

    for (final file in zipArchive) {
      if (file.name == 'collection.anki21') {
        final data = file.content as List<int>;
        final dbPath = '$tempPath/collection.anki21';
        final newFile = File(dbPath);
        await newFile.writeAsBytes(data);
        return dbPath;
      }
    }
    return null;
  }

  Future<Directory> CreateDeckFolder() async {
    final outputPath = await getApplicationDocumentsDirectory();
    //thu mucgoc
    final ankiDir = Directory('${outputPath.path}/anki');
    if (!ankiDir.existsSync()) {
      await ankiDir.create(recursive: true);
    }
    final deckDir = 'deck_${DateTime.now().toIso8601String().replaceAll(":", "-")}';
    final outputDir = Directory('${ankiDir.path}/${deckDir}');

    if (!outputDir.existsSync()) {
      try {
        await outputDir.create(recursive: true);
      } catch (e) {
        print(e);
      }
    }
    

    return outputDir;
  }

  Future<Directory> CreateUnZipFolder() async {
    final outputPath = await getApplicationDocumentsDirectory();
    //thu muc goc
    final ankiDir = Directory('${outputPath.path}/anki');
    if (!ankiDir.existsSync()) {
      await ankiDir.create(recursive: true);
    }
    final outputDir = Directory('${ankiDir.path}/unzipAnki');

    if (!outputDir.existsSync()) {
      try {
        await outputDir.create(recursive: true);
      } catch (e) {
        print(e);
      }
    }
    return outputDir;
  }

  Future<void> importDataFromAnki(String ankiDbPath) async {
    //open path
    final ankiDb = await openDatabase(ankiDbPath);
    //test create a card

    //test get a deck
    final jsonDeck = await ankiDb.rawQuery(' select decks from col c ');
    final String deckString = jsonDeck.first['decks'] as String;

    final Map<String, dynamic> deckMap =
        jsonDecode(deckString) as Map<String, dynamic>;

    final folderName=await MoveMediaFile();

    for (final deck in deckMap.entries) {
      {
        final deckId = int.parse(deck.key);
        if (deckId == 1) continue;
        final deckName = deck.value['name'] as String;
        //insert deck to my db
        //comment to debug
        Deck newDeck = Deck(name: deckName,media: folderName);
        final int myDeckId = await insertDeck(newDeck);
        await processCardForDeck(ankiDb, deckId, myDeckId);
      }
    }
    await ankiDb.close();
  }

  Future<void> processCardForDeck(
    Database ankiDb,
    int ankiDeckId,
    int deckId,
  ) async {
    final imgRegex = RegExp(r'<img\s+src="([^"]+)"');
    final soundRegex = RegExp(r'\[sound:([^\]]+)\]');
    final tagRegex = RegExp(r'<[^>]+>');

    final cards = await ankiDb.rawQuery(
      '''
        select n.flds ,n.id,c.id,c.did 
        from notes n 
        join cards c 
        on c.nid =n.id 
        where c.did=?
''',
      [ankiDeckId],
    );

    for (final row in cards) {
      final flds = row['flds'] as String;
      final List<String> fields = flds.split('\x1f');
      final imagePath=imgRegex.firstMatch(fields[1])?.group(1);
      final defSoundPath=soundRegex.firstMatch(fields[3])?.group(1);
      final usageSoundPath=soundRegex.firstMatch(fields[4])?.group(1);
      final soundPath=soundRegex.firstMatch(fields[2])?.group(1);
      if (fields.length == 8) {
        Flashcard newCard = Flashcard(
          deckId: deckId,
          word: fields[0].replaceAll(tagRegex, ''),
          meaning: fields[5],
          example: fields[6],
          ipa: fields[7].replaceAll(tagRegex, ""),
          due: DateTime.now(),
          defSound: defSoundPath,
          usageSound: usageSoundPath,
          img: imagePath,
          sound: soundPath,
        );
        insertCard(newCard);
      }
    }
  }

  Future<String> MoveMediaFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final mediaFile = File('${dir.path}/anki/unzipAnki/media');
    if (!mediaFile.existsSync()) {
      throw Exception("Khong tim thay media trong unzip");
    }

    final mediaJsonStr = await mediaFile.readAsString();
    final Map<String, dynamic> mediaMapRaw = jsonDecode(mediaJsonStr);

    // Convert sang Map<String, String>
    final mediaMap = mediaMapRaw.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    final outputDir = await CreateUnZipFolder();
    Directory deckDir = await CreateDeckFolder();
    try {
      
      for (final entry in mediaMap.entries) {
        final oldFile = File('${dir.path}/anki/unzipAnki/${entry.key}');
        if (oldFile.existsSync()) {
          final newFile = File('${deckDir.path}/${entry.value}');
          await oldFile.copy(newFile.path);
        } else {
          print('cant find ${oldFile.path}');
        }
      }

      //delete unzip
      try {
        await outputDir.delete(recursive: true);
        print("clean unzip ${outputDir.path}");
      } catch (e) {
        print("delete bug $e");
      }
    } catch (e) {
      print('import bug $e');
    }
    final folderName=basename(deckDir.path);
    return folderName;
  }
  Future<String?> getMediaFile(int deckID) async{
    final db= await database;
    final result =await db.rawQuery('''
      select media
      from decks
      where id=?
''',[deckID]);
  print(result);
    if(result.isNotEmpty){
      return result.first['media'] as String?;
    }
    return null;
  } 
}
