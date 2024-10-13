// lib/view/data_pembelajaran_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:offlineapp/model/data_materi_model.dart';
import 'package:offlineapp/model/data_pembelajaran_model.dart';
import 'package:offlineapp/model/sub_materi_model.dart';
import 'package:offlineapp/presenter/data_pembelajaran_presenter.dart';
import 'package:offlineapp/utils/helper.dart';
import '../model/data_bahanajar_model.dart';
import '../presenter/data_bahanajar_presenter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DataPerencanaanPembelajaranPage extends StatefulWidget {
  const DataPerencanaanPembelajaranPage({super.key});

  @override
  _DataPerencanaanPembelajaranPageState createState() =>
      _DataPerencanaanPembelajaranPageState();
}

class _DataPerencanaanPembelajaranPageState
    extends State<DataPerencanaanPembelajaranPage> {
  final DataBahanAjar model = DataBahanAjar();
  late final DataBahanajarPresenter presenter;
  late final DataPembelajaranPresenter matkulPresent;
  List<List<QuillController>> _controllers = [];
  final List<Map<String, dynamic>> _data = List.generate(3, (index) {
    String tahap;

    // Menentukan nama tahap berdasarkan index
    switch (index) {
      case 0:
        tahap = 'Pendahuluan'; // Untuk index 0
        break;
      case 1:
        tahap = 'Inti'; // Untuk index 1
        break;
      case 2:
        tahap = 'Penutup'; // Untuk index 2
        break;
      default:
        tahap = ''; // Kosongkan jika index di luar rentang
    }

    return {
      'no': index + 1,
      'tahap': tahap,
      'aktivitas': '',
      'waktu': '',
      'keterangan': '',
    };
  });

  final _namaMataKuliahController = TextEditingController();
  final _tingkatJenjangController = TextEditingController();
  final _namaDosenController = TextEditingController();
  final _mataKuliahPrasyaratController = TextEditingController();
  final _capaianPembelajaranController = TextEditingController();
  final _mediaPembelajrantextController = TextEditingController();
  final _strategiUmumController = TextEditingController(); // Added
  final _assessmentUseController = TextEditingController(); // Added
  final _alokasiController = TextEditingController(); // Added
  final _bahanKajianController = TextEditingController(); // Added
  final _jumlahAlokasiWaktuController = TextEditingController(); // Added
  QuillController _controller = QuillController.basic();
  void _initializeControllers() {
    var data = presenter.fetchDataFromModel(); // Ambil data
    _controllers = List.generate(data.length,
        (index) => List.generate(999, (i) => QuillController.basic()));
    // Inisialisasi kontroler
  }

  @override
  void initState() {
    super.initState();
    DataPembelajaranModel datamodel = DataPembelajaranModel(
        namaMataKuliah: "",
        tingkatJenjang: "",
        namaDosen: "",
        mataKuliahPrasyarat: "",
        capaianPembelajaran: "",
        strategiUmum: "",
        mediaPembelajran: "",
        mediaPembelajrantext: "",
        assessmentUse: "",
        bahanKajian: "",
        JumlahAlokasiWaktu: "",
        MediaSumber: "");
    matkulPresent = DataPembelajaranPresenter(datamodel);
    presenter = DataBahanajarPresenter(model);
    _initializeControllers();
    // model.addDummyData(); // Menambahkan data dummy
    loadData();
  }

  Future<void> loadData() async {
    try {
      await matkulPresent.loadData();
      await presenter.fetchAndUpdateDataFromDatabase();

      final data = matkulPresent.getData();
      final datku = presenter.fetchDataFromModel();

      // Lakukan logika pemuatan data di sini
      if (data.isNotEmpty) {
        _namaMataKuliahController.text = data['Nama Mata Kuliah'] ?? '';
        _tingkatJenjangController.text = data['Tingkat/Jenjang'] ?? '';
        _namaDosenController.text = data['Nama Dosen'] ?? '';
        _mataKuliahPrasyaratController.text =
            data['Mata Kuliah Prasyarat'] ?? '';
        _capaianPembelajaranController.text =
            data['Capaian Pembelajaran'] ?? '';
        _mediaPembelajrantextController.text = data['Media Pembelajaran'] ?? '';
        _strategiUmumController.text = data['Strategi Umum'] ?? '';
        _assessmentUseController.text =
            data['Assessment Yang Di Gunakan'] ?? '';
        _bahanKajianController.text = data['Bahan Kajian'] ?? '';
        _jumlahAlokasiWaktuController.text = data['Jumlah Alokasi Waktu'] ?? '';

        // Decode JSON
        var jsonData = jsonDecode(data['Media / Sumber Belajar Umum']!);
        var document = Document.fromJson(jsonData);

        _controller = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } else {
        // Jika tidak ada data, reset text controller atau isi dengan default
        print('Database kosong, menampilkan form kosong');
        _namaMataKuliahController.clear();
        _tingkatJenjangController.clear();
        _namaDosenController.clear();
        _mataKuliahPrasyaratController.clear();
        _capaianPembelajaranController.clear();
        _mediaPembelajrantextController.clear();
        _strategiUmumController.clear();
        _assessmentUseController.clear();
        _bahanKajianController.clear();
        _jumlahAlokasiWaktuController.clear();
      }

      // Periksa apakah datku tidak kosong
      if (datku.isNotEmpty) {
        _controllers = List.generate(datku.length, (index) {
          final literasi = datku[index];

          print("konteksLiterasi ${literasi.materi?.id}");
          print("konteksAktivitasLiterasi ${literasi.materi?.relevansi}");
          print("konteksNumerasi ${literasi.materi?.tujuanpembelajaran}");
          print("konteksKontesNumerasi ${literasi.materi?.deskripsi}");

          // Inisialisasi daftar controllers untuk setiap literasi
          return List.generate(4, (i) {
            switch (i) {
              case 0:
                // Mengisi controller pertama dengan konteks literasi
                var jsonData = jsonDecode(literasi.materi?.deskripsi ?? '');
                var document = Document.fromJson(jsonData);
                return QuillController(
                  document: document,
                  selection: const TextSelection.collapsed(offset: 0),
                );
              case 1:
                // Mengisi controller kedua dengan aktivitas literasi
                var jsonData = jsonDecode(literasi.materi?.relevansi ?? '');
                var document = Document.fromJson(jsonData);
                return QuillController(
                  document: document,
                  selection: const TextSelection.collapsed(offset: 0),
                );
              case 2:
                // Mengisi controller ketiga dengan konteks numerasi
                var jsonData =
                    jsonDecode(literasi.materi?.tujuanpembelajaran ?? '');
                var document = Document.fromJson(jsonData);
                return QuillController(
                  document: document,
                  selection: const TextSelection.collapsed(offset: 0),
                );
              default:
                // Mengisi controller keempat dengan aktivitas numerasi
                var jsonData = jsonDecode(literasi.materi?.relevansi ?? '');
                var document = Document.fromJson(jsonData);
                return QuillController(
                  document: document,
                  selection: const TextSelection.collapsed(offset: 0),
                );
            }
          });
        });
      } else {
        // Jika datku kosong
        print('Data tidak ditemukan dalam model bahan ajar.');
      }

      // Setelah semua data dimuat dan diproses, perbarui UI dengan setState
      setState(() {});
    } catch (e) {
      print('Error loading data: $e'); // Menangani error jika ada
    }
  }

  @override
  void dispose() {
    _namaMataKuliahController.dispose();
    _tingkatJenjangController.dispose();
    _namaDosenController.dispose();
    _alokasiController.dispose();
    _mataKuliahPrasyaratController.dispose();
    _capaianPembelajaranController.dispose();
    _mediaPembelajrantextController.dispose();
    _strategiUmumController.dispose(); // Added
    _assessmentUseController.dispose(); // Added
    _bahanKajianController.dispose(); // Added
    _controller.dispose();
    super.dispose();
  }

  void _removeBahanajar(int index) {
    presenter.removeDataBahanajar(index);
    setState(() {
      setState(() {
        // Perbarui state untuk memuat ulang UI setelah data dihapus
        presenter.fetchDataFromModel();
        _initializeControllers();
        // Memperbarui data yang diambil dari model
      });
    });
  }

  Future<void> generateModulPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // Mendapatkan data dari parameter
    final namaMataKuliah = data['Nama Mata Kuliah'] ?? 'N/A';
    final tingkatJenjang = data['Tingkat/Jenjang'] ?? 'N/A';
    final namaDosen = data['Nama Dosen'] ?? 'N/A';
    final mataKuliahPrasyarat = data['Mata Kuliah Prasyarat'] ?? 'N/A';
    final capaianPembelajaran = data['Capaian Pembelajaran'] ?? 'N/A';
    final mediaSumberBelajar = data['Media / Sumber Belajar Umum'] ?? 'N/A';

    var jsonData = jsonDecode(mediaSumberBelajar!);
    var document = Document.fromJson(jsonData);
    stderr.writeln(document);

    // Menambahkan halaman dengan format seperti di gambar
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Membuat judul dengan latar belakang berwarna
              pw.Container(
                width: double.infinity,
                color: PdfColor.fromHex("#F4CCCC"),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'INFORMASI UMUM',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 10),

              // Bagian Identitas
              pw.Text(
                'A. IDENTITAS',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Membuat tabel identitas seperti pada gambar
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(150), // Atur lebar kolom pertama
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('Nama Penyusun',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Text(': $namaMataKuliah',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text('Tingkat/Jenjang',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Text(': $tingkatJenjang',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text('Nama Dosen',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Text(': $namaDosen',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text('Mata Kuliah Prasyarat',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Text(': $mataKuliahPrasyarat',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Text('Capaian Pembelajaran',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 12)),
                      pw.Text(': $capaianPembelajaran',
                          style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Menyimpan PDF ke file
    try {
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/modul_bahan_ajar.pdf");
      await file.writeAsBytes(await pdf.save());
      print("PDF disimpan di: ${file.path}");

      // Membuka file PDF setelah disimpan
      await OpenFile.open(file.path);
    } catch (e) {
      print("Error saat menyimpan PDF: $e");
    }
  }

  void _addNewEntry(String tahap, int index) {
    print('dataindex $index');
    print('dataindex $tahap');
    setState(() {
      // Menambahkan entri baru setelah entri yang ada di index tertentu
      _data.insert(index + 1, {
        'no': _data.length + 1,
        'tahap': tahap,
        'aktivitas': '',
        'waktu': '',
        'keterangan': '',
      });
    });
  }

  void _handleEnterPressed(
      String tahap, String waktu, String keterangan, int index) {
    if (waktu.isNotEmpty && keterangan.isNotEmpty) {
      _addNewEntry(tahap, index);
    } else {
      showAlertDialog(
          context, "Gagal Menambah Tabel ", "Harap Isi Semua Field");
    }
  }

  void _updateTahap(String tahap, String waktu, int index) {
    // Mengambil total waktu yang diinput oleh pengguna
    final totalWaktu = double.tryParse(waktu) ?? 0;

    // Perbarui tahap berdasarkan index dan waktu yang diinputkan
    setState(() {
      if (tahap == 'Pendahuluan') {
        _data[index]['tahap'] = 'Pendahuluan ($totalWaktu menit)';
      } else if (tahap == 'Inti') {
        _data[index]['tahap'] = 'Inti ($totalWaktu menit)';
      } else if (tahap == 'Penutup') {
        _data[index]['tahap'] = 'Penutup ($totalWaktu menit)';
      }
      _data[index]['waktu'] = waktu; // Menyimpan waktu
    });
  }

  int _calculateTotalWaktu() {
    int totalWaktu = 0;
    for (var row in _data) {
      int? waktu = int.tryParse(row['waktu'] ?? '');
      if (waktu != null) {
        totalWaktu += waktu;
      }
    }
    return totalWaktu;
  }

  @override
  Widget build(BuildContext context) {
    List<DataBahanAjar> data = presenter.fetchDataFromModel();
    if (_controllers.length != data.length) {
      _initializeControllers(); // Reinitialize controllers if data length changes
    }
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Perencanaan Pembelajaran',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons
                        .floppy_disk), // Menggunakan ikon floppy disk
                    onPressed: () async {
                      try {
                        // Memuat data dari matkulPresent
                        await matkulPresent.loadData();

                        // Mengambil data setelah load
                        final data = matkulPresent.getData();

                        // Memastikan data terisi sebelum membuat PDF
                        if (data.isNotEmpty) {
                          // Buat PDF menggunakan data yang telah dimuat
                          await generateModulPdf(data);
                        } else {
                          print('Data kosong, tidak dapat membuat PDF');
                        }
                      } catch (e) {
                        print("Error saat memuat data dan membuat PDF: $e");
                      }
                    },
                  ),
                ],
              ),
              const Text(
                'Identitas Mata Kuliah / Mata Pembelajaran',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  // Baris 1
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _namaMataKuliahController,
                          decoration: const InputDecoration(
                            labelText: 'Mata Pembelajaran / Nama Mata Kuliah ',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _tingkatJenjangController,
                          decoration: const InputDecoration(
                            labelText: 'Tingkat/Jenjang',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // Baris 2
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _namaDosenController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Guru / Dosen',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _mataKuliahPrasyaratController,
                          decoration: const InputDecoration(
                            labelText: 'Materi / Mata Kuliah Prasyarat',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _namaDosenController,
                          decoration: const InputDecoration(
                            labelText: 'Sekolah / Instansi',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _capaianPembelajaranController,
                          decoration: const InputDecoration(
                            labelText: 'Capaian Pembelajaran',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // Baris 3
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _mediaPembelajrantextController,
                          decoration: const InputDecoration(
                            labelText: 'Media Pembelajaran',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _strategiUmumController,
                          decoration: const InputDecoration(
                            labelText: 'Strategi Umum',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // Baris 4
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _assessmentUseController,
                          decoration: const InputDecoration(
                            labelText: 'Assessment yang Digunakan',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _assessmentUseController,
                          decoration: const InputDecoration(
                            labelText: 'Perhitungan 1 JP ( Menit )',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _assessmentUseController,
                          decoration: const InputDecoration(
                            labelText: 'Jumalah Alokasi Waktu',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // Set the border color
                        width: 1, // Set the border width
                      ),
                      borderRadius: BorderRadius.circular(5),

                      // Set the border radius
                    ),
                    // Add padding to the Column

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10.0),
                        const Padding(
                          padding: EdgeInsets.only(
                              left:
                                  16.0), // Padding 16.0 di bagian start (kiri)
                          child: Text(
                            'Media Sumber Belajar Umum',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        QuillToolbar.simple(
                          controller: _controller,
                          configurations: QuillSimpleToolbarConfigurations(
                            showCodeBlock: false,
                            showDividers: true,
                            showInlineCode: false,
                            embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                          ),
                        ),
                        Container(
                          height: 300, // Set your desired height here
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors
                                  .grey, // Set the border color for QuillEditor
                              width: 1, // Set the border width for QuillEditor
                            ),

                            borderRadius: BorderRadius.circular(
                                5), // Set the border radius for QuillEditor
                          ),
                          // Add padding to the Column
                          padding: const EdgeInsets.all(16.0),

                          child: QuillEditor.basic(
                            controller: _controller,
                            configurations: QuillEditorConfigurations(
                              embedBuilders: kIsWeb
                                  ? FlutterQuillEmbeds.editorWebBuilders()
                                  : FlutterQuillEmbeds.editorBuilders(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (data.isNotEmpty)
                    SizedBox(
                      height: 500,
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var literasi = data[index];
                          var count = literasi.materi?.id ??
                              (literasi.materi?.id ?? 0) +
                                  1; // Jika literasi.id null, gunakan 0
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  Text(
                                    'Pertemuan $count',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 15), // Spasi antar widget
                                  const Text(
                                    'Tujuan Pembelajaran',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][0],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][0],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'Kata / Frasa Kunci',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][1],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][1],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'Kompetensi yang Harus Dimiliki Sebelum Mempelajari Topik',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][2],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][2],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'TARGET DAN JUMLAH PESERTA DIDIK',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][3],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][3],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'PROFIL PELAJAR PANCASILA',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][4],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][4],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'SARANA DAN PRASARANA',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][5],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][5],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'MODA PEMBELAJARAN',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][6],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][6],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'KETERSEDIAAN MATERI',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][7],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][7],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'MATERI AJAR',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][8],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][8],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'Pertanyaan Inti',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][9],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][9],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'KEGIATAN PEMBELAJARAN UTAMA',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][10],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][10],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _assessmentUseController,
                                    decoration: const InputDecoration(
                                      labelText: 'JUDUL ASESMEN',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 10.0),
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'PENJELASAN ASESMEN',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][11],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][11],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  const SizedBox(height: 20),
                                  Text(
                                    'KEGIATAN PEMBELAJARAN $count',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _jumlahAlokasiWaktuController,
                                    decoration: InputDecoration(
                                      labelText:
                                          'ALOKASI WAKTU KEGIATAN $count', // Tidak ada const di sini
                                      border: OutlineInputBorder(),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 10.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const SizedBox(height: 20),
                                  Container(
                                    width: double
                                        .infinity, // Mengatur lebar Container
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: DataTable(
                                      columns: [
                                        DataColumn(label: Text('No')),
                                        DataColumn(label: Text('Tahap')),
                                        DataColumn(label: Text('Aktivitas')),
                                        DataColumn(label: Text('Waktu')),
                                        DataColumn(label: Text('Keterangan')),
                                        DataColumn(label: Text('Aksi')),
                                      ],
                                      rows: _data.asMap().entries.map((entry) {
                                        int index = entry.key;
                                        String tahap;

                                        // Menentukan tahap berdasarkan index
                                        switch (index) {
                                          case 0:
                                            tahap = 'Pendahuluan';
                                            break;
                                          case 1:
                                            tahap = 'Inti';
                                            break;
                                          case 2:
                                            tahap = 'Penutup';
                                            break;
                                          default:
                                            tahap =
                                                ''; // Kosongkan jika index di luar rentang
                                        }

                                        // Mendapatkan map dari data
                                        Map<String, dynamic> row = entry.value;

                                        return DataRow(cells: [
                                          DataCell(Text(row['no'].toString())),
                                          DataCell(
                                            TextField(
                                              controller: TextEditingController(
                                                  text: row['tahap']),
                                              enabled:
                                                  false, // Mengisi TextField dengan nilai dari row['tahap']
                                              decoration: InputDecoration(
                                                  hintText: 'Masukkan Waktu'),
                                            ),
                                          ), // Menggunakan tahap yang sudah ditentukan
                                          DataCell(
                                            SizedBox(
                                              width: 250,
                                              child: TextField(
                                                maxLines: null,
                                                onChanged: (value) {
                                                  row['aktivitas'] =
                                                      value; // Update aktivitas
                                                },
                                                decoration: InputDecoration(
                                                    hintText:
                                                        'Masukkan Aktivitas'),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            TextField(
                                              onChanged: (value) {
                                                row['waktu'] =
                                                    value; // Update waktu
                                              },
                                              decoration: InputDecoration(
                                                  hintText: 'Masukkan Waktu'),
                                            ),
                                          ),
                                          DataCell(
                                            TextField(
                                              onSubmitted: (value) {
                                                setState(() {});
                                                _handleEnterPressed(
                                                    row['tahap'],
                                                    row['waktu'],
                                                    value,
                                                    index); // Tangani enter
                                                // Tangani enter
                                              },
                                              onChanged: (value) {
                                                row['keterangan'] =
                                                    value; // Update keterangan
                                              },
                                              decoration: InputDecoration(
                                                  hintText:
                                                      'Masukkan Keterangan'),
                                            ),
                                          ),
                                          DataCell(
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                // Hitung jumlah tahapan
                                                int countPendahuluan = _data
                                                    .where((row) =>
                                                        row['tahap'] ==
                                                        'Pendahuluan')
                                                    .length;
                                                int countInti = _data
                                                    .where((row) =>
                                                        row['tahap'] == 'Inti')
                                                    .length;
                                                int countPenutup = _data
                                                    .where((row) =>
                                                        row['tahap'] ==
                                                        'Penutup')
                                                    .length;

                                                // Cek jika tahap yang ingin dihapus adalah 'Pendahuluan', 'Inti', atau 'Penutup'
                                                if ((row['tahap'] ==
                                                            'Pendahuluan' &&
                                                        countPendahuluan ==
                                                            1) ||
                                                    (row['tahap'] == 'Inti' &&
                                                        countInti == 1) ||
                                                    (row['tahap'] ==
                                                            'Penutup' &&
                                                        countPenutup == 1)) {
                                                  // Tampilkan pesan kesalahan
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          "Tidak dapat menghapus '${row['tahap']}' jika itu satu-satunya baris."),
                                                    ),
                                                  );
                                                } else {
                                                  setState(() {
                                                    _data.removeAt(
                                                        index); // Hapus row berdasarkan index
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity, // Lebar penuh
                                         padding: const EdgeInsets.only(left: 8.0, right: 130.5, top: 8.0, bottom: 8.0), // Padding dengan tambahan kanan
// Padding untuk ruang di dalam
                                    child: Text(
                                      'Total Waktu: ${_calculateTotalWaktu()} menit',
                                      textAlign: TextAlign
                                          .end, // Untuk pusatkan teks
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                 const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'LEMBAR KERJA SISWA / MAHASISWA',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][12],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][12],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'PENILAIAN SIKAP',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][13],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][13],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  const SizedBox(height: 20),
 const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'REFLEKSI GURU',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][14],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][14],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'REFLEKSI MURID',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][15],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][15],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),
 const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const SizedBox(
                                      height: 20), // Spasi antar widget
                                  const Text(
                                    'REFERENSI',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  const SizedBox(
                                      height: 10), // Spasi antar widget

                                  QuillToolbar.simple(
                                    controller: _controllers[index][16],
                                    configurations:
                                        QuillSimpleToolbarConfigurations(
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
                                    height: 150, // Set your desired height here
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 0.9),
                                      borderRadius: BorderRadius.circular(0.9),
                                    ),
                                    padding: const EdgeInsets.all(16.0),
                                    child: QuillEditor.basic(
                                      controller: _controllers[index][16],
                                      configurations: QuillEditorConfigurations(
                                        embedBuilders: kIsWeb
                                            ? FlutterQuillEmbeds
                                                .editorWebBuilders()
                                            : FlutterQuillEmbeds
                                                .editorBuilders(),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  const SizedBox(height: 20),
                                  // Spasi antar widget
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Simpan Data button
                                      SizedBox(
                                        height:
                                            50, // Set height to match other buttons
                                        width: 300, // Set a consistent width
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final konteksLiterajson =
                                                _controllers[index][0]
                                                    .document
                                                    .toDelta()
                                                    .toJson();
                                            final aktivitasLiteasijson =
                                                _controllers[index][1]
                                                    .document
                                                    .toDelta()
                                                    .toJson();
                                            final konteksNumerisjson =
                                                _controllers[index][2]
                                                    .document
                                                    .toDelta()
                                                    .toJson();
                                            final aktivitasNumeraasijson =
                                                _controllers[index][3]
                                                    .document
                                                    .toDelta()
                                                    .toJson();
                                            final jsonStringLiterasiKonteks =
                                                jsonEncode(konteksLiterajson);
                                            final jsonStringAktivitasLiterasi =
                                                jsonEncode(
                                                    aktivitasLiteasijson);
                                            final jsonStringNumerasiKonteks =
                                                jsonEncode(konteksNumerisjson);
                                            final jsonStringNumerasiAktif =
                                                jsonEncode(
                                                    aktivitasNumeraasijson);
                                            final konteksLiterajson2 =
                                                _controllers[index][4]
                                                    .document
                                                    .toDelta()
                                                    .toJson();
                                            final aktivitasLiteasijson2 =
                                                _controllers[index][5]
                                                    .document
                                                    .toDelta()
                                                    .toJson();
                                            final konteksNumerisjson2 =
                                                _controllers[index][6]
                                                    .document
                                                    .toDelta()
                                                    .toJson();
                                            final jsonStringLiterasiKonteks2 =
                                                jsonEncode(konteksLiterajson2);
                                            final jsonStringAktivitasLiterasi2 =
                                                jsonEncode(
                                                    aktivitasLiteasijson2);
                                            final jsonStringNumerasiKonteks2 =
                                                jsonEncode(konteksNumerisjson2);

                                            var updatedMateri = Materi(
                                              id: count, // Pastikan ID yang benar digunakan untuk update
                                              deskripsi:
                                                  jsonStringLiterasiKonteks,
                                              relevansi:
                                                  jsonStringAktivitasLiterasi,
                                              tujuanpembelajaran:
                                                  jsonStringNumerasiKonteks,
                                            );
                                            var updateSubmateri =
                                                SubMateriModel(
                                                    id: literasi.subMateriList
                                                        ?.length, // Sesuaikan dengan nilai yang diinginkan
                                                    ilustrasi:
                                                        jsonStringNumerasiAktif, // Isi nilai ilustrasi
                                                    contohstudikasus:
                                                        jsonStringLiterasiKonteks2, // Isi nilai contoh studi kasus
                                                    latihan:
                                                        jsonStringAktivitasLiterasi2 // Isi nilai latihan
                                                    );
                                            var dataBahanAjar = DataBahanAjar(
                                              materi: updatedMateri,
                                              subMateriList: [
                                                updateSubmateri
                                              ], // Tambahkan subMateri ke dalam list
                                            );

// Panggil metode addDataBahanajar untuk menambahkan data ke model dan database
                                            bool success = await presenter
                                                .addDataBahanajar(
                                                    dataBahanAjar);
                                            if (success) {
                                              showAlertDialog(
                                                  context,
                                                  'Berhasil',
                                                  'Data berhasil disimpan.');
                                            } else {
                                              showAlertDialog(context, 'Gagal',
                                                  'Data gagal disimpan. Silakan coba lagi.');
                                            }
                                            // Save data when pressed
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(255, 6, 51,
                                                    142), // Background color
                                          ),
                                          child: const Text(
                                            'Simpan Data',
                                            style: TextStyle(
                                                color:
                                                    Colors.white), // Text color
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          width: 15), // Spacing between buttons

                                      // Hapus Data button
                                      SizedBox(
                                        height:
                                            50, // Set height to match other buttons
                                        width: 300, // Set a consistent width
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _removeBahanajar(index);
                                            // Delete item when pressed
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors
                                                .red, // Set the background color to red
                                          ),
                                          child: const Text(
                                            'Hapus Data',
                                            style: TextStyle(
                                                color:
                                                    Colors.white), // Text color
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: 16), // Spasi antar widget
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    const Center(child: Text("")), // Pesan jika data kosong
                  const SizedBox(height: 10.0),
                  Center(
                    child: SizedBox(
                      height: 50,
                      width: 350,
                      child: ElevatedButton(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        style: const ButtonStyle(
                          foregroundColor: WidgetStatePropertyAll<Color>(
                            Color.fromARGB(255, 13, 20,
                                33), // Menggunakan warna yang diinginkan
                          ),
                          overlayColor: WidgetStatePropertyAll<Color>(
                            Color.fromARGB(255, 65, 119,
                                226), // Menggunakan warna yang diinginkan
                          ),
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            Color.fromARGB(255, 6, 51,
                                142), // Menggunakan warna yang diinginkan
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            presenter.populateDummyData();
                            // Tambahkan logika untuk menambahkan bahan ajar di sini
                          });
                        },
                        child: const Text(
                          'Tambahkan Rencana Pembelajaran',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
