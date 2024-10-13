import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class Quil extends StatefulWidget {
  @override
  _QuilState createState() => _QuilState();
}

class _QuilState extends State<Quil> {
  List<List<QuillController>> _controllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (int i = 0; i < 3; i++) {
      List<QuillController> rowControllers = [];
      for (int j = 0; j < 2; j++) {
        var doc = Document()..insert(0, 'Text for editor $i,$j');
        var controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
        rowControllers.add(controller);
      }
      _controllers.add(rowControllers);
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Quill Editor in DataTable'),
    ),
    body: SingleChildScrollView( // Tambahkan SingleChildScrollView di sini
      child: Column(
        children: [
          // Konten yang menyebabkan overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('Column 1')),
                  DataColumn(label: Text('Quill Editor Column')),
                ],
                rows: List<DataRow>.generate(_controllers.length, (index) {
                  return DataRow(cells: [
                    DataCell(Text('Row $index, Column 1')),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 400, // Sesuaikan ukuran ini
                          maxHeight: 300, // Sesuaikan ukuran ini
                        ),
                        child: Column(
                          children: [
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
                            SizedBox(
                              height: 200, // Tinggi editor
                              child: QuillEditor.basic(
                                controller: _controllers[index][1],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
