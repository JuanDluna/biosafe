// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medicine_model.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_card.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'add_medicine_screen.dart';

/// Pantalla de inventario completo con filtros
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MedicineStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _selectedFilter = null; // Todos
              break;
            case 1:
              _selectedFilter = MedicineStatus.active;
              break;
            case 2:
              _selectedFilter = MedicineStatus.expiring;
              break;
            case 3:
              _selectedFilter = MedicineStatus.expired;
              break;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deleteMedicine(MedicineModel medicine, MedicineProvider medicineProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar?'),
        content: Text('Eliminar "${medicine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: BioSafeTheme.accentColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && medicine.id != null) {
      final success = await medicineProvider.deleteMedicine(medicine.id!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medicamento eliminado')),
        );
      }
    }
  }

  List<MedicineModel> _getFilteredMedicines(List<MedicineModel> medicines, MedicineStatus? filter) {
    if (filter == null) return medicines;
    return medicines.where((m) => m.status == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        backgroundColor: BioSafeTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Activos'),
            Tab(text: 'Por vencer'),
            Tab(text: 'Vencidos'),
          ],
        ),
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, medicineProvider, _) {
          if (medicineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final medicines = _getFilteredMedicines(medicineProvider.medicines, _selectedFilter);

          return RefreshIndicator(
            onRefresh: () => medicineProvider.loadMedicines(),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMedicineList(medicines, medicineProvider),
                _buildMedicineList(
                  _getFilteredMedicines(medicineProvider.medicines, MedicineStatus.active),
                  medicineProvider,
                ),
                _buildMedicineList(
                  _getFilteredMedicines(medicineProvider.medicines, MedicineStatus.expiring),
                  medicineProvider,
                ),
                _buildMedicineList(
                  _getFilteredMedicines(medicineProvider.medicines, MedicineStatus.expired),
                  medicineProvider,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
          ).then((_) {
            final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
            medicineProvider.loadMedicines();
          });
        },
        backgroundColor: BioSafeTheme.primaryColor,
        icon: const Icon(Icons.add, size: 28),
        label: const Text(
          'Agregar',
          style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
        ),
      ),
    );
  }

  Widget _buildMedicineList(List<MedicineModel> medicines, MedicineProvider medicineProvider) {
    if (medicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay medicamentos en esta categoría',
              style: TextStyle(
                fontSize: BioSafeTheme.fontSizeMedium,
                color: BioSafeTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final medicine = medicines[index];
        return MedicineCard(
          medicine: medicine,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddMedicineScreen(medicine: medicine),
              ),
            ).then((_) {
              medicineProvider.loadMedicines();
            });
          },
          onDelete: () => _deleteMedicine(medicine, medicineProvider),
        );
      },
    );
  }
}
