// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/medicine_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar servicio de notificaciones
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
  } catch (e) {
    // Error silencioso para compatibilidad con Web
    debugPrint('Error al inicializar notificaciones: $e');
  }
  
  runApp(const BioSafeApp());
}

class BioSafeApp extends StatelessWidget {
  const BioSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, MedicineProvider>(
          create: (_) => MedicineProvider(),
          update: (_, authProvider, previous) {
            final provider = previous ?? MedicineProvider();
            if (authProvider.isAuthenticated && authProvider.currentUser != null) {
              provider.setUserId(authProvider.currentUser!.uid);
            }
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: BioSafeTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Widget que decide mostrar login o home según autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (authProvider.isAuthenticated) {
          // Inicializar provider de medicamentos
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final medicineProvider = Provider.of<MedicineProvider>(context, listen: false);
            if (authProvider.currentUser != null) {
              medicineProvider.setUserId(authProvider.currentUser!.uid);
              medicineProvider.loadMedicines();
            }
          });
          
          return const HomeScreen();
        }
        
        return const LoginScreen();
      },
    );
  }
}
