import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Cart extends StatefulWidget {
  @override
  _FirebaseListScreenState createState() => _FirebaseListScreenState();
}

class _FirebaseListScreenState extends State<Cart> {
  late List<DocumentSnapshot> _allDocuments;
  List<DocumentSnapshot> _filteredDocuments = [];

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
    });
  }

  void _filterList(String searchText) {
    setState(() {
      _filteredDocuments = _allDocuments.where((document) {
        final item = document.data() as Map<String, dynamic>;
        final name = item['name'];
        return name.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    });
  }

  Future<void> _updateStatus(
      DocumentReference documentRef, bool newStatus, bool newStatus2) async {
    await documentRef.update({
      'livred': newStatus,
    });
    await documentRef.update({
      'reported': newStatus2,
    });
    setState(() {
      _fetchList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _filterList,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: _filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final document = _filteredDocuments[index];

                    final documentRef = document.reference;
                    final item = document.data() as Map<String, dynamic>;

                    final id = item['id'];
                    final name = item['name'];
                    List<dynamic>? productData =
                        item['product'] as List<dynamic>;
                    // List<MapEntry<String, dynamic>>? productList =
                    //     productData?.entries.toList();

                    bool livred = item['livred'];
                    bool reported = item['reported'];
                    final phone = item['phone'];
                    final GeoPoint location = item['latlon'];
                    final double latitude = location.latitude;
                    final double longitude = location.longitude;

                    return ListTile(
                      title: Container(
                        decoration: BoxDecoration(
                          color: livred
                              ? Color.fromARGB(255, 27, 129, 247)
                                  .withOpacity(0.5)
                              : reported
                                  ? Color.fromARGB(255, 36, 70, 110)
                                      .withOpacity(0.5)
                                  : Color.fromARGB(255, 93, 160, 236)
                                      .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB(255, 107, 107, 107)
                                  .withOpacity(0.5), // Shadow color
                              spreadRadius: 1, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset:
                                  Offset(0, 3), // Offset in x and y direction
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Select Status'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  title: Text('Livred'),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      livred = true;
                                                      reported = false;
                                                    });
                                                    _updateStatus(documentRef,
                                                        true, false);
                                                  },
                                                ),
                                                ListTile(
                                                  title: Text('Pending'),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      livred = false;
                                                      reported = false;
                                                    });
                                                    _updateStatus(documentRef,
                                                        false, false);
                                                  },
                                                ),
                                                ListTile(
                                                  title: Text('Reported'),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      livred = false;
                                                      reported = true;
                                                    });
                                                    _updateStatus(documentRef,
                                                        false, true);
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: livred
                                        ? Text(
                                            "Livred",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          )
                                        : reported
                                            ? Text(
                                                "Reported",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : Text(
                                                "Pending",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.shopping_cart,
                                      color: Color.fromARGB(255, 255, 230, 0),
                                      size: 27,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Center(
                                                child: Text('View Products')),
                                            content: Container(
                                              height: 150,
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  //mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    for (var product
                                                        in productData)
                                                      //final Map<String, dynamic> product = productData as Map<String, dynamic>;
                                                      ListTile(
                                                        title:
                                                            Column(children: [
                                                          Text(
                                                            'Name : ${product['name']} ',
                                                            style: TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            'Number : ${product['number']}',
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            'Price : ${product['price']} ',
                                                          ),
                                                          Text(
                                                            '-----------',
                                                          ),
                                                        ]),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.phone,
                                      color: Color.fromARGB(255, 0, 252, 8),
                                      size: 27,
                                    ),
                                    onPressed: () {
                                      launch('tel:+216$phone');
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      launch(
                                          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                    //////
                  })),
        ],
      ),
    );
  }
}

// class Home extends StatefulWidget {
//   @override
//   _FirebaseListScreenState createState() => _FirebaseListScreenState();
// }

// class _FirebaseListScreenState extends State<Home> {
//   Future<List<DocumentSnapshot>> _fetchList() async {
//     final CollectionReference collectionRef =
//         FirebaseFirestore.instance.collection('client_list');
//     final QuerySnapshot querySnapshot = await collectionRef.get();
//     return querySnapshot.docs;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<List<DocumentSnapshot>>(
//         future: _fetchList(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final List<DocumentSnapshot> documents = snapshot.data!;
//             return ListView.builder(
//               itemCount: documents.length,
//               itemBuilder: (context, index) {
//                 final document = documents[index];
//                 final item = document.data() as Map<String, dynamic>;
//                 final livred = item['livred'];
//                 final name = item['name'];
//                 final pending = item['pending'];
//                 final phone = item['phone'];
//                 final GeoPoint location = item['latlon'];
//                 final double latitude = location.latitude;
//                 final double longitude = location.longitude;

//                 print(item);
//                 return ListTile(
//                     title: item != null
//                         ? Container(
//                             decoration: BoxDecoration(
//                               color: Color.fromARGB(255, 66, 145, 236),
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             padding: EdgeInsets.all(8),
//                             margin: EdgeInsets.all(8),
//                             child: Column(
//                               children: [
//                                 Align(
//                                   alignment: Alignment.topLeft,
//                                   child: Text(
//                                     '$name',
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 20),
//                                   ),
//                                 ),
//                                 Align(
//                                   alignment: Alignment.bottomRight,
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       livred == true
//                                           ? Text(
//                                               "Livred",
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 16),
//                                             )
//                                           : Text(
//                                               "Pending",
//                                               style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontSize: 16),
//                                             ),
//                                       IconButton(
//                                         icon: Icon(
//                                           Icons.phone,
//                                           color: Colors.green,
//                                         ),
//                                         onPressed: () {
//                                           launch(
//                                               'tel:+216 $phone'); // Replace with the desired phone number
//                                         },
//                                       ),
//                                       IconButton(
//                                         icon: Icon(
//                                           Icons.location_on,
//                                           color: Colors.red,
//                                         ),
//                                         onPressed: () {
//                                           launch(
//                                               'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'); // Replace latitude and longitude with the desired location coordinates
//                                         },
//                                       )
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           )
//                         : const Text("no data")
//                     // Customize the ListTile widget as needed
//                     );
//               },
//             );
//           } else if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           }
//           return Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
// }