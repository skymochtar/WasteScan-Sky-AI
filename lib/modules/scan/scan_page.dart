import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'scan_controller.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ScanController>(
        init: ScanController(),
        builder: (controller) {
          return Stack(
            children: [
              // 1. LAYER TAMPILAN (Kamera atau Gambar Galeri)
              Obx(() {
                if (controller.selectedImagePath.value.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: Image.file(
                      File(controller.selectedImagePath.value),
                      fit: BoxFit.contain,
                    ),
                  );
                } else if (controller.isCameraInitialized.value &&
                    controller.cameraController.value.isInitialized) {
                  return SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: CameraPreview(controller.cameraController),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),

              // 2. ANIMASI SCANNER (Hanya muncul di mode Kamera)
              Obx(() {
                if (controller.selectedImagePath.value.isEmpty) {
                  return AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Positioned(
                        top: MediaQuery.of(context).size.height * 0.1 +
                            (_animController.value *
                                (MediaQuery.of(context).size.height * 0.5)),
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.tealAccent,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.tealAccent.withOpacity(0.5),
                                  blurRadius: 10)
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              }),

              // 3. HEADER "ARAHKAN KE OBJEK SAMPAH"
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "ARAHKAN KE OBJEK SAMPAH",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              // 4. TOMBOL GALERI & RESET
              Positioned(
                top: 50,
                right: 20,
                child: Obx(() {
                  if (controller.selectedImagePath.value.isNotEmpty) {
                    return CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => controller.resetToCamera(),
                      ),
                    );
                  }
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.image, color: Colors.teal),
                      onPressed: () => controller.pickImageFromGallery(),
                    ),
                  );
                }),
              ),

              // 5. PANEL HASIL DETEKSI (Di Bawah Layar)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10)
                    ],
                  ),
                  child: Obx(() {
                    // --- KODE BARU: Perhitungan Persentase ---
                    String persenAkurasi =
                        (controller.confidence.value * 100).toStringAsFixed(0) +
                            "%";
                    bool isDetected = controller.label.value.isNotEmpty &&
                        controller.label.value != "Tidak Dikenali";

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // --- Nama Sampah ---
                        Text(
                          controller.label.value.isEmpty
                              ? "Mencari..."
                              : controller.label.value.toUpperCase(),
                          style: TextStyle(
                            color: controller.confidence.value > 0.5
                                ? Colors.teal[800]
                                : Colors.grey,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        // --- KODE BARU: Teks Persentase Akurasi ---
                        if (isDetected) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Tingkat Akurasi: $persenAkurasi",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54, // Warna abu-abu gelap
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        // --- Kotak Deskripsi ---
                        if (controller.description.value.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              controller.description.value,
                              style: TextStyle(
                                  color: Colors.teal[900], fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 10),

                        // --- Garis Progress Bar Hijau ---
                        if (controller.confidence.value > 0)
                          LinearProgressIndicator(
                            value: controller.confidence.value,
                            color: Colors.teal,
                            backgroundColor: Colors.grey[200],
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
