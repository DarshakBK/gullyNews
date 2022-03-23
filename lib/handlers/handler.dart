import 'package:gully_news/models/newsData.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper; // Singleton DatabaseHelper
  static Database? _database; // Singleton Database

  String todoTable = 'news_table';
  String colId = 'id';
  String colPicture = 'picture';
  String colDate = 'date';
  String colTime = 'time';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'news.db';

    var todosDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todosDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colPicture TEXT, $colDate TEXT, $colTime TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNewsMapList() async {
    Database db = await database;
    var result = await db.query(todoTable, orderBy: '$colDate ASC');
    return result;
  }

  Future<int> insertTodo(NewsData newsData) async {
    Database db = await database;
    var result = await db.insert(todoTable, newsData.toMap());
    return result;
  }

  Future<int> updateTodo(NewsData newsData) async {
    var db = await database;
    var result = await db.update(todoTable, newsData.toMap(),
        where: '$colId = ?', whereArgs: [newsData.id]);
    return result;
  }

  Future<int> deleteTodo(int id) async {
    var db = await database;
    int result =
        await db.rawDelete('DELETE FROM $todoTable WHERE $colId = $id');
    return result;
  }

  Future<int?> getCount() async {
    Database db = await database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $todoTable');
    int? result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<NewsData>?> getNewsList() async {
    var todoNewsList = await getNewsMapList();
    int count = todoNewsList.length;
    List<NewsData>? news = [];
    for (int i = 0; i < count; i++) {
      news.add(NewsData.fromMap(todoNewsList[i]));
    }
    return news;
  }
}
