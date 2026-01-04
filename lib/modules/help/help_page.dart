import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pusat Bantuan"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHelpCard(
            icon: Icons.camera_alt_outlined,
            title: "Cara Menggunakan",
            content:
                "1. Buka menu 'Scan'.\n2. Arahkan kamera ke objek sampah.\n3. Tunggu beberapa detik hingga sistem mendeteksi jenis sampah.",
          ),
          const SizedBox(height: 15),
          _buildHelpCard(
            icon: Icons.category_outlined,
            title: "Kategori Sampah",
            content:
                "Aplikasi ini dapat mendeteksi:\n- Organik (Sisa makanan, daun)\n- Plastik (Botol, bungkus)\n- Kertas (Kardus, koran)\n- Logam (Kaleng, sendok)",
          ),
          const SizedBox(height: 15),
          _buildHelpCard(
            icon: Icons.tips_and_updates_outlined,
            title: "Tips Akurasi",
            content:
                "Pastikan objek terlihat jelas, tidak terlalu gelap, dan latar belakang tidak terlalu ramai.",
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              "Versi Aplikasi 1.0.0\nSkripsi 2026",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(
      {required IconData icon,
      required String title,
      required String content}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.teal, size: 30),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              content,
              style: const TextStyle(
                  fontSize: 15, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
