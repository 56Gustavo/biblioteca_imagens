import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/image_item.dart';

class ImagesProvider with ChangeNotifier {
  Database? _database;
  List<ImageItem> _images = [];

  List<ImageItem> get images => [..._images];

  Future<void> initDB() async {
    if (_database != null) return;
    final dbPath = await getDatabasesPath();
    final pathDB = join(dbPath, 'images.db');

    _database = await openDatabase(
      pathDB,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE images(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            imagePath TEXT
          )
        ''');
      },
    );
    await loadImages();
  }

  Future<void> loadImages() async {
    final dataList = await _database!.query('images');
    _images = dataList.map((item) => ImageItem.fromMap(item)).toList();
    notifyListeners();
  }

  Future<void> addImage(ImageItem image) async {
    final id = await _database!.insert('images', image.toMap());
    image.id = id;
    _images.add(image);
    notifyListeners();
  }

  Future<void> updateImage(ImageItem image) async {
    await _database!.update(
      'images',
      image.toMap(),
      where: 'id = ?',
      whereArgs: [image.id],
    );
    final index = _images.indexWhere((img) => img.id == image.id);
    if (index >= 0) {
      _images[index] = image;
      notifyListeners();
    }
  }

  Future<void> deleteImage(int id) async {
    await _database!.delete(
      'images',
      where: 'id = ?',
      whereArgs: [id],
    );
    _images.removeWhere((img) => img.id == id);
    notifyListeners();
  }
}
