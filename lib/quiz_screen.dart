import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  final List<Map<String, dynamic>> _questions = [
    {
      'question': '¿Dónde reciclar plástico PET?',
      'options': ['Contenedor azul', 'Contenedor amarillo', 'Basura normal'],
      'correctAnswer': 1,
    },
    // Añade más preguntas...
  ];

  void _answerQuestion(int selectedIndex) {
    bool isCorrect = selectedIndex == _questions[_currentQuestion]['correctAnswer'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? '¡Correcto!' : 'Incorrecto'),
        content: Text(isCorrect ? 'Bien hecho' : 'La respuesta correcta es: ${_questions[_currentQuestion]['options'][_questions[_currentQuestion]['correctAnswer']]}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_currentQuestion < _questions.length - 1) {
                setState(() => _currentQuestion++);
              }
            },
            child: const Text('Siguiente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz de Reciclaje')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(_questions[_currentQuestion]['question']),
            ..._questions[_currentQuestion]['options'].asMap().entries.map((entry) {
              int idx = entry.key;
              String option = entry.value;
              return ElevatedButton(
                onPressed: () => _answerQuestion(idx),
                child: Text(option),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}