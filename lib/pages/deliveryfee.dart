import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ig0tchaapp/pages/printsummary.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common.dart';
import 'firebase.dart';
import 'login.dart';
import 'user_session.dart';

void main() {
  runApp(const DeliveryFeeApp());
}

class DeliveryFeeApp extends StatelessWidget {
  const DeliveryFeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'g0tchaApp',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      routes: {'/': (context) => const DeliveryFeeScreen()},
    );
  }
}

class DeliveryFeeScreen extends StatefulWidget {
  const DeliveryFeeScreen({super.key});
  @override
  _DeliveryFeeScreenState createState() => _DeliveryFeeScreenState();
}

class _DeliveryFeeScreenState extends State<DeliveryFeeScreen> {
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  bool _fabVisible = true;
  bool _isExpanded = false;
  final _focusNode = FocusNode();

  List<DeliveryData> deliveryList = [];
  Map<String, dynamic> userSessionData = {};
  UserSession userSession = UserSession();
  String profileUrl = "";
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _fabVisible = !_focusNode.hasFocus;
      });
    });
    userSession.checkSession().then((isLoggedIn) async {
      setState(() {});
      if (isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Logged in successfully, Boss ${userSession.name}!')),
        );

        FirebaseService.instance
            .getDeliveryRecords(userSession.userId,
                DateFormat('MM-dd-yyyy').format(selectedDate))
            .then((deliveryListData) async {
          setState(() {
            deliveryList = deliveryListData;
          });
        });
      } else {
        await userSession.signOutSession();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void redirectToLoginPage() {
    // Code to redirect the user to the login page...
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()),
    );
  }

  void _addDelivery(DeliveryData delivery) {
    setState(() {
      deliveryList.add(delivery);
    });
  }

  void _removeDelivery(int index) {
    setState(() {
      deliveryList.removeAt(index);
    });
  }

  void _updateFabVisibility(bool hasFocus) {
    setState(() {
      _fabVisible = !hasFocus;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime date) {
        return date.isBefore(DateTime.now()) ||
            date.isAtSameMomentAs(DateTime.now());
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
    //print(DateFormat('MM-dd-yyyy').format(selectedDate));
    List<DeliveryData> deliveryListData = await FirebaseService.instance
        .getDeliveryRecords(
            userSession.userId, DateFormat('MM-dd-yyyy').format(selectedDate));
    setState(() {
      deliveryList = deliveryListData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              Text(
                'Hello ${userSession.aliasName?.isEmpty ?? true ? userSession.name : userSession.aliasName}!',
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    Uri.encodeFull(userSession.profileUrl),
                    scale: 1.0,
                  ),
                  radius: 20,
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
        title: const Text('BookingReceipt Calc2.0'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: userSession.isLoggedIn
            ? Column(
                children: [
                  const SizedBox(height: 5),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Delivery date:',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('MMMM d, yyyy').format(selectedDate),
                          style: const TextStyle(fontSize: 11),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 16.0,
                          height: 16.0,
                          child: FloatingActionButton(
                            onPressed: () => _selectDate(context),
                            child: const Icon(
                              Icons.calendar_today,
                              size: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DeliveryFeeForm(
                      deliveryList: deliveryList,
                      onAddDelivery: _addDelivery,
                      onTextEditingCtrlFocus: _updateFabVisibility,
                      focusNode: _focusNode),
                  DeliveryTable(
                      deliveries: deliveryList,
                      onDelete: _removeDelivery,
                      screenshotController: screenshotController),
                ],
              )
            : Center(
                child: ElevatedButton(
                child: const Text("Sign In, Pre!"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              )),
      ),
      floatingActionButton: _fabVisible
          ? Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              SizedBox(
                width: 32.0,
                height: 32.0,
                child: FloatingActionButton(
                  onPressed: () {
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        50.0,
                        MediaQuery.of(context).size.height - 70,
                        MediaQuery.of(context).size.width - 70,
                        0.0,
                      ),
                      items: <PopupMenuEntry>[
                        PopupMenuItem(
                          child: ListTile(
                            leading: const Icon(Icons.report),
                            title: const Text('View Report'),
                            onTap: () {
                              Navigator.pop(context); // Close the popup menu
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrintSummaryScreen(
                                      deliveries: deliveryList,
                                      riderName: userSession.name,
                                      profileUrl: userSession.profileUrl,
                                      selectedDate: selectedDate),
                                ),
                              );
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: ListTile(
                            leading: const Icon(Icons.save),
                            title: const Text('Save Report'),
                            onTap: () async {
                              await FirebaseService.instance.addDeliveryRecords(
                                  userSession.userId,
                                  DateFormat('MM-dd-yyyy').format(selectedDate),
                                  deliveryList);
                              if (deliveryList.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Records are Successfully Saved Rudder! Thanks ${userSession.name}!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Agi-ADD ka pay kuma Pre ${userSession.name}, bago agi-Save :)')),
                                );
                              }
                              Navigator.pop(context); // Close the popup menu
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  child: const Icon(Icons.menu),
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 32.0,
                height: 32.0,
                child: FloatingActionButton(
                  onPressed: () async {
                    await userSession.signOutSession();
                    await userSession.clearSessionData();
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.logout_sharp),
                ),
              ),
            ])
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

class DeliveryFeeForm extends StatefulWidget {
  final void Function(DeliveryData delivery) onAddDelivery;
  final void Function(bool hasFocus) onTextEditingCtrlFocus;
  final List<DeliveryData> deliveryList;
  final FocusNode focusNode;
  const DeliveryFeeForm(
      {super.key,
      required this.deliveryList,
      required this.onAddDelivery,
      required this.onTextEditingCtrlFocus,
      required this.focusNode});

  @override
  _DeliveryFeeFormState createState() => _DeliveryFeeFormState();
}

class _DeliveryFeeFormState extends State<DeliveryFeeForm> {
  TextEditingController deliveryNumberController = TextEditingController();
  TextEditingController deliveryFeeController = TextEditingController();
  TextEditingController handlingFeeController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  FocusNode focusNodeDeliveryNumber = FocusNode();
  FocusNode focusNodeDeliveryFee = FocusNode();
  FocusNode focusNodeHandlingFee = FocusNode();
  FocusNode focusNodeDiscount = FocusNode();

  bool handlingFeeSwitch = false;
  bool discountSwitch = false;
  bool paymentModeSwitch = false;
  bool transitModeSwitch = false;
  int defaultHandlingFeePercentage = 20;
  int baseDeliveryFee = 55;
  double totalDeliveryFee = 0;

  @override
  void initState() {
    super.initState();
    focusNodeDeliveryNumber.addListener(() {
      widget.onTextEditingCtrlFocus(focusNodeDeliveryNumber.hasFocus);
    });
    focusNodeDeliveryFee.addListener(() {
      widget.onTextEditingCtrlFocus(focusNodeDeliveryFee.hasFocus);
    });
    focusNodeHandlingFee.addListener(() {
      widget.onTextEditingCtrlFocus(focusNodeHandlingFee.hasFocus);
    });
    focusNodeDiscount.addListener(() {
      widget.onTextEditingCtrlFocus(focusNodeDiscount.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalDeliveryFee = 0.0;
    double totalHandlingFee = 0.0;
    double totalNetIncome = 0.0;
    if (widget.deliveryList.isNotEmpty) {
      totalDeliveryFee = widget.deliveryList
          .map((deliveryData) => deliveryData.deliveryFee)
          .reduce((value, element) => value + element);

      totalHandlingFee = widget.deliveryList
          .map((deliveryData) => deliveryData.handlingFeePercentage)
          .reduce((value, element) => value + element);
      totalNetIncome = totalDeliveryFee - totalHandlingFee;
    }

    return Column(
      children: [
        TextField(
          focusNode: focusNodeDeliveryNumber,
          controller: deliveryNumberController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction:
              TextInputAction.next, // allows keyboard to go to next field
          decoration: const InputDecoration(
            labelText: 'Delivery Number',
            labelStyle: TextStyle(fontSize: 12.0),
          ),
        ),
        TextField(
          focusNode: focusNodeDeliveryFee,
          controller: deliveryFeeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
          ],
          textInputAction:
              TextInputAction.done, // allows keyboard to go to next field
          decoration: const InputDecoration(
            labelText: 'Delivery Fee Amount',
            labelStyle: TextStyle(fontSize: 12.0),
          ),
        ),
        Row(
          children: [
            const Text('Handling Fee Percentage',
                style: TextStyle(fontSize: 12.0)),
            const Spacer(),
            Switch(
              value: handlingFeeSwitch,
              onChanged: (value) {
                setState(() {
                  handlingFeeSwitch = value;
                  if (!handlingFeeSwitch) {
                    handlingFeeController.clear();
                  }
                });
              },
            ),
          ],
        ),
        handlingFeeSwitch
            ? TextField(
                focusNode: focusNodeHandlingFee,
                controller: handlingFeeController,
                keyboardType: TextInputType.number,
                textInputAction:
                    TextInputAction.next, // allows keyboard to go to next field
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Enter Handling Fee Percentage',
                  labelStyle: TextStyle(fontSize: 12.0),
                ),
              )
            : Text(
                'Default Handling Fee Percentage: $defaultHandlingFeePercentage%',
                style: const TextStyle(fontSize: 12.0)),
        Row(
          children: [
            const Text('Discounts for BW/Shakeys/Others',
                style: TextStyle(fontSize: 12.0)),
            const Spacer(),
            Switch(
              value: discountSwitch,
              onChanged: (value) {
                setState(() {
                  discountSwitch = value;
                  if (!discountSwitch) {
                    discountController.clear();
                  }
                });
              },
            ),
          ],
        ),
        discountSwitch
            ? TextField(
                focusNode: focusNodeDiscount,
                controller: discountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction:
                    TextInputAction.next, // allows keyboard to go to next field
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
                ],
                decoration: const InputDecoration(
                  labelText: 'Enter Discounts',
                  labelStyle: TextStyle(fontSize: 12.0),
                ),
              )
            : const SizedBox(height: 1),
        Row(
          children: [
            const Text('Mode of Payment', style: TextStyle(fontSize: 12.0)),
            const Spacer(),
            Switch(
              value: paymentModeSwitch,
              onChanged: (value) {
                setState(() {
                  paymentModeSwitch = value;
                });
              },
            ),
          ],
        ),
        paymentModeSwitch
            ? const Text('GCASH', style: TextStyle(fontSize: 12.0))
            : const Text('COD', style: TextStyle(fontSize: 12.0)),
        Row(
          children: [
            const Text('Mode of Transit', style: TextStyle(fontSize: 12.0)),
            const Spacer(),
            Switch(
              value: transitModeSwitch,
              onChanged: (value) {
                setState(() {
                  transitModeSwitch = value;
                });
              },
            ),
          ],
        ),
        transitModeSwitch
            ? const Text('TRYKE', style: TextStyle(fontSize: 11.0))
            : const Text('2WHLS', style: TextStyle(fontSize: 11.0)),
        const SizedBox(height: 5),
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
                      'Total Delivery Count:${widget.deliveryList.length}',
                      style: const TextStyle(fontSize: 12.0))),
              const Spacer(
                flex: 1,
              ),
              Flexible(
                  child: Text(
                      'Total Delivery Fee:${totalDeliveryFee.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12.0))),
              const Spacer(
                flex: 1,
              ),
              Flexible(
                  child: Text(
                      'Total Handling Fee:${totalHandlingFee.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12.0))),
              const Spacer(
                flex: 1,
              ),
              Flexible(
                  child: Text(
                      'Total Income NET:${totalNetIncome.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12.0))),
              const Spacer(
                flex: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          onPressed: () {
            if (deliveryNumberController.text.isEmpty ||
                deliveryFeeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ney pay ngay, Rudder?!')),
              );
              return;
            }
            // Process data and save it to collection
            final deliveryData = DeliveryData(
              deliveryNumber: int.parse(deliveryNumberController.text),
              deliveryFee: double.parse(deliveryFeeController.text),
              handlingFeePercentage:
                  double.parse(deliveryFeeController.text) > baseDeliveryFee
                      ? handlingFeeSwitch
                          ? (double.parse(deliveryFeeController.text) *
                              (int.parse(handlingFeeController.text) / 100))
                          : (double.parse(deliveryFeeController.text) *
                              (defaultHandlingFeePercentage / 100))
                      : 5, //defaultHF for 55
              discount:
                  discountSwitch ? double.parse(discountController.text) : 0,
              paymentMode: paymentModeSwitch ? 'GCASH' : 'COD',
              transitMode: transitModeSwitch ? 'TRYKE' : '2WHLS',
            );

            //setState(() {
            //deliveryList.add(deliveryData);
            //});
            widget
                .onAddDelivery(deliveryData); // call the callback function here

            deliveryNumberController.clear();
            deliveryFeeController.clear();
            handlingFeeController.clear();
            discountController.clear();
            handlingFeeSwitch = false;
            discountSwitch = false;
            paymentModeSwitch = false;
            transitModeSwitch = false;
          },
          child:
              const Text('i-ADD mu garuden', style: TextStyle(fontSize: 12.0)),
        ),
        // Display Table Widget Here
        //Expanded(
        //child: DeliveryTable(deliveries: deliveryList),
        //),
      ],
    );
  }
}

class DeliveryTable extends StatefulWidget {
  final List<DeliveryData> deliveries;
  final Function(int) onDelete;
  //Create an instance of ScreenshotController
  final ScreenshotController screenshotController;

  const DeliveryTable(
      {super.key,
      required this.deliveries,
      required this.onDelete,
      required this.screenshotController});

  @override
  _DeliveryTableState createState() => _DeliveryTableState();
}

class _DeliveryTableState extends State<DeliveryTable> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: 750,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Screenshot(
            controller: widget.screenshotController,
            child: DataTable(
              columnSpacing: 10,
              dataRowHeight: 25.0, // set the height to a smaller value
              columns: const [
                DataColumn(
                    label: Flexible(
                        child: Text('Del#',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.0)))),
                DataColumn(
                    label: Flexible(
                        child: Text('Transit',
                            style: TextStyle(
                              fontSize: 11.0,
                            )))),
                DataColumn(
                    label: Flexible(
                        child:
                            Text('Payment', style: TextStyle(fontSize: 11.0)))),
                DataColumn(
                    label: Flexible(
                        child: Text('DF', style: TextStyle(fontSize: 11.0)))),
                DataColumn(
                    label: Flexible(
                        child: Text('Handling Fee',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.0)))),
                DataColumn(
                    label: Flexible(
                        child: Text('Extra Fee',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.0)))),
                DataColumn(
                    label: Flexible(
                        child:
                            Text('Action', style: TextStyle(fontSize: 11.0)))),
              ],
              rows: widget.deliveries.map((delivery) {
                return DataRow(
                  cells: [
                    DataCell(Center(
                        child: Text(delivery.deliveryNumber.toString(),
                            style: const TextStyle(fontSize: 10.0)))),
                    DataCell(Text(delivery.transitMode,
                        style: const TextStyle(fontSize: 10.0))),
                    DataCell(Text(delivery.paymentMode,
                        style: const TextStyle(fontSize: 10.0))),
                    DataCell(Text(delivery.deliveryFee.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10.0))),
                    DataCell(Center(
                        child: Text(
                            delivery.handlingFeePercentage.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10.0)))),
                    DataCell(Center(
                        child: Text(delivery.discount.toString(),
                            style: const TextStyle(fontSize: 10.0)))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete, size: 12),
                        onPressed: () => widget
                            .onDelete(widget.deliveries.indexOf(delivery)),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
