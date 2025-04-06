// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:fozo_customer_app/views/home/home_screen.dart';

// // import '../views/auth/otp_verification_screen.dart';

// // class AuthProvider with ChangeNotifier {
// //   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
// //   String _verificationId = '';

// //   String get verificationId => _verificationId;

// //   /// 🔹 Automatically Sends OTP to the Entered Phone Number
// //   Future<void> sendOTP(String phoneNumber, BuildContext context) async {
// //     try {
// //       await _firebaseAuth.verifyPhoneNumber(
// //         phoneNumber: phoneNumber,
// //         timeout: const Duration(seconds: 60),

// //         /// Code Auto-Detection (For Android)
// //         verificationCompleted: (PhoneAuthCredential credential) async {
// //           await _firebaseAuth.signInWithCredential(credential);
// //           notifyListeners();
// //         },

// //         /// If Verification Fails
// //         verificationFailed: (FirebaseAuthException e) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(content: Text(e.message ?? "Phone verification failed")),
// //           );
// //         },

// //         /// Receives the Verification ID and Navigates to OTP Screen
// //         codeSent: (String verificationId, int? resendToken) {
// //           _verificationId = verificationId;
// //           notifyListeners();
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (context) => OTPVerificationScreen(),
// //             ),
// //           ); // Navigate to OTP screen
// //         },

// //         codeAutoRetrievalTimeout: (String verificationId) {
// //           _verificationId = verificationId;
// //         },
// //       );
// //     } catch (e) {
// //       print("Error sending OTP: $e");
// //     }
// //   }

// //   /// 🔹 Verifies OTP Entered by User
// //   Future<void> verifyOTP(String otp, BuildContext context) async {
// //     try {
// //       PhoneAuthCredential credential = PhoneAuthProvider.credential(
// //         verificationId: _verificationId,
// //         smsCode: otp,
// //       );
// //       await _firebaseAuth.signInWithCredential(credential);
// //       notifyListeners();
// //       Navigator.push(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => HomeScreen(),
// //         ),
// //       ); // Naviga
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Invalid OTP")),
// //       );
// //     }
// //   }
// // }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fozo_customer_app/views/home/home_screen.dart';
// import '../views/auth/otp_verification_screen.dart';

// class AuthProvider with ChangeNotifier {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   String _verificationId = '';
//   String _uid = ''; // 🔹 Store UID after verification
//   bool _isSendingOTP = false;
//   bool _isVerifyingOTP = false;
//   bool _isResendAvailable = false;
//   int _resendTimer = 30;
//   Timer? _timer;

//   String get verificationId => _verificationId;
//   String get uid => _uid; // 🔹 Get UID for storing in Firestore
//   bool get isSendingOTP => _isSendingOTP;
//   bool get isVerifyingOTP => _isVerifyingOTP;
//   bool get isResendAvailable => _isResendAvailable;
//   int get resendTimer => _resendTimer;

//   /// 🔹 Starts the Resend OTP Timer (30s)
//   void _startResendTimer() {
//     _isResendAvailable = false;
//     _resendTimer = 30;
//     notifyListeners();

//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_resendTimer > 0) {
//         _resendTimer--;
//         notifyListeners();
//       } else {
//         _isResendAvailable = true;
//         notifyListeners();
//         timer.cancel();
//       }
//     });
//   }

//   /// 🔹 Sends OTP to the entered phone number
//   Future<void> sendOTP(String phoneNumber, BuildContext context) async {
//     try {
//       if (!phoneNumber.startsWith("+")) {
//         phoneNumber = "+91$phoneNumber";
//       }

//       _isSendingOTP = true;
//       notifyListeners();

//       await _firebaseAuth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         timeout: const Duration(seconds: 30),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await _firebaseAuth.signInWithCredential(credential);
//           _isSendingOTP = false;
//           notifyListeners();
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           _isSendingOTP = false;
//           notifyListeners();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(e.message ?? "Phone verification failed")),
//           );
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           _verificationId = verificationId;
//           _isSendingOTP = false;
//           notifyListeners();
//           _startResendTimer();

//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OTPVerificationScreen(
//                 phoneNumber: phoneNumber,
//               ),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           _verificationId = verificationId;
//         },
//       );
//     } catch (e) {
//       _isSendingOTP = false;
//       notifyListeners();
//       print("Error sending OTP: $e");
//     }
//   }

//   /// 🔹 Verifies OTP entered by the user
//   Future<void> verifyOTP(String otp, BuildContext context) async {
//     try {
//       _isVerifyingOTP = true;
//       notifyListeners();

//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId,
//         smsCode: otp,
//       );

//       UserCredential userCredential =
//           await _firebaseAuth.signInWithCredential(credential);

