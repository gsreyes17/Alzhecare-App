import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/basic_user.dart';
import '../../analysis/presentation/analysis_page.dart';
import '../../auth/presentation/auth_cubit.dart';
import '../data/doctor_repository.dart';

class DoctorPatientsPage extends StatefulWidget {
  const DoctorPatientsPage({super.key});

  @override
  State<DoctorPatientsPage> createState() => _DoctorPatientsPageState();
}

class _DoctorPatientsPageState extends State<DoctorPatientsPage> {
  final _searchController = TextEditingController();
  final _repository = <DoctorRepository?>[];

  Timer? _debounce;
  bool _loadingSearch = false;
  bool _loadingLinked = true;
  bool _loadingRequests = true;

  List<BasicUser> _searchResults = const [];
  List<BasicUser> _linkedPatients = const [];
  Set<String> _requestingPatients = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLinkedPatients();
      _loadRequests();
    });
  }

  DoctorRepository get _doctorRepository {
    if (_repository.isEmpty) {
      _repository.add(context.read<DoctorRepository>());
    }
    return _repository.first!;
  }

  Future<void> _loadLinkedPatients() async {
    setState(() => _loadingLinked = true);
    try {
      final patients = await _doctorRepository.listLinkedPatients();
      if (!mounted) return;
      setState(() => _linkedPatients = patients);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible cargar pacientes: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingLinked = false);
      }
    }
  }

  Future<void> _loadRequests() async {
    setState(() => _loadingRequests = true);
    try {
      final requests = await _doctorRepository.listRequests();
      if (!mounted) return;
      final pending = requests
          .where((request) => request.status.toLowerCase() == 'pendiente')
          .map((request) => request.patientUserId)
          .toSet();
      setState(() => _requestingPatients = pending);
    } catch (_) {
      // Non-blocking: la vista puede operar sin esta sección.
    } finally {
      if (mounted) {
        setState(() => _loadingRequests = false);
      }
    }
  }

  Future<void> _onSearchChanged(String value) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = value.trim();
      if (query.length < 2) {
        if (mounted) {
          setState(() {
            _searchResults = const [];
            _loadingSearch = false;
          });
        }
        return;
      }

      setState(() => _loadingSearch = true);
      try {
        final results = await _doctorRepository.searchPatients(query);
        if (!mounted) return;
        setState(() => _searchResults = results);
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No fue posible buscar pacientes: $error')),
        );
      } finally {
        if (mounted) {
          setState(() => _loadingSearch = false);
        }
      }
    });
  }

  Future<void> _sendRequest(BasicUser user) async {
    try {
      await _doctorRepository.sendRequest(user.id);
      if (!mounted) return;
      setState(() => _requestingPatients = {..._requestingPatients, user.id});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud enviada a ${user.fullName}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fue posible enviar la solicitud: $error')),
      );
    }
  }

  void _openAnalysis(BasicUser patient) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalysisPage(
          user: context.read<AuthCubit>().state.session!.user,
          analyzeForPatientId: patient.id,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadLinkedPatients();
        await _loadRequests();
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buscar pacientes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      labelText: 'Nombre, apellido o usuario',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingSearch)
                    const LinearProgressIndicator(minHeight: 2),
                  if (!_loadingSearch &&
                      _searchController.text.trim().length >= 2 &&
                      _searchResults.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('No se encontraron pacientes'),
                    ),
                  if (_searchResults.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._searchResults.map((user) {
                      final pending = _requestingPatients.contains(user.id);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(user.fullName),
                        subtitle: Text('@${user.username}'),
                        trailing: pending
                            ? const Chip(label: Text('Pendiente'))
                            : FilledButton(
                                onPressed: () => _sendRequest(user),
                                child: const Text('Enviar solicitud'),
                              ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pacientes vinculados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  if (_loadingLinked)
                    const Center(child: CircularProgressIndicator())
                  else if (_linkedPatients.isEmpty)
                    const Text('Aún no tienes pacientes vinculados')
                  else
                    ..._linkedPatients.map(
                      (patient) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.favorite_outline),
                        ),
                        title: Text(patient.fullName),
                        subtitle: Text('@${patient.username}'),
                        trailing: OutlinedButton.icon(
                          onPressed: () => _openAnalysis(patient),
                          icon: const Icon(Icons.medical_information_outlined),
                          label: const Text('Analizar'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_loadingRequests)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: LinearProgressIndicator(minHeight: 2),
            ),
        ],
      ),
    );
  }
}
