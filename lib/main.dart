import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_provider/screens/loginScreen.dart';
import 'theme/appframe.dart';
import 'package:intl/date_symbol_data_local.dart';

void main()async  {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await initializeDateFormatting('id_ID', null);
  runApp(const MyProviderApp());
}
 
class MyProviderApp extends StatelessWidget {
  const MyProviderApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyProvider',
      debugShowCheckedModeBanner: false,
      theme: Appframe.theme,
      home: const LoginScreen(),
    );
  }
}