

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colour_constants.dart';
import '../../utils/services/auth_phone.dart';
import '../../widgets/custom_button_widget.dart';

class OTPVerificationScreen extends StatelessWidget {
  const OTPVerificationScreen({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "OTP Verification",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// Title & Subtitle
                Text(
                  "We've sent you an OTP",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Text(
                  "We sent an OTP to your mobile number\n+91-$phoneNumber",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),

                /// OTP Input
                Pinput(
                  hapticFeedbackType: HapticFeedbackType.mediumImpact,
                  length: 6,
                  keyboardType: TextInputType.number,
                  defaultPinTheme: PinTheme(
                    width: 60.w,
                    height: 60.h,
                    textStyle: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                  onChanged: (value) {
                    authProvider.setOtpValue(value.trim());
                  },
                ),
                SizedBox(height: 20.h),

                /// Resend OTP Timer / Button
                authProvider.isResendAvailable
                    ? TextButton(
                        onPressed: () => authProvider.resendOTP(context),
                        child: Text(
                          "Did't get the OTP? Resend SMS",
                          style: TextStyle(fontSize: 16.sp, color: Colors.blue),
                        ),
                      )
                    : Text(
                        "Did't get the OTP? Sending in ${authProvider.resendTimer}s",
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                SizedBox(height: 30.h),

                /// Continue Button
                authProvider.isVerifyingOTP
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        text: "Continue",
                        onPressed: () {
                          if (authProvider.otpValue.length == 6) {
                            authProvider.verifyOTP(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Enter a valid 6-digit OTP"),
                              ),
                            );
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
