import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'result_screen.dart';
import 'services/classifier_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  File? _image;
  final ClassifierService _classifierService = ClassifierService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classifierService.loadModel();
  }

  // Permite escoger una imagen desde cámara o galería.
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });
      await _classifyAndNavigate(_image!);
    }
  }

  Future<void> _classifyAndNavigate(File image) async {
    final result = await _classifierService.classifyImage(image);
    setState(() {
      _isLoading = false;
    });
    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'])),
      );
      return;
    }
    const double confidenceThreshold = 0.7;
    if (result['confidence'] < confidenceThreshold) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            capturedImage: image,
            category: 'No clasificable',
            materialType: '',
            predictedClass: '',
            confidence: result['confidence'],
            isUnclear: true,
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          capturedImage: image,
          category: result['container'] == 'BLANCO'
              ? 'Residuos aprovechables'
              : 'Residuo no aprovechable',
          materialType: result['class'],
          predictedClass: result['class'],
          confidence: result['confidence'],
          isUnclear: false,
        ),
      ),
    );
  }

  // Muestra el menú modal para escoger la fuente de la imagen.
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFE6F5EA),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Seleccionar imagen',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Tomar foto',
                  color: const Color(0xFF66BB6A),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Seleccionar de galería',
                  color: const Color(0xFF43A047),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // Botón estilizado para cada opción de origen.
  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F5EA),
      appBar: AppBar(
        title: const Text('Clasificar Material', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Vista previa de la imagen seleccionada.
              if (_image != null)
                Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 3,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(_image!, fit: BoxFit.cover),
                  ),
                )
              else
                Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2E7D32).withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 60,
                        color: Color(0xFF2E7D32),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Previsualización',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),
              // Botón para mostrar las opciones de imagen.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showImageSourceOptions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Seleccionar Imagen',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
