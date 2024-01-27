import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(const DeliverySummaryApp());

class DeliverySummaryApp extends StatelessWidget {
  const DeliverySummaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'g0tchaApp',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      routes: {'/': (context) => const DeliverySummaryTable()},
    );
  }
}

class DeliverySummaryTable extends StatefulWidget {
  const DeliverySummaryTable({Key? key}) : super(key: key);

  @override
  _DeliverySummaryTableState createState() => _DeliverySummaryTableState();
}

class _DeliverySummaryTableState extends State<DeliverySummaryTable> {
  String? _selectedDocumentId = "04-07-2023";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Records'),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Select a document ID:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc("09054417846")
                        .collection("dailyTransactions")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final docs = snapshot.data!.docs;
                      print('Number of documents returned: ${docs.length}');
                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          return ListTile(
                            title: Text(doc.id),
                            selected: _selectedDocumentId == doc.id,
                            onTap: () {
                              setState(() {
                                _selectedDocumentId = doc.id;
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _selectedDocumentId != null
                ? DeliveryRecordTable(documentId: _selectedDocumentId!)
                : const Center(
                    child: Text(
                      'No document selected',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class DeliveryRecordTable extends StatelessWidget {
  const DeliveryRecordTable({required this.documentId, Key? key})
      : super(key: key);

  final String documentId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('dailyTransactions')
          .doc(documentId)
          .collection('deliveries')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final docs = snapshot.data!.docs;
        return SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Delivery Number')),
              DataColumn(label: Text('Transit')),
              DataColumn(label: Text('Payment')),
              DataColumn(label: Text('Delivery Fee')),
              DataColumn(label: Text('Handling Fee')),
              DataColumn(label: Text('Extra Fee')),
            ],
            rows: snapshot.data!.docs.map((DocumentSnapshot document) {
              final Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return DataRow(cells: [
                DataCell(Text(data['deliveryNumber'] ?? '')),
                DataCell(Text(data['Transit'] ?? '')),
                DataCell(Text(data['Payment'] ?? '')),
                DataCell(Text(data['DeliveryFee']?.toString() ?? '')),
                DataCell(Text(data['HandlingFee']?.toString() ?? '')),
                DataCell(Text(data['ExtraFee']?.toString() ?? '')),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}
