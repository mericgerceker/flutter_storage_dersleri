import 'dart:async';
import 'dart:io';
import 'package:flutter_storage_dersleri/model/ogrenci.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{

  static DatabaseHelper _databaseHelper;
  static Database _database;

  String _ogrenciTablo = "ogrenci";
  String _columnID = "id";
  String _columnIsim = "isim";
  String _columnAktif = "aktif";

  factory DatabaseHelper(){
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._internal();
      print("DBHelper null'dı oluşturuldu");
      return _databaseHelper;
    }else{
      print("DBHelper null değildi var olan oluşturuldu");
      return _databaseHelper;
    }
  }

  DatabaseHelper._internal();

  Future<Database> _getDatabase() async{
    if(_database == null){
      print("DB null'dı oluşturulacak");
      _database = await _initializeDatabase();
      return _database;
    }else{
      print("DB null değildi var olan kullanılacak");
      return _database;
    }
  }

  _initializeDatabase() async{
    Directory klasor = await getApplicationDocumentsDirectory();
    String dbPath = join(klasor.path, "ogrenci.db");
    print("DB Pathi:" + dbPath);
    var ogrenciDB = openDatabase(dbPath, version: 1, onCreate: _createDB);
    return ogrenciDB;
  }


  Future<void> _createDB(Database db, int version) async{
    print("create db methodu çalıştı tablo oluşturulacak");
    await db.execute("CREATE TABLE $_ogrenciTablo ($_columnID INTEGER PRIMARY KEY AUTOINCREMENT, $_columnIsim TEXT, $_columnAktif INTEGER )");
  }

  Future<int> ogrenciEkle(Ogrenci ogrenci) async{
    var db = await _getDatabase();
    var sonuc = await db.insert(_ogrenciTablo, ogrenci.dbyeYazmakIcinMapeDonustur(), nullColumnHack: "$_columnID");
    print("ogrenci dbye eklendi" + sonuc.toString());
    return sonuc;
  }

  Future<List<Map<String, dynamic>>> tumOgrenciler() async{
    var db = await _getDatabase();
    var sonuc = await db.query(_ogrenciTablo, orderBy: '$_columnID DESC');
    return sonuc;
  }

  Future<int> ogrenciGuncelle(Ogrenci ogrenci) async{
    var db = await _getDatabase();
    var sonuc = await db.update(_ogrenciTablo, ogrenci.dbyeYazmakIcinMapeDonustur(), where: '$_columnID = ?', whereArgs: [ogrenci.id]);
    return sonuc;
  }

  Future<int> ogrenciSil(int id) async{
    var db = await _getDatabase();
    var sonuc = await db.delete(_ogrenciTablo, where: '$_columnID = ?', whereArgs: [id]);
    return sonuc;
  }

  Future<int> tumOgrenciTablosunuSil() async{
    var db = await _getDatabase();
    var sonuc = await db.delete(_ogrenciTablo);
    return sonuc;
  }
}