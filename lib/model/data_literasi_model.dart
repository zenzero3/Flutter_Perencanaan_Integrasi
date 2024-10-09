import 'dart:ffi';

class DataLiterasi {
  int? id;
  String? konteksLiterai;
  String? aktivitasLiterasi;
  String? konteksNumerasi;
  String? aktivitasNumerasi;

  DataLiterasi({
    this.id = 0,
    this.konteksLiterai = '',
    this.aktivitasLiterasi = '',
    this.konteksNumerasi = '',
    this.aktivitasNumerasi = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'konten_literasi': konteksLiterai,
      'aktivitas_literasi': aktivitasLiterasi,
      'konten_numeric': konteksNumerasi,
      'aktivitas_numeric': aktivitasNumerasi,
    };
  }

  factory DataLiterasi.fromMap(Map<String, dynamic> map) {
    return DataLiterasi(
      id: map['id'],
      konteksLiterai: map['konten_literasi'],
      aktivitasLiterasi: map['aktivitas_literasi'],
      konteksNumerasi: map['konten_numeric'],
      aktivitasNumerasi: map['aktivitas_numeric'],
    );
  }
}

class DataLiterasiModel {
  List<DataLiterasi> literasiList = [];

  List<DataLiterasi> getData() {
    return literasiList;
  }

  void addLiterasi(DataLiterasi literasi) {
    literasiList.add(literasi);
  }

  void removeLiterasi(int index) {
    if (index >= 0 && index < literasiList.length) {
      literasiList.removeAt(index);
    }
  }

  void addDummyData(int id) {
    print(id);
    var dummyAsesmen = DataLiterasi(
      id: id,
      konteksLiterai: '',
      aktivitasLiterasi: "",
      konteksNumerasi: "",
      aktivitasNumerasi: "",
    );
    addLiterasi(dummyAsesmen); // Menambahkan data dummy ke list
  }
}
