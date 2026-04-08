import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/diagnostico_model.dart';
import 'historial_diagnosticos.dart';

class DiagnosticoResultado extends StatelessWidget {
  final File imagen;
  final AnalisisResponse resultado;

  const DiagnosticoResultado({
    super.key,
    required this.imagen,
    required this.resultado,
  });

  Color _getColorByResult(String resultado) {
    switch (resultado) {
      case 'Sin demencia':
        return Colors.green;
      case 'Demencia muy leve':
        return Colors.orange;
      case 'Demencia leve':
        return Colors.orangeAccent;
      case 'Demencia moderada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconByResult(String resultado) {
    switch (resultado) {
      case 'Sin demencia':
        return Icons.check_circle;
      case 'Demencia muy leve':
        return Icons.info;
      case 'Demencia leve':
        return Icons.warning;
      case 'Demencia moderada':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados del análisis'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconByResult(resultado.resultado),
                        color: _getColorByResult(resultado.resultado),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Análisis completado',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('ID: ${resultado.id}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    resultado.resultado,
                    style: TextStyle(
                      color: _getColorByResult(resultado.resultado),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Clase original: ${resultado.claseOriginal}'),
                  const SizedBox(height: 8),
                  Text('Confianza: ${resultado.confianzaTexto}'),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: resultado.confianza,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(6),
                    backgroundColor: Colors.grey[300],
                    color: _getColorByResult(resultado.resultado),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Imagen subida'),
                  subtitle: Text(resultado.imagenOriginalUrl.isEmpty
                      ? 'La URL firmada no está disponible'
                      : 'Imagen almacenada correctamente'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      imagen,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue[50],
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Este resultado es asistido por IA y debe ser validado por un especialista.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Nuevo análisis'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HistorialDiagnosticos(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Ver historial'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
