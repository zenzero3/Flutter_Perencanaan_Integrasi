import '../model/menu_model.dart';
import 'package:flutter/material.dart';
import '../services/databaseHelper.dart';
import 'data_pembelajaran_presenter.dart';

class MenuPresenter {
  final MenuModel model;

  MenuPresenter(this.model); // Konstruktor yang memerlukan model

   List<MenuItem> getMenuItems(BuildContext context, Function refreshCallback) {
    return model.getMenuItems(() => _showDeleteConfirmationDialog(context, refreshCallback));
  }
Future<DbCheckResult2> checkdb() async {
    final dbHelper = DatabaseHelper();
    final data = await dbHelper.getAllData();

    if (data.isNotEmpty) {
      // Extracting IDs from the data, assuming data is a list of maps
      return DbCheckResult2(true, data);
    } else {
      return DbCheckResult2(false, null);
    }
  }
  // Fungsi untuk menampilkan dialog konfirmasi penghapusan
  void _showDeleteConfirmationDialog(BuildContext context, Function refreshCallback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Data Pembelajaran'),
          content: Text(
              'Apakah Anda yakin ingin menghapus semua data pembelajaran?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
            ),
            TextButton(
              child: Text('Hapus'),
              onPressed: () async {
                final dbHelper = DatabaseHelper();
                bool success =
                    await dbHelper.deleteAllData(); // Call to delete all data
                Navigator.of(context).pop(); // Close dialog

                // Show a Snackbar based on the result
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Data pembelajaran berhasil dihapus')),
                  );
                                 refreshCallback(); // Call the refresh method

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Gagal menghapus data pembelajaran')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
