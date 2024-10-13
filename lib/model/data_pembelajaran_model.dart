// lib/model/data_pembelajaran_model.dart
class DataPembelajaranModel {
  String namaMataKuliah;
  String tingkatJenjang;
  String namaDosen;
  String mataKuliahPrasyarat;
  String capaianPembelajaran;
  String strategiUmum;
  String mediaPembelajran;
  String mediaPembelajrantext;
  String
      assessmentUse; // Perbaikan ejaan dari 'assesmentUse' menjadi 'assessmentUse'
  String bahanKajian;
  String JumlahAlokasiWaktu;
  String MediaSumber;

  DataPembelajaranModel({
    required this.namaMataKuliah,
    required this.tingkatJenjang,
    required this.namaDosen,
    required this.mataKuliahPrasyarat,
    required this.capaianPembelajaran,
    required this.strategiUmum,
    required this.mediaPembelajran,
    required this.mediaPembelajrantext,
    required this.assessmentUse,
    required this.bahanKajian,
    required this.JumlahAlokasiWaktu,
    required this.MediaSumber,
  });

  // Metode untuk memperbarui data
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
    String? jumlahAlokasiwaktu,
    String? mediaSumber,
  }) {
    if (namaMataKuliah != null) this.namaMataKuliah = namaMataKuliah;
    if (tingkatJenjang != null) this.tingkatJenjang = tingkatJenjang;
    if (namaDosen != null) this.namaDosen = namaDosen;
    if (mataKuliahPrasyarat != null) {
      this.mataKuliahPrasyarat = mataKuliahPrasyarat;
    }
    if (capaianPembelajaran != null) {
      this.capaianPembelajaran = capaianPembelajaran;
    }
    if (strategiUmum != null) this.strategiUmum = strategiUmum;
    if (mediaPembelajran != null) this.mediaPembelajran = mediaPembelajran;
    if (mediaPembelajrantext != null) {
      this.mediaPembelajran = mediaPembelajrantext;
    }
    if (assessmentUse != null) this.assessmentUse = assessmentUse;
    if (bahanKajian != null) this.bahanKajian = bahanKajian;
    if (jumlahAlokasiwaktu != null) {
      JumlahAlokasiWaktu = jumlahAlokasiwaktu;
    }
    if (mediaSumber != null) MediaSumber = mediaSumber;
  }

  // Metode untuk mengambil data sebagai Map
  Map<String, String> getData() {
    return {
      'Nama Mata Kuliah': namaMataKuliah,
      'Tingkat/Jenjang': tingkatJenjang,
      'Nama Dosen': namaDosen,
      'Mata Kuliah Prasyarat': mataKuliahPrasyarat,
      'Capaian Pembelajaran': capaianPembelajaran,
      'Strategi Umum': strategiUmum,
      'Media Pembelajaran': mediaPembelajran,
      'Media Pembelajarantext': mediaPembelajrantext,
      'Assessment Yang Di Gunakan': assessmentUse,
      'Bahan Kajian': bahanKajian,
      'Jumlah Alokasi Waktu': JumlahAlokasiWaktu,
      'Media / Sumber Belajar Umum': MediaSumber,
    };
  }
}
