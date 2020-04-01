import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:qrreaderapp/src/models/scan_model.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Database _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentDirectory.path, 'ScansDB.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      final String sql = 'CREATE TABLE scan('
          'id INTEGER PRIMARY KEY,'
          'type TEXT,'
          'value TEXT'
          ')';
      await db.execute(sql);
    });
  }

  nuevoScanRaw(ScanModel nuevoScan) async {
    final db = await database;
    final String sql = "INSERT INTO scan("
        "id,"
        ",type"
        ",value"
        ")"
        " VALUES("
        "${nuevoScan.id}"
        ",'${nuevoScan.type}'"
        ",'${nuevoScan.value}'"
        ")";

    final res = await db.rawInsert(sql);

    return res;
  }

  nuevoScan(ScanModel nuevoScan) async {
    final db = await database;
    final res = await db.insert('scan', nuevoScan.toJson());

    return res;
  }

  Future<ScanModel> getScanId(int id) async {
    final db = await database;
    final res = await db.query('scan', where: 'id = ?', whereArgs: [id]);

    return res.isNotEmpty ? ScanModel.fromJson(res.first) : null;
  }

  Future<List<ScanModel>> getAllScans() async {
    final db = await database;
    final res = await db.query('scan');

    List<ScanModel> list = res.isNotEmpty
        ? res.map((item) => ScanModel.fromJson(item)).toList()
        : [];

    return list;
  }

  Future<List<ScanModel>> getScansByType(String type) async {
    final db = await database;
    final String sql = "SELECT id"
        ",type"
        ",value"
        " FROM scan"
        " WHERE type = '$type'";
    final res = await db.rawQuery(sql);

    List<ScanModel> list = res.isNotEmpty
        ? res.map((item) => ScanModel.fromJson(item)).toList()
        : [];

    return list;
  }

  Future<int> updateScan(ScanModel nuevoScan) async {
    final db = await database;
    final res = db.update('scan', nuevoScan.toJson(),
        where: 'id = ?', whereArgs: [nuevoScan.id]);
    return res;
  }

  // Eliminar registros
  Future<int> deleteScan(int id) async {
    final db = await database;
    final res = await db.delete('scan', where: 'id = ?', whereArgs: [id]);
    return res;
  }

  Future<int> deleteAll() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM scan');
    return res;
  }
}
