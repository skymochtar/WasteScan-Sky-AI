import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'modules/home/dashboard_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WasteScan Sky AI', 
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal, 
          brightness: Brightness.light,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer 3 detik sebelum masuk ke aplikasi
    Future.delayed(const Duration(seconds: 3), () {
      Get.off(() => const DashboardPage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal, Colors.greenAccent],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon Logo dengan efek bayangan
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  size: 120, 
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                "WasteScan Sky AI",
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      offset: Offset(2, 2),
                      blurRadius: 5.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                "Deteksi Sampah Cerdas",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),

              // Loading Indicator Putih
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3, // 
              ),

              // Versi Aplikasi di bawah
              const SizedBox(height: 20),
              const Text(
                "Versi 1.0.0",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
