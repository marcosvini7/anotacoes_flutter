import 'package:sqflite/sqflite.dart';

class AnotacaoHelper {
  static final AnotacaoHelper anotacaoHelper = AnotacaoHelper.internal();
  Database _db;

  factory AnotacaoHelper() {
    return anotacaoHelper;
  }

  AnotacaoHelper.internal();

  get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  onCreate(db, version) async {
    await db.execute(
        "CREATE TABLE anotacoes(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo " +
            "VARCHAR(50), anotacao TEXT, data DATETIME)");
  }

  Future<Database> initDb() async {
    var caminhoDb = await getDatabasesPath() + '/banco.db';
    Database db = await openDatabase(caminhoDb, version: 1, onCreate: onCreate);
    return db;
  }
}
