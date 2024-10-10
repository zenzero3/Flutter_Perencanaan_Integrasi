import 'package:offlineapp/model/data_materi_model.dart';
import 'package:offlineapp/model/sub_materi_model.dart';

class DataBahanAjar {
  Materi? materi; // Data untuk materi
  List<SubMateriModel>? subMateriList; // Daftar sub materi
  List<DataBahanAjar> bahanAjarList = [];

  DataBahanAjar({
    this.materi,
    this.subMateriList,
  });
 // Mengambil semua data
  List<DataBahanAjar> getData() {
    return bahanAjarList;
  }
    void addBahanAjar(DataBahanAjar newData) {
    bahanAjarList.add(newData);
  }
    void removeBahanAjar(int index) {
    if (index >= 0 && index < bahanAjarList.length) {
      bahanAjarList.removeAt(index);
    }
  }
    void updateBahanAjar(int index, DataBahanAjar updatedData) {
    if (index >= 0 && index < bahanAjarList.length) {
      bahanAjarList[index] = updatedData;
    }
  }
  
  Map<String, dynamic> toMap() {
    return {
      'materi': materi?.toMap(),
      'subMateriList': subMateriList?.map((subMateri) => subMateri.toMap()).toList(),
    };
  }

  factory DataBahanAjar.fromMap(Map<String, dynamic> map) {
    return DataBahanAjar(
      materi: map['materi'] != null ? Materi.fromMap(map['materi']) : null,
      subMateriList: map['subMateriList'] != null
          ? List<SubMateriModel>.from(map['subMateriList'].map((subMateri) => SubMateriModel.fromMap(subMateri)))
          : [],
    );
  }

}
