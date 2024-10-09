// lib/view/data_pembelajaran_page.dart
import 'package:flutter/material.dart';
import '../model/data_bahanajar_model.dart';
import '../presenter/data_bahanajar_presenter.dart';


class DataBahanajarPage extends StatelessWidget {
  final DataBahanajarPresenter presenter;

  DataBahanajarPage({Key? key})
      : presenter = DataBahanajarPresenter(DataBahanajarModel()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DataBahanajar> data = presenter.fetchDataFromModel();

    return Scaffold(
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(data[index] as String),
            onTap: ()=>{
              print('kodok')
            },
          );
        },
      ),
    );
  }
}
