import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Регистрация
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return "Регистрация прошла успешно!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Логин
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Вход выполнен успешно!";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Выход
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Получение текущего пользователя
  User? get currentUser => _auth.currentUser;
}
