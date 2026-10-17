import 'package:flutter/material.dart';

class ClasificarScreen extends StatelessWidget {
  const ClasificarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clasificar Materiales')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Plástico FET'),
            subtitle: const Text('Reciclar en contenedor amarillo'),
            leading: const Icon(Icons.recycling),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Plástico FET'),
                  content: const Text('Cómo reciclarlo: Llevar a un punto limpio.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Añade más materiales aquí...
        ],
      ),
    );
  }
}