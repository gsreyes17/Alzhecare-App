import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/models/app_user.dart';
import '../../patient/presentation/diagnosis_cubit.dart';
import '../../patient/presentation/diagnosis_state.dart';

/// Análisis de imágenes para cualquier usuario (paciente, doctor, admin)
class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key, required this.user, this.analyzeForPatientId});

  /// Usuario actual (propietario de la sesión)
  final AppUser user;

  /// Si es doctor/admin, puede analizar a nombre de un paciente específico
  final String? analyzeForPatientId;

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  Uint8List? _imageBytes;
  String? _filename;
  bool _picking = false;

  Future<void> _pickImage() async {
    setState(() => _picking = true);
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _filename = file.name;
      });
    } finally {
      if (mounted) {
        setState(() => _picking = false);
      }
    }
  }

  Future<void> _analyze() async {
    if (_imageBytes == null || _filename == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una imagen')),
      );
      return;
    }

    if (!mounted) return;

    if (widget.analyzeForPatientId != null) {
      // Doctor/Admin analizando para un paciente
      context.read<DiagnosisCubit>().analyzeImageForPatient(
        patientId: widget.analyzeForPatientId!,
        bytes: _imageBytes!,
        filename: _filename!,
      );
    } else {
      // Usuario analizando para sí mismo
      context.read<DiagnosisCubit>().analyzeImage(
        bytes: _imageBytes!,
        filename: _filename!,
      );
    }

    setState(() {
      _imageBytes = null;
      _filename = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiagnosisCubit, DiagnosisState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        if (state.status == DiagnosisStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Error al analizar imagen'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == DiagnosisStatus.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Análisis completado')));
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.analyzeForPatientId != null)
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Analizando a nombre del paciente: ${widget.analyzeForPatientId}',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // Image selector
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  color: Colors.grey.shade50,
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      )
                    : GestureDetector(
                        onTap: _picking ? null : _pickImage,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Toca para seleccionar imagen',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (_imageBytes != null)
                Text(
                  'Imagen: $_filename',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 24),
              // Analyze button
              FilledButton.icon(
                onPressed: state.status == DiagnosisStatus.loading || _picking
                    ? null
                    : _analyze,
                icon: state.status == DiagnosisStatus.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.psychology_outlined),
                label: Text(
                  state.status == DiagnosisStatus.loading
                      ? 'Analizando...'
                      : 'Analizar imagen',
                ),
              ),
              const SizedBox(height: 32),
              // Last result
              if (state.lastAnalysis != null) ...[
                const Text(
                  'Último análisis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Resultado: ${state.lastAnalysis!.result}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${(state.lastAnalysis!.confidence * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(state.lastAnalysis!.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // Recent history
              if (state.history.isNotEmpty) ...[
                const Text(
                  'Análisis recientes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...state.history.take(5).map((record) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(
                          Icons.check_circle_outline,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      title: Text(record.result),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(record.createdAt),
                      ),
                      trailing: Text(
                        '${(record.confidence * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                })
              ],
            ],
          ),
        );
      },
    );
  }
}
