import 'package:offlineapp/services/databaseHelper.dart';

import '../model/data_literasi_model.dart';

class DataLiteralisasiPresenter {
  DataLiterasi? _dataLiterasi;
  final DataLiterasiModel model; // Menggunakan 'final' untuk model

  DataLiteralisasiPresenter(this.model);
  // Mengambil data asesmen dari model
  List<DataLiterasi> fetchDataFromModel() {
    return model.getData(); // Mengambil list Asesmen dari model
  }

  Future<void> loadDataLitersi() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getAllLiterasi();
    if (data.isNotEmpty) {
      List<DataLiterasi> literasiList =
          data.map((data) => DataLiterasi.fromMap(data)).toList();
      for (var literasi in literasiList) {
        model.addLiterasi(literasi);
      }
    }
  }

  Future<bool> addLIterasi(DataLiterasi data) async {
    // Simpan data asesmen ke database
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.getAllLiterasi();
    bool ischeck = false;
    for (var datas in db) {
      if (datas['id'] == data.id) {
        ischeck = true;
      }
    }
    if (ischeck == true) {
      try {
        await DatabaseHelper().updateLiterasi(data.id ?? 0, {
          "id": data.id,
          "konten_literasi": data.konteksLiterai,
          "aktivitas_literasi": data.aktivitasLiterasi,
          "konten_numeric": data.konteksNumerasi,
          "aktivitas_numeric": data.aktivitasNumerasi,
        });
        return true;
      } catch (e) {
        print('Error saving data: $e'); // Log kesalahan
        return false; // Mengembalikan false jika gagal
      }
    } else {
      try {
        await DatabaseHelper().insertLiterasi({
          "id": data.id,
          "konten_literasi": data.konteksLiterai,
          "aktivitas_literasi": data.aktivitasLiterasi,
          "konten_numeric": data.konteksNumerasi,
          "aktivitas_numeric": data.aktivitasNumerasi,
        });
        return true;
      } catch (e) {
        print('Error saving data: $e'); // Log kesalahan
        return false; // Mengembalikan false jika gagal
      }
    }
  }

  Future<void> removeAsesmen(int index) async {
    final db = DatabaseHelper();
    final data = await model.getData();
    final literasi = data[index];
    print('nilai ${literasi.id == null}');
    if (literasi.id == null) {
      model.removeLiterasi(index); // Menghapus asesmen dari model
    } else {
      try {
        await db.deleteAllData();
        model.removeLiterasi(index); // Menghapus asesmen dari model
      } catch (e) {
        print(e);
      }
    }
  }
}
