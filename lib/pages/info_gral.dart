import 'package:albaterrapp/pages/info_banco.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:flutter/material.dart';

class InfoGeneral extends StatefulWidget {
  const InfoGeneral({super.key});

  @override
  State<InfoGeneral> createState() => _InfoGeneralState();
}

class _InfoGeneralState extends State<InfoGeneral> {

  @override
  void initState() {    
    super.initState();
    initInfo();
  }

  Future<void> initInfo() async {    
    infoInvertaga = await getInversionista('invertaga');
    infoVision = await getInversionista('vision');

    nameIController.text = infoInvertaga['name'];
    nitIController.text = infoInvertaga['nit'];
    emailIController.text = infoInvertaga['email'];
    nameRepIController.text = infoInvertaga['nameRep'];
    idRepIController.text = infoInvertaga['idRep'];
    lugarIdRepIController.text = infoInvertaga['idLugar'];

    nameVController.text = infoVision['name'];
    nitVController.text = infoVision['nit'];
    emailVController.text = infoVision['email'];
    nameRepVController.text = infoVision['nameRep'];
    idRepVController.text = infoVision['idRep'];
    lugarIdRepVController.text = infoVision['idLugar'];
  }

  Map<String, dynamic> infoInvertaga = {};
  Map<String, dynamic> infoVision = {};  

  TextEditingController nameIController = TextEditingController(text: "");
  TextEditingController nitIController = TextEditingController(text: "");
  TextEditingController emailIController = TextEditingController(text: "");
  TextEditingController nameRepIController = TextEditingController(text: "");
  TextEditingController idRepIController = TextEditingController(text: "");
  TextEditingController lugarIdRepIController = TextEditingController(text: "");

  TextEditingController nameVController = TextEditingController(text: "");
  TextEditingController nitVController = TextEditingController(text: "");
  TextEditingController emailVController = TextEditingController(text: "");
  TextEditingController nameRepVController = TextEditingController(text: "");
  TextEditingController idRepVController = TextEditingController(text: "");
  TextEditingController lugarIdRepVController = TextEditingController(text: "");

  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {

    if(!isInitialized) {
      initInfo();
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
        title: Text('Información general', 
          style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[            
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoBancos()));                  
                },
                child: const Icon(
                  Icons.account_balance_outlined
                ),
              )
          ),
        ],
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                      child: Center(child: Text('PROMOTORES DEL PROYECTO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,))),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget(
                            "NOMBRE", Icons.abc_outlined, false, nameIController, true, 'name', (){}
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget(
                            "NIT", Icons.business_outlined, false, nitIController, true, 'email', (){}
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget(
                            "CORREO ELECTRÓNICO", Icons.email_outlined, false, emailIController, true, 'email', (){}
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget(
                            "NOMBRE DEL REPRESENTANTE", Icons.person_outline, false, nameRepIController, true, 'name', (){}
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 10,
                              child: textFieldWidget(
                                "CÉDULA DEL REPRESENTANTE", Icons.badge_outlined, false, idRepIController, true, 'email', (){}
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container()
                            ),
                            Expanded(
                              flex: 10,
                              child: textFieldWidget(
                                "LUGAR DE EXPEDICIÓN", Icons.gps_fixed_outlined, false, lugarIdRepIController, true, 'email', (){}
                              ),
                            ),
                          ],
                        ),                    
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget(
                            "NOMBRE", Icons.abc_outlined, false, nameVController, true, 'name', (){}
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget(
                            "NIT", Icons.business_outlined, false, nitVController, true, 'email', (){}
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget(
                            "CORREO ELECTRÓNICO", Icons.email_outlined, false, emailVController, true, 'email', (){}
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget(
                            "NOMBRE DEL REPRESENTANTE", Icons.person_outline, false, nameRepVController, true, 'name', (){}
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 10,
                              child: textFieldWidget(
                                "CÉDULA DEL REPRESENTANTE", Icons.badge_outlined, false, idRepVController, true, 'email', (){}
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container()
                            ),
                            Expanded(
                              flex: 10,
                              child: textFieldWidget(
                                "LUGAR DE EXPEDICIÓN", Icons.gps_fixed_outlined, false, lugarIdRepVController, true, 'email', (){}
                              ),
                            ),
                          ],
                        ),                    
                        const SizedBox(
                          height: 25,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ButtonStyle(fixedSize: MaterialStateProperty.all(const Size(250, 50))),
                      onPressed: () async {
                        if(nameIController.text.isEmpty ||
                          nitIController.text.isEmpty ||
                          emailIController.text.isEmpty || 
                          nameRepIController.text.isEmpty ||
                          idRepIController.text.isEmpty ||
                          lugarIdRepIController.text.isEmpty ||
                          nameRepVController.text.isEmpty ||
                          nitVController.text.isEmpty ||
                          emailVController.text.isEmpty ||
                          nameRepVController.text.isEmpty ||
                          idRepVController.text.isEmpty ||
                          lugarIdRepVController.text.isEmpty
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
                          await updateInv(
                            'invertaga',
                            nameIController.text,
                            nitIController.text, 
                            emailIController.text,
                            nameRepIController.text,
                            idRepIController.text,
                            lugarIdRepIController.text,
                            );
                          await updateInv(
                            'vision',
                            nameVController.text,
                            nitVController.text, 
                            emailVController.text,
                            nameRepVController.text,
                            idRepVController.text,
                            lugarIdRepVController.text,
                            ).then((_) {
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
                              Navigator.pop(context);
                          });
                        }
                      },
                      child: const Text('GUARDAR INFORMACIÓN'),
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
      ),
    );  
  }
}