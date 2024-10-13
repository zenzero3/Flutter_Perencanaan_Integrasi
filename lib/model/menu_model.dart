import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:offlineapp/model/data_bahanajar_model.dart';
import 'package:offlineapp/view/contoh_page.dart';
import 'package:offlineapp/view/data_assesment_page.dart';
import 'package:offlineapp/view/data_bahanajar_page.dart';
// import 'package:offlineapp/view/data_bahanajar_page.dart';
import 'package:offlineapp/view/data_literasi_numerasi_page.dart';
import 'package:offlineapp/view/data_pembelajaran_page.dart';
import 'package:offlineapp/view/data_perencanaan_pembelajaran_page.dart';
import 'package:offlineapp/view/quil.dart';
// import 'package:offlineapp/view/data_perencanaan_pembelajaran_page.dart';

class MenuItem {
  final String title;
  final Widget? onTap; // Untuk navigasi
  final Function? press; // Fungsi untuk aksi
  final IconData icon;

  MenuItem({
    this.press,
    required this.title,
    this.onTap,
    required this.icon,
  });
}

class MenuModel {
  List<MenuItem> getMenuItems(Function deleteConfirmationCallback) {
    return [
      MenuItem(
        title: 'Identitas Mata Kuliah / Mata Pembelajaran',
        onTap: DataPembelajaranPage(
          key: UniqueKey(), // Memaksa rebuild halaman
          shouldReload: true, // Parameter untuk reload data
        ),
        icon: FontAwesomeIcons.book, // Menambahkan ikon
      ),
      MenuItem(
          title: 'Perencanaan Pembelajaran',
          onTap: DataPerencanaanPembelajaranPage(),
          icon: FontAwesomeIcons.listCheck),
           MenuItem(
          title: 'Bahan Ajar',
          onTap: DataBahanajarPage(),
          icon: FontAwesomeIcons.list),
      MenuItem(
          title: 'Asesmen',
          onTap: const DataAssessmentPage(),
          icon: FontAwesomeIcons.chartGantt),
      MenuItem(
        title: 'Literasi Numerasi',
        icon: FontAwesomeIcons.listOl,
        onTap: const DataLiterasiNumerasiPage(),
      ),
      MenuItem(
          press: () {
            print(
                "Button clicked"); // Debugging untuk memastikan callback dipanggil
            deleteConfirmationCallback();
          },
          title: 'Hapus Data Pembelajaran',
          icon: FontAwesomeIcons.trashArrowUp),
    ];
  }
}
