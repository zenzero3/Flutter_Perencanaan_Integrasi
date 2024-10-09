


import '../model/data_bahanajar_model.dart';

class DataBahanajarPresenter {
  final DataBahanajarModel model; // Menggunakan 'final' untuk model
  
  DataBahanajarPresenter(this.model);
   List<DataBahanajar> fetchDataFromModel() {
    return model.getData(); // Mengambil list Asesmen dari model
  }
}
