import 'package:flutter/material.dart';
import 'dart:io';
import 'recycling_guide_screen.dart';

class ResultScreen extends StatelessWidget {
  final File capturedImage;
  final String category;
  final String materialType;
  final String predictedClass;
  final double confidence;
  final bool isUnclear;

  const ResultScreen({
    super.key,
    required this.capturedImage,
    required this.category,
    required this.materialType,
    required this.predictedClass,
    required this.confidence,
    this.isUnclear = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isUnclear) {
      return Scaffold(
        backgroundColor: const Color(0xFFE6F5EA),
        appBar: AppBar(
          title: const Text('Resultado', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF2E7D32),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      capturedImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'La imagen no es clara o el objeto no es clasificable.\nIntenta tomar la foto desde otro ángulo o con mejor iluminación.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final wasteInfo = getWasteInfo(predictedClass);
    return Scaffold(
      backgroundColor: const Color(0xFFE6F5EA),
      appBar: AppBar(
        title: const Text('Resultado', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 250,
              width: 250,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  capturedImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    wasteInfo['type'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    materialType,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Precisión: ${(confidence * 100).toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                const Text(
                  'DEPOSITA EN:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  wasteInfo['image'],
                  height: 150,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: wasteInfo['color'].withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: wasteInfo['color'],
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    wasteInfo['container'],
                    style: TextStyle(
                      color: wasteInfo['color'],
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecyclingGuideScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66BB6A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  '¿CÓMO RECICLAR?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getWasteInfo(String predictedClass) {
    if ([
      'cardboard', 'glass', 'metal', 'paper', 'plastic'
    ].contains(predictedClass)) {
      return {
        'type': 'Residuos aprovechables',
        'container': 'BLANCO',
        'color': Colors.blueGrey,
        'image': 'assets/images/contenedor1.png'
      };
    } else if (predictedClass == 'trash') {
      return {
        'type': 'Residuo no aprovechable',
        'container': 'NEGRO',
        'color': Colors.black,
        'image': 'assets/images/contenedor3.png'
      };
    } else {
      return {
        'type': 'Desconocido',
        'container': 'GENERAL',
        'color': Colors.grey,
        'image': 'assets/images/contenedor1.png'
      };
    }
  }
}
