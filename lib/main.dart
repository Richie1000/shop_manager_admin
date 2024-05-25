import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_manager_admin/providers/products.dart';

import 'providers/auth.dart';
import 'screens/auth_screen.dart';
import 'screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => Products())
        // ChangeNotifierProvider(create: (context) => Cart()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Arturo',
        theme: ThemeData(
          //colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
          scaffoldBackgroundColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white, // Default background for TextFormField
          ),
          dropdownMenuTheme: DropdownMenuThemeData(
              menuStyle: MenuStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.white))),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.user != null) {
              return HomePage();
            } else {
              return AuthScreen();
            }
          },
        ),
        // routes: {
        //   //'/': (BuildContext context) => HomePage(),
        //   //AuthScreen.routeName: (BuildContext context) => AuthScreen(),
        //   StocksScreen.routeName: (BuildContext context) => StocksScreen()
        // },
      ),
    );
  }
}
