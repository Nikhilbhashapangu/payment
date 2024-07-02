import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:payment/Authentication/enter_name.dart';
import 'package:payment/homepage.dart';


import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';



class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final bool isRegistered;

  OTPScreen(
      {Key? key,
      required this.phoneNumber,
      required this.verificationId,
      required this.isRegistered})
      : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _errorMessage;
  bool isLoading = false;

  // Define the base PinTheme as a static const
  static PinTheme basePinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 20,
      color: Color.fromRGBO(30, 60, 87, 1),
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  // Define the focused PinTheme based on basePinTheme
  final PinTheme focusedPinTheme = basePinTheme.copyWith(
    decoration: basePinTheme.decoration?.copyWith(
      border: Border.all(color: Colors.green),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Define the submitted PinTheme based on basePinTheme
  final PinTheme submittedPinTheme = basePinTheme.copyWith(
    decoration: basePinTheme.decoration?.copyWith(
      color: Color.fromRGBO(234, 239, 243, 1),
    ),
  );

  // Verify OTP entered by the user and sign in using Firebase authentication
  Future<void> _verifyOtp(String otp) async {
    setState(() {
      isLoading = true;
    });
    try {
      // Create PhoneAuthCredential using the verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Sign in with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Navigate based on isRegistered flag
      if (widget.isRegistered) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        setState(() {
          isLoading = false;
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => EnterNameScreen(
                    phoneNumber: widget.phoneNumber,
                  )),
        );
        setState(() {
          isLoading = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException and show appropriate error messages
      String errorMessage;

      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'The OTP entered is invalid. Please try again.';
          break;
        case 'user-disabled':
          errorMessage =
              'This user account has been disabled. Please contact support.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Phone sign-in is not enabled. Please enable it in the Firebase console.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Too many attempts have been made. Please try again later.';
          break;
        case 'invalid-verification-id':
          errorMessage = 'The verification ID is invalid. Please try again.';
          break;
        default:
          errorMessage = 'An unknown error occurred. Please try again.';
          break;
      }

      // Show a SnackBar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Handle other types of errors (e.g., network issues)
      String errorMessage =
          'An error occurred. Please check your connection and try again.';

      // Show a SnackBar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('OTP Verification'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pin input field
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Pinput(
                  controller: _otpController,
                  hapticFeedbackType: HapticFeedbackType.mediumImpact,
                  length: 6,
                  defaultPinTheme: basePinTheme,
                  autofocus: true,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                ),
              ),
              const SizedBox(height: 20.0),
              // Verify OTP button
              Container(
                width: 35.w,
                height: 6.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF70F570), Color(0xFF277612)],
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
                    await _verifyOtp(_otpController.text.trim());
                  },
                  child: isLoading
                      ? SpinKitThreeBounce(
                          color: Colors.white,
                          size: 6.w,
                        )
                      : Text(
                          'Verify OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
