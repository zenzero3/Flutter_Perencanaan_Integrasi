// lib/model/data_pembelajaran_model.dart
class DataPerencanaanModel {
  String kriteria;
  String indikator;
  String bobotPenilaian;

  DataPerencanaanModel(
     {
          required this.kriteria,
          required this.indikator,
          required this.bobotPenilaian,
     }
  )
  // Simulasi data pembelajaran
  List<String> getData() {
    return ['Perencanaan 1', 'Data 2', 'Data 3'];
  }
}
