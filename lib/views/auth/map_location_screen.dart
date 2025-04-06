// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';

// class AddDeliveryLocationScreen extends StatefulWidget {
//   const AddDeliveryLocationScreen({Key? key}) : super(key: key);

//   @override
//   State<AddDeliveryLocationScreen> createState() =>
//       _AddDeliveryLocationScreenState();
// }

// class _AddDeliveryLocationScreenState extends State<AddDeliveryLocationScreen> {
//   /// Controller for the GoogleMap to move camera, etc.
//   Completer<GoogleMapController> _mapController = Completer();

//   /// Initial camera position, for example at some default lat/long
//   static const CameraPosition _initialPosition = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962), // e.g. Google HQ
//     zoom: 14,
//   );

//   bool _isLocationGranted = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionStatus();
//   }

//   /// Check permission at startup
//   Future<void> _checkPermissionStatus() async {
//     final status = await Permission.location.status;
//     setState(() {
//       _isLocationGranted = status.isGranted;
//     });
//   }

//   /// Request location permission
//   Future<void> _requestLocationPermission() async {
//     final status = await Permission.location.request();
//     if (status.isGranted) {
//       setState(() => _isLocationGranted = true);
//       // Optionally, move camera to the current location if you have that logic
//     } else {
//       // Permission denied. You can decide how to handle it.
//       setState(() => _isLocationGranted = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       /// Simple app bar
//       appBar: AppBar(
//         title: const Text("Add delivery location"),
//         centerTitle: true,
//       ),

//       /// Use a Stack so we can layer the map behind the bottom card
//       body: Stack(
//         children: [
//           /// Google Map at the back
//           GoogleMap(
//             onMapCreated: (controller) => _mapController.complete(controller),
//             initialCameraPosition: _initialPosition,
//             myLocationEnabled: _isLocationGranted,
//             myLocationButtonEnabled: _isLocationGranted,
//           ),

//           /// Bottom Container or BottomSheet
//           if (!_isLocationGranted)
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 24,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(16),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 10,
//                       offset: const Offset(0, -2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min, // only as tall as contents
//                   children: [
//                     /// "Location Permission is Off"
//                     Text(
//                       "Location Permission is Off",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     /// Description
//                     Text(
//                       "Granting location permission will ensure accurate address and hassle-free selection",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                     ),
//                     const SizedBox(height: 16),

//                     /// Allow Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 50,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green.shade900,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         onPressed: _requestLocationPermission,
//                         child: const Text(
//                           "Allow",
//                           style: TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     /// Skip for now
//                     InkWell(
//                       onTap: () {
//                         // e.g. Navigator.pop(context) or ignore
//                       },
//                       child: Text(
//                         "Skip for now",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[800],
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fozo_customer_app/core/constants/colour_constants.dart';
import 'package:fozo_customer_app/provider/address_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../utils/helper/shared_preferences_helper.dart';
import '../../utils/http/api.dart';
import '../home/home_screen.dart';

class AddDeliveryLocationScreen extends StatefulWidget {
  final String phoneNumber; // <-- phone from OTP
  final String firebaseUid; // <-- user.uid from OTP
  final String idToken; // <-- user.uid from OTP
  final String name; // <-- user.uid from OTP

  const AddDeliveryLocationScreen({
    super.key,
    required this.phoneNumber,
    required this.firebaseUid,
    required this.idToken,
    required this.name,
  });
  @override
  State<AddDeliveryLocationScreen> createState() =>
      _AddDeliveryLocationScreenState();
}

