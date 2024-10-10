class SubMateriModel {
  int? id; // ID untuk database
  String? uraianmateri; // Deskripsi materi
  String? ilustrasi; // Deskripsi materi
  String? contohstudikasus; // Relevansi materi
  String? latihan; // Relevansi materi
  int? materiId; // Menyimpan ID materi yang terkait

  SubMateriModel({
    this.id = 0,
    this.uraianmateri = '',
    this.ilustrasi = '',
    this.contohstudikasus = '',
    this.latihan = '',
    this.materiId, // Inisialisasi materiId jika diperlukan
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uraianmateri': uraianmateri,
      'ilustrasi': ilustrasi,
      'contohstudikasus': contohstudikasus,
      'latihan': latihan,
      'materiId': materiId, // Tambahkan ke peta
    };
  }

  factory SubMateriModel.fromMap(Map<String, dynamic> map) {
    return SubMateriModel(
      id: map['id'],
      uraianmateri: map['uraianmateri'],
      ilustrasi: map['ilustrasi'],
      contohstudikasus: map['contohstudikasus'],
      latihan: map['latihan'],
      materiId: map['materiId'], // Ambil materiId dari peta
    );
  }
}
