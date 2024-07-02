import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:payment/homepage.dart';

import 'package:sizer/sizer.dart';


import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ignore: unused_field
  String? _errorMessage;
  String _phoneNumber = '';
  String _countryCode = '+91';
  // ignore: unused_field
  String _verificationId = '';
  bool isLoading = false;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        _phoneNumber = _phoneController.text;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Initiates the process of sending an OTP to the user's phone number for authentication.
  Future<void> _sendOtp() async {
    print(_isRegistered);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error signing in: $e')),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                verificationId: verificationId,
                isRegistered: _isRegistered,
                phoneNumber: _phoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle auto retrieval timeout if needed
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    }
  }

  // Validate the phone number input field and proceed to the next step if valid.
  void _validatePhoneNumber() {
    setState(() {
      isLoading = true;
    });
    String phone = _phoneController.text.trim();

    if (phone.length == 10) {
      _phoneNumber = '$_countryCode$phone';
      isUserRegistered(_phoneNumber);
      setState(() {
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid mobile number')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to remove non-numeric characters from a string
  String _getNumericString(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // Function to check if a user is registered based on the provided phone number
  Future<bool> isUserRegistered(String phoneNumber) async {
    try {
      // Remove the first character of the phoneNumber and convert to only numbers
      String formattedPhoneNumber = _getNumericString(phoneNumber.substring(1));

      CollectionReference users =
          FirebaseFirestore.instance.collection('Users');
      QuerySnapshot querySnapshot = await users
          .where('phone_number', isEqualTo: formattedPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _isRegistered = true; // Update the state if user is not registered
        });
        // Assuming _sendOtp() is called to send OTP if user is registered
        await _sendOtp();
        return true;
      } else {
        setState(() {
          _isRegistered = false; // Update the state if user is registered
        });
        // Assuming _sendOtp() is called even if user is not registered
        await _sendOtp();
        return false;
      }
    } on FirebaseException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error checking user registration: ${e.message}')),
      );
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color.fromARGB(255, 14, 106, 52),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Container(
                margin: EdgeInsets.only(right: 2.w),
                width: 25.w,
                height: 4.h,
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(51, 255, 255, 255),
                    elevation: 10,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(height: 5.h),
                    SizedBox(
                      width: 23.h,
                      height: 23.h,
                      child: Image.asset('assets/images/nf_logo.png'),
                    ),
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 1.h),
                  Container(
                    width: 100.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.w),
                        topRight: Radius.circular(16.w),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 4.h),
                          Text(
                            "Welcome",
                            style: TextStyle(
                              fontSize: 25.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Column(
                            children: <Widget>[
                              Container(
                                width: 90.w,
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDF0F2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    CountryCodePicker(
                                      onChanged: (country) {
                                        setState(() {
                                          _countryCode = country.dialCode!;
                                        });
                                      },
                                      onInit: (code) {
                                        _countryCode = code!.dialCode!;
                                      },
                                      initialSelection: 'भारत',
                                      favorite: const ['+91', 'भारत'],
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneController,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'Mobile Number',
                                        ),
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                height: 6.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF70F570),
                                      Color(0xFF277612)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    _validatePhoneNumber();
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  child: isLoading
                                      ? SpinKitThreeBounce(
                                          color: Colors.white,
                                        )
                                      : Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 3.w),
                                          child: Text(
                                            'Proceed',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
