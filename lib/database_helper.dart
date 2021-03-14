import 'dart:io';
import 'package:money_expense_recorder/expenseCategoryModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:money_expense_recorder/expenseModel.dart';
class DatabaseHelper {
  static final _databaseName = "expense.db";
  static final _databaseVersion = 1;
  static final columnId = '_id';
  static final columnName = 'name';
//  EXPENSE CATEGORY TABLE START
  static final expenseCategoryTable = 'expense_category';
//  EXPENSE CATEGORY TABLE END
  //  EXPENSE TABLE START
  static final expenseTable = 'expense';
  static final columnExpenseDate = 'expense_date';
  static final columnExpenseTime = 'expense_time';
  static final columnExpenseReason = 'expense_reason';
  static final columnExpenseAmount = 'expense_amount';
  static final columnExpenseCategoryId = 'expense_category_id';
  static final columnExpenseCategoryName = 'expense_category_name';
  //  EXPENSE TABLE END
  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // this deletes the database (and creates it if it doesn't exist)
  deleteCreatedDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return await deleteDatabase(documentsDirectory.path);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $expenseCategoryTable (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $expenseTable (
            $columnId INTEGER PRIMARY KEY,
            $columnExpenseDate TEXT NULL,
            $columnExpenseTime TEXT NULL,
            $columnExpenseReason TEXT NULL,
            $columnExpenseAmount DOUBLE NULL,
            $columnExpenseCategoryId INTEGER NULL,
            $columnExpenseCategoryName TEXT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(String table,Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(tableName,Map<String, dynamic> row,id) async {
    Database db = await instance.database;
//    int id = row[columnId];
    return await db.update(tableName, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
//  Future<int> delete(int id) async {
//    Database db = await instance.database;
//    return await db.delete(userTable, where: '$columnId = ?', whereArgs: [id]);
//  }

  Future<int> deleteAll(table) async {
    Database db = await instance.database;
    return await db.delete(table, where: '1');
  }

  Future<int> delete(table, columnName, int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnName = ?', whereArgs: [id]);
  }

  Future<List<ExpenseModel>> getExpenseData() async {
    Database db = await instance.database;
    String sql;
    sql = "SELECT * FROM $expenseTable ORDER BY $columnExpenseDate DESC";
    var result = await db.rawQuery(sql);
    if (result.length == 0) return null;
    List<ExpenseModel> list = result.map((item) {
      return ExpenseModel.fromJson(item);
    }).toList();
    return list;
  }

  Future<List<ExpenseModel>> getFollowupModelInRangeData(startDate,endDate) async {
    Database db = await instance.database;
    String sql;
    sql = "SELECT * FROM $expenseTable WHERE $columnExpenseDate BETWEEN $startDate AND $endDate ORDER BY $columnExpenseDate DESC";
    var result = await db.rawQuery(sql);
    if (result.length == 0) return null;
    print("result");
    print(result);
    List<ExpenseModel> list = result.map((item) {
      return ExpenseModel.fromJson(item);
    }).toList();
    return list;
  }

  Future<List<ExpenseCategoryModel>> getExpenseCategoriesData() async {
    Database db = await instance.database;
    String sql;
    sql = "SELECT * FROM $expenseCategoryTable";
    var result = await db.rawQuery(sql);
    print(result.toString());
    if (result.length == 0) return null;
    List<ExpenseCategoryModel> list = result.map((item) {
      return ExpenseCategoryModel.fromJson(item);
    }).toList();
    return list;
  }

  Future<List<Map<String, dynamic>>> getExpenseCategoriesData2() async {
    Database db = await instance.database;
    return await db.rawQuery('SELECT * FROM $expenseCategoryTable');
  }

}
