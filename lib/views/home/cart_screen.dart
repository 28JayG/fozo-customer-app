import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Replace with your actual color constants import
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import 'package:uuid/uuid.dart';

import '../../utils/http/api.dart';
import '../payment/payment_screen.dart';

class CheckoutPage extends StatefulWidget {
  final int restaurantId;
  final String myAddress;
  final List myCart;
  final Map resData;

  const CheckoutPage({
    super.key,
    required this.restaurantId,
    required this.myAddress,
    required this.myCart,
    required this.resData,
  });
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  double totalItemPrice = 0;
  int totalBag = 0;

  var uuid = Uuid();
  String cartId = "";

  List _addresses = [];
  Map _selectAddress = {};

  Future<void> _getData() async {
    final resAddress = await ApiService.getRequest("address");
    _addresses = resAddress["data"];
    _selectAddress = _addresses.firstWhere(
      (addr) => addr["isDefault"] == true,
      orElse: () => {},
    );

    setState(() {}); // Refresh the UI if inside a StatefulWidget
  }

  @override
  void initState() {
    super.initState();
    // Fetch data once the widget is initialized
    cartId = uuid.v4();
    getMyData();
    _getData();
  }

  void getMyData() {
    totalItemPrice = 0;
    totalBag = 0;
    for (int i = 0; i < widget.myCart.length; i++) {
      String itemName = widget.myCart[i]["itemName"];
      int cartCount = widget.myCart[i]["cart"];
      int index = widget.resData["restaurants"]
          .indexWhere((item) => item["packsize"] == itemName);
      double priceTag = widget.resData["restaurants"][index]["discountedPrice"];
      totalItemPrice = totalItemPrice + (cartCount * priceTag);
      totalBag = totalBag + cartCount;
    }
    setState(() {});
  }

  void addToCart(Map selectItem) {
    int index = widget.myCart
        .indexWhere((item) => item["itemName"] == selectItem["packsize"]);
    if (index == -1) {
      widget.myCart.add({"itemName": selectItem["packsize"], "cart": 1});
    } else {
      widget.myCart[index]["cart"] += 1;
    }
    setState(() {});
    getMyData();
  }

