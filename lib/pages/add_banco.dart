import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AddBancoPage extends StatefulWidget {
  const AddBancoPage({super.key});

  @override
  State<AddBancoPage> createState() => _AddBancoPageState();
}

class _AddBancoPageState extends State<AddBancoPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bancoController = TextEditingController();
  final TextEditingController nroCuentaController = TextEditingController();
  final TextEditingController tipoCuentaController = TextEditingController();
  final TextEditingController nitController = TextEditingController();
  final TextEditingController nameRepController = TextEditingController();

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        title: Center(
          child: Text(
            "Agregar cuenta bancaria", 
            style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Apodo de la cuenta", Icons.abc_outlined, false, nameController, true, 'email', (){}
                      ),
                    ),                    
                    const SizedBox(
                      height: 20,
                    ),                     
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Banco", Icons.account_balance_outlined, false, bancoController, true, 'name', (){}
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),                    
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Tipo de cuenta", Icons.account_balance_wallet_outlined, false, tipoCuentaController, true, 'email', (){}
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Número de cuenta", Icons.numbers_outlined, false, nroCuentaController, true, 'number', (){}
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Propietario de la cuenta", Icons.person_outline, false, nameRepController, true, 'email', (){}
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),  
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "NIT o Documento de identidad", Icons.badge_outlined, false, nitController, true, 'email', (){}
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
                          if(nameController.text.isEmpty ||
                            bancoController.text.isEmpty ||
                            nitController.text.isEmpty ||
                            tipoCuentaController.text.isEmpty ||
                            nroCuentaController.text.isEmpty ||
                            nameRepController.text.isEmpty
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
                            await addBanco(
                            nameController.text,
                            bancoController.text,                              
                            nroCuentaController.text,
                            tipoCuentaController.text,                            
                            nitController.text,
                            nameRepController.text,                              
                            );
                              // ignore: use_build_context_synchronously
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
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
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
}