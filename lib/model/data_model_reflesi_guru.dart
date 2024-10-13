class RefleksiGuruModel {
  String pendekatanStrategi; // Pendekatan atau strategi yang digunakan
  bool sudahDilakukan; // Apakah sudah dilakukan
  bool belumEfektif; // Apakah belum efektif
  bool perluDitingkatkan; // Apakah perlu ditingkatkan

  RefleksiGuruModel({
    required this.pendekatanStrategi,
    this.sudahDilakukan = false,
    this.belumEfektif = false,
    this.perluDitingkatkan = false,
  });

  // Method untuk mengubah model ke bentuk Map (bisa untuk penyimpanan database)
  Map<String, dynamic> toMap() {
    return {
      'pendekatanStrategi': pendekatanStrategi,
      'sudahDilakukan': sudahDilakukan,
      'belumEfektif': belumEfektif,
      'perluDitingkatkan': perluDitingkatkan,
    };
  }

  // Factory method untuk membuat model dari Map
  factory RefleksiGuruModel.fromMap(Map<String, dynamic> map) {
    return RefleksiGuruModel(
      pendekatanStrategi: map['pendekatanStrategi'],
      sudahDilakukan: map['sudahDilakukan'],
      belumEfektif: map['belumEfektif'],
      perluDitingkatkan: map['perluDitingkatkan'],
    );
  }
}
