import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/diagnostico_card.dart';
import '../../data/providers/diagnostico_provider.dart';
import 'detalle_diagnostico.dart';
import 'subir_imagen.dart';

class HistorialDiagnosticos extends StatefulWidget {
  const HistorialDiagnosticos({super.key});

  @override
  State<HistorialDiagnosticos> createState() => _HistorialDiagnosticosState();
}

class _HistorialDiagnosticosState extends State<HistorialDiagnosticos> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiagnosticoProvider>(context, listen: false).cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de diagnósticos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubirImagen()),
              );
            },
            icon: const Icon(Icons.upload_file),
            tooltip: 'Nuevo análisis',
          ),
        ],
      ),
      body: Consumer<DiagnosticoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHistorial && provider.diagnosticos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty && provider.diagnosticos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(provider.errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.cargarHistorial(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.diagnosticos.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.cargarHistorial(),
              child: ListView(
                children: [
                  const SizedBox(height: 120),
                  const Icon(Icons.history, size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay diagnósticos registrados',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Realiza tu primer análisis para ver el historial.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SubirImagen()),
                        );
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Subir imagen'),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.cargarHistorial(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.diagnosticos.length,
              itemBuilder: (context, index) {
                final diagnostico = provider.diagnosticos[index];
                return DiagnosticoCard(
                  diagnostico: diagnostico,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalleDiagnostico(diagnosticoId: diagnostico.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
