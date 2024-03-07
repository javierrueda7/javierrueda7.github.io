import 'package:albaterrapp/pages/init_page.dart';
import 'package:albaterrapp/pages/reset_password_page.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  List sellers = [];

  void obtainSellerList() async {
    sellers = await getSellers();
  }

  @override
  void initState() {
    super.initState();
    obtainSellerList();
  }

  final TextEditingController _passwordTextcontroller = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    obtainSellerList();
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromARGB(255, 244, 246, 252),
            Color.fromARGB(255, 222, 224, 227),
            Color.fromARGB(255, 222, 224, 227)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0.1, 20, 0),
                child: Column(
                  children: <Widget>[
                    logoWidget("assets/images/logo.png"),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                          "Ingresa tu correo electronico",
                          Icons.person_outline,
                          false,
                          _emailTextController,
                          true,
                          'email',
                          (value) {}),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                          "Ingresa tu contraseña",
                          Icons.lock_outline,
                          true,
                          _passwordTextcontroller,
                          true,
                          'password',
                          (value) {}),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: forgetPassword(context)),
                    Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: firebaseButton(context, "INICIAR SESIÓN", () {
                          final email = _emailTextController.text;
                          final password = _passwordTextcontroller.text;
                          const allowedEmail = 'javieruedase@gmail.com';
                          final sellerWithEmail = sellers.firstWhere(
                            (seller) => seller['emailSeller'] == email,
                            orElse: () => null,
                          );
                          if (sellerWithEmail != null &&
                                  sellerWithEmail['statusSeller'] == 'Activo' ||
                              email == allowedEmail) {
                            // Allow login
                            FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: email, password: password)
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: CustomAlertMessage(
                                    errorTitle: "Genial!",
                                    errorText: "Inicio de sesión satisfactorio",
                                    stateColor: Color.fromRGBO(52, 194, 64, 1),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              );
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const InitPage()));
                            // ignore: sdk_version_since
                            }).onError((error, stackTrace) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: CustomAlertMessage(
                                    errorTitle: "Oops!",
                                    errorText:
                                        "Sus datos no coinciden con nuestra información, verifíquelos o cree una cuenta",
                                    stateColor: Color.fromRGBO(214, 66, 66, 1),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              );
                            });
                          } else {
                            // Deny login
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: CustomAlertMessage(
                                  errorTitle: "Oops!",
                                  errorText:
                                      "Sus datos no coinciden con nuestra información, verifíquelos o cree una cuenta",
                                  stateColor: Color.fromRGBO(214, 66, 66, 1),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                            );
                          }
                        })),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: Text(
          "¿Olvidaste tu contraseña?",
          style: TextStyle(
              color: fifthColor.withOpacity(0.8), fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
          );
        },
      ),
    );
  }

  Row beAGuest() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
        onTap: () {
          FirebaseAuth.instance.signInAnonymously().then((value) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const InitPage()));
          // ignore: sdk_version_since
          }).onError((error, stackTrace) {});
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          color: fourthColor.withOpacity(0.5),
          height: 50,
          width: 300,
          child: Center(
            child: Text(
              "CONTINUAR SIN INICIAR SESIÓN",
              style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    ]);
  }
}
