import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import 'register_page.dart';
import '../modules/home/dashboard_page.dart'; // Mengarah ke halaman utama aplikasi

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // Inisialisasi AuthController di sini agar bisa dipakai di halaman Register juga
  final AuthController authController = Get.put(AuthController());
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Aplikasi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco, size: 80, color: Colors.teal),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  "WasteScan Sky AI",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Silakan masuk untuk melanjutkan",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                
                // Input Email
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.teal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Input Password
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.teal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Tombol Login
                Obx(() => authController.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.teal)
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if(emailController.text.isEmpty || passwordController.text.isEmpty) {
                              Get.snackbar("Peringatan", "Email dan Password harus diisi!", snackPosition: SnackPosition.BOTTOM);
                              return;
                            }

                            // Eksekusi fungsi login
                            bool isSuccess = await authController.loginUser(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                            
                            if (isSuccess) {
                              // Jika sukses, lempar ke Dashboard dan hapus history halaman sebelumnya
                              Get.offAll(() => const DashboardPage()); 
                            }
                          },
                          child: const Text("LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      )),
                      
                const SizedBox(height: 24),
                
                // Teks Menuju Halaman Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun?", style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                        Get.to(() => RegisterPage());
                      },
                      child: const Text("Daftar di sini", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}