import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart'; // Import file_selector
import 'package:offlineapp/services/pdf_desktop.dart';
import 'package:offlineapp/services/pdf_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Untuk Membuat PDF
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import '../presenter/data_pembelajaran_presenter.dart';
import '../model/data_pembelajaran_model.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../utils/helper.dart';

class DataPembelajaranPage extends StatefulWidget {
  final bool shouldReload; // Change 'late final' to 'final'

  const DataPembelajaranPage(
      {super.key, this.shouldReload = false}); // Default to false

  @override
  _DataPembelajaranPageState createState() => _DataPembelajaranPageState();
}

Future<void> generateModulPdf(Map<String, dynamic> data) async {
  final pdf = pw.Document();

  // Mendapatkan data dari parameter
  // final namaMataKuliah = data['Nama Mata Kuliah'] ?? 'N/A';
  // final tingkatJenjang = data['Tingkat/Jenjang'] ?? 'N/A';
  // final namaDosen = data['Nama Dosen'] ?? 'N/A';
  // final mataKuliahPrasyarat = data['Mata Kuliah Prasyarat'] ?? 'N/A';
  // final capaianPembelajaran = data['Capaian Pembelajaran'] ?? 'N/A';

  // Cek apakah data 'Media / Sumber Belajar Umum' tersedia dan berbentuk JSON
  Document? document;
  // if (data['Media / Sumber Belajar Umum'] != null) {
  //   var jsonData = jsonDecode(data['Media / Sumber Belajar Umum']);
  //   document = Document.fromJson(jsonData); // Ini untuk mengubah Quill JSON ke dalam format dokumen
  // }

  // Menambahkan halaman dengan format yang diinginkan
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('A. IDENTITAS',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Nama Mata Kuliah : ',
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.Text('Tingkat/Jenjang : ',
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.Text('Nama Dosen : ', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.Text('Mata Kuliah Prasyarat : ',
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 5),
            pw.Text('Capaian Pembelajaran : ',
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),

            // Bagian untuk menampilkan 'Media / Sumber Belajar Umum'
          ],
        );
      },
    ),
  );
    final pdfBytes = await pdf.save(); // Menyimpan PDF ke dalam bytes
 try {
    if (kIsWeb) {
      // Panggil fungsi untuk web
      savePdfWeb(pdfBytes);
    } else {
      // Panggil fungsi untuk desktop
      await savePdfDesktop(pdfBytes);
    }
  } catch (e) {
    print("Error saat menyimpan PDF: $e");
  }
}

