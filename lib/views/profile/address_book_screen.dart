import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import 'package:fozo_customer_app/widgets/custom_button_widget.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  // Sample addresses to display
  final List<Map<String, dynamic>> _addresses = const [
    {
      "type": "Home",
      "icon": Icons.home_outlined,
      "address":
          "Akshya Nagar 1st Block 1st Cross, Rammurthy nagar, Bangalore-560016",
      "phone": "876796356",
    },
    {
      "type": "Office",
      "icon": Icons.work_outline,
      "address":
          "Akshya Nagar 1st Block 1st Cross, Rammurthy nagar, Bangalore-560016",
      "phone": "876796356",
    },
    {
      "type": "Other",
      "icon": Icons.location_on_outlined,
      "address":
          "Akshya Nagar 1st Block 1st Cross, Rammurthy nagar, Bangalore-560016",
      "phone": "876796356",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,

      // 1) AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Address Book",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 2) Body
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            // The address cards
            Expanded(
              child: ListView.builder(
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final item = _addresses[index];
                  return _buildAddressCard(item);
                },
              ),
            ),

            // "+ Add Address" button at the bottom
            SizedBox(height: 8.h),
            CustomButton(text: "+ Add Address", onPressed: () {}),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  // A helper to build each address card
  Widget _buildAddressCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade50,
        ),
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with icon + type
          Row(
            children: [
              Icon(
                item["icon"],
                size: 20.sp,
                color: Colors.black87,
              ),
              SizedBox(width: 8.w),
              Text(
                item["type"] ?? "",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Address text
          Text(
            item["address"] ?? "",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 4.h),

          // Phone text
          Text(
            "Phone Number: ${item["phone"]}",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
