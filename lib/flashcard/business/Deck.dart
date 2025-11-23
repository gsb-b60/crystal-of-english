import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:mygame/data/flashcard/database_helper.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Deck {
  final int? id;
  final String name;
  final String? description;
  DateTime? createdAt;
  DateTime? updatedAt;
  final String? media;

  Deck({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.media,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'media': media,
    };
  }

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
      media: map["media"] as String?,
    );
  }
}

class Deckmodel with ChangeNotifier {
  static final _dbhelper = DatabaseHelper.instance;

  final List<Deck> _decks = [];
  List<Deck> get deck => _decks;
  Future<void> fetchDecks() async {
    final data = await _dbhelper.getDecks();
    _decks.clear();
    _decks.addAll(data);
    notifyListeners();
  }

  Future<void> insertDeck(String name, {String? description}) async {
    Deck addDeck = Deck(name: name, description: description);
    int newId = await _dbhelper.insertDeck(addDeck);
    Deck newDeck = Deck(id: newId, name: name, description: description);
    _decks.add(newDeck);
    await fetchDecks();
  }

  Future<void> deleteDeck(int id) async {
    await _dbhelper.deleteDeck(id);
    _decks.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  Future<void> filePicker() async {
    final filePath = await _dbhelper.pickAndCopyFile();
    if (filePath == null || filePath.isEmpty) {
      try {
        await (DatabaseHelper.instance as dynamic).importFromAssetApkg(
          'assets/anki-deck/IELTS - Advanced__Unit 02 - Time for a change.apkg',
        );
      } catch (_) {
        return;
      }
    } else {
      final ankiDbPath = await _dbhelper.unzipApkgFile(filePath);
      if (ankiDbPath == null || ankiDbPath.isEmpty) {
        return;
      }
      await _dbhelper.importDataFromAnki(ankiDbPath);
    }
    await fetchDecks();
  }

  Future<String?> getMediaFile(int id) async {
    final String? result = await _dbhelper.getMediaFile(id);
    return result;
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

    if (pickedFile == null || pickedFile.isEmpty) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final savedPath = join(appDir.path, basename(pickedFile));
    await File(pickedFile).copy(savedPath);
    return savedPath;
  }

  Future<void> filePickerReal() async {
    final filePath = await pickAndCopyFile();
    final ankiDbPath = await _dbhelper.unzipApkgFile(filePath!);
    await _dbhelper.importDataFromAnki(ankiDbPath!);
    await fetchDecks();
  }
}