  void removeFromCart(Map selectItem) {
    int index = widget.myCart
        .indexWhere((item) => item["itemName"] == selectItem["packsize"]);
    if (index != -1) {
      widget.myCart[index]["cart"] -= 1;
      if (widget.myCart[index]["cart"] <= 0) {
        widget.myCart.removeAt(index);
      }
      setState(() {});
    }
    getMyData();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryCharge = 50;
    final handlingCharge = 35;

    // final subTotal = bagProvider.totalCost; // sum of item.price * quantity
    // final grandTotal = subTotal + deliveryCharge + handlingCharge;

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        // If you want a back arrow, or you can omit
        automaticallyImplyLeading: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Checkout",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CO2 Saved Message
              Container(
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
                child: Text(
                  "You saved 0.7kg Co2 on this order",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // "Cart" heading
              Text(
                "Cart",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10.h),

              ListView.separated(
                // Use a shrinkWrap to fit inside SingleChildScrollView
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.resData["restaurants"]!.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = widget.resData["restaurants"][index];
                  return _buildCartItemRow(item);
                },
              ),

              SizedBox(height: 20.h),

              Container(
                padding: EdgeInsets.all(12.r),
                margin: EdgeInsets.only(bottom: 8.h),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.green.shade900,
                          size: 18.sp,
                        ),
                        SizedBox(width: 6.w),

                        // Wrap the whole Column with Expanded instead
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Delivery Address",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "${_selectAddress["name"]} | ${_selectAddress["apartment"]}, ${_selectAddress["city"]}, ${_selectAddress["state"]}, ${_selectAddress["postalCode"]} | Recipient Name: ${_selectAddress["recipientName"]} | Phone No: ${_selectAddress["phoneNumber"]}",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 6.w),

                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    constraints: BoxConstraints(
                                        maxHeight:
                                            500), // scrollable if more addresses
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Select Delivery Address",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: _addresses.length,
                                            itemBuilder: (context, index) {
                                              final item = _addresses[index];
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectAddress = item;
                                                  });
                                                  Navigator.pop(
                                                      context); // close popup
                                                },
                                                child: Card(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    side: BorderSide(
                                                      color:
                                                          item["isDefault"] ==
                                                                  true
                                                              ? Colors.green
                                                              : Colors.grey
                                                                  .shade300,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  elevation: 3,
                                                  child: Padding(
                                                    padding: EdgeInsets.all(12),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.home,
                                                              color: Colors
                                                                  .green
                                                                  .shade800,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              item["name"] ??
                                                                  "",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            if (item[
                                                                    "isDefault"] ==
                                                                true) ...[
                                                              SizedBox(
                                                                  width: 6),
                                                              Container(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .green
                                                                      .shade50,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Text(
                                                                  "Default",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .green
                                                                        .shade800,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              )
                                                            ]
                                                          ],
                                                        ),
                                                        SizedBox(height: 6),
                                                        Text(
                                                          "${item["apartment"]}, ${item["streetAddress"]}, ${item["city"]}, ${item["state"]} - ${item["postalCode"]}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[700],
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          "Phone: ${item["phoneNumber"]}",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            "Change",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Color(0xFF1C4D1E),
                              fontWeight: FontWeight.bold, // 👈 Add this
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200.w,
                          height: 1.h,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_clock,
                          color: Colors.green.shade900,
                          size: 18.sp,
                        ),
                        SizedBox(width: 6.w),

                        // Wrap the whole Column with Expanded instead
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Delivered by 10-11 PM",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "You will receive 20 minutes before the delivery time.",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Delivery Address

              SizedBox(height: 20.h),

              // Bill Details
              Text(
                "Bill Details",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),

              // Bill details container
              Container(
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
                child: Column(
                  children: [
                    _buildBillRow("Sub total", "₹$totalItemPrice"),
                    SizedBox(height: 4.h),
                    _buildBillRow("Delivery charge", "₹$deliveryCharge"),
                    SizedBox(height: 4.h),
                    _buildBillRow("Handling charge", "₹$handlingCharge"),
                    SizedBox(height: 8.h),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    SizedBox(height: 8.h),
                    _buildBillRow(
                      "Grand total",
                      "₹${totalItemPrice + deliveryCharge + handlingCharge}",
                      isBold: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // "Process to pay" Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectAddress.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("No Address Selected"),
                            content: Text(
                                "Please select an address before confirming."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentMethodPage(
                            cartId: cartId,
                            selectAddress: _selectAddress,
                            totalPayPrice: totalItemPrice +
                                handlingCharge +
                                deliveryCharge),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  child: Text(
                    "Process to pay",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // A helper row for the Bill details
  Widget _buildBillRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black87,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black87,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Build each item in the cart
  Widget _buildCartItemRow(item) {
    int count = widget.myCart.firstWhere(
        (e) => e["itemName"] == item["packsize"],
        orElse: () => {"cart": 0})["cart"];
    if (count == 0) {
      return SizedBox(
        height: 0,
        width: 0,
      );
    }

    return Container(
      padding: EdgeInsets.all(12.r),
      margin: EdgeInsets.only(bottom: 8.h),
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
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: item["imageUrl"],
              width: 60.w,
              height: 60.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          SizedBox(width: 10.w),

          // Middle texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The screenshot shows "Barbeque Nation, HSR" as the main line
                // then "Medium Surprise Bag" below. You can store these
                // in your BagItem or you can combine them. For demonstration,
                // let's show bagItem.title on top and bagItem.description below.
                Text(
                  item["packsize"] ?? "",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item["description"] ?? "",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "₹${item["discountedPrice"]} worth ₹${item["originalPrice"]}",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Quantity selector
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green.shade900),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // minus
                GestureDetector(
                  onTap: () {
                    removeFromCart(item);
                  },
                  child: Icon(
                    Icons.remove,
                    size: 18.sp,
                    color: Colors.green.shade900,
                  ),
                ),
                SizedBox(width: 8.w),

                // quantity
                Text(
                  "$count",
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.w),

                // plus
                GestureDetector(
                  onTap: () {
                    addToCart(item);
                  },
                  child: Icon(
                    Icons.add,
                    size: 18.sp,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
