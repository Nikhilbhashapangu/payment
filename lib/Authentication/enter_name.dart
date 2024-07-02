

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:payment/homepage.dart';
import 'package:sizer/sizer.dart';

class EnterNameScreen extends StatefulWidget {
  final String _phoneNumber; // Define _phoneNumber as a parameter

  EnterNameScreen({Key? key, required String phoneNumber})
      : _phoneNumber = phoneNumber,
        super(key: key);

  @override
  State<EnterNameScreen> createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends State<EnterNameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    // Dispose of text editing controllers to free up resources
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUserDetails() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Convert _phoneNumber to int
      int phoneNumber = int.parse(widget._phoneNumber);

      await _firestore.collection('Users').doc(user.uid).set({
        'account_createdAt': Timestamp.now(),
        'organic_points': 0,
        'phone_number': phoneNumber,
        'pincode': 0,
        'profilepic_url': '',
        'referral_code': '',
        'referral_points': 0,
        'referrals': [],
        'referred_by': '',
        'user_id': user.uid,
        'username': _usernameController.text.trim(),
      });

      // Navigate to the home screen after saving user details
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding:
                    EdgeInsets.all(8.0.w), // Using Sizer for responsive padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Part 1: Image with network height 100.h and width 100.w
                    Container(
                      width: 80.w,
                      height: 50.h,
                      child: Image.network(
                        'https://www.agrifarming.in/wp-content/uploads/Banganapalli-Mango-Farming-in-India3.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Part 2: Username input
                    Container(
                      width: 90.w,
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF0F2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person, size: 25.sp),
                              ),
                              keyboardType: TextInputType.name,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Part 3: Proceed button
                    Container(
                      width: 30.w,
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
                          // Handle proceed button logic here
                          _saveUserDetails();
                        },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Proceed',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