class _AddDeliveryLocationScreenState extends State<AddDeliveryLocationScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddressFormProvider>(context);
    Future.microtask(() => provider.init());

    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColor.backgroundColor,
        title: Text(
          "Add delivery location",
          style: TextStyle(fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          /// Google Map
          GoogleMap(
            onMapCreated: (controller) => provider.setMapController(controller),
            initialCameraPosition: provider.initialCameraPosition,
            myLocationEnabled: provider.isLocationGranted,
            myLocationButtonEnabled: provider.isLocationGranted,
            markers: provider.currentLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId("current_location"),
                      position: provider.currentLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                    ),
                  }
                : {},
          ),

          /// Search Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5.r,
                ),
              ],
            ),
            child: TextField(
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: "Search for area, street name...",
                hintStyle: TextStyle(fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
              ),
            ),
          ),

          /// Bottom Location Confirmation
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.r,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Selected Location Display
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFFF6FCEB), // A pale green-ish background
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.green.shade900,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.address,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8.h),

                  /// Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: () async {
                        provider.confirmLocation();

                        final res = await ApiService.postRequest(
                            "auth/register/customer", {
                          "idToken": widget.idToken,
                          "fullName": widget.name,
                          "contactNumber": widget.phoneNumber,
                          "address": provider.address,
                          "profileImage": "https://example.com/image.jpg"
                        });

                        print(res["user"]?["role"]);
                        if (res["user"]?["role"] == "Customer") {
                          // Convert JSON to string and save
                          String actionString = jsonEncode(res);
                          await SharedPreferencesHelper.saveString('userLookup',
                              actionString); // Save a string value

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FozoHomeScreen(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  /// Skip for now
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Skip for now",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

// class AddDeliveryLocationScreen extends StatefulWidget {
//   const AddDeliveryLocationScreen({Key? key}) : super(key: key);

//   @override
//   State<AddDeliveryLocationScreen> createState() =>
//       _AddDeliveryLocationScreenState();
// }

// class _AddDeliveryLocationScreenState extends State<AddDeliveryLocationScreen> {
//   Completer<GoogleMapController> _mapController = Completer();
//   bool _isLocationGranted = false;
//   LatLng? _currentLocation;
//   String _address = "Fetching location...";

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissionAndFetchLocation();
//   }

//   /// **Step 1: Check if permission is already granted, if so, fetch location directly**
//   Future<void> _checkPermissionAndFetchLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();

//     if (permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse) {
//       setState(() => _isLocationGranted = true);
//       _fetchCurrentLocation(); // 🔹 Fetch location directly
//     }
//   }

//   /// **Step 2: Request permission only if needed**
//   Future<void> _allowLocationAccess() async {
//     LocationPermission permission = await Geolocator.requestPermission();

//     if (permission == LocationPermission.always ||
//         permission == LocationPermission.whileInUse) {
//       setState(() => _isLocationGranted = true);
//       _fetchCurrentLocation(); // 🔹 Fetch location after granting permission
//     } else {
//       print("❌ Location permission denied");
//     }
//   }

//   /// **Step 3: Fetch the user's current location and move map**
//   Future<void> _fetchCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       LatLng newLocation = LatLng(position.latitude, position.longitude);
//       setState(() {
//         _currentLocation = newLocation;
//       });

//       _moveCamera(newLocation);
//       _getAddressFromCoordinates(newLocation);
//     } catch (e) {
//       print("Error fetching location: $e");
//     }
//   }

//   /// **Step 4: Move the map camera to user's location**
//   Future<void> _moveCamera(LatLng location) async {
//     final GoogleMapController controller = await _mapController.future;
//     controller.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
//   }

//   /// **Step 5: Get the address from coordinates**
//   Future<void> _getAddressFromCoordinates(LatLng location) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         location.latitude,
//         location.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         setState(() {
//           _address = "${place.street}, ${place.locality}, ${place.country}";
//         });
//       }
//     } catch (e) {
//       print("Error fetching address: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:
//           AppBar(title: const Text("Add delivery location"), centerTitle: true),
//       body: Stack(
//         children: [
//           /// Google Map
//           GoogleMap(
//             onMapCreated: (controller) => _mapController.complete(controller),
//             initialCameraPosition: const CameraPosition(
//               target: LatLng(
//                   37.42796133580664, -122.085749655962), // Default Google HQ
//               zoom: 14,
//             ),
//             myLocationEnabled: _isLocationGranted,
//             myLocationButtonEnabled: _isLocationGranted,
//             markers: _currentLocation != null
//                 ? {
//                     Marker(
//                       markerId: const MarkerId("current_location"),
//                       position: _currentLocation!,
//                       icon: BitmapDescriptor.defaultMarkerWithHue(
//                           BitmapDescriptor.hueGreen),
//                     )
//                   }
//                 : {},
//           ),

//           /// **Show "Allow" screen only if permission is not granted**
//           if (!_isLocationGranted)
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: double.infinity,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(16)),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.black.withOpacity(0.1), blurRadius: 10)
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       "Location Permission is Off",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       "Granting location permission will ensure accurate address and hassle-free selection.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green.shade900,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 14),
//                       ),
//                       onPressed: _allowLocationAccess,
//                       child: const Text("Allow",
//                           style: TextStyle(color: Colors.white, fontSize: 16)),
//                     ),
//                     const SizedBox(height: 8),
//                     InkWell(
//                       onTap: () => Navigator.pop(context),
//                       child: const Text(
//                         "Skip for now",
//                         style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                             decoration: TextDecoration.underline),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//           /// **Show Address & Confirm Button if permission is granted**
//           if (_isLocationGranted)
//             Align(
//               alignment: Alignment.bottomCenter,
//               child: Container(
//                 width: double.infinity,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(16)),
//                   boxShadow: [
//                     BoxShadow(
//                         color: Colors.black.withOpacity(0.1), blurRadius: 10)
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.location_on, color: Colors.green.shade900),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             _address,
//                             style: const TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green.shade900,
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 14),
//                       ),
//                       onPressed: () => print("✅ Confirmed location: $_address"),
//                       child: const Text("Confirm",
//                           style: TextStyle(color: Colors.white, fontSize: 16)),
//                     ),
//                     const SizedBox(height: 8),
//                     InkWell(
//                       onTap: () => Navigator.pop(context),
//                       child: const Text(
//                         "Skip for now",
//                         style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey,
//                             decoration: TextDecoration.underline),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
