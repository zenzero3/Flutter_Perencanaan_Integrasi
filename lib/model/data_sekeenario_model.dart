import 'package:offlineapp/model/data_aktivitas_pembelajaran_model.dart';
import 'package:offlineapp/model/data_model_reflesi_guru.dart';
import 'package:offlineapp/model/data_murid_model.dart';

class DataSekeenarioModel {
  String id;
  String idbahanajar;
  String tujuanPembelajaran;
  String idassesmen;
  String idliterasi;
  String kataFasa;
  String targetJumlah;
  String pertanyaanpemantik;
  String kompetesiprasyaran;
  String mediaPembelajrantext;
  String
      assessmentUse; // Perbaikan ejaan dari 'assesmentUse' menjadi 'assessmentUse'
  String bahanKajian;
  String JumlahAlokasiWaktu;
  String MediaSumber;
  String ModaPembelajaran;
  String KetersediaMateri;
  String materiAjar;
  String KegiatanPembelajaranUtama;
  DataAktivitasPembelajaranModel dataAktivitasPembelajaranModel;
  String Lembarkerja;
  List<RefleksiGuruModel> refleksiGuruList;
  List<RefleksiMuridModel> refleksiMuridList;
  String referensi;

  DataSekeenarioModel({
    required this.id,
    required this.idbahanajar,
    required this.tujuanPembelajaran,
    required this.idassesmen,
    required this.idliterasi,
    required this.kataFasa,
    required this.targetJumlah,
    required this.mediaPembelajrantext,
    required this.assessmentUse,
    required this.bahanKajian,
    required this.JumlahAlokasiWaktu,
    required this.MediaSumber,
    required this.dataAktivitasPembelajaranModel,
    required this.Lembarkerja,
    required this.refleksiGuruList,
    required this.refleksiMuridList,
    required this.referensi
  });
}