//       _uid =
//           userCredential.user?.uid ?? ''; // 🔹 Store UID for database storage
//       _isVerifyingOTP = false;
//       notifyListeners();

//       /// 🔹 Navigate to Home Screen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomeScreen(),
//         ),
//       );
//     } catch (e) {
//       _isVerifyingOTP = false;
//       notifyListeners();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Invalid OTP. Please try again.")),
//       );
//     }
//   }

//   /// 🔹 Resends OTP after the timer ends
//   Future<void> resendOTP(String phoneNumber, BuildContext context) async {
//     if (!_isResendAvailable) return;
//     await sendOTP(phoneNumber, context);
//   }

//   /// 🔹 Dispose Timer when not needed
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fozo_customer_app/views/auth/information_screen.dart';
// import 'package:fozo_customer_app/views/auth/otp_verification_screen.dart';
// import 'package:fozo_customer_app/views/home/home_screen.dart';

// class AuthProvider with ChangeNotifier {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//   /// 🔹 Values stored for phone & OTP (instead of local controllers)
//   String _phoneNumber = '';
//   String _otpValue = '';

//   /// 🔹 Firebase verification properties
//   String _verificationId = '';
//   String _uid = '';
//   bool _isSendingOTP = false;
//   bool _isVerifyingOTP = false;
//   bool _isResendAvailable = false;
//   int _resendTimer = 30;
//   Timer? _timer;

//   /// 🔹 Getters
//   String get phoneNumber => _phoneNumber;
//   String get otpValue => _otpValue;
//   String get verificationId => _verificationId;
//   String get uid => _uid;
//   bool get isSendingOTP => _isSendingOTP;
//   bool get isVerifyingOTP => _isVerifyingOTP;
//   bool get isResendAvailable => _isResendAvailable;
//   int get resendTimer => _resendTimer;

//   /// 🔹 Setters
//   void setPhoneNumber(String value) {
//     _phoneNumber = value;
//     notifyListeners();
//   }

//   void setOtpValue(String value) {
//     _otpValue = value;
//     notifyListeners();
//   }

//   /// 🔹 Starts the Resend OTP Timer (e.g., 30s)
//   void _startResendTimer() {
//     _isResendAvailable = false;
//     _resendTimer = 30;
//     notifyListeners();

//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_resendTimer > 0) {
//         _resendTimer--;
//         notifyListeners();
//       } else {
//         _isResendAvailable = true;
//         notifyListeners();
//         timer.cancel();
//       }
//     });
//   }

//   /// 🔹 Sends OTP to the entered phone number
//   Future<void> sendOTP(BuildContext context) async {
//     try {
//       // Make sure the phone number has the +91 prefix
//       var formattedNumber = _phoneNumber;
//       if (!formattedNumber.startsWith("+")) {
//         formattedNumber = "+91$formattedNumber";
//       }

//       _isSendingOTP = true;
//       notifyListeners();

//       await _firebaseAuth.verifyPhoneNumber(
//         phoneNumber: formattedNumber,
//         timeout: const Duration(seconds: 30),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await _firebaseAuth.signInWithCredential(credential);
//           _isSendingOTP = false;
//           notifyListeners();
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           _isSendingOTP = false;
//           notifyListeners();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(e.message ?? "Phone verification failed")),
//           );
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           _verificationId = verificationId;
//           _isSendingOTP = false;
//           notifyListeners();
//           _startResendTimer();

