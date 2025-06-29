import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';

/// Página para escanear patentes usando la cámara y ML Kit.
class PlateScannerPage extends StatefulWidget {
  const PlateScannerPage({Key? key}) : super(key: key);

  @override
  _PlateScannerPageState createState() => _PlateScannerPageState();
}

class _PlateScannerPageState extends State<PlateScannerPage> {
  CameraController? _controller;
  late TextRecognizer _textRecognizer;
  bool _isProcessing = false;
  String? _detectedPlate;
  bool _cameraSupported = true;

  @override
  void initState() {
    super.initState();
    _textRecognizer = GoogleMlKit.vision.textRecognizer();
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      _initializeCamera();
    } else {
      _cameraSupported = false;
    }
  }

  Future<void> _pickAndProcess() async {
    final picker = ImagePicker();
    final XFile? pic = await picker.pickImage(source: ImageSource.camera);
    if (pic == null) return;

    // Procesar la imagen con el mismo recognizer
    final input = InputImage.fromFilePath(pic.path);
    final recognizedText = await _textRecognizer.processImage(input);
    final match = RegExp(r'[A-Z]{2,3}\d{3,4}')
        .firstMatch(recognizedText.text.replaceAll(' ', ''));
    if (match != null) {
      setState(() {
        _detectedPlate = match.group(0);
      });
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller!.initialize();
    await _controller!.startImageStream(_processCameraImage);
    if (mounted) setState(() {});
  }

  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final inputImage = InputImage.fromBytes(
      bytes: allBytes.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: _imageFormatFromRaw(image.format.group),
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    final recognizedText = await _textRecognizer.processImage(inputImage);
    for (final block in recognizedText.blocks) {
      final text = block.text.replaceAll(' ', '');
      final match = RegExp(r'[A-Z]{2,3}\d{3,4}').firstMatch(text);
      if (match != null) {
        _detectedPlate = match.group(0);
        _stopScanning();
        break;
      }
    }

    _isProcessing = false;
    if (mounted) setState(() {});
  }

  void _stopScanning() {
    _controller?.stopImageStream();
    _controller?.dispose();
    _textRecognizer.close();
  }

  @override
  void dispose() {
    _stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Escanear Patente')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _pickAndProcess,
                child: const Text('Tomar foto y escanear'),
              ),
              const SizedBox(height: 16),
              if (_detectedPlate != null)
                Text(
                  'Patente: $_detectedPlate',
                  style: const TextStyle(fontSize: 24),
                ),
            ],
          ),
        ),
      );
    }
    if (!_cameraSupported) {
      return Scaffold(
        appBar: AppBar(title: const Text('Escanear Patente')),
        body: const Center(child: Text('Esta función solo está disponible en dispositivos móviles.')),
      );
    }
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Escanear Patente')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Patente')),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          if (_detectedPlate != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.black54,
                child: Text(
                  'Patente: $_detectedPlate',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }

  InputImageFormat _imageFormatFromRaw(ImageFormatGroup? format) {
    switch (format) {
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv420;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      default:
        return InputImageFormat.nv21;
    }
  }
}