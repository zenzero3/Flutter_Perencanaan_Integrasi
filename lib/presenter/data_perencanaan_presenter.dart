


import '../model/data_perencanaan_model.dart';

class DataPerencanaanPresenter {
  final DataPerencanaanModel model; // Menggunakan 'final' untuk model
  
  DataPerencanaanPresenter(this.model);
  List<String> fetchData() {
    return model.getData();
  }
}
