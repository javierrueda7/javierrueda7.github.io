import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EditLotePage extends StatefulWidget {
  const EditLotePage({super.key});

  @override
  State<EditLotePage> createState() =>  _EditLotePageState();
}

class _EditLotePageState extends State<EditLotePage> {

  
  @override
  void initState() {
    super.initState();
  }

  TextEditingController idController = TextEditingController(text: "");
  TextEditingController loteNameController = TextEditingController(text: "");
  TextEditingController etapaController = TextEditingController(text: "");
  TextEditingController areaController = TextEditingController(text: "");
  TextEditingController priceController = TextEditingController(text: "");
  TextEditingController stateController = TextEditingController(text: "");
  TextEditingController linderosController = TextEditingController(text: "");
  TextEditingController startDateController = TextEditingController(text: "");
  TextEditingController statusController = TextEditingController(text: "");

  late double price;
 
  bool isInitialized = false;


  
  @override
  Widget build(BuildContext context) {   
  Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if(isInitialized==false){      
      idController.text = arguments['loteId'];
      loteNameController.text = arguments['loteName'];
      etapaController.text = arguments['loteEtapa'];
      areaController.text = '${((arguments['loteArea'].toInt()).toString())} m²';
      priceController.text = (currencyCOP((arguments['lotePrice'].toInt()).toString()));
      stateController.text = arguments['loteState'];
      price = stringConverter(priceController.text);
      linderosController.text = arguments['loteLinderos'];
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
        title: Text('Editar ${loteNameController.text}', 
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
                          "Id", Icons.abc_outlined, false, idController, false, 'email', (){}
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),   
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                          "Lote", Icons.gps_fixed_outlined, false, loteNameController, false, 'email', (){}
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                          "Etapa", Icons.map_outlined, false, etapaController, false, 'email', (){}
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                          "Area", Icons.straighten_outlined, false, areaController, false, 'email', (){}
                        ),
                      ),                      
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                          "Precio", Icons.monetization_on_outlined, false, priceController, true, 'number', (String value) {
                            setState(() {
                              price = stringConverter(value);
                              priceController.value = TextEditingValue(
                                text: (currencyCOP((price.toInt()).toString())),
                                selection: TextSelection.collapsed(offset: (currencyCOP((price.toInt()).toString())).length),
                              );
                            });                            
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                          "Estado", Icons.sell_outlined, false, stateController, false, 'email', (){}
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: TextField(
                          controller: linderosController,
                          maxLines: null,
                          obscureText: false,
                          enableSuggestions: true,
                          autocorrect: true,
                          cursorColor: fifthColor,
                          enabled: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: fifthColor.withOpacity(0.9)),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.flag_outlined,
                              color: fifthColor,
                            ),
                            hintText: "Linderos",
                            hintStyle: TextStyle(color: fifthColor.withOpacity(0.9)),
                            filled: true,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            fillColor: primaryColor.withOpacity(0.2),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                  width: 1, style: BorderStyle.solid, color: fifthColor.withOpacity(0.1))),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(width: 2, style: BorderStyle.solid, color: fifthColor)),
                          ),
                          keyboardType: TextInputType.emailAddress,
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
                                if(priceController.text.isEmpty ||
                                  linderosController.text.isEmpty
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
                                  await updateLote(     
                                  idController.text,                                                
                                  stringConverter(priceController.text),
                                  linderosController.text,
                                  );
                                    // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: CustomAlertMessage(
                                        errorTitle: "Genial!", 
                                        errorText: "Datos actualizados de manera satisfactoria.",
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
                              child: const Text("Actualizar"),
                            ),
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

  double stringConverter(String valorAConvertir){
    String valorSinPuntos = valorAConvertir.replaceAll('\$', '').replaceAll('.', '');
    return double.parse(valorSinPuntos);
  }
}