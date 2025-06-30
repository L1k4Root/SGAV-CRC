import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

/// Página para subir imagen de patente, enviarla al backend y mostrar el resultado.
class PlateScannerPage extends StatefulWidget {
  const PlateScannerPage({Key? key}) : super(key: key);

  @override
  _PlateScannerPageState createState() => _PlateScannerPageState();
}

class _PlateScannerPageState extends State<PlateScannerPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Uint8List? _selectedBytes;
  String? _detectedPlate;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      if (kIsWeb) {
        _selectedBytes = bytes;
        _selectedImage = null;
      } else {
        _selectedImage = File(picked.path);
        _selectedBytes = null;
      }
      _detectedPlate = null;
      _error = null;
    });
  }

  Future<void> _scanPlate() async {
    if (_selectedImage == null && _selectedBytes == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final uri = Uri.parse('http://localhost:3000/scan-plate');
      final request = http.MultipartRequest('POST', uri);
      if (_selectedBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _selectedBytes!,
          filename: 'plate.png',
          contentType: MediaType('image', 'png'),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }
      final response = await request.send();
      final body = await response.stream.bytesToString();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(body) as Map<String, dynamic>;
        final plate = data['plate'] as String?;
        if (plate != null) {
          setState(() {
            _detectedPlate = plate;
          });
          Navigator.pop(context, plate);
          return;
        } else {
          setState(() {
            _error = 'Respuesta sin campo "plate"';
          });
        }
      } else {
        setState(() {
          _error = 'Error del servidor: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error procesando la imagen: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear Patente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Seleccionar imagen'),
            ),
            const SizedBox(height: 16),
            if (_selectedBytes != null)
              Image.memory(_selectedBytes!, height: 200),
            if (_selectedBytes == null && _selectedImage != null)
              Image.file(_selectedImage!, height: 200),
            if (_selectedImage != null || _selectedBytes != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _scanPlate,
                icon: const Icon(Icons.camera_alt),
                label: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Escanear'),
              ),
              const SizedBox(height: 16),
            ],
            if (_detectedPlate != null)
              Text(
                'Patente detectada: $_detectedPlate',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}