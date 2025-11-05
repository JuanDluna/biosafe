// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';
import 'login_screen.dart';

/// Pantalla de configuración con opciones de accesibilidad
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _textToSpeechEnabled = false;
  bool _doubleTapConfirm = false;
  bool _largeText = false;
  bool _highContrast = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await _flutterTts.setLanguage('es-ES');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (_textToSpeechEnabled) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: BioSafeTheme.accentColor),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: BioSafeTheme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(BioSafeTheme.spacingMedium),
        children: [
          // Sección: Cuenta
          _buildSectionHeader('Cuenta', Icons.account_circle),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, size: 32, color: BioSafeTheme.primaryColor),
              title: const Text(
                'Nombre',
                style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              ),
              subtitle: Text(
                user?.name ?? 'No disponible',
                style: const TextStyle(
                  fontSize: BioSafeTheme.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _speak('Nombre: ${user?.name ?? "No disponible"}'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email, size: 32, color: BioSafeTheme.primaryColor),
              title: const Text(
                'Correo electrónico',
                style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              ),
              subtitle: Text(
                user?.email ?? 'No disponible',
                style: const TextStyle(
                  fontSize: BioSafeTheme.fontSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _speak('Correo: ${user?.email ?? "No disponible"}'),
            ),
          ),
          if (user?.age != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, size: 32, color: BioSafeTheme.primaryColor),
                title: const Text(
                  'Edad',
                  style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
                ),
                subtitle: Text(
                  '${user!.age} años',
                  style: const TextStyle(
                    fontSize: BioSafeTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _speak('Edad: ${user.age} años'),
              ),
            ),
          const SizedBox(height: 24),
          
          // Sección: Notificaciones
          _buildSectionHeader('Notificaciones', Icons.notifications),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_active, size: 32, color: BioSafeTheme.primaryColor),
              title: const Text(
                'Activar notificaciones',
                style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              ),
              subtitle: const Text(
                'Recibir recordatorios de medicamentos',
                style: TextStyle(fontSize: 14),
              ),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _speak(value ? 'Notificaciones activadas' : 'Notificaciones desactivadas');
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // Sección: Accesibilidad
          _buildSectionHeader('Accesibilidad', Icons.accessibility),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.volume_up, size: 32, color: BioSafeTheme.primaryColor),
              title: const Text(
                'Lectura por voz',
                style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              ),
              subtitle: const Text(
                'Leer texto en voz alta',
                style: TextStyle(fontSize: 14),
              ),
              value: _textToSpeechEnabled,
              onChanged: (value) {
                setState(() => _textToSpeechEnabled = value);
                _speak(value ? 'Lectura por voz activada' : 'Lectura por voz desactivada');
              },
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.touch_app, size: 32, color: BioSafeTheme.primaryColor),
              title: const Text(
                'Confirmación por doble toque',
                style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              ),
              subtitle: const Text(
                'Requiere doble toque para confirmar acciones',
                style: TextStyle(fontSize: 14),
              ),
              value: _doubleTapConfirm,
              onChanged: (value) {
                setState(() => _doubleTapConfirm = value);
                _speak(value ? 'Confirmación por doble toque activada' : 'Confirmación por doble toque desactivada');
              },
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.text_fields, size: 32, color: BioSafeTheme.primaryColor),
              title: const Text(
                'Texto grande',
                style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              ),
              subtitle: const Text(
                'Aumentar tamaño de fuente',
                style: TextStyle(fontSize: 14),
              ),
              value: _largeText,
              onChanged: (value) {
                setState(() => _largeText = value);
                _speak(value ? 'Texto grande activado' : 'Texto grande desactivado');
              },
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.contrast, size: 32, color: BioSafeTheme.primaryColor),
              title: const Text(
                'Alto contraste',
                style: TextStyle(fontSize: BioSafeTheme.fontSizeSmall),
              ),
              subtitle: const Text(
                'Mejorar visibilidad de elementos',
                style: TextStyle(fontSize: 14),
              ),
              value: _highContrast,
              onChanged: (value) {
                setState(() => _highContrast = value);
                _speak(value ? 'Alto contraste activado' : 'Alto contraste desactivado');
              },
            ),
          ),
          const SizedBox(height: 32),
          
          // Botón de cerrar sesión
          ElevatedButton(
            onPressed: _handleSignOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: BioSafeTheme.accentColor,
              minimumSize: const Size(double.infinity, BioSafeTheme.buttonMinHeight),
              padding: const EdgeInsets.symmetric(vertical: BioSafeTheme.spacingMedium),
            ),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(
                fontSize: BioSafeTheme.fontSizeSmall,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 28, color: BioSafeTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: BioSafeTheme.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: BioSafeTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}

