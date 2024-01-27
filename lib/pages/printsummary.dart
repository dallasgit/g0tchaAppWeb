import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'common.dart';

class PrintSummaryScreen extends StatelessWidget {
  final List<DeliveryData> deliveries;
  final String riderName;
  final String profileUrl;
  final DateTime selectedDate;

  const PrintSummaryScreen(
      {super.key,
      required this.deliveries,
      required this.riderName,
      required this.profileUrl,
      required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    double totalDeliveryFee = 0.0;
    double totalHandlingFee = 0.0;
    double totalNetIncome = 0.0;
    if (deliveries.isNotEmpty) {
      totalDeliveryFee = deliveries
          .map((deliveryData) => deliveryData.deliveryFee)
          .reduce((value, element) => value + element);

      totalHandlingFee = deliveries
          .map((deliveryData) => deliveryData.handlingFeePercentage)
          .reduce((value, element) => value + element);
      totalNetIncome = totalDeliveryFee - totalHandlingFee;
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    Uri.encodeFull(profileUrl),
                    scale: 1.0,
                  ),
                  radius: 20,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
        title: const Text('Summary Report'),
      ),
      body: Column(children: [
        const SizedBox(height: 3),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Flexible(
                  child: Text('Poging Rider: $riderName',
                      style: const TextStyle(fontSize: 12.0))),
              const SizedBox(width: 115),
              Flexible(
                child: Text(DateFormat('MMMM d, yyyy').format(selectedDate),
                    style: const TextStyle(fontSize: 12.0)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Flexible(
                  child: Text('Total Delivery Count: ${deliveries.length}',
                      style: const TextStyle(fontSize: 12.0))),
              const SizedBox(width: 90),
              Flexible(
                  child: Text(
                      'Total Delivery Fee: ${totalDeliveryFee.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12.0))),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Flexible(
                  child: Text(
                      'Total Handling Fee: ${totalHandlingFee.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12.0))),
              const SizedBox(width: 95),
              Flexible(
                  child: Text(
                      'Total Income NET: ${totalNetIncome.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12.0))),
            ],
          ),
        ),
        DataTable(
          columnSpacing: 10,
          dataRowHeight: 25.0, // set the height to a smaller value
          columns: const [
            DataColumn(
                label: Expanded(
                    child: Text('Del#',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.0))),
                numeric: true),
            DataColumn(
                label: Expanded(
                    child: Text('Transit',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.0))),
                numeric: true),
            DataColumn(
                label: Expanded(
                    child: Text('Payment',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.0))),
                numeric: true),
            DataColumn(
                label: Expanded(
                    child: Text('Delivery Fee',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.0))),
                numeric: true),
            DataColumn(
                label: Expanded(
                    child: Text('HandlingFee',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.0))),
                numeric: true),
            DataColumn(
                label: Expanded(
                    child: Text('ExtraFee',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.0))),
                numeric: true),
          ],
          rows: deliveries.map((delivery) {
            return DataRow(
              cells: [
                DataCell(Center(
                    child: Text(delivery.deliveryNumber.toString(),
                        style: TextStyle(fontSize: 10.0)))),
                DataCell(Text(delivery.transitMode,
                    style: TextStyle(fontSize: 10.0))),
                DataCell(Center(
                    child: Text(delivery.paymentMode,
                        style: TextStyle(fontSize: 10.0)))),
                DataCell(Center(
                    child: Text(delivery.deliveryFee.toStringAsFixed(2),
                        style: TextStyle(fontSize: 10.0)))),
                DataCell(Center(
                    child: Text(
                        delivery.handlingFeePercentage.toStringAsFixed(2),
                        style: TextStyle(fontSize: 10.0)))),
                DataCell(Center(
                    child: Text(delivery.discount.toString(),
                        style: TextStyle(fontSize: 10.0)))),
              ],
            );
          }).toList(),
        ),
      ]),
    );
  }
}
