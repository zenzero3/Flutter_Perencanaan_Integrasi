import 'dart:ffi';

class DataBahanajar {
  int? id;
  String? konteksLiterai;
  String? aktivitasLiterasi;
  String? konteksNumerasi;
  String? aktivitasNumerasi;


  DataBahanajar({
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
      'aktivitas_numerasi': aktivitasNumerasi,
    };
  }

  factory DataBahanajar.fromMap(Map<String, dynamic> map) {
    return DataBahanajar(
      id: map['id'],
      konteksLiterai: map['konten_literasi'],
      aktivitasLiterasi: map['aktivitas_literasi'],
      konteksNumerasi: map['konten_numeric'],
      aktivitasNumerasi: map['aktivitas_numerasi'],
    );
  }
}

class DataBahanajarModel {
  List<DataBahanajar> asesmenList = [];

  List<DataBahanajar> getData() {
    return asesmenList;
  }

  void addDatabahanAjar(DataBahanajar asesmen) {
    asesmenList.add(asesmen);
  }

  void removeDatabahanAjar(int index) {
    if (index >= 0 && index < asesmenList.length) {
      asesmenList.removeAt(index);
    }
  }

  void addDummyData() {
    var dummyAsesmen = DataBahanajar(
      konteksLiterai: '',
      aktivitasLiterasi: "",
      konteksNumerasi: "",
      aktivitasNumerasi: "",
    );
    addDatabahanAjar(dummyAsesmen); // Menambahkan data dummy ke list
  }
}
