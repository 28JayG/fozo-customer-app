import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Replace with your actual color constants import
import '../../core/constants/colour_constants.dart';
import '../../provider/address_provider.dart';
import '../home/home_screen.dart';



class AddressFormScreen extends StatefulWidget {

  final String phoneNumber; // <-- phone from OTP
  final String firebaseUid; // <-- user.uid from OTP
  final String idToken; // <-- user.uid from OTP
  final String name; // <-- user.uid from OTP

  const AddressFormScreen({
    super.key,
    required this.phoneNumber,
    required this.firebaseUid,
    required this.idToken,
    required this.name,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {


  @override
  Widget build(BuildContext context) {
    // Access the provider
    final addressProvider = Provider.of<AddressFormProvider>(context);

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Add more address details",
          style: TextStyle(
            fontSize: 16.sp,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
          EdgeInsets.all(16.w), // horizontal/vertical responsive padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Display
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FCEB), // A pale green-ish background
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addressProvider.address,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Implement change address logic
                        },
                        child: Text(
                          "Change",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Address Type Selection
              Text(
                "Save address as",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: ["Home", "Work", "Other"].map((type) {
                  return Padding(
                    padding:
                    EdgeInsets.only(right: 8.w), // spacing between chips
                    child: ChoiceChip(
                      backgroundColor: AppColor.backgroundColor,
                      label: Padding(
                        // The label padding inside each chip
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      selected: addressProvider.selectedAddressType == type,
                      onSelected: (selected) {
                        if (selected) {
                          addressProvider.setSelectedAddressType(type);
                        }
                      },
                      selectedColor: Colors.lightGreen,
                      labelStyle: TextStyle(
                        color: addressProvider.selectedAddressType == type
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 20.h),

              // Address Input Fields
              buildLabeledTextField(
                label: "House number",
                hint: "Enter house number",
                controller: addressProvider.houseNumberController,
              ),
              buildLabeledTextField(
                label: "Floor",
                hint: "Enter floor number",
                controller: addressProvider.floorController,
              ),
              buildLabeledTextField(
                label: "Tower/Block",
                hint: "Enter tower/block (optional)",
                controller: addressProvider.towerBlockController,
              ),
              buildLabeledTextField(
                label: "Nearby landmark",
                hint: "Enter landmark (optional)",
                controller: addressProvider.landmarkController,
              ),

              SizedBox(height: 20.h),

              // Confirm Address Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FozoHomeScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[900],
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  "Confirm Address",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // Skip for now Button
              Center(
                child: TextButton(
                  onPressed: () {
                    // Handle skip logic
                  },
                  child: Text(
                    "Skip for now",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A helper widget that shows a label above the TextField.
  Widget buildLabeledTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 14.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }


}



