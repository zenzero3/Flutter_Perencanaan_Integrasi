class Materi {
  int? id; // ID untuk database
  String? deskripsi; // Deskripsi materi
  String? relevansi; // Relevansi materi
  String? tujuanpembelajaran; // Relevansi materi

  Materi({
    this.id =0 ,
    this.deskripsi='',
    this.relevansi='',
    this.tujuanpembelajaran='',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deskripsi': deskripsi,
      'relevansi': relevansi,
      'tujuanpembelajran': tujuanpembelajaran,
    };
  }

  factory Materi.fromMap(Map<String, dynamic> map) {
    return Materi(
      id: map['id'],
      deskripsi: map['deskripsi'],
      relevansi: map['relevansi'],
      tujuanpembelajaran: map['tujuanpembelajaran'],
    );
  }
}
