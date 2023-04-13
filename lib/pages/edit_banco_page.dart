import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EditBancoPage extends StatefulWidget {
  const EditBancoPage({super.key});

  @override
  State<EditBancoPage> createState() =>  _EditBancoPageState();
}

class _EditBancoPageState extends State<EditBancoPage> {

  
  @override
  void initState() {
    super.initState();
  }

  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController bancoController = TextEditingController(text: "");
  TextEditingController nroCuentaController = TextEditingController(text: "");
  TextEditingController nitController = TextEditingController(text: "");
  TextEditingController nameRepController = TextEditingController(text: "");
  String selectedTipoCuenta = '';
  String bid = '';
  List<String> tipoCuentaList = ['Corriente', 'Ahorros'];
  bool isInitialized = false;


  
  @override
  Widget build(BuildContext context) {   
  Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if(isInitialized==false){      
      nameController.text = arguments['bid'];
      bancoController.text = arguments['banco'];
      nroCuentaController.text = arguments['nroCuenta'];
      nitController.text = arguments['nit'];
      nameRepController.text = arguments['nameRep'];      
      selectedTipoCuenta = arguments['tipoCuenta'];
    } else {
      isInitialized = true;
    }
    
    isInitialized = true;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Editar cuenta bancaria', 
          style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),),
      ),
      body: 
        Center(          
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                          "Apodo de la cuenta", Icons.abc_outlined, false, nameController, true, 'name', (){}
                        ),
                      ), 
                      const SizedBox(
                        height: 20,
                      ),                         
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                          "Banco", Icons.person_outline, false, bancoController, true, 'name', (){}
                        ),
                      ),
                      const SizedBox(
                      height: 20,
                    ),                    
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: easyDropdown(tipoCuentaList, selectedTipoCuenta, (tempTipoCuenta){setState(() {
                        selectedTipoCuenta = tempTipoCuenta!;
                      });}),
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
                        "Propietario de la cuenta", Icons.person_outline, false, nameRepController, true, 'name', (){}
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
                            selectedTipoCuenta.isEmpty ||
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
                            selectedTipoCuenta,                            
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
                              setState(() {});               
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                          }                          
                        },
                        child: const Text("Guardar"),
                      ),
                    ), 
                      const SizedBox(
                        height: 30,
                      ), 
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }
}