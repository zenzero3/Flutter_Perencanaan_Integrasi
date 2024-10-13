import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContohPage extends StatefulWidget {
  const ContohPage({super.key});

  @override
  _ContohPageState createState() => _ContohPageState();
}

class _ContohPageState extends State<ContohPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Planner'),
      ),
      body: ActivityTable(),
    );
  }
}

class ActivityTable extends StatefulWidget {
  @override
  _ActivityTableState createState() => _ActivityTableState();
}

class _ActivityTableState extends State<ActivityTable> {
  final List<Activity> activities = [Activity()]; // Start with one activity

  void _addActivity(int index, {bool isSubActivity = false}) {
    setState(() {
      Activity newActivity = Activity();
      if (isSubActivity) {
        activities[index]
            .subActivities
            .add(newActivity); // Add as a sub-activity
      } else {
        activities.insert(index + 1, newActivity); // Insert new activity
      }
    });
  }

  String _prependNumbering(String text, int index, {int? subIndex}) {
    print('numbering');
    if (subIndex != null) {
      return '1.$subIndex. $text';
    }
    return '1. $text';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 50,
                child: Center(child: Text('No')),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text('Tahap')),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text('Aktivitas')),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text('Waktu')),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text('Ket')),
                ),
              ),
            ],
          ),
          // Divider line
          const Divider(thickness: 2),
          // Data Rows
          ...List<Widget>.generate(activities.length, (index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                        padding: const EdgeInsets.all(4.0),
                      child: Center(child: Text('${index + 1}')), // Numbering
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Isi Tahap',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            activities[index].tahap = value;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              maxLines: null, // Allow multiple lines
                              decoration: InputDecoration(
                                hintText: 'Aktivitas',
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(
                                text: _prependNumbering(
                                    activities[index].aktivitas.isEmpty
                                        ? 'Aktivitas'
                                        : activities[index].aktivitas,
                                    index + 1),
                              ), // Automatically prepend numbering
                              onChanged: (value) {
                                if (value.isEmpty || !value.startsWith('1.')) {
                                  activities[index].aktivitas = '1. $value';
                                } else {
                                  activities[index].aktivitas = value;
                                }
                              },
                            ),
                            // Display sub-activities
                            ...activities[index]
                                .subActivities
                                .asMap()
                                .entries
                                .map((entry) {
                              int subIndex = entry.key + 1;
                              return Container(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: TextField(
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: 'Sub Aktivitas',
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: TextEditingController(
                                    text: _prependNumbering(
                                      entry.value.aktivitas.isEmpty
                                          ? 'Sub Aktivitas'
                                          : entry.value.aktivitas,
                                      index + 1,
                                      subIndex: subIndex,
                                    ),
                                  ), // Automatically prepend numbering
                                  onChanged: (value) {
                                    if (value.isEmpty ||
                                        !value.startsWith('1.$subIndex.')) {
                                      entry.value.aktivitas =
                                          '1.$subIndex. $value';
                                    } else {
                                      entry.value.aktivitas = value;
                                    }
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Waktu',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            activities[index].waktu = value;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          maxLines: null, // Allow multiple lines
                          decoration: InputDecoration(
                            hintText: 'Keterangan',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            activities[index].ket = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(
                    thickness: 1), // Divider for better visual separation
              ],
            );
          }),
        ],
      ),
    );
  }
}

class Activity {
  String tahap = '';
  String aktivitas = '';
  String waktu = '';
  String ket = '';
  List<Activity> subActivities = []; // List to hold sub-activities
}
