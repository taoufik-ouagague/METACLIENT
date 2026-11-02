import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/config_controller.dart';
import 'controllers/crbt_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/expedition_controller.dart';
import 'controllers/facture_controller.dart';
import 'controllers/retour_fond_controller.dart';
import 'screens/home/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Storage & Networking Services
  await StorageService.init();
  ApiService.init();

  runApp(const MetaClientApp());
}

class MetaClientApp extends StatelessWidget {
  const MetaClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Permanent controllers injection (same architecture as Meta Fleet)
    Get.put(ConfigController(), permanent: true);
    Get.put(AuthController(), permanent: true);
    Get.put(DashboardController(), permanent: true);
    Get.put(ExpeditionController(), permanent: true);
    Get.put(FactureController(), permanent: true);
    Get.put(RetourFondController(), permanent: true);
    Get.put(CrbtController(), permanent: true);

    return GetMaterialApp(
      title: 'Meta Client',
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 360),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
