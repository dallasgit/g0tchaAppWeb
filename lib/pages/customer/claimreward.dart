import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ig0tchaapp/pages/common.dart';
import 'package:ig0tchaapp/pages/firebase.dart';

import '../user_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();
  runApp(const CustomerRewardApp());
}

class CustomerRewardApp extends StatelessWidget {
  const CustomerRewardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'g0tchaApp',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      routes: {'/': (context) => const ClaimRewardPage()},
    );
  }
}

class ClaimRewardPage extends StatefulWidget {
  const ClaimRewardPage({Key? key}) : super(key: key);

  @override
  _ClaimRewardPageState createState() => _ClaimRewardPageState();
}

class _ClaimRewardPageState extends State<ClaimRewardPage> {
  final _formKey = GlobalKey<FormState>();
  String? _phoneNumber;
  String? _transactionValue;
  bool _isClaimReward = true;
  bool _isLoading = false;
  final UserSession _userSession = UserSession();
  String? _verificationId;
  // Use HtmlElementView to embed the container element in your Flutter widget tree
  final recaptchaView = HtmlElementView(
    viewType: 'recaptcha-container',
    key: UniqueKey(),
  );

  @override
  void initState() {
    super.initState();
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _verificationId =
          await _userSession.handleVerifyGooglePhoneNumber(_phoneNumber);
      print("Verification Passed!");
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("VerifyPhoneNumber Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signInPhoneNumber() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _userSession.handleSignInGooglePhoneNumber(
          _verificationId, _transactionValue);

      // Reset validator message
      _formKey.currentState!.reset();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User is Verified Successfully!")),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "User Verification failed! Please check sms code or retry verification process.")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _submitForm() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_formKey.currentState!.validate()) {
        DeliveryRewardData rewardData = await FirebaseService.instance
            .claimCustomerReward(
                _isClaimReward, _phoneNumber!, _transactionValue!);
        setState(() {
          _isLoading = false;
        });
        // form is valid, process data and show result
        // replace the placeholders with actual data
        final isNewClaimedText =
            rewardData.isClaimed ? "New Claimed. " : "Already Claimed.";
        final resultClaimedText =
            '\nLast Transaction Date: ${rewardData.transactionDate}\nOperator Name: ${rewardData.operatorName}\nRider Name: ${rewardData.riderName}\nCurrent Point: 1pt-$isNewClaimedText\nOverall Reward Points: ${rewardData.totalPoints}pt(s)';
        final redeemRequestStatus =
            rewardData.isRedeemed ? "Approved" : "Rejected";
        final resultRedeemText =
            '\nRequest Status:$redeemRequestStatus\nRequest Points: ${_transactionValue}pt(s)\nCurrent Total Points: ${rewardData.totalPoints}pt(s)';
        final claimRewardText = _isClaimReward ? 'Claim' : 'Redeem';
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  'Hello $_phoneNumber! Thank you for being our Loyal Suki.\n\n$claimRewardText Reward Information:'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              content: FractionallySizedBox(
                widthFactor: 0.95,
                child: Container(
                  height: 200,
                  color: const Color.fromARGB(255, 59, 255, 229),
                  child: _isClaimReward
                      ? Text(resultClaimedText)
                      : Text(resultRedeemText),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      print("ClaimReward: Error claiming in: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gotcha eReward App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                title: _isClaimReward
                    ? const Text('Claim Reward')
                    : const Text('Redeem Reward'),
                value: _isClaimReward,
                onChanged: (value) {
                  setState(() {
                    _isClaimReward = value;
                    // Reset validator message
                    _formKey.currentState!.reset();
                  });
                },
                secondary: Icon(_isClaimReward
                    ? Icons.card_giftcard
                    : Icons.monetization_on),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cellphone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid cellphone number';
                  }
                  if (value.length != 11) {
                    return 'Please enter a valid 11-digit cellphone number';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                maxLength: 11,
                onChanged: (value) => _phoneNumber = value,
              ),
              const SizedBox(height: 10),
              _userSession.isLoggedIn
                  ? const SizedBox()
                  : ElevatedButton(
                      onPressed: () async {
                        await _verifyPhoneNumber();
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Send verification code'),
                    ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: _userSession.isLoggedIn
                      ? _isClaimReward
                          ? 'Transaction Code'
                          : 'Amount'
                      : 'Verification Code',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_userSession.isLoggedIn) {
                    if (value == null || value.isEmpty) {
                      return _isClaimReward
                          ? 'Please enter a valid Transaction Code'
                          : 'Please enter a valid Reedemable Amount';
                    }
                    final guidRegex = _isClaimReward
                        ? RegExp(r'^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$')
                        : RegExp(r'^([5-9]|1[0-5])\d{0,1}(\.\d{0,2})?$');
                    if (!guidRegex.hasMatch(value)) {
                      return _isClaimReward
                          ? 'Please enter a valid Transaction Code'
                          : 'Please enter a valid Reedemable Amount';
                    }
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
                onChanged: (value) => _transactionValue = value,
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () async {
                  if (_userSession.isLoggedIn) {
                    _submitForm();
                  } else {
                    _signInPhoneNumber();
                  }
                },
                child: _userSession.isLoggedIn
                    ? _isLoading
                        ? const CircularProgressIndicator()
                        : _isClaimReward
                            ? const Text('Claim')
                            : const Text('Redeem')
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
