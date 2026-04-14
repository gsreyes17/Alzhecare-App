import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'diagnosis_cubit.dart';
import 'diagnosis_state.dart';

class PatientAnalysisPage extends StatefulWidget {
  const PatientAnalysisPage({super.key});

  @override
  State<PatientAnalysisPage> createState() => _PatientAnalysisPageState();
}

class _PatientAnalysisPageState extends State<PatientAnalysisPage> {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiagnosisCubit, DiagnosisState>(
      listenWhen: (previous, current) =>
          previous.message != current.message ||
          previous.lastAnalysis != current.lastAnalysis,
      listener: (context, state) {
        if (state.status == DiagnosisStatus.failure && state.message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message!)));
        }
        if (state.status == DiagnosisStatus.success &&
            state.lastAnalysis != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Diagnóstico generado correctamente')),
          );
        }
      },
      builder: (context, state) {
        final isBusy = state.status == DiagnosisStatus.loading || _picking;

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const _SectionHeader(
              title: 'Análisis de imagen',
              subtitle:
                  'Selecciona una imagen, envíala al backend y revisa la predicción generada.',
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: isBusy ? null : _pickImage,
                            icon: const Icon(Icons.upload_file_outlined),
                            label: const Text('Seleccionar imagen'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: (_imageBytes == null || isBusy)
                                ? null
                                : () {
                                    context.read<DiagnosisCubit>().analyzeImage(
                                      bytes: _imageBytes!,
                                      filename: _filename ?? 'image.jpg',
                                    );
                                  },
                            icon: const Icon(Icons.analytics_outlined),
                            label: Text(
                              isBusy ? 'Procesando...' : 'Analizar imagen',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_filename != null) ...[
                      Text(
                        'Archivo: $_filename',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (_imageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          _imageBytes!,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'Aquí se mostrará la previsualización de la imagen',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (state.lastAnalysis != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Último diagnóstico',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AnalysisResultRow(
                        label: 'Resultado',
                        value: state.lastAnalysis!.result,
                      ),
                      _AnalysisResultRow(
                        label: 'Confianza',
                        value:
                            '${(state.lastAnalysis!.confidence * 100).toStringAsFixed(2)}%',
                      ),
                      _AnalysisResultRow(
                        label: 'Fecha',
                        value: DateFormat(
                          'dd/MM/yyyy HH:mm',
                        ).format(state.lastAnalysis!.createdAt),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Historial reciente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (state.history.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Aún no hay diagnósticos cargados.'),
                ),
              )
            else
              ...state.history
                  .take(5)
                  .map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.medical_information_outlined,
                          ),
                          title: Text(record.result),
                          subtitle: Text(
                            '${(record.confidence * 100).toStringAsFixed(2)}% • ${DateFormat('dd/MM/yyyy HH:mm').format(record.createdAt)}',
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}

class PatientHistoryPage extends StatelessWidget {
  const PatientHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiagnosisCubit, DiagnosisState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<DiagnosisCubit>().loadHistory(),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const _SectionHeader(
                title: 'Historial de diagnósticos',
                subtitle:
                    'Lista cronológica de resultados, confianza y fechas de análisis.',
              ),
              const SizedBox(height: 20),
              if (state.history.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Todavía no hay diagnósticos para mostrar.'),
                  ),
                )
              else
                ...state.history.map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ExpansionTile(
                        leading: const Icon(Icons.assignment_outlined),
                        title: Text(record.result),
                        subtitle: Text(
                          '${(record.confidence * 100).toStringAsFixed(2)}% • ${DateFormat('dd/MM/yyyy HH:mm').format(record.createdAt)}',
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          20,
                        ),
                        children: [
                          _AnalysisResultRow(
                            label: 'Diagnóstico',
                            value: record.result,
                          ),
                          _AnalysisResultRow(
                            label: 'Confianza',
                            value:
                                '${(record.confidence * 100).toStringAsFixed(2)}%',
                          ),
                          _AnalysisResultRow(
                            label: 'Estado',
                            value: record.status ?? 'N/A',
                          ),
                          _AnalysisResultRow(label: 'ID', value: record.id),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF617084), height: 1.6),
        ),
      ],
    );
  }
}

class _AnalysisResultRow extends StatelessWidget {
  const _AnalysisResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF617084)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
