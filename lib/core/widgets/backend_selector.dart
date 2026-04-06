import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BackendSelector extends StatefulWidget {
  const BackendSelector({super.key});

  @override
  State<BackendSelector> createState() => _BackendSelectorState();
}

class _BackendSelectorState extends State<BackendSelector> {
  late String _selectedUrl;
  final Map<String, String> _availableUrls = ApiService.getAvailableUrls();

  @override
  void initState() {
    super.initState();
    _selectedUrl = ApiService.baseUrl;
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await ApiService.initialize();
    setState(() {
      _selectedUrl = ApiService.baseUrl;
    });
  }

  Future<void> _changeBackendUrl(String newUrl) async {
    await ApiService.changeBaseUrl(newUrl);
    setState(() {
      _selectedUrl = newUrl;
    });

    // Mostrar confirmacion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Backend cambiado a: ${ApiService.getCurrentUrlName()}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración del Backend'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Backend Actual:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ApiService.getCurrentUrlName(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedUrl,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Seleccionar Backend:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _availableUrls.entries.map((entry) {
                  final isSelected = _selectedUrl == entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    child: ListTile(
                      leading: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.blue[700] : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.blue[600]
                              : Colors.grey[600],
                        ),
                      ),
                      onTap: () => _changeBackendUrl(entry.value),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // btn de prueba de con
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testConnection,
                icon: const Icon(Icons.wifi),
                label: const Text('Probar Conexión'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Probando conexión...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final response = await ApiService.get('/health');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conexión exitosa'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Error: ${response.statusCode}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
