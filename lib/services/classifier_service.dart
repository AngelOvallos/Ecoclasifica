import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ClassifierService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/modelo_reciclaje.tflite');
      _isModelLoaded = true;
    } catch (e) {
      print('Error loading model: $e');
      _isModelLoaded = false;
    }
  }

  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    if (!_isModelLoaded) {
      print('Modelo no cargado');
      return {'error': 'Modelo no cargado'};
    }

    try {
      print('Leyendo imagen: ${imageFile.path}');
      final image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) {
        print('No se pudo decodificar la imagen');
        return {'error': 'No se pudo procesar la imagen'};
      }
      print('Imagen decodificada: ${image.width}x${image.height}');

      final resizedImage = img.copyResize(image, width: 224, height: 224);
      print('Imagen redimensionada: ${resizedImage.width}x${resizedImage.height}');

      // Preparar tensor de entrada
      var input = List.generate(
        1,
        (_) => List.generate(
          224,
          (_) => List.generate(
            224,
            (_) => List<double>.filled(3, 0),
          ),
        ),
      );

      // Extraer y normalizar valores RGB
      for (var y = 0; y < resizedImage.height; y++) {
        for (var x = 0; x < resizedImage.width; x++) {
          final pixel = resizedImage.getPixel(x, y);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;

          input[0][y][x][0] = r / 255.0;
          input[0][y][x][1] = g / 255.0;
          input[0][y][x][2] = b / 255.0;
        }
      }

      // Preparar tensor de salida
      var output = List.filled(6, 0.0).reshape([1, 6]);

      print('Ejecutando inferencia...');
      _interpreter!.run(input, output);
      print('Inferencia completada');

      // Procesar resultados
      var results = output[0] as List<double>;
      var maxScore = results.reduce((a, b) => a > b ? a : b);
      var maxIndex = results.indexOf(maxScore);

      return {
        'class': _getClassName(maxIndex),
        'confidence': maxScore,
        'container': _mapToContainer(maxIndex),
        'probabilities': results,
      };
    } catch (e) {
      print('Error durante la clasificación: $e');
      return {'error': 'Error durante la clasificación'};
    }
  }

  String _getClassName(int index) {
    final classes = ['cardboard', 'glass', 'metal', 'paper', 'plastic', 'trash'];
    return classes[index];
  }

  String _mapToContainer(int classIndex) {
    return classIndex == 5 ? 'NEGRO' : 'BLANCO';
  }

  void dispose() {
    _interpreter?.close();
  }
}
