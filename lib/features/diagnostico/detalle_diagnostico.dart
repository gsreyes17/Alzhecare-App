import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/providers/diagnostico_provider.dart';

class DetalleDiagnostico extends StatefulWidget {
  final String diagnosticoId;

  const DetalleDiagnostico({super.key, required this.diagnosticoId});

  @override
  State<DetalleDiagnostico> createState() => _DetalleDiagnosticoState();
}

class _DetalleDiagnosticoState extends State<DetalleDiagnostico> {
  String _formatFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiagnosticoProvider>(context, listen: false)
          .cargarDetalleDiagnostico(widget.diagnosticoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del diagnóstico'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DiagnosticoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetalle) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(provider.errorMessage, textAlign: TextAlign.center),
              ),
            );
          }

          final diagnostico = provider.diagnosticoDetalle;
          if (diagnostico == null) {
            return const Center(child: Text('Diagnóstico no encontrado'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.cargarDetalleDiagnostico(widget.diagnosticoId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnostico.resultado,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Confianza: ${(diagnostico.confianza * 100).toStringAsFixed(1)}%'),
                        Text('Clase original: ${diagnostico.claseOriginal}'),
                        Text('Estado: ${diagnostico.estado}'),
                        Text('Fecha: ${_formatFecha(diagnostico.createdAt)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo),
                        title: const Text('Imagen original'),
                        subtitle: const Text('URL firmada de S3'),
                      ),
                      if (diagnostico.imagenOriginalUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: diagnostico.imagenOriginalUrl,
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const SizedBox(
                            height: 240,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => const SizedBox(
                            height: 240,
                            child: Center(child: Icon(Icons.broken_image, size: 48)),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No hay URL disponible para la imagen.'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (diagnostico.datosRoboflow.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Datos técnicos',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ...diagnostico.datosRoboflow.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text('${entry.key}: ${entry.value}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
