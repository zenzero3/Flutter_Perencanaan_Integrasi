class RefleksiMuridModel {
  String pengetahuan; // Materi atau kemampuan yang sedang dievaluasi
  bool sudahPaham; // Apakah murid sudah paham
  bool perluBelajarLebih; // Apakah masih perlu belajar lebih

  RefleksiMuridModel({
    required this.pengetahuan,
    this.sudahPaham = false,
    this.perluBelajarLebih = false,
  });

  // Method untuk mengubah model ke bentuk Map (bisa untuk penyimpanan database)
  Map<String, dynamic> toMap() {
    return {
      'pengetahuan': pengetahuan,
      'sudahPaham': sudahPaham,
      'perluBelajarLebih': perluBelajarLebih,
    };
  }

  // Factory method untuk membuat model dari Map
  factory RefleksiMuridModel.fromMap(Map<String, dynamic> map) {
    return RefleksiMuridModel(
      pengetahuan: map['pengetahuan'],
      sudahPaham: map['sudahPaham'],
      perluBelajarLebih: map['perluBelajarLebih'],
    );
  }
}