class _DataPembelajaranPageState extends State<DataPembelajaranPage> {
  late DataPembelajaranPresenter presenter;

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
  final _mediaSumberWaktuController = TextEditingController(); // Added
  QuillController _controller = QuillController.basic();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final model = DataPembelajaranModel(
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
      JumlahAlokasiWaktu: '',
      MediaSumber: '',
    );
    presenter = DataPembelajaranPresenter(model);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.shouldReload) {
      loadData();
    }
  }

  Future<void> loadData() async {
    try {
      await presenter.loadData();
      // Setelah data dimuat, perbarui UI dengan setState
      setState(() {
        final data = presenter.getData();
        print('d$data');

        if (data.isNotEmpty) {
          // Jika ada data, masukkan ke text controller
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
          var jsonData = jsonDecode(data['Media / Sumber Belajar Umum']!);
          var document = Document.fromJson(jsonData);
          _controller = QuillController(
            document: document,
            selection: const TextSelection.collapsed(offset: 0),
          );
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
      }); // Panggil loadData dari presenter
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

  // Function to pick an image from the folder using file_selector
  Future<void> _pickImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'jpeg', 'png'],
    );

    final XFile? result = await openFile(acceptedTypeGroups: [typeGroup]);

    if (result != null) {
      setState(() {
        _selectedImage = File(result.path);
      });
      presenter.updateData(mediaPembelajran: result.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Identitas Mata Pembelajaran / Mata Kuliah',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _namaMataKuliahController,
                decoration: const InputDecoration(
                  labelText: 'Mata Pembelajaran / Nama Mata Kuliah',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _tingkatJenjangController,
                decoration: const InputDecoration(
                  labelText: 'Tingkat/Jenjang',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _namaDosenController,
                decoration: const InputDecoration(
                  labelText: 'Nama Penyusun',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _namaDosenController,
                decoration: const InputDecoration(
                  labelText: 'Sekolah / Instansi ',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _mataKuliahPrasyaratController,
                decoration: const InputDecoration(
                  labelText: 'Materi / Mata Kuliah Prasyarat',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _capaianPembelajaranController,
                decoration: const InputDecoration(
                  labelText: 'Capaian Pembelajaran',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _strategiUmumController, // Added field
                decoration: const InputDecoration(
                  labelText: 'Strategi Umum',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _assessmentUseController, // Added field
                decoration: const InputDecoration(
                  labelText: 'Assessmen Yang Digunakan',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _bahanKajianController, // Added field
                decoration: const InputDecoration(
                  labelText: 'Bahan Kajian',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _mediaPembelajrantextController, // Added field
                decoration: const InputDecoration(
                  labelText: 'Media Pembelajaran',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),

              const SizedBox(height: 25),
              TextFormField(
                controller: _jumlahAlokasiWaktuController, // Added field
                decoration: const InputDecoration(
                  labelText: 'Jumlah Alokasi Waktu',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.only(
                    left: 12.0), // Set your desired margin here
                child: const Text(
                  'Media / Sumber Belajar Umum',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 10),
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

              // Column(
              //   children: [
              //     if (presenter.getData()['Media Pembelajaran'] != null &&
              //         presenter.getData()['Media Pembelajaran']!.isNotEmpty)
              //       ClipRRect(
              //         borderRadius: BorderRadius.circular(8.0),
              //         child: Image.file(
              //           File(presenter.getData()['Media Pembelajaran']!), // Display image from mediaPembelajran
              //           width: 250,
              //           height: 200,
              //           fit: BoxFit.cover,
              //         ),
              //       )
              //     else if (_selectedImage != null) // Check if an image was selected
              //       ClipRRect(
              //         borderRadius: BorderRadius.circular(8.0),
              //         child: Image.file(
              //           _selectedImage!,
              //           width: 250,
              //           height: 200,
              //           fit: BoxFit.cover,
              //         ),
              //       )
              //     else
              //       Container(
              //         width: 250,
              //         height: 200,
              //         decoration: BoxDecoration(
              //           border: Border.all(color: Colors.grey),
              //           borderRadius: BorderRadius.circular(8.0),
              //         ),
              //         child: Center(child: Text('Tidak ada gambar terpilih')),
              //       ),
              //     SizedBox(height: 10),
              //     ElevatedButton(
              //       onPressed: _pickImage,
              //       child: Text('Pilih Media Pembelajaran'),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 25),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                       
                      final jsonData = _controller.document.toDelta().toJson();
                      final jsonString =
                          jsonEncode(jsonData); // Convert to JSON string
                      presenter.updateData(
                        namaMataKuliah: _namaMataKuliahController.text,
                        tingkatJenjang: _tingkatJenjangController.text,
                        namaDosen: _namaDosenController.text,
                        mataKuliahPrasyarat:
                            _mataKuliahPrasyaratController.text,
                        capaianPembelajaran:
                            _capaianPembelajaranController.text,
                        mediaPembelajran: _mediaPembelajrantextController.text,
                        mediaPembelajrantext:
                            _mediaPembelajrantextController.text,
                        strategiUmum: _strategiUmumController.text,
                        assessmentUse: _assessmentUseController.text,
                        bahanKajian: _bahanKajianController.text,
                        jumlahAlokasiWaktu: _jumlahAlokasiWaktuController.text,
                        mediaSumber: jsonString,
                      );
                      DbCheckResult kondisi = await presenter.checkdb();
                      // Convert it to a string
                      if (kondisi.isNotEmpty) {
                        bool success = await presenter
                            .updateDataInDb(kondisi.ids[0]); // Menunggu hasil
                        if (success) {
                          showAlertDialog(context, 'Berhasil',
                              'Data Identitas Mata Kuliah / Mata Pelajaran Berhasil Disimpan');
                        } else {
                          showAlertDialog(context, 'Gagal',
                              'Data gagal disimpan. Silakan coba lagi.');
                        }
                      } else {
                        bool success =
                            await presenter.saveData(); // Menunggu hasil
                        if (success) {
                          showAlertDialog(
                              context, 'Berhasil', 'Data berhasil disimpan.');
                        } else {
                          showAlertDialog(context, 'Gagal',
                              'Data gagal disimpan. Silakan coba lagi.');
                        }
                      }
                    },
                    child: const Text(
                      'Simpan Data',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
