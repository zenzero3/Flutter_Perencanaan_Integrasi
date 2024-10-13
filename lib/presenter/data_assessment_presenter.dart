import 'package:offlineapp/model/data_assesment_model.dart';
import 'package:offlineapp/services/databaseHelper.dart';

class DataAssessmentPresenter {
  final DataAssessmentModel model;
  final DatabaseHelper databaseHelper; // Menambahkan database helper

  DataAssessmentPresenter(this.model, this.databaseHelper);

  // Mengambil data asesmen dari model
  List<Asesmen> fetchDataFromModel() {
    return model.getData(); // Mengambil list Asesmen dari model
  }

  Future<void> loadDataAssesment() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getAllAsesmen();
    if (data.isNotEmpty) {
      List<Asesmen> asesmenList =
          data.map((data) => Asesmen.fromMap(data)).toList();
      for (var asesmen in asesmenList) {
        model.addAsesmen(asesmen);
      }
    }
  }

  // Menambahkan asesmen baru ke database
  Future<bool> addAsesmen(Asesmen data) async {
    // Simpan data asesmen ke database
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.getAllAsesmen();
    bool ischeck = false;
    for (var datas in db) {
      if (datas['id'] == data.id) {
        ischeck = true;
      }
    }
    if (ischeck == true) {
      try {
        await databaseHelper.updateDataAssesment(data.id ?? 0, {
          'Pertemuan Ke': data.pertemuanKe,
          'Indikator Diagnostik': data.indikatorDiagnostik,
          'Indikator Formatif':
              data.indikatorFormatif, // Kosongkan atau isi sesuai data
          'Indikator Sumatif':
              data.indikatorSumatif, // Kosongkan atau isi sesuai data
          'Kognitif': data.kognitif, // Kosongkan atau isi sesuai data
          'Afektif': data.afektif, // Kosongkan atau isi sesuai data
          'Psikomotorik': data.psikomotorik, // Kosongkan atau isi sesuai data
        });
        return true;
      } catch (e) {
        print('Error saving data: $e'); // Log kesalahan
        return false; // Mengembalikan false jika gagal
      }
    } else {
      try {
        await databaseHelper.insertAsesmen({
          'Pertemuan Ke': data.pertemuanKe,
          'Indikator Diagnostik': data.indikatorDiagnostik,
          'Indikator Formatif':
              data.indikatorFormatif, // Kosongkan atau isi sesuai data
          'Indikator Sumatif':
              data.indikatorSumatif, // Kosongkan atau isi sesuai data
          'Kognitif': data.kognitif, // Kosongkan atau isi sesuai data
          'Afektif': data.afektif, // Kosongkan atau isi sesuai data
          'Psikomotorik': data.psikomotorik, // Kosongkan atau isi sesuai data
        });
        return true;
      } catch (e) {
        print('Error saving data: $e'); // Log kesalahan
        return false; // Mengembalikan false jika gagal
      }
    }
  }

  // Menghapus asesmen berdasarkan index
  Future<void> removeAsesmen(int index) async {
    final data = model.getData();
    final asesmen = data[index];
    
    print('assasi ${asesmen.id}');
    if(asesmen.id == null){
      model.removeAsesmen(index); // Menghapus asesmen dari model
    }else{
    try {
      await databaseHelper
          .deleteDataasesmen(asesmen.id!); // Menghapus asesmen dari database
      model.removeAsesmen(index); // Menghapus asesmen dari model
    } catch (e) {
      print(e);
    }
    }
  }
}
