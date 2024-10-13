import 'package:flutter/material.dart';
import 'package:offlineapp/model/data_assesment_model.dart';
import 'package:offlineapp/utils/helper.dart';
import '../presenter/data_assessment_presenter.dart';
import '../services/databaseHelper.dart';

class DataAssessmentPage extends StatefulWidget {
  const DataAssessmentPage({super.key});

  @override
  _DataAssessmentPageState createState() => _DataAssessmentPageState();
}

class _DataAssessmentPageState extends State<DataAssessmentPage> {
  final DataAssessmentModel model = DataAssessmentModel();
  late DataAssessmentPresenter presenter;
  final DatabaseHelper databaseHelper =
      DatabaseHelper(); // Buat instance DatabaseHelper

  @override
  void initState() {
    super.initState();
    presenter = DataAssessmentPresenter(model, databaseHelper);
    // model.addDummyData(); // Menambahkan data dummy
    loadData();
  }

  Future<void> loadData() async {
    try {
      await presenter.loadDataAssesment();

      setState(() {});
      // Setelah data dimuat, perbarui UI dengan setState
      // Panggil loadData dari presenter
    } catch (e) {
      print('Error loading data: $e'); // Menangani error jika ada
    }
  }

  void _removeAsesmen(int index) {
    presenter.removeAsesmen(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Asesmen> data = presenter.fetchDataFromModel(); // Ambil data asesmen

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Asesmen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10), // Spasi antar widget

            if (data
                .isNotEmpty) // Hanya menampilkan Expanded jika data tidak kosong
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var asesmen = data[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TextFormField untuk input nama asesmen
                            TextFormField(
                              readOnly: true,
                              initialValue: asesmen
                                  .pertemuanKe, // Pastikan untuk mengubah ke string
                              onChanged: (value) {
                                asesmen.pertemuanKe =
                                    value; // Update pertemuanKe
                              },
                              decoration: const InputDecoration(
                                labelText: '',
                                    border: InputBorder.none, // Menghilangkan border
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                            const SizedBox(height: 16), // Spasi antar widget

                            // Indikator Diagnostik
                            TextFormField(
                              initialValue: asesmen.indikatorDiagnostik,
                              onChanged: (value) {
                                asesmen.indikatorDiagnostik = value;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Asesmen Awal / Diagnostik',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                            const SizedBox(height: 16), // Spasi antar widget

                            // Indikator Formatif
                            TextFormField(
                              initialValue: asesmen.indikatorFormatif,
                              onChanged: (value) {
                                asesmen.indikatorFormatif = value;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Asesmen Formatif',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                            const SizedBox(height: 16), // Spasi antar widget

                            // Indikator Sumatif
                            TextFormField(
                              initialValue: asesmen.indikatorSumatif,
                              onChanged: (value) {
                                asesmen.indikatorSumatif = value;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Asesmen Sumatif',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                            const SizedBox(height: 16), // Spasi antar widget

                            // Kemampuan Kognitif
                            TextFormField(
                              initialValue: asesmen.kognitif,
                              onChanged: (value) {
                                asesmen.kognitif = value;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Kemampuan Kognitif / Pengetahuan',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                            const SizedBox(height: 16), // Spasi antar widget

                            // Kemampuan Afektif
                            TextFormField(
                              initialValue: asesmen.afektif,
                              onChanged: (value) {
                                asesmen.afektif = value;
                              },
                              decoration: const InputDecoration(
                                labelText: 'Kemampuan Afektif / Sikap',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                            const SizedBox(height: 16), // Spasi antar widget

                            // Kemampuan Psikomotorik
                            TextFormField(
                              initialValue: asesmen.psikomotorik,
                              onChanged: (value) {
                                asesmen.psikomotorik = value;
                              },
                              decoration: const InputDecoration(
                                labelText:
                                    'Kemampuan Psikomotorik / Keterampilan',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: SizedBox(
                                width: 200,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    
                                    bool sukses =
                                        await presenter.addAsesmen(asesmen);
                                    if (sukses) {
                                      showAlertDialog(context, 'Berhasil',
                                          'Data berhasil disimpan.');
                                    } else {
                                      showAlertDialog(context, 'Gagal',
                                          'Data gagal disimpan. Silakan coba lagi.');
                                    }
                                    // Logika simpan data
                                  },
                                  child: const Text(
                                    'Simpan Data',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16), // Spasi antar widget
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _removeAsesmen(index), // Hapus asesmen
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              const Center(child: Text("")), // Pesan jika data kosong

            const SizedBox(height: 16), // Spasi antar widget
            Center(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    final count = data.isNotEmpty ? data.length + 1 : 1;
                    model.addDummyData(count);

                    setState(() {});
                  },
                  child: const Text(
                    'Tambahkan Asesmen ',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
