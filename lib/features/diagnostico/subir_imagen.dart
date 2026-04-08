import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_alzhecare_cnn/core/widgets/drawer.dart';
import 'package:flutter_alzhecare_cnn/data/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../data/providers/diagnostico_provider.dart';
import 'diagnostico_resultado.dart';

class SubirImagen extends StatefulWidget {
  final bool showScaffold;

  const SubirImagen({super.key, this.showScaffold = true});

  @override
  _SubirImagenState createState() => _SubirImagenState();
}

class _SubirImagenState extends State<SubirImagen> {
  File? _imagen;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imagen = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error seleccionando imagen: $e')));
    }
  }

  Future<void> _analizarImagen() async {
    if (_imagen == null) return;

    final diagnosticoProvider = Provider.of<DiagnosticoProvider>(
      context,
      listen: false,
    );

    try {
      final resultado = await diagnosticoProvider.analizarImagen(_imagen!);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DiagnosticoResultado(imagen: _imagen!, resultado: resultado),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analizando imagen: $e'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosticoProvider = Provider.of<DiagnosticoProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _imagen == null
                      ? Column(
                          children: [
                            Icon(
                              Icons.medical_services,
                              size: 120,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Selecciona una imagen MRI para análisis de Alzheimer",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Image.file(
                              _imagen!,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Imagen seleccionada",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: Icon(Icons.photo_library),
                          label: Text("Galería"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: Icon(Icons.camera_alt),
                          label: Text("Cámara"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  diagnosticoProvider.isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _imagen != null ? _analizarImagen : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text("Analizar"),
                        ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recomendaciones",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildRecommendationItem(
                    "• Imágenes MRI cerebrales en formato JPEG o PNG",
                  ),
                  _buildRecommendationItem(
                    "• Asegúrate de que la imagen sea clara y nítida",
                  ),
                  _buildRecommendationItem(
                    "• Los resultados deben ser validados por un médico",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (!widget.showScaffold) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Subir Imagen Médica"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(
        currentRole: authProvider.userRole,
        currentUserName: authProvider.userName,
      ),
      body: content,
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: TextStyle(fontSize: 14)),
    );
  }
}
