// lib/view/data_pembelajaran_page.dart
import 'dart:convert';
import 'dart:io';

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
import 'package:offlineapp/view/data_pembelajaran_page.dart';
import '../model/data_bahanajar_model.dart';
import '../presenter/data_bahanajar_presenter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DataPerencanaanPembelajaranPage extends StatefulWidget {
  late final bool shouldReload;
  DataPerencanaanPembelajaranPage({Key? key, this.shouldReload = false}) : super(key: key);
  @override
  _DataPerencanaanPembelajaranPageState createState() => _DataPerencanaanPembelajaranPageState();
}

class _DataPerencanaanPembelajaranPageState extends State<DataPerencanaanPembelajaranPage> {
  final DataBahanAjar model = DataBahanAjar();
  late final DataBahanajarPresenter presenter;
  late final DataPembelajaranPresenter matkulPresent;
  List<List<QuillController>> _controllers = [];

  final _namaMataKuliahController = TextEditingController();
  final _tingkatJenjangController = TextEditingController();
  final _namaDosenController = TextEditingController();
  final _mataKuliahPrasyaratController = TextEditingController();
  final _capaianPembelajaranController = TextEditingController();
  final _mediaPembelajrantextController = TextEditingController();
  final _strategiUmumController = TextEditingController(); // Added
  final _assessmentUseController = TextEditingController(); // Added
  final _bahanKajianController = TextEditingController(); // Added
  final _jumlahAlokasiWaktuController = TextEditingController(); // Added
  QuillController _controller = QuillController.basic();
  void _initializeControllers() {
    var data = presenter.fetchDataFromModel();
    var nilai = data.length;
    print(
        'length of data: ${data.length}'); // Total number of elements in 'data'
    for (var i = 0; i < data.length; i++) {
      if (data[i].subMateriList?.length != data.length) {
        nilai = data[i].subMateriList!.length;
      }
      print(
          'length of subMateriList at index $i: ${data[i].subMateriList?.length ?? 0}');
    }
    print('length  $nilai');
    // Ambil data
    _controllers = List.generate(
        nilai, (index) => List.generate(10, (i) => QuillController.basic()));
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

      // Setelah data dimuat, perbarui UI dengan setState
      setState(() async {
        final data = matkulPresent.getData();
        final datku = presenter.fetchDataFromModel();
        if (data.isNotEmpty) {
          _namaMataKuliahController.text = data['Nama Mata Kuliah'] ?? '';
          _tingkatJenjangController.text = data['Tingkat/Jenjang'] ?? '';
          _namaDosenController.text = data['Nama Dosen'] ?? '';
          _mataKuliahPrasyaratController.text =
              data['Mata Kuliah Prasyarat'] ?? '';
          _capaianPembelajaranController.text =
              data['Capaian Pembelajaran'] ?? '';
          _mediaPembelajrantextController.text =
              data['Media Pembelajaran'] ?? '';
          _strategiUmumController.text = data['Strategi Umum'] ?? '';
          _assessmentUseController.text =
              data['Assessment Yang Di Gunakan'] ?? '';
          _bahanKajianController.text = data['Bahan Kajian'] ?? '';
          _jumlahAlokasiWaktuController.text =
              data['Jumlah Alokasi Waktu'] ?? '';

          if (data['Media / Sumber Belajar Umum'] != null) {
            var jsonData = jsonDecode(data['Media / Sumber Belajar Umum']!);
            var document = Document.fromJson(jsonData);
            _controller = QuillController(
              document: document,
              selection: TextSelection.collapsed(offset: 0),
            );
          }
        } else {
          // Jika tidak ada data, reset text controller atau isi dengan default
          print('Database kosong, menampilkan form kosong');
          _namaMataKuliahController.text = '';
          _tingkatJenjangController.text = '';
          _namaDosenController.text = '';
          _mataKuliahPrasyaratController.text = '';
          _capaianPembelajaranController.text = '';
          _mediaPembelajrantextController.text = '';
          _strategiUmumController.text = '';
          _assessmentUseController.text = '';
          _bahanKajianController.text = '';
          _jumlahAlokasiWaktuController.text = '';
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
                    selection: TextSelection.collapsed(offset: 0),
                  );
                case 1:
                  // Mengisi controller kedua dengan aktivitas literasi
                  var jsonData = jsonDecode(literasi.materi?.relevansi ?? '');
                  var document = Document.fromJson(jsonData);
                  return QuillController(
                    document: document,
                    selection: TextSelection.collapsed(offset: 0),
                  );
                case 2:
                  // Mengisi controller ketiga dengan konteks numerasi
                  var jsonData =
                      jsonDecode(literasi.materi?.tujuanpembelajaran ?? '');
                  var document = Document.fromJson(jsonData);
                  return QuillController(
                    document: document,
                    selection: TextSelection.collapsed(offset: 0),
                  );
                default:
                  // Mengisi controller keempat dengan aktivitas numerasi
                  var jsonData = jsonDecode(literasi.materi?.relevansi ?? '');
                  var document = Document.fromJson(jsonData);
                  return QuillController(
                    document: document,
                    selection: TextSelection.collapsed(offset: 0),
                  );
              }
            });
          });
        } else {
          print('Data tidak ditemukan dalam model bahan ajar.');
        }

        // Mengisi Text Controller jika ada data dari matkulPresent
      }); // Memanggil loadData dari presenter
    } catch (e) {
      print('Error loading data: $e'); // Menangani error jika ada
    }
  }

  @override
  void dispose() {
    _namaMataKuliahController.dispose();
    _tingkatJenjangController.dispose();
    _namaDosenController.dispose();
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
                0: pw.FixedColumnWidth(150), // Atur lebar kolom pertama
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text('Nama Penyusun',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.Text(': $namaMataKuliah', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Tingkat/Jenjang',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.Text(': $tingkatJenjang', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Nama Dosen',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.Text(': $namaDosen', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Mata Kuliah Prasyarat',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.Text(': $mataKuliahPrasyarat', style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Capaian Pembelajaran',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    pw.Text(': $capaianPembelajaran', style: pw.TextStyle(fontSize: 12)),
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
                  Expanded(
                    child: Text(
                      'Perencanaan Pembelajaran',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(CupertinoIcons
                        .floppy_disk), // Menggunakan ikon floppy disk
                    onPressed: () async {
                      try {
                        // Memuat data dari matkulPresent
                        await matkulPresent.loadData();

                        // Mengambil data setelah load
                        final data = matkulPresent.getData();

                        // Memastikan data terisi sebelum membuat PDF
                        if (data != null && data.isNotEmpty) {
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
              Text(
                'Identitas Mata Kuliah / Mata Pembelajaran',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              Column(
                children: [
                  // Baris 1
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _namaMataKuliahController,
                          decoration: InputDecoration(
                            labelText: 'Nama Mata Kuliah / Mata Pembelajaran',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _tingkatJenjangController,
                          decoration: InputDecoration(
                            labelText: 'Tingkat/Jenjang',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),

                  // Baris 2
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _namaDosenController,
                          decoration: InputDecoration(
                            labelText: 'Nama Dosen',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _mataKuliahPrasyaratController,
                          decoration: InputDecoration(
                            labelText: 'Mata Kuliah Prasyarat',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),

                  // Baris 3
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _capaianPembelajaranController,
                          decoration: InputDecoration(
                            labelText: 'Capaian Pembelajaran',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _mediaPembelajrantextController,
                          decoration: InputDecoration(
                            labelText: 'Media Pembelajaran',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),

                  // Baris 4
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _strategiUmumController,
                          decoration: InputDecoration(
                            labelText: 'Strategi Umum',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _assessmentUseController,
                          decoration: InputDecoration(
                            labelText: 'Assessment yang Digunakan',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),

                  // Baris 5
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bahanKajianController,
                          decoration: InputDecoration(
                            labelText: 'Bahan Kajian',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: _jumlahAlokasiWaktuController,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Alokasi Waktu',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // Set the border color
                        width: 1, // Set the border width
                      ),
                      borderRadius: BorderRadius.circular(5),

                      // Set the border radius
                    ),
                    padding: const EdgeInsets.only(
                        top: 16.0), // Add padding to the Column

                    child: Column(
                      children: [
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
                          padding: const EdgeInsets.all(
                              16.0), // Add padding to the Column

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
                    Container(
                      height: 500,
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var literasi = data[index];
                          var count = literasi.materi?.id == null
                              ? (literasi.materi?.id ?? 0) + 1
                              : literasi.materi
                                  ?.id; // Jika literasi.id null, gunakan 0
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 20),
                                  Text(
                                    'Pertemuan ${count}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  SizedBox(height: 15), // Spasi antar widget
                                  Text(
                                    'Tujuan Pembelajaran',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  SizedBox(height: 10), // Spasi antar widget

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
                                  SizedBox(height: 8),

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
                                  SizedBox(height: 20), // Spasi antar widget
                                  Text(
                                    'Relevansi',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  SizedBox(height: 10), // Spasi antar widget

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
                                  SizedBox(height: 8),

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

                                  SizedBox(height: 20), // Spasi antar widget
                                  Text(
                                    'Tujuan Pembelajaran',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal),
                                  ),
                                  SizedBox(height: 10), // Spasi antar widget

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
                                  SizedBox(height: 8),

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

                                  SizedBox(height: 20), // Spasi antar widget
                                  
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
                                            backgroundColor: Color.fromARGB(255,
                                                6, 51, 142), // Background color
                                          ),
                                          child: Text(
                                            'Simpan Data',
                                            style: TextStyle(
                                                color:
                                                    Colors.white), // Text color
                                          ),
                                        ),
                                      ),
                                      SizedBox(
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
                                          child: Text(
                                            'Hapus Data',
                                            style: TextStyle(
                                                color:
                                                    Colors.white), // Text color
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16), // Spasi antar widget
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Center(child: Text("")), // Pesan jika data kosong
                  SizedBox(height: 10.0),
                  Center(
                    child: SizedBox(
                      height: 50,
                      width: 350,
                      child: ElevatedButton(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        style: ButtonStyle(
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
