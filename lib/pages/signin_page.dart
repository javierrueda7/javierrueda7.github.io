import 'package:albaterrapp/pages/init_page.dart';
import 'package:albaterrapp/pages/reset_password_page.dart';
import 'package:albaterrapp/pages/signup_page.dart';
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
  final TextEditingController _passwordTextcontroller = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.1, 20, 0
                ),
                child: Column(
                  children: <Widget>[
                    logoWidget("assets/images/logo.png"),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingresa tu correo electronico", Icons.person_outline, false, _emailTextController, true, 'email', (){}
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingresa tu contraseña", Icons.lock_outline, true, _passwordTextcontroller, true, 'password', (){}
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    Container(
                      constraints: const BoxConstraints(maxWidth: 800), 
                      child: forgetPassword(context)
                    ),

                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: firebaseButton(context, "INICIAR SESIÓN", (){
                        FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailTextController.text , password: _passwordTextcontroller.text).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: CustomAlertMessage(
                                errorTitle: "Genial!", 
                                errorText: "Iniciaste sesión de manera satisfactoria",
                                stateColor: Color.fromRGBO(52, 194, 64, 1),
                              ), 
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          ); 
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const InitPage()));
                        }).onError((error, stackTrace) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: CustomAlertMessage(
                                errorTitle: "Oops!", 
                                errorText: "Tus datos no coinciden con nuestra información, verificalos o crea una cuenta",
                                stateColor: Color.fromRGBO(214, 66, 66, 1),
                              ), 
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          );
                        });
                      }),
                    ),
                    /*Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: signUpOption()
                    ),*/
                    const SizedBox(
                      height: 20,
                    ),
                    beAGuest(),
                  ],
                ),
              ),
            ), 
          ),
        ),
      ),             
    );
  }

  Row signUpOption(){
    return Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("¿Aún no tienes una cuenta?", style: TextStyle(color: fifthColor.withOpacity(0.4))),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
          },
          child: Text( 
            " Registrate aquí",
            style: TextStyle(color: fifthColor.withOpacity(0.8), fontWeight: FontWeight.bold),
          ),
        ),
      ]
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
          style: TextStyle(color: fifthColor.withOpacity(0.8), fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        onPressed: (){
          Navigator.push(
            context, MaterialPageRoute(
              builder: (context) => const ResetPasswordPage()
            ),
          );
        },
      ),
    );
  }

  Row beAGuest(){
    return Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [       
        GestureDetector(
          onTap: () {
            FirebaseAuth.instance.signInAnonymously().then((value) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const InitPage()));
            }).onError((error, stackTrace) {
                
              });
            },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            color: fourthColor.withOpacity(0.5),
            height: 50,
            width: 300,
            child: Center(
              child: Text( 
                "CONTINUAR SIN INICIAR SESIÓN",
                style: TextStyle(color: primaryColor, fontSize: 14,fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ]
    );
  }
}

