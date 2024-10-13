import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:offlineapp/model/data_literasi_model.dart';
import 'package:offlineapp/presenter/data_literalisasi_presenter.dart';
import 'package:offlineapp/utils/helper.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../services/databaseHelper.dart';

class DataLiterasiNumerasiPage extends StatefulWidget {
  const DataLiterasiNumerasiPage({super.key});

  @override
  _DataLiterasiNumerasiState createState() => _DataLiterasiNumerasiState();
}

class _DataLiterasiNumerasiState extends State<DataLiterasiNumerasiPage> {
  final DataLiterasiModel model = DataLiterasiModel();
  late DataLiteralisasiPresenter presenter;
  final DatabaseHelper databaseHelper =
      DatabaseHelper(); // Buat instance DatabaseHelper
  List<List<QuillController>> _controllers = [];
  @override
  void initState() {
    super.initState();
    presenter = DataLiteralisasiPresenter(model);
    _initializeControllers();
    // model.addDummyData(); // Menambahkan data dummy
    loadData();
  }

  void _initializeControllers() {
    var data = presenter.fetchDataFromModel(); // Ambil data
    _controllers = List.generate(data.length,
        (index) => List.generate(4, (i) => QuillController.basic()));
    // Inisialisasi kontroler
  }

  Future<void> loadData() async {
    try {
      await presenter.loadDataLitersi();
      final fetxh = presenter.fetchDataFromModel();
      setState(() {
        if (fetxh.isNotEmpty) {
          // Inisialisasi controllers berdasarkan data dari fetxh
          _controllers = List.generate(fetxh.length, (index) {
            // Ambil literasi dari fetxh
            var literasi = fetxh[index];
            print("konteesliterasi ${literasi.id}");
            print("konteeskkonteks ${literasi.konteksLiterai}");
            print("konteesnumerasi ${literasi.aktivitasNumerasi}");
            print("konteeskontesnumerasi ${literasi.konteksNumerasi}");
            // Inisialisasi daftar controllers untuk setiap literasi
            return List.generate(4, (i) {
              if (i == 0) {
                // Mengisi controller pertama dengan konteks literasi
                var jsonData = jsonDecode(literasi
                    .konteksLiterai!); // Pastikan konteksLiterai tidak null
                var document = Document.fromJson(jsonData);
                return QuillController(
                  document: document,
                  selection: const TextSelection.collapsed(offset: 0),
                );
              } else if (i == 1) {
                // Mengisi controller kedua dengan aktivitas literasi
                var jsonData = jsonDecode(literasi
                    .aktivitasLiterasi!); // Pastikan aktivitasLiterasi tidak null
                var document = Document.fromJson(jsonData);
                return QuillController(
                  document: document,
                  selection: const TextSelection.collapsed(offset: 0),
                );
              } else if (i == 2) {
                // Mengisi controller ketiga dengan konteks numerasi
                var jsonData = jsonDecode(literasi
                    .konteksNumerasi!); // Pastikan konteksNumerasi tidak null
                var document = Document.fromJson(jsonData);
                return QuillController(
                  document: document,
                  selection: const TextSelection.collapsed(offset: 0),
                );
              } else {
                // Mengisi controller keempat dengan aktivitas numerasi
                var jsonData = jsonDecode(literasi
                    .aktivitasNumerasi!); // Pastikan aktivitasNumerasi tidak null
                var document = Document.fromJson(jsonData);
                return QuillController(
                  document: document,
                  selection: const TextSelection.collapsed(offset: 0),
                );
              }
            });
          });
        }
      });
      // Setelah data dimuat, perbarui UI dengan setState
      // Panggil loadData dari presenter
    } catch (e) {
      print('Error loading data: $e'); // Menangani error jika ada
    }
  }

  void _removeAsesmen(int index) {
    presenter.removeAsesmen(index);
    setState(() {
      setState(() {
        // Perbarui state untuk memuat ulang UI setelah data dihapus
        presenter
            .fetchDataFromModel(); // Memperbarui data yang diambil dari model
      });
    });
  }

