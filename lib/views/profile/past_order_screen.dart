import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';

class PastOrderScreen extends StatefulWidget {
  const PastOrderScreen({super.key});

  @override
  State<PastOrderScreen> createState() => _PastOrderScreenState();
}

class _PastOrderScreenState extends State<PastOrderScreen> {
  // Sample data to replicate multiple orders
  final List<Map<String, dynamic>> _orders = const [
    {
      "restaurantName": "Barbeque Nation, HSR",
      "itemInfo": "1 X Surprise Bag",
      "price": 585,
      "deliveryAddress": "Creative Residency | 24th Main Rd, IT",
      "deliveryTime": "10-11 PM",
      "rating": 4.5,
      "imageUrl":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=4299&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", // sample image
    },
    {
      "restaurantName": "Barbeque Nation, HSR",
      "itemInfo": "1 X Surprise Bag",
      "price": 585,
      "deliveryAddress": "Creative Residency | 24th Main Rd, IT",
      "deliveryTime": "10-11 PM",
      "rating": 4.5,
      "imageUrl":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=4299&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
    {
      "restaurantName": "Barbeque Nation, HSR",
      "itemInfo": "1 X Surprise Bag",
      "price": 585,
      "deliveryAddress": "Creative Residency | 24th Main Rd, IT",
      "deliveryTime": "10-11 PM",
      "rating": 4.5,
      "imageUrl":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=4299&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Past Orders",
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        // Thin gray border to replicate the screenshot's outline
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) Top row: Restaurant Name + Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  order["imageUrl"] ?? "https://via.placeholder.com/80",
                  width: 60.w,
                  height: 60.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 10.w),
              // Restaurant name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order["restaurantName"] ?? "Barbeque Nation, HSR",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      order["itemInfo"] ?? "1 X Surprise Bag",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
              // Price on the right
              Text(
                "₹${order["price"] ?? 585}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          SizedBox(height: 8.h),

          // Thin divider
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 8.h),

          // 3) Delivery Address row
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16.sp,
                color: Colors.green.shade900,
              ),
              SizedBox(width: 4.w),
              Text(
                "Delivery Address",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Actual address
          Text(
            order["deliveryAddress"] ??
                "Creative Residency | 24th Main Rd, IT...",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),

          // 4) Delivered time row
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14.sp,
                color: Colors.green.shade900,
              ),
              SizedBox(width: 4.w),
              Text(
                "Delivered at ${order["deliveryTime"] ?? "10-11 PM"}",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 8.h),
          // 5) Bottom row: "Rate" + rating bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "Rate" text
              Text(
                "Rate",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade700,
                ),
              ),

              // RatingBar from flutter_rating_bar
              RatingBar.builder(
                initialRating: (order["rating"] ?? 0).toDouble(),
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 16.sp,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.green.shade900,
                ),
                onRatingUpdate: (rating) {
                  // TODO: handle rating update logic
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
