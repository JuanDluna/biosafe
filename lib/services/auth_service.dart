// BioSafe - archivo generado con IA asistida - revisión: Pablo

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

/// Servicio de autenticación con FirebaseAuth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  final FirestoreService _firestoreService = FirestoreService();
  static const String _uidKey = 'biosafe_uid';

  /// Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  /// Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Iniciar sesión con correo y contraseña
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Guardar UID localmente
        await _saveUidLocally(userCredential.user!.uid);
        
        // Sincronizar datos del usuario desde Firestore
        await _syncUserData(userCredential.user!.uid);
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Registrar nuevo usuario
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    int? age,
  }) async {
    try {
      // Crear usuario en FirebaseAuth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        
        // Guardar UID localmente
        await _saveUidLocally(uid);

        // Crear documento de usuario en Firestore
        final userModel = UserModel(
          uid: uid,
          name: name,
          email: email,
          age: age,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);
        
        // Sincronizar datos del usuario
        await _syncUserData(uid);
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Iniciar sesión con Google
  Future<User?> signInWithGoogle() async {
    try {
      // Iniciar el flujo de autenticación de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return null;
      }

      // Obtener los detalles de autenticación del usuario
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear un nuevo credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión en Firebase con el credential de Google
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        final firebaseUser = userCredential.user!;
        
        // Guardar UID localmente
        await _saveUidLocally(uid);

        // Obtener nombre y email del usuario de Google
        // Prioridad: Firebase User > Google Account
        String userName = firebaseUser.displayName ?? 
                         googleUser.displayName ?? 
                         (googleUser.email.isNotEmpty ? googleUser.email.split('@').first : 'Usuario');
        String userEmail = firebaseUser.email ?? 
                         googleUser.email;

        // Si no tenemos nombre, intentar obtenerlo del email
        if ((userName.isEmpty || userName == 'Usuario') && userEmail.isNotEmpty) {
          final emailParts = userEmail.split('@');
          if (emailParts.isNotEmpty) {
            userName = emailParts[0];
          }
        }

        // Verificar si el usuario ya existe en Firestore
        var userModel = await _firestoreService.getUser(uid);
        
        if (userModel == null) {
          // Crear nuevo usuario con datos de Google
          userModel = UserModel(
            uid: uid,
            name: userName.isNotEmpty ? userName : 'Usuario',
            email: userEmail.isNotEmpty ? userEmail : '',
            createdAt: DateTime.now(),
          );
          await _firestoreService.createUser(userModel);
        } else {
          // Actualizar usuario existente con datos de Google (si faltan o están desactualizados)
          if (userModel.name.isEmpty || userModel.name == 'Usuario' || 
              userModel.email.isEmpty || userModel.email != userEmail ||
              userName.isNotEmpty && userName != userModel.name) {
            userModel = userModel.copyWith(
              name: userName.isNotEmpty && userName != 'Usuario' ? userName : userModel.name,
              email: userEmail.isNotEmpty ? userEmail : userModel.email,
            );
            await _firestoreService.updateUser(userModel);
          }
        }
        
        // Sincronizar datos del usuario
        await _syncUserData(uid);
      }

      return userCredential.user;
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _clearUidLocally();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// Obtener UID guardado localmente
  Future<String?> getSavedUid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_uidKey);
    } catch (e) {
      return null;
    }
  }

  /// Guardar UID localmente
  Future<void> _saveUidLocally(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_uidKey, uid);
    } catch (e) {
      // Error silencioso, no crítico
    }
  }

  /// Limpiar UID guardado localmente
  Future<void> _clearUidLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_uidKey);
    } catch (e) {
      // Error silencioso, no crítico
    }
  }

  /// Sincronizar datos del usuario desde Firestore
  Future<void> _syncUserData(String uid) async {
    try {
      // Descargar y guardar datos del usuario, medicamentos, tratamientos y notificaciones
      // Esto se maneja en el servicio de sincronización
      // Por ahora solo verificamos que el usuario existe
      await _firestoreService.getUser(uid);
    } catch (e) {
      // Error silencioso, se puede manejar después
    }
  }

  /// Manejar excepciones de FirebaseAuth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró un usuario con este correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      case 'operation-not-allowed':
        return 'Esta operación no está permitida.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  /// Verificar si el usuario está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Obtener UID del usuario actual
  String? get currentUid => currentUser?.uid;
}


