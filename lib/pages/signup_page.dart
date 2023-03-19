import 'package:albaterrapp/pages/init_page.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _usernameTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        title: Text(
          "CREAR USUARIO", 
          style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),
        )
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,            
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 244, 246, 252),
                  Color.fromARGB(255, 222, 224, 227),
                  Color.fromARGB(255, 222, 224, 227)
                ],
                begin: Alignment.topCenter, end: Alignment.bottomCenter
              )
            ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingrese su nombre de usuario", Icons.person_outline, false, _usernameTextController, true, 'email', (){}
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),                
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingrese su nombre completo", Icons.person_outline, false, _nameTextController, true, 'email', (){}
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),                
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingrese su correo electrónico", Icons.mail_outline, false, _emailTextController, true, 'email', (){}
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),                
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingrese su contraseña", Icons.lock_outline, true, _passwordTextController, true, 'password', (){}
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: firebaseButton(context, "CREAR CUENTA", (){
                        FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _emailTextController.text, password: _passwordTextController.text).then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: CustomAlertMessage(
                                    errorTitle: "Genial!", 
                                    errorText: "Tu cuenta ha sido creada satisfactoriamente",
                                    stateColor: Color.fromRGBO(52, 194, 64, 1),
                                  ), 
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              );
                            
                            Navigator.push(context, 
                              MaterialPageRoute(builder: ((context) => const InitPage()))
                            ); 
                          }).onError((error, stackTrace) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: CustomAlertMessage(
                                    errorTitle: "Oops!", 
                                    errorText: "Parece que ya existe una cuenta con los datos que ingresaste",
                                    stateColor: Color.fromRGBO(214, 66, 66, 1),
                                  ), 
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              );
                            }
                        );            
                      }),
                    )  
                  ]
                ),
              ),
            ),
          ),
        ),
      )
    );
  }
}