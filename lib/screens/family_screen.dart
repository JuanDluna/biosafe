// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/medicine_model.dart';
import '../models/treatment_model.dart';
import '../utils/theme.dart';
import 'package:intl/intl.dart';

/// Pantalla de gestión familiar - vista de familiares y sus tratamientos
class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _linkedFamily = [];
  Map<String, List<MedicineModel>> _familyMedicines = {};
  Map<String, List<TreatmentModel>> _familyTreatments = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
  }

  Future<void> _loadFamilyData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.userModel;

      if (currentUser?.linkedFamily != null && currentUser!.linkedFamily!.isNotEmpty) {
        // Cargar datos de cada familiar
        for (final familyUid in currentUser.linkedFamily!) {
          final familyUser = await _firestoreService.getUser(familyUid);
          
          if (familyUser != null) {
            _linkedFamily.add(familyUser);
            
            // Cargar medicamentos del familiar
            final medicines = await _firestoreService.getMedicines(familyUid);
            _familyMedicines[familyUid] = medicines;
            
            // Cargar tratamientos del familiar
            final treatments = await _firestoreService.getTreatments(familyUid);
            _familyTreatments[familyUid] = treatments;
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos familiares: $e')),
        );
      }
    }
  }

  Future<void> _addFamilyMember() async {
    final emailController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Familiar'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Correo electrónico del familiar',
            hintText: 'correo@ejemplo.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, emailController.text),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      // TODO: Buscar usuario por email y agregar a linked_family
      // Por ahora solo mostramos un mensaje
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Funcionalidad en desarrollo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Familia'),
        backgroundColor: BioSafeTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, size: 28),
            onPressed: _addFamilyMember,
            tooltip: 'Agregar familiar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFamilyData,
              child: _linkedFamily.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay familiares vinculados',
                            style: TextStyle(
                              fontSize: BioSafeTheme.fontSizeMedium,
                              color: BioSafeTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca el botón + para agregar uno',
                            style: TextStyle(
                              fontSize: BioSafeTheme.fontSizeSmall,
                              color: BioSafeTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(BioSafeTheme.spacingMedium),
                      itemCount: _linkedFamily.length,
                      itemBuilder: (context, index) {
                        final familyMember = _linkedFamily[index];
                        final medicines = _familyMedicines[familyMember.uid] ?? [];
                        final treatments = _familyTreatments[familyMember.uid] ?? [];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            leading: const Icon(
                              Icons.person,
                              size: 32,
                              color: BioSafeTheme.primaryColor,
                            ),
                            title: Text(
                              familyMember.name,
                              style: const TextStyle(
                                fontSize: BioSafeTheme.fontSizeMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              familyMember.email,
                              style: const TextStyle(
                                fontSize: BioSafeTheme.fontSizeSmall,
                                color: BioSafeTheme.textSecondary,
                              ),
                            ),
                            children: [
                              // Medicamentos del familiar
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.medication_liquid,
                                          size: 24,
                                          color: BioSafeTheme.primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Medicamentos (${medicines.length})',
                                          style: const TextStyle(
                                            fontSize: BioSafeTheme.fontSizeSmall,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (medicines.isEmpty)
                                      const Text(
                                        'No hay medicamentos registrados',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: BioSafeTheme.textSecondary,
                                        ),
                                      )
                                    else
                                      ...medicines.take(3).map((medicine) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.arrow_forward, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${medicine.name} - ${medicine.dosage}',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                    const SizedBox(height: 16),
                                    // Tratamientos del familiar
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.favorite,
                                          size: 24,
                                          color: BioSafeTheme.accentColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Tratamientos (${treatments.length})',
                                          style: const TextStyle(
                                            fontSize: BioSafeTheme.fontSizeSmall,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (treatments.isEmpty)
                                      const Text(
                                        'No hay tratamientos registrados',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: BioSafeTheme.textSecondary,
                                        ),
                                      )
                                    else
                                      ...treatments.take(3).map((treatment) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.arrow_forward, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${treatment.type.displayName}: ${treatment.measurementValue} ${treatment.measurementUnit} - ${DateFormat('dd/MM/yyyy HH:mm').format(treatment.timestamp)}',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}