  @override
  void dispose() {
    // Dispose all controllers to free up resources
    for (var controllers in _controllers) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<DataLiterasi> data =
        presenter.fetchDataFromModel(); // Ambil data asesmen
    if (_controllers.length != data.length) {
      _initializeControllers(); // Reinitialize controllers if data length changes
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Literasi dan Numerasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16), // Spasi antar widget

            if (data
                .isNotEmpty) // Hanya menampilkan Expanded jika data tidak kosong
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var literasi = data[index];
                    var count = literasi.id ?? (literasi.id ?? 0) + 1; // Jika literasi.id null, gunakan 0
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pertemuan $count',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal),
                            ),
                            const SizedBox(height: 15), // Spasi antar widget
                            const Text(
                              'Konten dan Konteks Literasi',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal),
                            ),
                            const SizedBox(height: 10), // Spasi antar widget

                            QuillToolbar.simple(
                              controller: _controllers[index][0],
                              configurations: QuillSimpleToolbarConfigurations(
                                showCodeBlock: false,
                                showDividers: true,
                                showInlineCode: false,
                                embedButtons:
                                    FlutterQuillEmbeds.toolbarButtons(),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // QuillEditor untuk aktivitas literasi
                            Container(
                              height: 300, // Set your desired height here
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.9),
                                borderRadius: BorderRadius.circular(0.9),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: QuillEditor.basic(
                                controller: _controllers[index][0],
                                configurations: QuillEditorConfigurations(
                                  embedBuilders: kIsWeb
                                      ? FlutterQuillEmbeds.editorWebBuilders()
                                      : FlutterQuillEmbeds.editorBuilders(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20), // Spasi antar widget
                            const Text(
                              'Aktivitas Literasi',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal),
                            ),
                            const SizedBox(height: 10), // Spasi antar widget

                            QuillToolbar.simple(
                              controller: _controllers[index][1],
                              configurations: QuillSimpleToolbarConfigurations(
                                showCodeBlock: false,
                                showDividers: true,
                                showInlineCode: false,
                                embedButtons:
                                    FlutterQuillEmbeds.toolbarButtons(),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // QuillEditor untuk aktivitas literasi
                            Container(
                              height: 300, // Set your desired height here
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.9),
                                borderRadius: BorderRadius.circular(0.9),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: QuillEditor.basic(
                                controller: _controllers[index][1],
                                configurations: QuillEditorConfigurations(
                                  embedBuilders: kIsWeb
                                      ? FlutterQuillEmbeds.editorWebBuilders()
                                      : FlutterQuillEmbeds.editorBuilders(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16), // Spasi antar widget
                            const SizedBox(height: 20), // Spasi antar widget
                            const Text(
                              'Konten dan Konteks Numerasi',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal),
                            ),
                            const SizedBox(height: 10), // Spasi antar widget

                            QuillToolbar.simple(
                              controller: _controllers[index][2],
                              configurations: QuillSimpleToolbarConfigurations(
                                showCodeBlock: false,
                                showDividers: true,
                                showInlineCode: false,
                                embedButtons:
                                    FlutterQuillEmbeds.toolbarButtons(),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // QuillEditor untuk aktivitas literasi
                            Container(
                              height: 300, // Set your desired height here
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.9),
                                borderRadius: BorderRadius.circular(0.9),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: QuillEditor.basic(
                                controller: _controllers[index][2],
                                configurations: QuillEditorConfigurations(
                                  embedBuilders: kIsWeb
                                      ? FlutterQuillEmbeds.editorWebBuilders()
                                      : FlutterQuillEmbeds.editorBuilders(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16), // Spasi antar widget
                            const SizedBox(height: 20), // Spasi antar widget
                            const Text(
                              'Aktivitas Numerasi',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.normal),
                            ),
                            const SizedBox(height: 10), // Spasi antar widget

                            QuillToolbar.simple(
                              controller: _controllers[index][3],
                              configurations: QuillSimpleToolbarConfigurations(
                                showCodeBlock: false,
                                showDividers: true,
                                showInlineCode: false,
                                embedButtons:
                                    FlutterQuillEmbeds.toolbarButtons(),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // QuillEditor untuk aktivitas literasi
                            Container(
                              height: 300, // Set your desired height here
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.9),
                                borderRadius: BorderRadius.circular(0.9),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: QuillEditor.basic(
                                controller: _controllers[index][3],
                                configurations: QuillEditorConfigurations(
                                  embedBuilders: kIsWeb
                                      ? FlutterQuillEmbeds.editorWebBuilders()
                                      : FlutterQuillEmbeds.editorBuilders(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16), // Spasi antar widget
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    final konteksLiterajson =
                                        _controllers[index][0]
                                            .document
                                            .toDelta()
                                            .toJson();
                                    final aktivitasliteasijson =
                                        _controllers[index][1]
                                            .document
                                            .toDelta()
                                            .toJson();
                                    final konteksnumerisjson =
                                        _controllers[index][2]
                                            .document
                                            .toDelta()
                                            .toJson();
                                    final aktivitasnumeraasijson =
                                        _controllers[index][3]
                                            .document
                                            .toDelta()
                                            .toJson();
                                    final jsonStringliterasikonteks =
                                        jsonEncode(konteksLiterajson);
                                    final jsonStringakvitasliterasi =
                                        jsonEncode(aktivitasliteasijson);
                                    final jsonStringNumerasiKontes =
                                        jsonEncode(konteksnumerisjson);
                                    final jsonStringnumerasiAktif =
                                        jsonEncode(aktivitasnumeraasijson);
                                    var newLiterasi = DataLiterasi(
                                      id: count,
                                      konteksLiterai:
                                          jsonStringliterasikonteks, // Misalnya ini hasil dari Quill
                                      aktivitasLiterasi:
                                          jsonStringakvitasliterasi, // Ganti sesuai inputan
                                      konteksNumerasi: jsonStringNumerasiKontes,
                                      aktivitasNumerasi:
                                          jsonStringnumerasiAktif,
                                    );

                                    bool sukses = await presenter
                                        .addLIterasi(newLiterasi);
                                    if (sukses) {
                                      showAlertDialog(context, 'Berhasil',
                                          'Data berhasil disimpan.');
                                      setState(() {
                                        loadData();
                                      });
                                    } else {
                                      showAlertDialog(context, 'Gagal',
                                          'Data gagal disimpan. Silakan coba lagi.');
                                    }
                                  }, // Save data when pressed
                                  child: const Text('Simpan Data'),
                                ),
                                const SizedBox(width: 15), // Spacing between buttons
                                SizedBox(
                                  // Wrap Hapus button in SizedBox for custom width

                                  child: ElevatedButton(
                                    onPressed: () {
                                      _removeAsesmen(index);
                                    }, // Delete item when pressed
                                    child: const Text('Hapus Data'),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 16), // Spasi antar widget
                          ],
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
                    'Tambah Literasi dan Numerasi',
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
