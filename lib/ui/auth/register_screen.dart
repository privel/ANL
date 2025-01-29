import 'package:dolby/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _passwordConfirm = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordValid = true;
  bool _doPasswordsMatch = true;
  bool isPassword = false;

  // Функция проверки паролей в реальном времени
  void _validatePasswords() {
    setState(() {
      _isPasswordValid = _password.text.length >= 8;
      _doPasswordsMatch = _password.text == _passwordConfirm.text;
    });
  }

  void _register() async {
    if (!_isPasswordValid || !_doPasswordsMatch) return;

    String? message = await _authService.register(_email.text, _password.text);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message ?? 'Ошибка!')));
    }
  }

  @override
  void initState() {
    super.initState();

    // Добавляем слушателей для проверки пароля в реальном времени
    _password.addListener(_validatePasswords);
    _passwordConfirm.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.06,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.16,
                            left: MediaQuery.of(context).size.width * 0.09,
                            child: Text(
                              "Dolby",
                              style: GoogleFonts.getFont(
                                "Inria Sans",
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/icons/icon8-png/icons8-dolby-digital-144.png',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildTextField(_email, "Email"),
                    const SizedBox(height: 15),
                    _buildTextFieldPassword(_password, "Password"),
                    const SizedBox(height: 15),
                    _buildTextFieldPassword(
                        _passwordConfirm, "Confirm Password"),
                    // _buildPasswordValidationText(),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    _buildRegisterButton(),
                    const SizedBox(height: 10),
                    _buildGoogleSignUp(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Виджет текстового поля
  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool isPassword = false}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        cursorWidth: 1,
        cursorColor: const Color(0xFF30d35c),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF30d35c), width: 1),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color.fromARGB(64, 245, 245, 245)),
        ),
      ),
    );
  }

  Widget _buildTextFieldPassword(
    TextEditingController controller,
    String hintText,
  ) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        cursorWidth: 1,
        cursorColor: const Color(0xFF30d35c),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF1A1A1A), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF30d35c), width: 1),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color.fromARGB(64, 245, 245, 245)),
          suffixIcon: IconButton(
            iconSize: 20,
            icon: Icon(
              isPassword ? Icons.visibility_off : Icons.visibility,
              color: !isPassword
                  ? Color(0xFF30d35c)
                  : Colors.white24, // Цвет иконки
            ),
            onPressed: () {
              setState(() {
                isPassword = !isPassword; // Меняем состояние
              });
            },
          ),
        ),
      ),
    );
  }

  // Виджет проверки паролей
  Widget _buildPasswordValidationText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            _isPasswordValid
                ? "✅ Пароль достаточно длинный"
                : "❌ Минимум 8 символов",
            style: TextStyle(
              color: _isPasswordValid ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
          Text(
            _doPasswordsMatch ? "✅ Пароли совпадают" : "❌ Пароли не совпадают",
            style: TextStyle(
              color: _doPasswordsMatch ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Кнопка регистрации
  Widget _buildRegisterButton() {
    bool isButtonEnabled = _isPasswordValid && _doPasswordsMatch;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isButtonEnabled
                ? const Color(0xFF1DDA63).withOpacity(0.6)
                : Colors.grey.withOpacity(0.4),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(280, 50),
          backgroundColor: isButtonEnabled ? Colors.transparent : Colors.grey,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: isButtonEnabled ? _register : null,
        child: Text(
          "Sign Up",
          style: GoogleFonts.getFont(
            'Inter',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: isButtonEnabled ? 10 : 0,
                color: isButtonEnabled
                    ? const Color(0xFF1DDA63)
                    : Colors.transparent,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Регистрация через Google
  Widget _buildGoogleSignUp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'or sign up with',
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF1DDA63)),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => print("Google Sign Up"),
          child: const CircleAvatar(
            radius: 12,
            backgroundImage: AssetImage("assets/icons/icons8-google.png"),
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
