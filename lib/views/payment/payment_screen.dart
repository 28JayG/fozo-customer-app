import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Replace with your actual color constants import
import 'package:fozo_customer_app/core/constants/colour_constants.dart';

class PaymentMethodPage extends StatefulWidget {
  final double totalPayPrice;
  final String cartId;
  final Map selectAddress;

  const PaymentMethodPage({
    super.key,
    required this.cartId,
    required this.totalPayPrice,
    required this.selectAddress,
  });
  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Payment Method",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Bill Total Container
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // "Bill Total"
                  Text(
                    "Bill Total",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      // "₹585"
                      Text(
                        "₹${widget.totalPayPrice}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 4.w),

                      // Arrow
                      Icon(
                        Icons.chevron_right,
                        color: Colors.black87,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 2) Cards
            _buildPaymentSection(
              title: "Cards",
              subtitle: "Add credit or debit cards",
              trailingText: "Add",
              onTap: () {
                // Implement card-adding logic
              },
            ),
            SizedBox(height: 12.h),

            // 3) UPI
            _buildPaymentSection(
              title: "UPI",
              subtitle: "Add new UPI ID",
              trailingText: "Add",
              onTap: () {
                // Implement UPI-adding logic
              },
            ),
            SizedBox(height: 12.h),

            // 4) Wallets
            Text(
              "Wallets",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),

            // Example wallets
            _buildWalletRow(
              iconAsset: Icons.payment, // or your custom icon for Amazon Pay
              walletName: "Amazon pay",
              onTap: () {
                // Link Amazon pay
              },
            ),
            SizedBox(height: 8.h),

            _buildWalletRow(
              iconAsset: Icons.payment, // or your custom icon for Paytm
              walletName: "Paytm",
              onTap: () {
                // Link Paytm
              },
            ),

            // Add more wallets if needed...
          ],
        ),
      ),
    );
  }

  /// A helper to build a payment section like "Cards" or "UPI"
  Widget _buildPaymentSection({
    required String title,
    required String subtitle,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Right "Add" link
          GestureDetector(
            onTap: onTap,
            child: Text(
              trailingText,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A helper to build each wallet row
  Widget _buildWalletRow({
    required IconData iconAsset,
    required String walletName,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left icon
          Icon(
            iconAsset,
            size: 20.sp,
            color: Colors.green.shade900,
          ),
          SizedBox(width: 8.w),

          // Wallet name
          Expanded(
            child: Text(
              walletName,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),

          // Right "Link"
          GestureDetector(
            onTap: onTap,
            child: Text(
              "Link",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
