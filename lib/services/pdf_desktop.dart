import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<void> savePdfDesktop(Uint8List pdfBytes) async {
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/modul_bahan_ajar.pdf");
  await file.writeAsBytes(pdfBytes);
  print("PDF disimpan di: ${file.path}");

  // Buka file PDF setelah disimpan
  await OpenFile.open(file.path);
}
