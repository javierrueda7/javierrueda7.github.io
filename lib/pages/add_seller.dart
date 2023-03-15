import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddSellerPage extends StatefulWidget {
  const AddSellerPage({super.key});

  @override
  State<AddSellerPage> createState() => _AddSellerPageState();
}

class _AddSellerPageState extends State<AddSellerPage> {
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _lastnameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _phoneTextController = TextEditingController();
  final TextEditingController _addressTextController = TextEditingController();
  final TextEditingController _idTextController = TextEditingController();
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
  late int userCounter;
  
  

  @override
  Widget build(BuildContext context) {
    collectionReference.get().then((QuerySnapshot usersSnapshot) {
      userCounter = usersSnapshot.size;
    });
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
                        "Ingrese su nombre", Icons.person_outline, false, _nameTextController, true
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),   
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingrese su apellido", Icons.person_outline, false, _lastnameTextController, true
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),                  
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingrese su número de teléfono", Icons.person_outline, false, _phoneTextController, true
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingrese su correo electrónico", Icons.person_outline, false, _emailTextController, true
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ), 
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingrese su dirección", Icons.mail_outline, false, _addressTextController, true
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),                
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ingrese su cédula", Icons.lock_outline, false, _idTextController, true
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ElevatedButton(
                        style: ButtonStyle(fixedSize: MaterialStateProperty.all(const Size(250, 50))),
                        onPressed: () async {    
                          if(_nameTextController.text.isEmpty ||
                            _lastnameTextController.text.isEmpty ||
                            _addressTextController.text.isEmpty ||
                            _phoneTextController.text.isEmpty ||
                            _emailTextController.text.isEmpty ||
                            _idTextController.text.isEmpty
                            ){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: CustomAlertMessage(
                                  errorTitle: "Oops!", 
                                  errorText: "Verifique que todos los campos se hayan llenado correctamente.",
                                  stateColor: dangerColor,
                                ), 
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                              ),
                            );
                          } else {
                            await addUsers(
                              idGenerator(userCounter),
                              _nameTextController.text,
                              _lastnameTextController.text,
                              _emailTextController.text,
                              _phoneTextController.text,                            
                              _addressTextController.text,
                              _idTextController.text
                              ).then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: CustomAlertMessage(
                                      errorTitle: "Genial!", 
                                      errorText: "Datos almacenados de manera satisfactoria.",
                                      stateColor: successColor,
                                    ), 
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                  ),
                                );                        
                                Navigator.pop(context);
                            });
                          }
                        },
                        child: const Text("Guardar"),
                      ),
                    ),  
                  ]
                ),
              ),
            ),
          ),
        ),
      )
    );
  }

  String idGenerator(int userCount){
    userCount++;
    String idGenerated = userCount.toString().padLeft(3, '0');
    return idGenerated;
  }
}