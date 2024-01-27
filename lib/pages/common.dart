class DeliveryData {
  final int deliveryNumber;
  final double deliveryFee;
  final double handlingFeePercentage;
  final double discount;
  final String paymentMode;
  final String transitMode;

  DeliveryData({
    required this.deliveryNumber,
    required this.deliveryFee,
    required this.handlingFeePercentage,
    required this.discount,
    required this.paymentMode,
    required this.transitMode,
  });

  Map<String, dynamic> toMap() {
    return {
      'deliveryNumber': deliveryNumber,
      'transit': transitMode,
      'payment': paymentMode,
      'deliveryFee': deliveryFee,
      'handlingFee': handlingFeePercentage,
      'extraFee': discount,
    };
  }

  static DeliveryData fromMap(Map<String, dynamic> map) {
    return DeliveryData(
      deliveryNumber: map['deliveryNumber'] as int,
      transitMode: map['transit'] as String,
      paymentMode: map['payment'] as String,
      deliveryFee: map['deliveryFee'] as double,
      handlingFeePercentage: map['handlingFee'] as double,
      discount: map['extraFee'] as double,
    );
  }
}

class DeliveryRewardData {
  final String transactionId;
  final String transactionDate;
  bool isClaimed;
  final bool isRedeemed;
  final String riderName;
  final String operatorName;
  String totalPoints;

  DeliveryRewardData(
      {required this.transactionId,
      required this.transactionDate,
      required this.isClaimed,
      required this.isRedeemed,
      required this.riderName,
      required this.operatorName,
      required this.totalPoints});

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'transactionDate': transactionDate,
      'isClaimed': isClaimed,
      'isRedeemed': isRedeemed,
      'riderName': riderName,
      'operatorName': operatorName
    };
  }

  static DeliveryRewardData fromMap(Map<String, dynamic> map) {
    return DeliveryRewardData(
      transactionId: map['transactionId'] as String,
      transactionDate: map['transactionDate'] as String,
      isClaimed: map['isClaimed'] as bool,
      isRedeemed: map['isRedeemed'] as bool,
      riderName: map['riderName'] as String,
      operatorName: map['operatorName'] as String,
      totalPoints: "0",
    );
  }
}

class CurrentUserSessionData {
  final String loginName;
  final String userId;
  final String profileUrl;
  final String roleName;
  final String aliasName;

  CurrentUserSessionData(
      {required this.loginName,
      required this.aliasName,
      required this.userId,
      required this.profileUrl,
      required this.roleName});
}
