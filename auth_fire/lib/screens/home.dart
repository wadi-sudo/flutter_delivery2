import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:auth_fire/screens/livred.dart';
import 'package:auth_fire/screens/pending.dart';
import 'package:auth_fire/screens/reported.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<DocumentSnapshot> _allDocuments;
  List<DocumentSnapshot> _filteredDocuments = [];
  double livredPercentage = 0.0;
  double reportedPercentage = 0.0;
  double pendingPercentage = 0.0;
  int livredCount = 0;
  int reportedCount = 0;
  int pendingCount = 0;
  @override
  void initState() {
    super.initState();
    _fetchList();
  }

  Future<void> _fetchList() async {
    final CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('client_list');
    final QuerySnapshot querySnapshot = await collectionRef.get();
    setState(() {
      _allDocuments = querySnapshot.docs;
      _filteredDocuments = _allDocuments;
      _calculateStatistics();
    });
  }

  void _calculateStatistics() {
    for (final document in _filteredDocuments) {
      final item = document.data() as Map<String, dynamic>;
      bool livred = item['livred'];
      bool reported = item['reported'];
      if (livred) {
        livredCount++;
      } else {
        if (reported) {
          reportedCount++;
        } else {
          pendingCount++;
        }
      }
    }

    int totalCount = _filteredDocuments.length;
    livredPercentage = totalCount > 0 ? (livredCount / totalCount) * 100 : 0.0;
    reportedPercentage =
        totalCount > 0 ? (reportedCount / totalCount) * 100 : 0.0;
    pendingPercentage =
        totalCount > 0 ? (pendingCount / totalCount) * 100 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ///////////////////////////////
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 250,
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          PieSeries<ChartData, String>(
                            dataSource: <ChartData>[
                              ChartData(
                                  'Livred',
                                  double.parse(
                                      livredPercentage.toStringAsFixed(2))),
                              ChartData(
                                  'Pending',
                                  double.parse(
                                      pendingPercentage.toStringAsFixed(2))),
                              ChartData(
                                  'Reported',
                                  double.parse(
                                      reportedPercentage.toStringAsFixed(2))),
                            ],
                            xValueMapper: (ChartData data, _) => data.category,
                            yValueMapper: (ChartData data, _) =>
                                data.percentage,
                            radius: '80%',
                            //innerRadius: '50%',
                            explode: true,
                            explodeIndex: 10,
                            explodeOffset: '10%',
                            startAngle: 180,
                            endAngle: 180,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                fontSize:
                                    20, // Specify the desired font size here
                              ),
                              labelPosition: ChartDataLabelPosition.outside,
                            ),
                            pointColorMapper: (ChartData data, _) {
                              if (data.category == 'Livred') {
                                return Color.fromARGB(255, 150, 185, 161);
                                //Color.fromARGB(255, 27, 129, 247);
                              } else if (data.category == 'Pending') {
                                return Color.fromARGB(255, 220, 221, 134);
                                //Color.fromARGB(255, 93, 160, 236);
                              } else if (data.category == 'Reported') {
                                return Color.fromARGB(255, 231, 152, 152);
                                //Color.fromARGB(255, 36, 70, 110);
                              }
                              return Colors.grey;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildLabel(
                            'Livred', Color.fromARGB(255, 150, 185, 161)),
                        SizedBox(
                          width: 20,
                        ),
                        buildLabel(
                            'Pending', Color.fromARGB(255, 220, 221, 134)),
                        SizedBox(
                          width: 20,
                        ),
                        buildLabel(
                            'Reported', Color.fromARGB(255, 231, 152, 152)),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Livredlist()),
                    );
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(216, 224, 224,
                            224), //Color.fromARGB(255, 27, 129, 247),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 143, 206, 162)
                                .withOpacity(0.5), // Shadow color
                            spreadRadius: 1, // Spread radius
                            blurRadius: 5, // Blur radius
                            offset: Offset(0, 3), // Offset in x and y direction
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.fromLTRB(10, 5, 10, 10),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle,
                              size: 60,
                              color: Color.fromARGB(255, 146, 196, 162)),
                          Text(
                            'Livred (${livredCount})',
                            //'Livred: ${livredPercentage.toStringAsFixed(2)}%',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          LinearProgressIndicator(
                            value: livredPercentage / 100,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 146, 196, 162)),
                          ),
                        ],
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => pendinglist()),
                    );
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(216, 224, 224,
                            224), //Color.fromARGB(255, 93, 160, 236),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 220, 221, 134)
                                .withOpacity(0.5), // Shadow color
                            spreadRadius: 1, // Spread radius
                            blurRadius: 5, // Blur radius
                            offset: Offset(0, 3), // Offset in x and y direction
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Icon(Icons.warning,
                              size: 60,
                              color: Color.fromARGB(255, 204, 206, 111)),
                          Text(
                            'Pending (${pendingCount})',
                            //'Pending: ${pendingPercentage.toStringAsFixed(2)}%',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          LinearProgressIndicator(
                            value: pendingPercentage / 100,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 214, 216, 110)),
                          ),
                        ],
                      )),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => reportedlist()),
                    );
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(216, 224, 224,
                            224), //Color.fromARGB(255, 36, 70, 110),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 226, 181, 181)
                                .withOpacity(0.5), // Shadow color
                            spreadRadius: 1, // Spread radius
                            blurRadius: 3, // Blur radius
                            offset: Offset(0, 3), // Offset in x and y direction
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Icon(Icons.report,
                              size: 60,
                              color: Color.fromARGB(255, 240, 132, 132)),
                          Text(
                            'Reported (${reportedCount})',
                            //'Reported: ${reportedPercentage.toStringAsFixed(2)}%',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          LinearProgressIndicator(
                            value: reportedPercentage / 100,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromARGB(255, 240, 132, 132)),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildLabel(String text, Color color) {
  return Row(
    children: [
      Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
      SizedBox(width: 10),
      Text(text),
    ],
  );
}

class ChartData {
  final String category;
  final double percentage;

  ChartData(this.category, this.percentage);
}
