import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:offlineapp/utils/helper.dart';
import '../presenter/data_pembelajaran_presenter.dart';
import 'data_pembelajaran_page.dart';
import 'data_bahanajar_page.dart';
import '../model/menu_model.dart';
import '../presenter/menu_presenter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MenuModel model = MenuModel(); // Membuat instance dari MenuModel
  late final MenuPresenter presenter; // Menentukan presenter

  int selectedIndex = 0; // Menyimpan indeks item yang dipilih

  @override
  void initState() {
    super.initState();
    presenter = MenuPresenter(model); // Menginisialisasi presenter dengan model
  }

  Widget _currentPage =
      Center(child: DataPembelajaranPage(
        key: UniqueKey(), // Memaksa rebuild halaman
        shouldReload: true, // Parameter untuk reload data
      )); // Halaman default
      
  void refreshData() {
    setState(() {
      selectedIndex = 0;
      _currentPage =
          Center(child: DataPembelajaranPage(
            key: UniqueKey(), // Memaksa rebuild halaman
        shouldReload: true, // Parameter untuk reload data
          )); // Refresh the main page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perencanaan Pembelajaran Integratif',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 11, 142, 229),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Row(
        children: [
          // Custom Sidebar
          Container(
            width: 300,
            color: Color.fromARGB(255, 54, 54, 228),
            child: Column(
              children: presenter
                  .getMenuItems(context, refreshData)
                  .asMap()
                  .entries
                  .map((entry) {
                int index = entry.key;
                var item = entry.value;

                // Menentukan apakah item saat ini dipilih
                bool isSelected = selectedIndex == index;

                return Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color.fromARGB(
                            255, 94, 107, 250) // Warna untuk item terpilih
                        : null, // Warna default jika tidak dipilih
                    border: Border.all(
                      color: Colors.transparent, // Warna border
                      width: 12, // Lebar border
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ListTile(
                    leading: FaIcon(
                      item.icon, // Ikon FontAwesome
                      color: isSelected
                          ? Colors.white
                          : Colors.grey, // Warna sesuai status terpilih
                      size: 20, // Sesuaikan ukuran ikon jika perlu
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: isSelected
                            ? Colors.white // Warna untuk item terpilih
                            : Colors.grey,
                        // Warna untuk item terpilih
                      ),
                    ),
                    onTap: item.press != null
                        ? () async {
                            DbCheckResult2 kondisi = await presenter.checkdb();
                            int length = kondisi.data?.length ??
                                0; // Use optional chaining to get length, or 0 if null
                            if (length != 0) {
                              item.press!();
                            }
                          }
                        : () async {
                            DbCheckResult2 kondisi = await presenter.checkdb();
                            int length = kondisi.data?.length ??
                                0; // Use optional chaining to get length, or 0 if null

                            if (length != 0 && index != 1 && index != 2) {
                              setState(() {
                                selectedIndex =
                                    index; // Memperbarui indeks item yang dipilih
                                _currentPage = item.onTap!; // Handle onTap
                              });
                            } else if (index == 1 || index == 0 || index == 2) {
                              setState(() {
                                selectedIndex =
                                    index; // Memperbarui indeks item yang dipilih
                                _currentPage = item.onTap!; // Handle onTap
                              });
                            } else {
                              print(index);
                              showAlertDialog(
                                  context,
                                  "Identitas Matakuliah Kosong",
                                  "Harap Lengkapi Identitas Matakuliah");
                            }
                          },
                  ),
                );
              }).toList(),
            ),
          ),
          // Konten Utama
          Expanded(
            child: _currentPage, // Halaman yang aktif akan ditampilkan di sini
          ),
        ],
      ),
    );
  }
}
