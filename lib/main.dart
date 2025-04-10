import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fozo_customer_app/utils/helper/shared_preferences_helper.dart';
import 'package:fozo_customer_app/utils/permission/permissions.dart';
import 'package:fozo_customer_app/utils/services/auth_phone.dart';
import 'package:fozo_customer_app/views/auth/login_screen.dart';
import 'package:fozo_customer_app/views/home/home_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'provider/home_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request all necessary app permissions (e.g., storage, location, etc.)
  await AppPermissions.requestAllPermissions();

  // Initialize SharedPreferences to persist user data locally
  await SharedPreferencesHelper.init();

  // Retrieve the stored user email to check login status
  String? userLookup = await SharedPreferencesHelper.getString("userLookup");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp(userLookup: userLookup ?? ""));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.userLookup});
  final String? userLookup;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        // ChangeNotifierProvider(
        //   create: (context) => AddressFormProvider(),
        // ),
        ChangeNotifierProvider(
          create: (context) => FozoHomeProvider(),
        ),
        // ChangeNotifierProvider(
        //   create: (context) => BagProvider(),
        // ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // Base design dimensions
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // home: LoginScreen(),

            // // Determine the home screen based on login status
            home: (userLookup!.isNotEmpty && userLookup != "")
                ? const FozoHomeScreen() // If user is logged in, navigate to HomeScreen
                : LoginScreen(), // Otherwise, show EntryScreen (login/signup)
          );
        },
      ),
    );
  }
}
