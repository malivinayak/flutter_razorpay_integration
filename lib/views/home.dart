import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Razorpay razorpay;
  TextEditingController name = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController amount = TextEditingController();
  String paymentStatus = "Processed to Pay";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    razorpay = new Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }

  void openCheckOut() {
    setState(() {
      paymentStatus = "Payment Processing";
    });
    var options = {
      "key": dotenv.get('razorpay_api'),
      "amount": num.parse(amount.text) * 100,
      "name": "Vinayak Mali",
      "description": "Payment for App Development",
      "prefill": {"contact": phoneNumber.text, "email": email.text},
      "external": {
        "wallets": ["Paytm"]
      },
      'retry': {'enabled': true, 'max_count': 1}
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void handlerPaymentSuccess(PaymentSuccessResponse response) {
    print("P.Payment Successful");
    setState(() {
      paymentStatus = "Payment Successful";
    });
  }

  void handlerErrorFailure(PaymentFailureResponse response) {
    print("P.Payment Fail");
    // Toast.show("Payment Fail",duration: Toast.lengthLong, gravity: Toast.bottom);
    setState(() {
      paymentStatus = "Payment Failed\nTry Again";
    });
  }

  void handlerExternalWallet(ExternalWalletResponse response) {
    setState(() {
      paymentStatus = "Payment handlerExternalWallet";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Razorpay Payment"),
        ),
        resizeToAvoidBottomInset: false,
        body: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                TextField(
                  controller: name,
                  decoration: InputDecoration(hintText: "Enter Your Name"),
                ),
                TextField(
                  controller: phoneNumber,
                  decoration:
                      InputDecoration(hintText: "Enter Your phone Number"),
                ),
                TextField(
                  controller: email,
                  decoration: InputDecoration(hintText: "Enter your email"),
                ),
                TextField(
                  controller: amount,
                  decoration: InputDecoration(hintText: "Amount to Pay"),
                ),
                SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    openCheckOut();
                  },
                ),
                Text(
                  paymentStatus,
                  style: Theme.of(context).textTheme.headline4,
                ),
                // const Text(
                //   'Thank You for running this',
                // ),
              ],
            )));
  }
}
