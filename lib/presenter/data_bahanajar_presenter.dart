import 'package:offlineapp/model/data_bahanajar_model.dart';
import 'package:offlineapp/model/data_materi_model.dart';
import 'package:offlineapp/model/sub_materi_model.dart';
import 'package:offlineapp/services/databaseHelper.dart';

class DataBahanajarPresenter {
  final DataBahanAjar model; // Menggunakan 'final' untuk model

  DataBahanajarPresenter(this.model);

  // Mengambil semua data dari model
  List<DataBahanAjar> fetchDataFromModel() {
    return model.getData();
  }

 Future<void> fetchAndUpdateDataFromDatabase() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    // Ambil semua materi dan submateri dari database
    final List<Map<String, dynamic>> materiList = await dbHelper.getAllMateri();
    final List<Map<String, dynamic>> subMateriList = await dbHelper.getAllSubMateri();

    for (var materi in materiList) {
      // Misalkan Anda memiliki cara untuk mengonversi Map ke objek Materi dan SubMateri
      var materiObj = Materi.fromMap(materi);
      var subMateriObjs = subMateriList.map((subMateri) => SubMateriModel.fromMap(subMateri)).toList();
      
      var dataBahanAjar = DataBahanAjar(materi: materiObj, subMateriList: subMateriObjs);
      model.addBahanAjar(dataBahanAjar);
    }
  }
  // Menambah data baru ke model dan ke database
  Future<bool> addDataBahanajar(DataBahanAjar newData) async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      
      // Menyimpan materi dan mendapatkan ID
      await dbHelper.insertMateri(newData.materi?.toMap() ?? {});
      int materiId = newData.materi?.id ?? 0; // Ambil ID setelah penyimpanan

      // Menyimpan submateri dengan foreign key
      for (var subMateri in newData.subMateriList ?? []) {
        subMateri.materiId = materiId; // Menetapkan foreign key
        await dbHelper.insertSubMateri(subMateri.toMap());
      }

      model.addBahanAjar(newData); // Menambahkan data baru ke dalam model
      return true; // Mengembalikan true jika berhasil
    } catch (e) {
      print('Error adding data: $e');
      return false; // Mengembalikan false jika terjadi error
    }
  }

  // Menghapus data berdasarkan index
  Future<bool> removeDataBahanajar(int index) async {
    // Check if the index is valid
    if (index < 0 || index >= model.getData().length) {
      throw Exception("Invalid index: $index");
    }

    // Ambil DataBahanAjar berdasarkan index
    var dataBahanAjar = model.getData()[index];

    // Hapus data terkait dalam tabel materi dan submateri
    if (dataBahanAjar.materi != null) {
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.deleteMateri(dataBahanAjar.materi!.id!); // Hapus data materi
      
      // Hapus data subMateri yang terkait
      for (var subMateri in dataBahanAjar.subMateriList ?? []) {
        await dbHelper.deleteSubMateri(subMateri.id!); // Hapus data subMateri yang terkait
      }
    }

    // Hapus data dari model
    model.removeBahanAjar(index);
    return true; // Mengembalikan true jika berhasil
  }

  // Mengupdate data bahan ajar
  Future<bool> updateDataBahanajar(int index, DataBahanAjar updatedData) async {
    // Check if the index is valid
    if (index < 0 || index >= model.getData().length) {
      throw Exception("Invalid index: $index");
    }

    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      
      // Mengupdate data pada model
      model.updateBahanAjar(index, updatedData);

      // Mengupdate di database
      await dbHelper.updateMateri(updatedData.materi?.id ?? 0, updatedData.materi?.toMap() ?? {});
      for (var subMateri in updatedData.subMateriList ?? []) {
        await dbHelper.updateSubMateri(subMateri.id!, subMateri.toMap());
      }

      return true; // Mengembalikan true jika berhasil
    } catch (e) {
      print('Error updating data: $e');
      return false; // Mengembalikan false jika terjadi error
    }
  }

 void populateDummyData() {
  // Buat beberapa objek Materi
  var materi1 = Materi(id: 1, deskripsi: '', relevansi: '', tujuanpembelajaran: '');

  // Buat beberapa objek SubMateriModel
  var subMateri1 = SubMateriModel(id: 1, ilustrasi: '', contohstudikasus: '', latihan: '');

  // Buat DataBahanAjar dengan materi dan sub materi
  var dataBahanAjar1 = DataBahanAjar(materi: materi1, subMateriList: [subMateri1]); // Pastikan struktur konsisten

  // Tambahkan ke dalam list
  model.addBahanAjar(dataBahanAjar1);
}


  void populateDummyData2(int index, SubMateriModel newSubMateri) {
    // Check if the index is valid
    if (index < 0 || index >= model.getData().length) {
      throw Exception("Invalid index: $index");
    }

    // Retrieve the existing DataBahanAjar from the model
    var existingDataBahanAjar = model.getData()[index];

    // Add the new SubMateriModel to the existing DataBahanAjar
    existingDataBahanAjar.subMateriList?.add(newSubMateri);
  }
}
