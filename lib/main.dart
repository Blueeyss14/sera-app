import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/services/session_service.dart';
import 'res/colors.dart';
import 'res/constant.dart';
import 'src/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  await Get.putAsync(() => SessionService().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: ColorValues.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ColorValues.primary,
          primary: ColorValues.primary,
          surface: ColorValues.background,
        ),
      ),
    );
  }
}
