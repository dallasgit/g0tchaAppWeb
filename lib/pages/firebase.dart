import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'common.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._();
  static FirebaseService get instance => _instance;

  FirebaseService._();

  Future<void> init() async {
    const FirebaseOptions firebaseOptions = FirebaseOptions(
      appId: '1:737312422791:web:9b3343dbe24459df1a3122',
      apiKey: 'AIzaSyA-gOjy6uX1MMjdNykR-vprJEGVkR1Zc5Y',
      projectId: 'g0tcha',
      messagingSenderId: '737312422791',
      authDomain: '737312422791',
      storageBucket: 'g0tcha.appspot.com',
    );
    await Firebase.initializeApp(options: firebaseOptions);
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<QuerySnapshot> getUsers() async {
    return await FirebaseFirestore.instance.collection('users').get();
  }

  Future<DocumentSnapshot?> validateUser(String userid, String password) async {
    DocumentReference rider =
        FirebaseFirestore.instance.collection('users').doc(userid);
    DocumentSnapshot riderSnapshot = await rider.get();

    if (riderSnapshot.exists) {
      Map<String, dynamic>? riderData =
          riderSnapshot.data() as Map<String, dynamic>?;
      String riderDataPassword = riderData?['password'] ?? '';
      return riderDataPassword == password ? riderSnapshot : null;
    } else {
      return null;
    }
  }

  Future<void> addUser(String name, String email) async {
    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'email': email,
    });
  }

  Future<void> addDeliveryRecords(
      String userId, String deliveryDateId, List<DeliveryData> records) async {
    // Get today's date in the format of MM-dd-yyyy
    //String deliveryDateId = DateFormat('MM-dd-yyyy').format(DateTime.now());
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    CollectionReference deliveriesRef = userDocRef
        .collection('dailyTransactions')
        .doc(deliveryDateId)
        .collection('deliveries');

    // Delete all existing documents under "deliveries" collection
    QuerySnapshot querySnapshot = await deliveriesRef.get();
    List<Future<void>> deleteFutures = [];
    for (DocumentSnapshot doc in querySnapshot.docs) {
      deleteFutures.add(doc.reference.delete());
    }
    await Future.wait(deleteFutures);

    // Loop through the list of records and add each record to the "deliveries" collection
    for (DeliveryData record in records) {
      // Set the document ID manually
      DocumentReference recordRef =
          deliveriesRef.doc(record.deliveryNumber.toString());
      await recordRef.set(record.toMap());
    }
  }

  Future<List<DeliveryData>> getDeliveryRecords(
      String userId, String deliveryDateId) async {
    List<DeliveryData> records = [];

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    CollectionReference deliveriesRef = userDocRef
        .collection('dailyTransactions')
        .doc(deliveryDateId)
        .collection('deliveries');

    QuerySnapshot querySnapshot = await deliveriesRef.get();
    for (DocumentSnapshot doc in querySnapshot.docs) {
      records.add(DeliveryData.fromMap(doc.data() as Map<String, dynamic>));
    }

    return records;
  }

  Future<void> addDeliveryRewardRecords(
      String customerId, DeliveryRewardData record) async {
    // Get today's date in the format of MM-dd-yyyy
    //String deliveryDateId = DateFormat('MM-dd-yyyy').format(DateTime.now());
    DocumentReference customerDocRef =
        FirebaseFirestore.instance.collection('customers').doc(customerId);
    CollectionReference customerDeliveryTransactionRef = customerDocRef
        .collection('rewards')
        .doc('current')
        .collection('transactions');

    // Set the document ID manually
    DocumentReference recordRef =
        customerDeliveryTransactionRef.doc(record.transactionId.toString());
    await recordRef.set(record.toMap());
  }

  Future<DeliveryRewardData> claimCustomerReward(
      bool isClaimReward, String customerId, String? transactionValue) async {
    DocumentReference customerDocRef =
        FirebaseFirestore.instance.collection('customers').doc(customerId);

    CollectionReference customerDeliveryTransactionRef = customerDocRef
        .collection('rewards')
        .doc('current')
        .collection('transactions');

    QuerySnapshot preClaimedTransactionsSnapshot =
        await customerDeliveryTransactionRef
            .where('isClaimed', isEqualTo: true)
            .where('isRedeemed', isEqualTo: false)
            .get();

    int preTotalClaimedTransactions = preClaimedTransactionsSnapshot.size;
    // ignore: unnecessary_null_comparison
    if (!isClaimReward) {
      int? requestedRedeemAmount = int.tryParse(transactionValue ?? '');
      bool hasValidRedeemableAmount =
          preTotalClaimedTransactions > requestedRedeemAmount!;
      return DeliveryRewardData(
          transactionId: "",
          transactionDate: "",
          riderName: "",
          operatorName: "",
          isClaimed: false,
          isRedeemed: hasValidRedeemableAmount,
          totalPoints: "$preTotalClaimedTransactions");
    }

    String transactionId = transactionValue!;
    QuerySnapshot querySnapshot = await customerDeliveryTransactionRef
        .where('transactionId', isEqualTo: transactionId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return DeliveryRewardData(
          transactionId: "",
          transactionDate: "",
          riderName: "",
          operatorName: "",
          isClaimed: false,
          isRedeemed: false,
          totalPoints: "");
    }

    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    await customerDeliveryTransactionRef
        .doc(documentSnapshot.id)
        .update({'isClaimed': true});

    QuerySnapshot claimedTransactionsSnapshot =
        await customerDeliveryTransactionRef
            .where('isClaimed', isEqualTo: true)
            .where('isRedeemed', isEqualTo: false)
            .get();

    int totalClaimedTransactions = claimedTransactionsSnapshot.size;
    bool isNewClaimed =
        !(preTotalClaimedTransactions == totalClaimedTransactions);
    await customerDocRef
        .collection('rewards')
        .doc('current')
        .update({'points': totalClaimedTransactions});

    DeliveryRewardData deliveryRewardData = DeliveryRewardData.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>);
    deliveryRewardData.isClaimed = isNewClaimed;
    deliveryRewardData.totalPoints = '$totalClaimedTransactions';

    return deliveryRewardData;
  }
}
