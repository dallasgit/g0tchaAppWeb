import 'package:flutter/services.dart';
import 'package:ig0tchaapp/pages/login.dart';
import 'package:ig0tchaapp/pages/user_session.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

import 'common.dart';
import 'firebase.dart';

class OperatorReward extends StatefulWidget {
  const OperatorReward({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OperatorRewardFormState createState() => _OperatorRewardFormState();
}

class _OperatorRewardFormState extends State<OperatorReward> {
  late String phoneNumber;
  late String transactionGuidId = "";
  TextEditingController phoneNumberController = TextEditingController();
  late DateTime selectedDate = DateTime.now();
  late String selectedRider = "";
  late String currentOperator = userSession.aliasName;
  late List<String> riderOptions = [
    "Genesis",
    "JMel",
    "Allan",
    "Samson",
    "Mark",
    "JRoy"
  ];
  late List<String> operatorOptions = ["Libby", "Audry"];
  UserSession userSession = UserSession();
  // Copy the URL to the clipboard
  void copyTransactionId() {
    Clipboard.setData(ClipboardData(text: transactionGuidId));
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$transactionGuidId copied to clipboard')));
  }

  @override
  void initState() {
    super.initState();
    userSession.checkSession().then((isLoggedIn) async {
      setState(() {});
      if (isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Logged in successfully, Boss ${userSession.name}!')),
        );
      } else {
        await userSession.signOutSession();
        // ignore: use_build_context_synchronously
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              Text(
                'Hello ${userSession.name}!',
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
        title: const Text('Gotcha Reward 1.0'),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: userSession.isLoggedIn
              ? Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10.0),
                      TextField(
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Phone Number',
                        ),
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          setState(() {
                            phoneNumber = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      Text('Selected Date: ${selectedDate.toString()}'),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: () {
                          _selectDate(context);
                        },
                        child: const Text('Select Date'),
                      ),
                      const SizedBox(height: 20.0),
                      const Text('Select Rider: '),
                      Row(
                        children: riderOptions.map((rider) {
                          return Expanded(
                            child: RadioListTile(
                              title: Text(rider),
                              value: rider,
                              groupValue: selectedRider,
                              onChanged: (value) {
                                setState(() {
                                  selectedRider = value.toString();
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                      const Text('Current Operator: '),
                      Column(
                        children: operatorOptions.map((operator) {
                          return RadioListTile(
                            title: Text(operator),
                            value: operator,
                            groupValue: currentOperator,
                            onChanged: (value) {
                              setState(() {
                                currentOperator = value.toString();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final customerId = phoneNumberController.text;

                            // Validate inputs
                            if (customerId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Invalid Customer PhoneNo. Please check input again.')),
                              );

                              return;
                            }

                            if (selectedRider.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Invalid Rider. Please select again.')),
                              );

                              return;
                            }

                            final transactionDate = selectedDate.toString();
                            final transactionId = generateGuid();
                            final rewardData = DeliveryRewardData(
                                transactionId: transactionId,
                                transactionDate: transactionDate,
                                isClaimed: false,
                                isRedeemed: false,
                                riderName: selectedRider,
                                operatorName: currentOperator,
                                totalPoints: "");
                            await FirebaseService.instance
                                .addDeliveryRewardRecords(
                                    customerId, rewardData);
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Customer Transaction Record Saved! Thanks ${userSession.name}!')),
                            );
                            setState(() {
                              transactionGuidId = transactionId;
                            });
                            phoneNumberController.clear();
                            selectedRider = "";
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error Saving Customer Transaction: $e!')),
                            );
                          }
                        },
                        child: const Text('Submit'),
                      ),
                      const SizedBox(height: 16.0),
                      transactionGuidId.isNotEmpty
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border:
                                    Border.all(color: Colors.blue, width: 2.0),
                              ),
                              padding: const EdgeInsets.all(10.0),
                              child: GestureDetector(
                                onTap: copyTransactionId,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Click to Copy Reward Code',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10.0,
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text(
                                      transactionGuidId,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                )
              : null),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String generateGuid() {
    String guid = const Uuid().v4();
    return guid;
  }
}
