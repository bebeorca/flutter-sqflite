import 'package:sqf/models/data.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE Users(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name VARCHAR(255),
        nim INT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'dimasqf2.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(Data dt) async {
    final db = await SQLHelper.db();
    final data = {'name': dt.Name, 'nim': dt.NIM};
    final id = await db.insert('Users', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);

    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('Users', orderBy: "nim");
  }

  static Future<List<Map<String, dynamic>>> getItem(String q) async {
    final db = await SQLHelper.db();
    return db.query('Users', where: "q = %$q% or nim = %$q%", whereArgs: [q], limit: 1);
  }

  static Future<int> updateItem(int id, String name, int nim) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'nim': nim,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('Users', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("Users", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong: $err");
    }
  }
}
