class DataAktivitasPembelajaranModel {
  String? pendahuluan; // Deskripsi materi
  String? inti; // Deskripsi materi
  String? penutup; // Relevansi materi

  DataAktivitasPembelajaranModel({
    this.pendahuluan = '',
    this.inti = '',
    this.penutup = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'pendahuluan': pendahuluan,
      'ilustrasi': inti,
      'contohstudikasus': penutup,
    };
  }

  factory DataAktivitasPembelajaranModel.fromMap(Map<String, dynamic> map) {
    return DataAktivitasPembelajaranModel(
      pendahuluan: map['pendahuluan'],
      inti: map['inti'],
      penutup: map['penutup'],
    );
  }
}
