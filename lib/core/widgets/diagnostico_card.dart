import 'package:flutter/material.dart';
import '../../data/models/diagnostico_model.dart';

class DiagnosticoCard extends StatelessWidget {
  final Diagnostico diagnostico;
  final VoidCallback onTap;

  const DiagnosticoCard({
    super.key,
    required this.diagnostico,
    required this.onTap,
  });

  Color _getColorByResult(String resultado) {
    final result = resultado.toLowerCase();
    if (result.contains('sin demencia')) return Colors.green;
    if (result.contains('muy leve')) return Colors.orange;
    if (result.contains('leve')) return Colors.orangeAccent;
    if (result.contains('moderada')) return Colors.red;
    return Colors.grey;
  }

  IconData _getIconByResult(String resultado) {
    final result = resultado.toLowerCase();
    if (result.contains('sin demencia')) return Icons.check_circle;
    if (result.contains('muy leve')) return Icons.info;
    if (result.contains('leve')) return Icons.warning;
    if (result.contains('moderada')) return Icons.error;
    return Icons.help;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono del resultado
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getColorByResult(
                    diagnostico.resultado,
                  ).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconByResult(diagnostico.resultado),
                  color: _getColorByResult(diagnostico.resultado),
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Info del diagnostico
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagnostico.resultado,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getColorByResult(diagnostico.resultado),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confianza: ${(diagnostico.confianza * 100).toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${diagnostico.fechaFormateada} - ${diagnostico.horaFormateada}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              // nav
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
