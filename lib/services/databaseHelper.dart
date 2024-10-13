import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Singleton
  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<bool> deleteAllData() async {
    final db = await database;
    try {
      // This will delete all rows from the 'identitasmatkul' table
      await db.delete('identitasmatkul');
      await db.delete('asesmen');
      await db.delete('literasi');
      return true; // Return true if deletion is successful
    } catch (e) {
      print('Error deleting data: $e'); // Log error if any
      return false; // Return false if there was an error
    }
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Use the web-compatible database factory
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      // Initialize sqflite for FFI on non-web platforms
      sqfliteFfiInit();
    }

    // Getting the database path
    String path = join(
      await databaseFactory.getDatabasesPath(),
      'data_pembelajaran.db',
    );

    // Open the database
    final db = await databaseFactory.openDatabase(path);

    // Call function to create tables if not exist
    await _onCreate(db);
    return db;
  }

  Future<void> _onCreate(Database db) async {
  
    await db.execute('''
    CREATE TABLE IF NOT EXISTS identitasmatkul (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_mata_kuliah TEXT NOT NULL,
      tingkat_jenjang TEXT NOT NULL,
      nama_dosen TEXT NOT NULL,
      mata_kuliah_prasyarat TEXT,
      capaian_pembelajaran TEXT,
      strategi_umum TEXT,
      media_pembelajaran TEXT,
      assessment_use TEXT,
      bahan_kajian TEXT,
      alokasi_waktu TEXT,
      media_sumber TEXT
    )
  ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS asesmen (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pertemuan_ke TEXT NOT NULL,
        indikator_diagnostik TEXT,
        indikator_formatif TEXT,
        indikator_sumatif TEXT,
        kognitif TEXT,
        afektif TEXT,
        psikomotorik TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS literasi (
        id INTEGER PRIMARY KEY,
         konten_literasi TEXT,
         aktivitas_literasi TEXT,
         konten_numeric TEXT,
        aktivitas_numeric TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS materi (
        id INTEGER PRIMARY KEY,
         deskripsi TEXT,
         relevansi TEXT,
         tujuanpembelajran TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS submateri (
         id INTEGER PRIMARY KEY,
         materi_id INTEGER, -- Foreign key to the materi table
         uraianmateri TEXT,
         ilustrasi TEXT,
         contohstudikasus TEXT,
         latihan TEXT,
        FOREIGN KEY(materi_id) REFERENCES materi(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insertData(Map<String, dynamic> data) async {
    final db = await database;
    // Pastikan untuk memeriksa semua field yang penting
    if (data["Nama Mata Kuliah"] == null ||
        data["Tingkat/Jenjang"] == null ||
        data["Nama Dosen"] == null) {
      throw Exception("Field tidak boleh kosong. Data yang diterima: $data");
    }

    // Siapkan data untuk disimpan
    Map<String, dynamic> dataToInsert = {
      "nama_mata_kuliah": data["Nama Mata Kuliah"],
      "tingkat_jenjang": data["Tingkat/Jenjang"],
      "nama_dosen": data["Nama Dosen"],
      "mata_kuliah_prasyarat": data["Mata Kuliah Prasyarat"],
      "capaian_pembelajaran": data["Capaian Pembelajaran"],
      "strategi_umum": data["Strategi Umum"],
      "media_pembelajaran": data["Media Pembelajaran"], // Jika ada
      "assessment_use": data["Assessment Yang Di Gunakan"],
      "bahan_kajian": data["Bahan Kajian"],
      "alokasi_waktu": data["Jumlah Alokasi Waktu"],
      "media_sumber": data["Media / Sumber Belajar Umum"]
    };

    await db.insert(
      'identitasmatkul',
      dataToInsert,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertAsesmen(Map<String, dynamic> data) async {
    final db = await database;

    Map<String, dynamic> asesmenData = {
      "pertemuan_ke": data["Pertemuan Ke"],
      "indikator_diagnostik": data["Indikator Diagnostik"],
      "indikator_formatif": data["Indikator Formatif"],
      "indikator_sumatif": data["Indikator Sumatif"],
      "kognitif": data["Kognitif"],
      "afektif": data["Afektif"],
      "psikomotorik": data["Psikomotorik"]
    };

    await db.insert(
      'asesmen',
      asesmenData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertLiterasi(Map<String, dynamic> data) async {
    final db = await database;
    print('data1${data["konten_literasi"]}');
    print('data2${data["aktivitas_literasi"]}');
    print('data3${data["konten_numeric"]}');
    print('data4${data["aktivitas_numeric"]}');
    Map<String, dynamic> literasi = {
      "konten_literasi": data["konten_literasi"],
      "aktivitas_literasi": data["aktivitas_literasi"],
      "konten_numeric": data["konten_numeric"],
      "aktivitas_numeric": data["aktivitas_numeric"],
    };

    await db.insert(
      'literasi',
      literasi,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fungsi untuk memperbarui data berdasarkan id
  Future<void> updateData(int id, Map<String, dynamic> data) async {
    final db = await database;

    // Siapkan data yang akan diperbarui
    Map<String, dynamic> dataToUpdate = {
      "nama_mata_kuliah": data["Nama Mata Kuliah"],
      "tingkat_jenjang": data["Tingkat/Jenjang"],
      "nama_dosen": data["Nama Dosen"],
      "mata_kuliah_prasyarat": data["Mata Kuliah Prasyarat"],
      "capaian_pembelajaran": data["Capaian Pembelajaran"],
      "strategi_umum": data["Strategi Umum"],
      "media_pembelajaran": data["Media Pembelajaran"],
      "assessment_use": data["Assessment Yang Di Gunakan"],
      "bahan_kajian": data["Bahan Kajian"],
      "alokasi_waktu": data["Jumlah Alokasi Waktu"],
      "media_sumber": data["Media / Sumber Belajar Umum"]
    };

    // Update data dalam database
    await db.update(
      'identitasmatkul', // Nama tabel
      dataToUpdate, // Data yang akan diperbarui
      where: 'id = ?', // Kondisi pembaruan berdasarkan id
      whereArgs: [id], // Nilai dari syarat
    );
  }

  Future<void> updateDataAssesment(int id, Map<String, dynamic> data) async {
    final db = await database;

    // Siapkan data yang akan diperbarui
    Map<String, dynamic> dataToUpdate = {
      "pertemuan_ke": data["Pertemuan Ke"],
      "indikator_diagnostik": data["Indikator Diagnostik"],
      "indikator_formatif": data["Indikator Formatif"],
      "indikator_sumatif": data["Indikator Sumatif"],
      "kognitif": data["Kognitif"],
      "afektif": data["Afektif"],
      "psikomotorik": data["Psikomotorik"]
    };

    // Update data dalam database
    await db.update(
      'asesmen', // Nama tabel
      dataToUpdate, // Data yang akan diperbarui
      where: 'id = ?', // Kondisi pembaruan berdasarkan id
      whereArgs: [id], // Nilai dari syarat
    );
  }
Future<void> insertMateri(Map<String, dynamic> data) async {
  final db = await database;

  Map<String, dynamic> materiData = {
    "deskripsi": data["deskripsi"],
    "relevansi": data["relevansi"],
    "tujuanpembelajran": data["tujuanpembelajran"]
  };

  await db.insert(
    'materi',
    materiData,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
Future<void> insertSubMateri(Map<String, dynamic> data) async {
  final db = await database;

  Map<String, dynamic> subMateriData = {
    "materi_id": data["materi_id"], // Foreign key dari materi
    "uraianmateri": data["uraianmateri"],
    "ilustrasi": data["ilustrasi"],
    "contohstudikasus": data["contohstudikasus"],
    "latihan": data["latihan"],
  };

  await db.insert(
    'submateri',
    subMateriData,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
Future<void> deleteSubMateri(int id) async {
  final db = await database;

  await db.delete(
    'submateri',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteMateri(int id) async {
  final db = await database;

  await db.delete(
    'materi',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> updateMateri(int id, Map<String, dynamic> data) async {
  final db = await database;

  Map<String, dynamic> materiData = {
    "deskripsi": data["deskripsi"],
    "relevansi": data["relevansi"],
    "tujuanpembelajran": data["tujuanpembelajran"]
  };

  await db.update(
    'materi',
    materiData,
    where: 'id = ?',
    whereArgs: [id],
  );
}
Future<void> updateSubMateri(int id, Map<String, dynamic> data) async {
  final db = await database;

  Map<String, dynamic> subMateriData = {
    "materi_id": data["materi_id"],
    "uraianmateri": data["uraianmateri"],
    "ilustrasi": data["ilustrasi"],
    "contohstudikasus": data["contohstudikasus"],
    "latihan": data["latihan"],
  };

  await db.update(
    'submateri',
    subMateriData,
    where: 'id = ?',
    whereArgs: [id],
  );
}

  Future<void> updateLiterasi(int id, Map<String, dynamic> data) async {
    final db = await database;

    // Siapkan data yang akan diperbarui
    Map<String, dynamic> dataToUpdate = {
      "konten_literasi": data["konten_literasi"],
      "aktivitas_literasi": data["aktivitas_literasi"],
      "konten_numeric": data["konten_numeric"],
      "aktivitas_numeric": data["aktivitas_numeric"],
    };

    // Update data dalam database
    await db.update(
      'literasi', // Nama tabel
      dataToUpdate, // Data yang akan diperbarui
      where: 'id = ?', // Kondisi pembaruan berdasarkan id
      whereArgs: [id], // Nilai dari syarat
    );
  }

  Future<void> deleteData(int id) async {
    final db = await database;

    // Hapus data berdasarkan id
    await db.delete(
      'identitasmatkul',
      where: 'id = ?', // Kondisi untuk menghapus data berdasarkan id
      whereArgs: [id], // Argumen untuk where clause
    );
  }

  Future<void> deleteDataasesmen(int id) async {
    final db = await database;
  final List<Map<String, dynamic>> result = await db.query('asesmen');
  int length = result.length;
    // Hapus data berdasarkan id
    await db.delete(
      'asesmen',
      where: 'id = ?', // Kondisi untuk menghapus data berdasarkan id
      whereArgs: [id], // Argumen untuk where clause
    );
    if (length == 1) {
    // Jika hanya ada satu data yang dihapus, reset tabel atau lakukan tindakan lain
    await resetTableAsest(); // Misalnya, panggil fungsi untuk reset tabel
    // Atau Anda bisa menggunakan:
    // await clearTable(); // Jika Anda hanya ingin menghapus data
  }
    
  }
  Future<void> resetTableAsest() async {
  final db = await database;

  // Hapus tabel jika sudah ada
  await db.execute('DROP TABLE IF EXISTS asesmen');

  // Buat ulang tabel
  await db.execute('''
    CREATE TABLE asesmen (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
       nama_mata_kuliah TEXT NOT NULL,
      tingkat_jenjang TEXT NOT NULL,
      nama_dosen TEXT NOT NULL,
      mata_kuliah_prasyarat TEXT,
      capaian_pembelajaran TEXT,
      strategi_umum TEXT,
      media_pembelajaran TEXT,
      assessment_use TEXT,
      bahan_kajian TEXT,
      alokasi_waktu TEXT,
      media_sumber TEXT
    )
  ''');
}
  Future<void> resetTable() async {
  final db = await database;

  // Hapus tabel jika sudah ada
  await db.execute('DROP TABLE IF EXISTS literasi');

  // Buat ulang tabel
   await db.execute('''
      CREATE TABLE IF NOT EXISTS literasi (
        id INTEGER PRIMARY KEY,
         konten_literasi TEXT,
         aktivitas_literasi TEXT,
         konten_numeric TEXT,
        aktivitas_numeric TEXT
      )
    ''');
}

  

  Future<void> deleteLiterasi(int id) async {
    final db = await database;
  final List<Map<String, dynamic>> result = await db.query('literasi');
  int length = result.length;
    // Hapus data berdasarkan id
    await db.delete(
      'literasi',
      where: 'id = ?', // Kondisi untuk menghapus data berdasarkan id
      whereArgs: [id], // Argumen untuk where clause
    );
    if (length == 1) {
    // Jika hanya ada satu data yang dihapus, reset tabel atau lakukan tindakan lain
    await resetTable(); // Misalnya, panggil fungsi untuk reset tabel
    // Atau Anda bisa menggunakan:
    // await clearTable(); // Jika Anda hanya ingin menghapus data
  }
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await database;
    return await db.query('identitasmatkul');
  }

  Future<List<Map<String, dynamic>>> getAllLiterasi() async {
    final db = await database;
    return await db.query('literasi');
  }

  Future<List<Map<String, dynamic>>> getAllAsesmen() async {
    final db = await database;
    return await db.query('asesmen');
  }
  Future<List<Map<String, dynamic>>> getAllMateri() async {
  final db = await database;
  return await db.query('materi');
}
Future<List<Map<String, dynamic>>> getAllSubMateri() async {
  final db = await database;
  return await db.query('submateri');
}


  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
