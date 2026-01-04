import 'dart:io'; 
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart'; 

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;
  var label = "".obs;
  var confidence = 0.0.obs;
  var description = "".obs;

  var selectedImagePath = "".obs;

  Interpreter? _interpreter;
  List<String>? _labels;
  var isWorking = false;

  final Map<String, String> dataDeskripsi = {
    "Plastik":
        "Jenis: Sampah Anorganik (Plastik).\n\nPenjelasan: Material sintetis yang sulit terurai secara alami (bisa ratusan tahun).\n\nSaran: Cuci bersih, remas agar hemat tempat, dan setor ke Bank Sampah.",
    "Kertas":
        "Jenis: Sampah Anorganik (Kertas/Kardus).\n\nPenjelasan: Berbahan dasar serat kayu atau selulosa.\n\nSaran: Pastikan kering dan tidak berminyak. Sangat bernilai jual di pengepul barang bekas.",
    "Organik":
        "Jenis: Sampah Organik (Sisa Hayati).\n\nPenjelasan: Berasal dari sisa makhluk hidup yang mudah membusuk.\n\nSaran: Jangan dibuang ke TPA! Olah menjadi pupuk kompos atau pakan ternak.",
    "Logam":
        "Jenis: Sampah Anorganik (Logam).\n\nPenjelasan: Berbahan dasar metal, aluminium, besi, atau seng.\n\nSaran: Bernilai ekonomis tinggi. Pisahkan dan jual ke pengepul.",
  };

  @override
  void onInit() {
    super.onInit();
    initTFLite();
    initCamera();
  }

  @override
  void onClose() {
    if (isCameraInitialized.value) {
      cameraController.dispose();
    }
    _interpreter?.close();
    super.onClose();
  }

  // --- FUNGSI KAMERA ---
  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras[0],
          ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );

        await cameraController.initialize();
        isCameraInitialized.value = true;

        int frameCount = 0;
        cameraController.startImageStream((CameraImage image) {
          // Hanya proses jika TIDAK sedang menampilkan gambar galeri
          if (selectedImagePath.value.isEmpty) {
            frameCount++;
            if (frameCount % 30 == 0 && !isWorking) {
              isWorking = true;
              runInferenceCamera(image);
            }
          }
        });
      }
    } catch (e) {
      print("Error Init Camera: $e");
    }
  }

  Future<void> initTFLite() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels =
          labelData.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } catch (e) {
      print("Error Model: $e");
    }
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImagePath.value = image.path; // Simpan path gambar
      isWorking = true;
      await runInferenceFile(image.path); // Jalankan deteksi file
    }
  }

  // Reset agar kembali ke mode kamera live
  void resetToCamera() {
    selectedImagePath.value = "";
    label.value = "";
    description.value = "";
    confidence.value = 0.0;
  }

  // --- LOGIC DETEKSI KHUSUS FILE (GALERI) ---
  Future<void> runInferenceFile(String path) async {
    try {
      // 1. Baca File Gambar
      final imageData = File(path).readAsBytesSync();
      img.Image? decodedImage = img.decodeImage(imageData);

      if (decodedImage == null) return;

      var inputTensor = _interpreter!.getInputTensor(0);
      int inputSize = inputTensor.shape[1]; // 224
      img.Image resizedImage =
          img.copyResize(decodedImage, width: inputSize, height: inputSize);

      // 3. Siapkan Input (RGB)
      var input = List.generate(
          1,
          (i) => List.generate(
              inputSize,
              (y) => List.generate(inputSize, (x) {
                    var pixel = resizedImage.getPixel(x, y);
                    if (inputTensor.type == TensorType.uint8) {
                      return [
                        pixel.r.toInt(),
                        pixel.g.toInt(),
                        pixel.b.toInt()
                      ];
                    } else {
                      return [
                        pixel.r / 255.0,
                        pixel.g / 255.0,
                        pixel.b / 255.0
                      ];
                    }
                  })));

      // 4. Jalankan Model
      await _runModelOnInput(input);
    } catch (e) {
      print("Error Gallery Inference: $e");
    } finally {
      isWorking = false;
    }
  }

  // --- LOGIC DETEKSI KHUSUS KAMERA (STREAM) ---
  Future<void> runInferenceCamera(CameraImage cameraImage) async {
    if (_interpreter == null || _labels == null) {
      isWorking = false;
      return;
    }

    try {
      var inputTensor = _interpreter!.getInputTensor(0);
      int inputSize = inputTensor.shape[1];

      img.Image? convertedImage = _convertYUV420ToImage(cameraImage);
      if (convertedImage == null) return;

      img.Image resizedImage =
          img.copyResize(convertedImage, width: inputSize, height: inputSize);

      var input = List.generate(
          1,
          (i) => List.generate(
              inputSize,
              (y) => List.generate(inputSize, (x) {
                    var pixel = resizedImage.getPixel(x, y);
                    if (inputTensor.type == TensorType.uint8) {
                      return [
                        pixel.r.toInt(),
                        pixel.g.toInt(),
                        pixel.b.toInt()
                      ];
                    } else {
                      return [
                        pixel.r / 255.0,
                        pixel.g / 255.0,
                        pixel.b / 255.0
                      ];
                    }
                  })));

      await _runModelOnInput(input);
    } catch (e) {
      print("Error Camera Inference: $e");
    } finally {
      isWorking = false;
    }
  }

  // --- LOGIC UMUM JALANKAN AI (Dipakai Camera & Galeri) ---
  Future<void> _runModelOnInput(List<dynamic> input) async {
    var outputTensor = _interpreter!.getOutputTensor(0);
    var outputBuffer;

    if (outputTensor.type == TensorType.uint8) {
      outputBuffer =
          List.filled(1 * _labels!.length, 0).reshape([1, _labels!.length]);
    } else {
      outputBuffer =
          List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);
    }

    _interpreter!.run(input, outputBuffer);

    List<double> finalOutput;
    if (outputTensor.type == TensorType.uint8) {
      finalOutput =
          (outputBuffer[0] as List<int>).map((e) => e / 255.0).toList();
    } else {
      finalOutput = List<double>.from(outputBuffer[0]);
    }

    double maxScore = 0;
    int maxIndex = -1;

    for (int i = 0; i < finalOutput.length; i++) {
      if (finalOutput[i] > maxScore) {
        maxScore = finalOutput[i];
        maxIndex = i;
      }
    }

    if (maxIndex != -1 && maxScore > 0.5) {
      String detectedLabel = _labels![maxIndex];
      String cleanLabel = detectedLabel.replaceAll(RegExp(r'^[0-9\s]+'), '');
      label.value = cleanLabel;
      description.value = dataDeskripsi[cleanLabel] ?? "Tidak ada deskripsi.";
      confidence.value = maxScore;
    } else {
      label.value = "Tidak Dikenali";
      description.value = "Objek tidak jelas.";
      confidence.value = maxScore;
    }
  }

  img.Image? _convertYUV420ToImage(CameraImage cameraImage) {
    try {
      final int width = cameraImage.width;
      final int height = cameraImage.height;
      final int uvRowStride = cameraImage.planes[1].bytesPerRow;
      final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;
      final image = img.Image(width: width, height: height);
      for (int w = 0; w < width; w++) {
        for (int h = 0; h < height; h++) {
          final int uvIndex =
              uvPixelStride! * (w / 2).floor() + uvRowStride * (h / 2).floor();
          final int index = h * width + w;
          final y = cameraImage.planes[0].bytes[index];
          final u = cameraImage.planes[1].bytes[uvIndex];
          final v = cameraImage.planes[2].bytes[uvIndex];
          int r = (y + v * 1.432 - 179.456).round().clamp(0, 255);
          int g =
              (y - u * 0.39465 - v * 0.58060 + 135.459).round().clamp(0, 255);
          int b = (y + u * 2.03211 - 276.836).round().clamp(0, 255);
          image.setPixelRgb(w, h, r, g, b);
        }
      }
      return image;
    } catch (e) {
      return null;
    }
  }
}
