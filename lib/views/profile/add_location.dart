import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:fozo_customer_app/core/constants/colour_constants.dart';
// import 'package:fozo_customer_app/provider/address_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/colour_constants.dart';
import '../../utils/http/api.dart';

class AddNewDeliveryLocationScreen extends StatefulWidget {
  const AddNewDeliveryLocationScreen({
    super.key,
  });
  @override
  State<AddNewDeliveryLocationScreen> createState() =>
      _AddNewDeliveryLocationScreenState();
}

class _AddNewDeliveryLocationScreenState
    extends State<AddNewDeliveryLocationScreen> {
  List searchList = [];

  final Completer<GoogleMapController> _controller = Completer();

// Initial Location
  final LatLng _initialLatLng = LatLng(22.420524, 87.337126);

// Location & Address states
  LatLng? selectLocation;
  String? selectPlaceAddress;
  Placemark? place;

  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _setInitialMarker();
    _getCurrentLocation();
  }

  void _setInitialMarker() {
    selectLocation = _initialLatLng;
    _marker = Marker(
      markerId: MarkerId('current_location'),
      position: _initialLatLng,
      infoWindow: InfoWindow(title: "Initial Location"),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
      permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng newPosition = LatLng(position.latitude, position.longitude);

    // Update marker and selected location
    setState(() {
      selectLocation = newPosition;
      _marker = Marker(
        markerId: MarkerId('current_location'),
        position: newPosition,
        infoWindow: InfoWindow(title: "Your Location"),
      );
    });

    // Move camera to new location
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newPosition));

    // Get human-readable address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    setState(() {
      place = placemarks.first;

      selectPlaceAddress =
          "${place?.street}, ${place?.locality}, ${place?.postalCode}";
    });
  }

  /// When user selects a place from search
  Future<void> onPlaceSelected(Map placeData) async {
    // Get location from Google Place result
    double lat = placeData["geometry"]["location"]["lat"];
    double lng = placeData["geometry"]["location"]["lng"];
    String address = placeData["formatted_address"];

    LatLng newPosition = LatLng(lat, lng);
    print(placeData);
    print("placeData");

    selectLocation = newPosition;
    selectPlaceAddress = address;
    _marker = Marker(
      markerId: MarkerId("selected_place"),
      position: newPosition,
      infoWindow: InfoWindow(title: "Selected Place"),
    );

    // Move camera
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newPosition));

    // Get human-readable address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      lat,
      lng,
    );

    place = placemarks.first;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
            initialCameraPosition: CameraPosition(
              target: _initialLatLng,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _marker != null ? {_marker!} : {},
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          /// Search Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.r),
                bottomRight: Radius.circular(8.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5.r,
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) async {
                if (value != "") {
                  // Do something with the value
                  print("User typed: $value");

                  String encodedUrl = Uri.encodeFull(value.toString().trim());
                  print(encodedUrl);

                  final response = await http.get(Uri.parse(
                      'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodedUrl}&key=AIzaSyAy8IOF5Fdx7gPUfWWelE_-kYFiyzYZqYE'));

                  print(
                      'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${encodedUrl}&key=AIzaSyAy8IOF5Fdx7gPUfWWelE_-kYFiyzYZqYE');

                  if (response.statusCode >= 200 && response.statusCode < 300) {
                    Map data = jsonDecode(response.body);
                    print(data);
                    searchList = data["results"];
                    setState(() {});
                  } else {
                    print(
                        'HTTP Error: ${response.statusCode} - ${response.body}');
                    Map data = {};
                  }
                }
              },
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
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.r)),
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
                    /// Scrollable String List (min 3 items height)

                    searchList.isNotEmpty
                        ? SizedBox(
                            height: 100.h,
                            child: ListView.builder(
                              itemCount: searchList.length,
                              itemBuilder: (context, index) {
                                Map onePlace = searchList[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4.h, horizontal: 8.w),
                                  child: GestureDetector(
                                    onTap: () {
                                      onPlaceSelected(
                                          onePlace); // Pass the whole place object

                                      print("Clicked on: ${onePlace["name"]}");
                                      // Your logic here
                                    },
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(12.r),
                                        child: Text(
                                          "${onePlace["name"]} - ${onePlace["formatted_address"]}",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : SizedBox.shrink(),

                    // SizedBox(height: 12.h),

                    /// Selected Location Display
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6FCEB),
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
                                  selectPlaceAddress ?? "",
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
                        onPressed: () => _showAddressPopup(context),
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
                  ],
                )),
          ),
        ],
      ),
    );
  }

  void _showAddressPopup(BuildContext context) async {
    // Wait for popup to close
    await showDialog(
      context: context,
      builder: (context) {
        print(place);
        return Dialog(
          child: SingleChildScrollView(
            child: AddressForm(
              selectLocation: selectLocation,
              selectPlaceAddress: selectPlaceAddress,
              place: place,
            ),
          ),
        );
      },
    );

    // After popup closes, navigate to a new screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         SelectLocationScreen(), // Replace with your actual screen
    //   ),
    // );

    Navigator.pop(context);
  }
}

class AddressForm extends StatefulWidget {
  final LatLng? selectLocation;
  final String? selectPlaceAddress;
  final Placemark? place;

  const AddressForm({
    super.key,
    required this.selectLocation,
    required this.selectPlaceAddress,
    required this.place,
  });

  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String recipientName = "";
  String? streetAddress = "";
  String? apartment = "";
  String? city = "";
  String? state = "";
  String? postalCode = "";
  String? country = "";
  String phoneNumber = "";
  String deliveryInstructions = "";
  bool isDefault = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void _getData() {
    print(widget.place);
    streetAddress = widget.place?.street;
    city = widget.place?.locality;
    postalCode = widget.place?.postalCode;
    country = widget.place?.country;
    state = widget.place?.administrativeArea;
    apartment = widget.place?.name;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildTextField('Label', name, (val) => name = val),
            _buildTextField(
                'Recipient Name', recipientName, (val) => recipientName = val),
            _buildTextField(
                'Street Address', streetAddress!, (val) => streetAddress = val),
            _buildTextField('Apartment', apartment!, (val) => apartment = val),
            _buildTextField('City', city!, (val) => city = val),
            _buildTextField('State', state!, (val) => state = val),
            _buildTextField(
                'Postal Code', postalCode!, (val) => postalCode = val),
            _buildTextField('Country', country!, (val) => country = val),
            _buildTextField(
                'Phone Number', phoneNumber, (val) => phoneNumber = val),
            _buildTextField('Delivery Instructions', deliveryInstructions,
                (val) => deliveryInstructions = val),
            Row(
              children: [
                Checkbox(
                  value: isDefault,
                  onChanged: (value) => setState(() => isDefault = value!),
                ),
                Text("Set as Default"),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Map<String, dynamic> formData = {
                    "name": name,
                    "recipientName": recipientName,
                    "streetAddress": streetAddress,
                    "apartment": apartment,
                    "city": city,
                    "state": state,
                    "postalCode": postalCode,
                    "country": country,
                    "phoneNumber": phoneNumber,
                    "isDefault": isDefault,
                    "deliveryInstructions": deliveryInstructions,
                  };

                  final resOutlate =
                      await ApiService.postRequest("address", formData);
                  Navigator.pop(context);
                }
              },
              child: Text('Submit..'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
