import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';

void savePdfWeb(Uint8List pdfBytes) {
  final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Buat elemen HTML untuk memicu download
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "modul_bahan_ajar.pdf")
    ..click();

  // Bersihkan URL blob setelah selesai
  html.Url.revokeObjectUrl(url);
  print("PDF berhasil diunduh di Web.");
}
