import 'package:music_album/Database/db_helper.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  DatabaseConnection? _databaseConnection;
  Database? _database;

  Repository() {
    _databaseConnection = DatabaseConnection();
  }

  Future<Database?> get mydatabase async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _databaseConnection?.setDatabase();
      return _database;
    }
  }

  // Insert Data
  insertData(String table, Map<String, dynamic> data) async {
    var con = await mydatabase;
    return await con!.insert(table, data);
  }

  // Get Data
  getData(String table) async {
    var con = await mydatabase;
    return await con!.query(table);
  }

  // Update Data
  updateData(String table, Map<String, dynamic> data) async {
    var con = await mydatabase;
    return await con!.update(
      table,
      data,
      where: "id=?",
      whereArgs: [data["id"]],
    );
  }

  // Delete Data
  deleteData(String table, Map<String, dynamic> data) async {
    var con = await mydatabase;
    return await con!.delete(table, where: "id=?", whereArgs: [data["id"]]);
  }

  // Get Filtered Data
  Future<List<Map<String, dynamic>>> getDataByCondition(
    String table,
    String condition,
  ) async {
    var con = await mydatabase;
    return await con!.query(table, where: condition);
  }

  // Raw Data
  Future<int> updateRaw(String sql, List<Object?> arguments) async {
    var con = await mydatabase;
    return await con!.rawUpdate(sql, arguments);
  }
}
