class Materi {
  int? id; // ID untuk database
  String? deskripsi; // Deskripsi materi
  String? relevansi; // Relevansi materi

  Materi({
    this.id,
    this.deskripsi,
    this.relevansi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deskripsi': deskripsi,
      'relevansi': relevansi,
    };
  }

  factory Materi.fromMap(Map<String, dynamic> map) {
    return Materi(
      id: map['id'],
      deskripsi: map['deskripsi'],
      relevansi: map['relevansi'],
    );
  }
}
