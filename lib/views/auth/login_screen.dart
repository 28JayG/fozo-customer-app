import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import '../../utils/constant/dimensions.dart';
import '../../utils/services/auth_phone.dart';
import '../../utils/services/auth.dart';
import '../../widgets/custom_button_widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  int currentIndex = 0;
  final List<Map<String, dynamic>> content = [
    {
      'title': 'Discover Restaurants',
      'description':
      'Find Surprise Bags from your favorite restaurants at up to 50% OFF near you.',
      'image': 'assets/png/photo1.png',
    },
    {
      'title': 'Enjoy Delicious Meals',
      'description':
      'Get tasty meals at amazing prices and enjoy new culinary experiences.',
      'image': 'assets/png/photo2.png',
    },
    {
      'title': 'Explore New Cuisines',
      'description':
      'Discover a variety of cuisines and expand your food horizons.',
      'image': 'assets/png/photo3.png',
    },
  ];

  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);

    _timer = Timer.periodic(Duration(milliseconds: 1500), (Timer timer) {
      if (currentIndex < content.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      _pageController.animateToPage(
        currentIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    double widthP = Dimensions.myWidthThis(context);
    double heightP = Dimensions.myHeightThis(context);

    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Top Section (Skip Button + Illustration)
            Stack(
              children: [
                Container(
                  height: screenHeight * 0.5,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEFFA9),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.05),

                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          width: widthP*75,
                          height: heightP*35,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                          decoration: BoxDecoration(
                            color:  Color(0xFF0732280F).withOpacity(0.2), // Change the color as needed
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                                  'Skip',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                  ),
                                ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: PageView.builder(
                          itemCount: content.length,
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: screenWidth * 0.4,
                                  height: screenWidth * 0.4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: AssetImage(content[index]['image']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  content[index]['title']!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: screenWidth * 0.07,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.05),
                                  child: Text(
                                    content[index]['description']!,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(content.length,
                                          (indicatorIndex) {
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          width: indicatorIndex == currentIndex
                                              ? 16
                                              : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: indicatorIndex == currentIndex
                                                ? Color(0xFF3D914F)
                                                : Colors.grey,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


            /// Phone Input Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter your phone number",
                    style:
                    TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text("+91", style: TextStyle(fontSize: 16.sp)),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              hintText: "96149-75333",
                              border: InputBorder.none,
                              counterText: "", // Remove the default counter
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 12.w),
                            ),
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            onChanged: (value) {
                              authProvider.setPhoneNumber(value.trim());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  /// Show Progress Indicator When Sending OTP

                  CustomButton(
                    text: "Continue",
                    onPressed: () {
                      // Minimal check: phone length should be 10
                      if (authProvider.phoneNumber.length == 10) {
                        authProvider.sendOTP(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Enter a valid 10-digit number")),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            /// Social Login Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text("Or login with",
                            style:
                            TextStyle(fontSize: 14.sp, color: Colors.grey)),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  // TODO: Add social login buttons here
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          AuthMethods().signInWithGoogle(context);
                          // Add your function here
                        },
                        child: SvgPicture.asset(
                          'assets/svg/google_log_in.svg',
                          height: 56,
                          width: 56,
                        ),
                      ),

                      SizedBox(width: 40.w),

                      GestureDetector(
                        onTap: () {
                          AuthMethods().signInWithGoogle(context);
                          // Add your function here
                        },
                        child: SvgPicture.asset(
                          'assets/svg/apple_log_in.svg',
                          height: 56,
                          width: 56,
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),


            SizedBox(height: 30.h),

            /// Terms and Conditions
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: [
                  Text(
                    "By continuing you agree to our",
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





