import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../model/note_model.dart';

class DatabaseHelper {
  // Single instance of Database helper class
  static final DatabaseHelper instance = DatabaseHelper._instance();
  DatabaseHelper._instance();

  // Database private instance
  static Database? _db;

  // table and column names
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  // Getter for the database instance
  Future<Database?> get db async {
    _db = _db ?? await initDb();
    return _db;
  }

  // Initialize the database
  Future<Database?> initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = '${dir.path}todo_list.db';
    final todoListDB = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
    return todoListDB;
  }

  // Create the database table
  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER)',
    );
  }

  // Get a list of maps representing notes
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database? db = await this.db;
    final List<Map<String, dynamic>> result = await db!.query(noteTable);
    return result;
  }

  // Get a list of Note objects
  Future<List<Note>> getNoteList() async {
    final List<Map<String, dynamic>> noteMapList = await getNoteMapList();
    final List<Note> noteList = [];
    for (var noteMap in noteMapList) {
      noteList.add(Note.fromMap(noteMap));
    }
    noteList.sort(
      (noteA, noteB) => noteA.date!.compareTo(noteB.date!),
    );
    return noteList;
  }

  // Insert a new note into the database
  Future<int> insertNote(Note note) async {
    Database? db = await this.db;
    int result = await db!.insert(
      noteTable,
      note.toMap(),
    );
    return result;
  }

  // Update an existing note in the database
  Future<int> updateNote(Note note) async {
    Database? db = await this.db;
    int result = await db!.update(
      noteTable,
      note.toMap(),
      where: '$colId = ?',
      whereArgs: [note.id],
    );
    return result;
  }

  // Delete a note from the database
  Future<int> deleteNote(int id) async {
    Database? db = await this.db;
    int result = await db!.delete(
      noteTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
