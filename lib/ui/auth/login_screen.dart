import 'package:dolby/services/auth_service.dart';
import 'package:dolby/ui/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool obscurePassword = true; // Флаг для скрытия пароля

  void showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isError ? Colors.white : Colors.black),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void signInMethod() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showSnackbar("Введите email и пароль!", isError: true);
      return;
    }

    String? result = await _authService.login(email, password);
    if (result == "Вход выполнен успешно!") {
      showSnackbar("Успешный вход!");
      // Здесь можно добавить переход на главный экран
    } else {
      showSnackbar(result ?? "Ошибка входа", isError: true);
    }
  }

  void forgetPassword() {
    showSnackbar("Функция восстановления пароля пока не реализована!",
        isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.12,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/icon8-png/icons8-dolby-digital-144.png',
                            width: MediaQuery.of(context).size.width *
                                0.4, // Адаптивный размер
                          ),
                          Positioned(
                            bottom: MediaQuery.of(context).size.height *
                                0.001, // Сделать адаптивным
                            child: Text(
                              "Dolby",
                              style: GoogleFonts.getFont(
                                "Inria Sans",
                                fontSize: MediaQuery.of(context).size.width *
                                    0.07, // Адаптивный размер
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        controller: emailController,
                        cursorWidth: 1,
                        cursorColor: const Color(0xFF30d35c),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color(0xFF1A1A1A),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Color(0xFF1A1A1A),
                                width: 1,
                              ), // Default border color
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                  color: Color(0xFF30d35c),
                                  width: 1), // Border when focused
                            ),
                            hintText: "Email",
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(64, 245, 245, 245))),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: TextField(
                        controller: passwordController,
                        obscureText: obscurePassword, // Используем флаг
                        cursorWidth: 1,
                        cursorColor: const Color(0xFF30d35c),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFF1A1A1A),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: Color(0xFF1A1A1A),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                                color: Color(0xFF30d35c), width: 1),
                          ),
                          hintText: "Password",
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(64, 245, 245, 245),
                          ),
                          suffixIcon: IconButton(
                            iconSize: 20,
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: !obscurePassword
                                  ? Color(0xFF30d35c)
                                  : Colors.white24, // Цвет иконки
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword; // Меняем состояние
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 50,
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  widthFactor: 100,
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(
                          Colors.transparent), // No press effect
                      splashFactory:
                          NoSplash.splashFactory, // Removes splash effect
                    ),
                    onPressed: forgetPassword,
                    child: Text(
                      "Forget password?",
                      style: GoogleFonts.getFont(
                        "Inter",
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(
                            124, 158, 158, 158), // Neon color
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(30), // Matches button shape
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1DDA63)
                                .withOpacity(0.6), // Neon glow color
                            blurRadius: 0, // Adjust glow intensity
                            spreadRadius: 0, // Increases glow size
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1DDA63), // Neon green
                            Color(0x001DDA63), // Transparent neon green
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(280, 50),
                          backgroundColor: Colors
                              .transparent, // Transparent to show gradient
                          shadowColor: Colors
                              .transparent, // Remove default button shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: signInMethod,
                        child: Text(
                          "Sign In",
                          style: GoogleFonts.getFont(
                            'Inter',
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                blurRadius: 10, // Glow effect
                                color: Color(0xFF1DDA63),
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'or sign up with',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF1DDA63)),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            print(321);
                          },
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundImage:
                                AssetImage("assets/icons/icons8-google.png"),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.12),
              // Bottom navigation text
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.zero, // Remove padding for inline look
                        minimumSize: Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Sign up",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1DDA63), // Neon green
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
