import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:note_app/models/category.dart';
import 'package:note_app/models/notes.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  //dbye veri yazilirken db lock durumuna gecer ve baska bir duzenleme kabul etmez
  //bu yuzden singleton olarak duzenlemek lazim
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper!;
    } else {
      return _databaseHelper!;
    }
  }
  DatabaseHelper._internal();
  Future<Database?> _getDatabase() async {
    if (_database == null) {
      _database = await _initializeDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  Future<Database> _initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = await join(databasesPath, "ogrenci.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notlar.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

// open the database
    return await openDatabase(path, readOnly: false);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    var db = await _getDatabase();
    var result = await db!.query("category");
    return result;
  }

  Future<int> addCategory(Category category) async {
    var db = await _getDatabase();
    var result = await db!.insert('category', category.toMap());
    return result;
  }

  Future<int> updateCategory(Category category) async {
    var db = await _getDatabase();
    var result = await db!.update('category', category.toMap(),
        where: 'categoryID = ?', whereArgs: [category.categoryID]);
    return result;
  }

  Future<int> deleteCategory(Category categoryID) async {
    var db = await _getDatabase();
    var result = await db!
        .delete('category', where: 'categoryID = ?', whereArgs: [categoryID]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    var db = await _getDatabase();
    var result = await db!.query("note", orderBy: 'noteID DESC');
    return result;
  }

  Future<int> addNote(Note note) async {
    var db = await _getDatabase();
    var result = await db!.insert('note', note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    var db = await _getDatabase();
    var result = await db!.update('note', note.toMap(),
        where: 'noteID = ?', whereArgs: [note.noteID]);
    return result;
  }

  Future<int> deleteNote(Note noteID) async {
    var db = await _getDatabase();
    var result =
        await db!.delete('note', where: 'noteID = ?', whereArgs: [noteID]);
    return result;
  }

  String dateFormat(DateTime tm) {
    DateTime today = DateTime.now();
    Duration oneDay = Duration(days: 1);
    Duration twoDay = Duration(days: 2);
    Duration threeDay = Duration(days: 3);
    Duration oneWeek = Duration(days: 7);
    String month;
    switch (tm.month) {
      case 1:
        month = 'ocak';
        break;
      case 2:
        month = 'subat';
        break;
      case 3:
        month = 'mart';
        break;
      case 4:
        month = 'nisan';
        break;
      case 5:
        month = 'mayis';
        break;
      case 6:
        month = 'haziran';
        break;
      case 7:
        month = 'temmuz';
        break;
      case 8:
        month = 'agustos';
        break;
      case 9:
        month = 'eylul';
        break;
      case 10:
        month = 'ekim';
        break;
      case 11:
        month = 'kasim';
        break;
      case 12:
        month = 'aralik';
        break;
    }
    Duration difference = today.difference(tm);
    if (difference.compareTo(oneDay) < 1) {
      return 'bugun';
    } else if (difference.compareTo(twoDay) < 1) {
      return 'dun';
    } else if (difference.compareTo(threeDay) < 1) {
      return '3 gun once';
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return 'pazartesi';
        case 2:
          return 'sali';
        case 3:
          return 'carsamba';
        case 4:
          return 'persembe';
        case 5:
          return 'cuma';
        case 6:
          return 'cumartesi';
        case 7:
          return 'pazar';
      }
    } else if (tm.year == today.year) {
      return '${tm.day} ${tm.month}';
    } else {
      '${tm.day} ${tm.month} ${tm.year}';
    }
    return '';
  }
}
