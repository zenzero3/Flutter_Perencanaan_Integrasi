import '../services/databaseHelper.dart';
import '../model/data_pembelajaran_model.dart';

// Custom class to hold the result of the database check
class DbCheckResult {
  final bool isNotEmpty;
  final List<int> ids; // List to store the IDs

  DbCheckResult(this.isNotEmpty, this.ids);
}
class DbCheckResult2 {
  final bool isNotEmpty;
  final data; // List to store the IDs

  DbCheckResult2(this.isNotEmpty, this.data);
}

class DataPembelajaranPresenter {
  final DataPembelajaranModel model;

  DataPembelajaranPresenter(this.model);

  // Check if the database has data and return IDs
  Future<DbCheckResult> checkdb() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getAllData();

    if (data.isNotEmpty) {
      // Extracting IDs from the data, assuming data is a list of maps
      List<int> ids = data.map((item) => item['id'] as int).toList();
      return DbCheckResult(true, ids);
    } else {
      return DbCheckResult(false, []);
    }
  }

  // Load data from the database and update the model
  Future<void> loadData() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getAllData();
    print('isidata $data');

    if (data.isNotEmpty) {
      // Ambil data pertama dari hasil query
      var firstData = data[0];

      updateData(
        namaMataKuliah: firstData['nama_mata_kuliah'] as String,
        tingkatJenjang: firstData['tingkat_jenjang'] as String,
        namaDosen: firstData['nama_dosen'] as String,
        mataKuliahPrasyarat: firstData['mata_kuliah_prasyarat'] as String,
        capaianPembelajaran: firstData['capaian_pembelajaran'] as String,
        mediaPembelajran: firstData['media_pembelajaran'] as String,
        mediaPembelajrantext: firstData['media_pembelajaran'] as String,
        strategiUmum: firstData['strategi_umum'] as String,
        assessmentUse: firstData['assessment_use'] as String,
        bahanKajian: firstData['bahan_kajian'] as String,
        jumlahAlokasiWaktu: firstData['alokasi_waktu'] as String,
        mediaSumber: firstData['media_sumber'] as String,
      );
    }
  }

  // Delete data by ID
  Future<void> deleteData(int id) async {
    final dbHelper = DatabaseHelper();
    try {
      await dbHelper.deleteData(id);
      print('Data with id $id deleted successfully');
    } catch (e) {
      print('Error deleting data: $e');
    }
  }

  // Save data to the database
  Future<bool> saveData() async {
    final dbHelper = DatabaseHelper();
    try {
      // Memanggil insertData dan menunggu penyimpanan selesai
      await dbHelper.insertData(model.getData());
      return true; // Mengembalikan true jika berhasil
    } catch (e) {
      print('Error saving data: $e'); // Log kesalahan
      return false; // Mengembalikan false jika gagal
    }
  }

  // Update data in the database
  Future<bool> updateDataInDb(int id) async {
    final dbHelper = DatabaseHelper();
    try {
      await dbHelper.updateData(id, model.getData());
      return true; // Mengembalikan true jika berhasil
    } catch (e) {
      print('Error updating data: $e'); // Log kesalahan
      return false; // Mengembalikan false jika gagal
    }
  }

  // Get the data from the model
  Map<String, String> getData() {
    return model.getData();
  }

  // Update the model data
  void updateData({
    String? namaMataKuliah,
    String? tingkatJenjang,
    String? namaDosen,
    String? mataKuliahPrasyarat,
    String? capaianPembelajaran,
    String? strategiUmum,
    String? mediaPembelajran,
    String? mediaPembelajrantext,
    String? assessmentUse,
    String? bahanKajian,
    String? jumlahAlokasiWaktu,
    String? mediaSumber,
  }) {
    model.updateData(
      namaMataKuliah: namaMataKuliah,
      tingkatJenjang: tingkatJenjang,
      namaDosen: namaDosen,
      mataKuliahPrasyarat: mataKuliahPrasyarat,
      capaianPembelajaran: capaianPembelajaran,
      strategiUmum: strategiUmum,
      mediaPembelajran: mediaPembelajran,
      mediaPembelajrantext: mediaPembelajrantext,
      assessmentUse: assessmentUse,
      bahanKajian: bahanKajian,
      jumlahAlokasiwaktu:jumlahAlokasiWaktu,
      mediaSumber: mediaSumber,
    );
  }
}
