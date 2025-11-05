// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/medicine_model.dart';
import '../providers/medicine_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/medicine_card.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'add_medicine_screen.dart';
import 'inventory_screen.dart';
import 'notifications_screen.dart';
import 'family_screen.dart';
import 'settings_screen.dart';

/// Pantalla principal - Home
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
      medicineProvider.loadMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final medicineProvider = Provider.of<MedicineProvider>(context);

    if (!authProvider.isAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: BioSafeTheme.primaryColor,
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: BioSafeTheme.fontSizeSmall,
        unselectedFontSize: BioSafeTheme.fontSizeSmall,
        selectedItemColor: BioSafeTheme.primaryColor,
        unselectedItemColor: BioSafeTheme.textSecondary,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2, size: 28),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 28),
            label: 'Tratamientos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 28),
            label: 'Recordatorios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people, size: 28),
            label: 'Familia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 28),
            label: 'Configuración',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddMedicineScreen()),
                ).then((_) {
                  medicineProvider.loadMedicines();
                });
              },
              backgroundColor: BioSafeTheme.primaryColor,
              icon: const Icon(Icons.add, size: 28),
              label: const Text(
                'Agregar',
                style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              ),
            )
          : null,
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const InventoryScreen();
      case 2:
        return _buildTreatmentsPlaceholder();
      case 3:
        return const NotificationsScreen();
      case 4:
        return const FamilyScreen();
      case 5:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Consumer<MedicineProvider>(
      builder: (context, medicineProvider, _) {
        if (medicineProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final medicines = medicineProvider.medicines;
        final expiringMedicines = medicines.where((m) => m.isExpiringSoon).toList();

        return RefreshIndicator(
          onRefresh: () => medicineProvider.loadMedicines(),
          child: CustomScrollView(
            slivers: [
              // Header con estadísticas
              SliverToBoxAdapter(
                child: _buildStatsHeader(medicines, expiringMedicines),
              ),
              
              // Sección de medicamentos próximos a vencer
              if (expiringMedicines.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: BioSafeTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: BioSafeTheme.warningColor, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber, 
                                  color: BioSafeTheme.warningColor, size: 28),
                              const SizedBox(width: 8),
                              const Text(
                                'Medicamentos por vencer',
                                style: TextStyle(
                                  fontSize: BioSafeTheme.fontSizeMedium,
                                  fontWeight: FontWeight.bold,
                                  color: BioSafeTheme.warningColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...expiringMedicines.take(3).map((med) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.arrow_forward,
                                      color: BioSafeTheme.warningColor, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${med.name} - Vence: ${DateFormat('dd/MM/yyyy').format(med.expirationDate)}',
                                      style: const TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Lista de todos los medicamentos
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: medicines.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              Icon(
                                Icons.medication_liquid,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                AppConstants.emptyInventory,
                                style: TextStyle(
                                  fontSize: BioSafeTheme.fontSizeMedium,
                                  color: BioSafeTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Toca el botón + para agregar uno',
                                style: TextStyle(
                                  fontSize: BioSafeTheme.fontSizeSmall,
                                  color: BioSafeTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final medicine = medicines[index];
                            return MedicineCard(
                              medicine: medicine,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddMedicineScreen(medicine: medicine),
                                  ),
                                ).then((_) => medicineProvider.loadMedicines());
                              },
                              onDelete: () => _deleteMedicine(medicine, medicineProvider),
                            );
                          },
                          childCount: medicines.length,
                        ),
                      ),
              ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsHeader(List<MedicineModel> medicines, List<MedicineModel> expiring) {
    final totalMedicines = medicines.length;
    final totalExpiring = expiring.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: BioSafeTheme.primaryColor.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(
              fontSize: BioSafeTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: BioSafeTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  totalMedicines.toString(),
                  Icons.medication_liquid,
                  BioSafeTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Por vencer',
                  totalExpiring.toString(),
                  Icons.warning_amber,
                  BioSafeTheme.warningColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: BioSafeTheme.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: BioSafeTheme.fontSizeSmall,
              color: BioSafeTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tratamientos Especiales',
            style: TextStyle(
              fontSize: BioSafeTheme.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: BioSafeTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Funcionalidad en desarrollo',
            style: TextStyle(
              fontSize: BioSafeTheme.fontSizeMedium,
              color: BioSafeTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMedicine(MedicineModel medicine, MedicineProvider medicineProvider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar medicamento?'),
        content: Text('¿Estás seguro de eliminar "${medicine.name}"?'),
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
}
