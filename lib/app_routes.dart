import 'package:fitness_life/screen/screen.dart';
import 'package:get/get.dart';

import 'bindings/binding.dart';


List<GetPage> appPages = [

  // 1. Splash Screen
  GetPage(
    name: SplashScreen.pageId,
    page: () => const SplashScreen(),
    binding: SplashBinding(),
  ),

  // 2. Login Screen
  GetPage(
    name: LoginScreen.pageId,
    page: () => const LoginScreen(),
    binding: LoginBinding(),
  ),

  // 3. Register Screen
  GetPage(
    name: RegisterScreen.pageId,
    page: () => const RegisterScreen(),
    binding: RegisterBinding(),
  ),

  // 4. Home Screen (User)
  GetPage(
    name: HomeScreen.pageId,
    page: () => const HomeScreen(),
    binding: HomeBinding(),
  ),

  GetPage(
    name: PlanScreen.pageId,
    page: () => const PlanScreen(),
    binding: PlanBinding(),
  ),

  GetPage(
    name: AboutScreen.pageId,
    page: () => const AboutScreen(),
    binding: AboutBinding(),
  ),

  // GetPage(
  //     name: WgerWorkoutScreen.pageId,
  //     page: () => const WgerWorkoutScreen(),
  //     binding: WgerBinding() // Don't forget the binding!
  // ),

  GetPage(
    name: MainNavigationScreen.pageId,
    page: () => const MainNavigationScreen(),
  ),

];