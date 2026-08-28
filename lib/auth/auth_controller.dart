import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'login_page.dart'; // Pastikan path ini sesuai dengan file login_page Anda

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var isLoading = false.obs;
  
  // Variabel untuk menyimpan nama user yang sedang login
  var userName = "Sobat Lingkungan".obs; 

  // --- FUNGSI 1: MENGAMBIL DATA NAMA PENGGUNA ---
  Future<void> fetchUserData() async {
    try {
      if (_auth.currentUser != null) {
        String uid = _auth.currentUser!.uid;
        DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
        
        if (doc.exists) {
          userName.value = doc['namaLengkap']; // Mengambil nama dari database
        }
      }
    } catch (e) {
      print("Gagal mengambil data user: $e");
    }
  }

  // --- FUNGSI 2: REGISTER ---
  Future<void> registerUser(String nama, String email, String password) async {
    try {
      isLoading.value = true;
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'namaLengkap': nama,
        'email': email,
        'tanggalDaftar': DateTime.now(),
        'totalScan': 0, 
      });

      isLoading.value = false;
      
      Get.defaultDialog(
        title: "Pendaftaran Berhasil!",
        middleText: "Akun Anda telah terdaftar. Silakan lanjut Login.",
        barrierDismissible: false, 
        titleStyle: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
        textConfirm: "Login Sekarang",
        confirmTextColor: Colors.white,
        buttonColor: Colors.teal,
        onConfirm: () {
          Get.back(); 
          Get.back(); 
        },
      );
    } catch (e) {
      isLoading.value = false; 
      if (Get.isDialogOpen != true) {
        Get.defaultDialog(
          title: "Gagal Mendaftar",
          middleText: "Terjadi kesalahan. Silakan cek terminal VS Code.",
          textConfirm: "OK", confirmTextColor: Colors.white, buttonColor: Colors.teal,
          onConfirm: () => Get.back(),
        );
      }
      print("🚨🚨🚨 ERROR FIREBASE ASLI (REGISTER): 🚨🚨🚨 \n$e");
    }
  }

  // --- FUNGSI 3: LOGIN ---
  Future<bool> loginUser(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // Setelah berhasil login, panggil fungsi ambil nama
      await fetchUserData();

      isLoading.value = false;
      return true; 
    } catch (e) {
      isLoading.value = false;
      if (Get.isDialogOpen != true) {
        Get.defaultDialog(
          title: "Gagal Login",
          middleText: "Email/Password salah, atau cek koneksi internet.",
          textConfirm: "OK", confirmTextColor: Colors.white, buttonColor: Colors.teal,
          onConfirm: () => Get.back(),
        );
      }
      return false; 
    }
  }

  // --- FUNGSI 4: LOGOUT (KELUAR) ---
  Future<void> logout() async {
    // Munculkan Pop-up konfirmasi sebelum keluar
    Get.defaultDialog(
      title: "Keluar Aplikasi",
      middleText: "Apakah Anda yakin ingin keluar?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.teal,
      buttonColor: Colors.redAccent, // Warna merah agar jelas ini tombol keluar
      onConfirm: () async {
        await _auth.signOut(); // Putuskan koneksi dari Firebase
        userName.value = "Sobat Lingkungan"; // Kembalikan nama ke default
        Get.offAll(() => LoginPage()); // Lempar kembali ke halaman Login
      },
    );
  }
}