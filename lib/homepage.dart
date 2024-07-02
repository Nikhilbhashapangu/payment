import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Razorpay _razorpay = Razorpay();
  @override
  void initState() {
    super.initState();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear;
  }

  var options = {
    'key': '<rzp_live_wXFzvEG9gUK6LP>',
    'amount': 100,
    'name': 'Sample',
    'description': 'New order',
    'prefill': {'contact': '9553716214', 'email': 'test@razorpay.com'}
  };
  TextEditingController amount = TextEditingController();

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Payment success");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment failed");
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Payment Integration")),
        body: Center(
            child: Column(
          children: [
            TextFormField(
              controller: amount,
              keyboardType: TextInputType.number,
            ),
            TextButton(
                child: Text("Pay amount"),
                onPressed: () {
                  _razorpay.open(options);
                })
          ],
        )));
  }
}