//           /// ✅ Immediately navigate to OTP screen once `codeSent`
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => OTPVerificationScreen(
//                 phoneNumber: phoneNumber,
//               ),
//             ),
//           );
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           _verificationId = verificationId;
//         },
//       );
//     } catch (e) {
//       _isSendingOTP = false;
//       notifyListeners();
//       debugPrint("Error sending OTP: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error sending OTP. Please try again.")),
//       );
//     }
//   }

//   /// 🔹 Verifies OTP entered by the user
//   Future<void> verifyOTP(BuildContext context) async {
//     try {
//       _isVerifyingOTP = true;
//       notifyListeners();

//       final credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId,
//         smsCode: _otpValue,
//       );

//       final userCredential =
//           await _firebaseAuth.signInWithCredential(credential);
//       _uid = userCredential.user?.uid ?? '';
//       _isVerifyingOTP = false;
//       notifyListeners();

//       /// Navigate to HomeScreen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => InformationScreen(),
//         ),
//       );
//     } catch (e) {
//       _isVerifyingOTP = false;
//       notifyListeners();
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Invalid OTP. Please try again.")),
//       );
//     }
//   }

//   /// 🔹 Resend OTP after timer ends
//   Future<void> resendOTP(BuildContext context) async {
//     if (!_isResendAvailable) return;
//     await sendOTP(context);
//   }

//   /// 🔹 Dispose timer when the provider is destroyed
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fozo_customer_app/utils/http/api.dart';
import 'package:fozo_customer_app/views/auth/information_screen.dart';
import 'package:fozo_customer_app/views/auth/otp_verification_screen.dart';
import 'package:fozo_customer_app/views/home/home_screen.dart';

import '../helper/shared_preferences_helper.dart';

class AuthProvider with ChangeNotifier {

  // Obtain shared preferences.

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  /// 🔹 Values stored for phone & OTP (instead of local controllers)
  String _phoneNumber = '';
  String _otpValue = '';

  /// 🔹 Firebase verification properties
  String _verificationId = '';
  String _uid = '';
  bool _isSendingOTP = false;
  bool _isVerifyingOTP = false;
  bool _isResendAvailable = false;
  int _resendTimer = 30;
  Timer? _timer;

  /// 🔹 Getters
  String get phoneNumber => _phoneNumber;
  String get otpValue => _otpValue;
  String get verificationId => _verificationId;
  String get uid => _uid;
  bool get isSendingOTP => _isSendingOTP;
  bool get isVerifyingOTP => _isVerifyingOTP;
  bool get isResendAvailable => _isResendAvailable;
  int get resendTimer => _resendTimer;

  /// 🔹 Setters
  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  void setOtpValue(String value) {
    _otpValue = value;
    notifyListeners();
  }

  /// ---------------------------------------------------------------------------
  /// 🔹 NEW METHOD: Check if user is already logged in
  ///
  /// Call this from your splash or main screen to decide if the user goes
  /// directly to HomeScreen or must enter phone number.
  /// ---------------------------------------------------------------------------
  Future<void> checkExistingUser(BuildContext context) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // User is already logged in => go to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FozoHomeScreen()),
      );
    } else {
      // User is new => go to phone input (or your initial screen)
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const InformationScreen()),
      // );
    }
  }

  /// 🔹 Starts the Resend OTP Timer (e.g., 30s)
  void _startResendTimer() {
    _isResendAvailable = false;
    _resendTimer = 30;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        notifyListeners();
      } else {
        _isResendAvailable = true;
        notifyListeners();
        timer.cancel();
      }
    });
  }

  /// 🔹 Sends OTP to the entered phone number
  Future<void> sendOTP(BuildContext context) async {
    try {
      // Ensure +91 prefix
      var formattedNumber = _phoneNumber;
      if (!formattedNumber.startsWith("+")) {
        formattedNumber = "+91$formattedNumber";
      }

      _isSendingOTP = true;
      notifyListeners();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedNumber,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification case
          await _firebaseAuth.signInWithCredential(credential);
          _isSendingOTP = false;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _isSendingOTP = false;
          notifyListeners();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Phone verification failed")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _isSendingOTP = false;
          notifyListeners();
          _startResendTimer();

          /// ✅ Navigate to OTP screen once `codeSent`
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                phoneNumber: phoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _isSendingOTP = false;
      notifyListeners();
      debugPrint("Error sending OTP: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error sending OTP. Please try again.")),
      );
    }
  }

  /// 🔹 Verifies OTP entered by the user
  Future<void> verifyOTP(BuildContext context) async {


    try {
      _isVerifyingOTP = true;
      notifyListeners();

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpValue,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final idToken = await userCredential.user?.getIdToken() ?? '';


      _uid = userCredential.user?.uid ?? '';
      _isVerifyingOTP = false;
      notifyListeners();
      print("userCredential.user");
      print(userCredential.user);


      if(_uid.isNotEmpty){
        final res = await ApiService.getRequest("auth/lookup?contactNumber=$_phoneNumber");
        // final res = await ApiService.getRequest("auth/lookup?contactNumber=4444444");
        print("kkkkkkkkkkkkkkkkkkkkkk");
        print(res);


        print(res["user"]?["role"]);
        if (res["user"]?["role"] == "Customer") {
          // Convert JSON to string and save
          String actionString = jsonEncode(res);
          await SharedPreferencesHelper.saveString('userLookup', actionString); // Save a string value

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FozoHomeScreen(),
            ),
          );

        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InformationScreen(
                phoneNumber: _phoneNumber,
                firebaseUid: _uid,
                  idToken:idToken
              ),
            ),
          );
        }
      }


      return;





// In authProvider.verifyOTP:

      /// Navigate to InformationScreen (or Home if user info is complete)
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const InformationScreen(),
      //   ),
      // );
    } catch (e) {
      _isVerifyingOTP = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }

  /// 🔹 Resend OTP after timer ends
  Future<void> resendOTP(BuildContext context) async {
    if (!_isResendAvailable) return;
    await sendOTP(context);
  }

  /// 🔹 Dispose timer when the provider is destroyed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
