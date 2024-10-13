
class Asesmen {
  int? id;
  String? pertemuanKe;
  String? indikatorDiagnostik;
  String? indikatorFormatif;
  String? indikatorSumatif;
  String? kognitif;
  String? afektif;
  String? psikomotorik;

  Asesmen({
    this.id,
    this.pertemuanKe = '',
    this.indikatorDiagnostik = '',
    this.indikatorFormatif = '',
    this.indikatorSumatif = '',
    this.kognitif = '',
    this.afektif = '',
    this.psikomotorik = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pertemuan_ke': pertemuanKe,
      'indikator_diagnostik': indikatorDiagnostik,
      'indikator_formatif': indikatorFormatif,
      'indikator_sumatif': indikatorSumatif,
      'kognitif': kognitif,
      'afektif': afektif,
      'psikomotorik': psikomotorik,
    };
  }

  factory Asesmen.fromMap(Map<String, dynamic> map) {
    return Asesmen(
      id: map['id'],
      pertemuanKe: map['pertemuan_ke'],
      indikatorDiagnostik: map['indikator_diagnostik'],
      indikatorFormatif: map['indikator_formatif'],
      indikatorSumatif: map['indikator_sumatif'],
      kognitif: map['kognitif'],
      afektif: map['afektif'],
      psikomotorik: map['psikomotorik'],
    );
  }
}

class DataAssessmentModel {
  List<Asesmen> asesmenList = [];

  List<Asesmen> getData() {
    return asesmenList;
  }

  void addAsesmen(Asesmen asesmen) {
    asesmenList.add(asesmen);
  }

  void removeAsesmen(int index) {
    if (index >= 0 && index < asesmenList.length) {
      asesmenList.removeAt(index);
    }
  }

  void addDummyData(index) {
    var dummyAsesmen = Asesmen(
      pertemuanKe: 'Pertemua $index',
      indikatorDiagnostik: "",
      indikatorFormatif: "",
      indikatorSumatif: "",
      kognitif: "",
      afektif: "",
      psikomotorik: "",
    );
    addAsesmen(dummyAsesmen); // Menambahkan data dummy ke list
  }
}
