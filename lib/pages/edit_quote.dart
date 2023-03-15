import 'package:albaterrapp/pages/pdf_generator.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

FirebaseFirestore db = FirebaseFirestore.instance;

class EditQuotePage extends StatefulWidget {
  final List<dynamic> loteInfo;
  const EditQuotePage({Key? key, required this.loteInfo}) : super(key: key);

  @override
  State<EditQuotePage> createState() => _EditQuotePageState();
}

class _EditQuotePageState extends State<EditQuotePage> {
  // ignore: prefer_typing_uninitialized_variables
  var timer;

  @override
  void initState() {
    super.initState();    
    loteInfo = widget.loteInfo;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        realtimeDateTime = dateOnly(true, 0, DateTime.now());
      });
    });
  }
  
  @override
  void dispose() {
    timer.cancel(); //cancel the periodic task
    timer; //clear the timer variable
    super.dispose();
}
  List sellers = [];
  late int quoteCounter;
  late String qid;
  DateTime quotePickedDate = DateTime.now();
  List<dynamic> loteInfo = [];
  List sellerList = [];

  String realtimeDateTime = '';
  double porcCuotaInicial = 30;
  double vlrSeparacion = 10000000;
  double plazoCI = 4;
  double vlrTEM = 0.0;
  late double cuotaInicial;
  late double saldoCI;
  late double valorAPagar;
  late double valorCuota;
  List<String> nroCuotasList = ['12', '24', '36'];
  String selectedNroCuotas = '12';
  List<String> idtypeList = ['CC', 'CE', 'Pasaporte', 'NIT'];
  String selectedItemIdtype = 'CC';
  List<String> genderList = ['Masculino', 'Femenino', 'Otro'];
  bool countryBool = true;
  List countries = [];
  List<String> paymentMethodList= ['Pago de contado', 'Financiación directa'];
  String paymentMethodSelectedItem = 'Pago de contado';
  Stream<QuerySnapshot>? citiesStream;
  Stream<QuerySnapshot>? sellerStream;
  final CollectionReference collectionReference = FirebaseFirestore.instance.collection('quotes');

  String selectedSeller = '';
  String sellerName = '';
  String sellerEmail = '';
  String sellerPhone = '';
  TextEditingController quoteDateController = TextEditingController(text: DateFormat('MM-dd-yyyy').format(DateTime.now()));
  TextEditingController quoteDeadlineController = TextEditingController(text: dateOnly(false, 0.5, DateTime.now()));
  TextEditingController loteController = TextEditingController(text: "");
  TextEditingController etapaloteController = TextEditingController(text: "");
  TextEditingController arealoteController = TextEditingController(text: "");
  TextEditingController priceloteController = TextEditingController(text: "");
  TextEditingController porcCuotaInicialController = TextEditingController(text: "");
  TextEditingController vlrCuotaIniController = TextEditingController(text: "");
  TextEditingController vlrSeparacionController = TextEditingController(text: "\$10.000.000");
  TextEditingController separacionDeadlineController = TextEditingController(text: dateOnly(false, 0, DateTime.now()));
  TextEditingController saldoCuotaIniController = TextEditingController(text: "");
  TextEditingController saldoCuotaIniDeadlineController = TextEditingController(text: dateOnly(false, 4, DateTime.now()));

  TextEditingController vlrPorPagarController = TextEditingController(text: "");
  TextEditingController pagoContadoDeadlineController = TextEditingController(text: dateOnly(false, 5, DateTime.now()));
  TextEditingController statementsStartDateController = TextEditingController(text: dateOnly(false, 5, DateTime.now()));
  TextEditingController vlrCuotaController = TextEditingController(text: "");
  TextEditingController temController = TextEditingController(text: "");
  TextEditingController observacionesController = TextEditingController(text: "");


  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController lastnameController = TextEditingController(text: "");
  String selectedGender = 'Masculino';
  TextEditingController birthdayController = TextEditingController(text: "");
  TextEditingController ocupacionController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController idtypeController = TextEditingController(text: "");
  TextEditingController idController = TextEditingController(text: "");
  String selectedIssuedCountry = 'País';
  String selectedIssuedState = 'Estado';
  String selectedIssuedCity = 'Ciudad';
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  String selectedCountry = 'País';
  String selectedState = 'Estado';
  String selectedCity = 'Ciudad';

  @override
  Widget build(BuildContext context) {
    collectionReference.get().then((QuerySnapshot quotesSnapshot) {
      quoteCounter = quotesSnapshot.size;
    });
    int intLotePrice = loteInfo[9].toInt();
    cuotaInicial = intLotePrice * (porcCuotaInicial/100);
    saldoCI = cuotaInicial - vlrSeparacion;
    valorAPagar = intLotePrice - cuotaInicial;
    valorCuota = valorAPagar/(double.parse(selectedNroCuotas));

    priceloteController.text = (currencyCOP((intLotePrice.toInt()).toString()));
    vlrCuotaIniController.text = (currencyCOP((cuotaInicial.toInt()).toString()));
    saldoCuotaIniController.text = (currencyCOP((saldoCI.toInt()).toString()));
    vlrCuotaController.text = (currencyCOP((valorCuota.toInt()).toString()));
    vlrPorPagarController.text = (currencyCOP((valorAPagar.toInt()).toString()));

    return Scaffold(      
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Nueva cotización ${loteInfo[1]}', 
          style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),),
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
                    
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), border: Border.all(color: fifthColor.withOpacity(0.1))),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').snapshots(),
                          builder: (context, usersSnapshot) {
                            List<DropdownMenuItem> userItems = [];
                            if (!usersSnapshot.hasData) {
                              const CircularProgressIndicator();
                            } else {
                              final usersList = usersSnapshot.data?.docs;
                              for (var users in usersList!) {
                                userItems.add(
                                  DropdownMenuItem(
                                    value: users.id,
                                    child: Center(child: Text(users['nameUser'])),
                                  ),
                                );
                              }
                            }
                            return DropdownButton(
                              items: userItems,
                              hint: Center(child: Text(selectedSeller)),
                              underline: Container(),
                              style: TextStyle(color: fifthColor.withOpacity(0.9),),
                              onChanged: (userValue) {
                                setState(() {
                                  selectedSeller = userValue!;
                                });
                              },
                              isExpanded: true,
                            );
                          },
                        ),
                      ),
                    ),               
                    
                    
                    
                    
                    
                    
                    
                    const SizedBox(
                      height: 15,
                      child: Center(child: Text('Vigencia cotización', style: TextStyle(fontSize: 12),)),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                  child: Text('Desde', style: TextStyle(fontSize: 10),),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(width: 1, style: BorderStyle.solid, color: fifthColor.withOpacity(0.1)),                                
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: TextField(
                                      cursorColor: fifthColor,                              
                                      style: TextStyle(color: fifthColor.withOpacity(0.9)),
                                      controller: quoteDateController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(Icons.date_range_outlined, color: fifthColor,),
                                        hintText: DateFormat('MM-dd-yyyy').format(quotePickedDate),                                    
                                      ),
                                      readOnly: true,
                                      onTap: () async{
                                        DateTime? quotePickedDate = await showDatePicker(
                                          context: context, 
                                          initialDate: DateTime.now(), 
                                          firstDate: DateTime(1900), 
                                          lastDate: DateTime.now(),
                                        );
                                        if(quotePickedDate != null) {
                                          setState(() {
                                            quoteDateController.text = DateFormat('MM-dd-yyyy').format(quotePickedDate);
                                            quoteDeadlineController.text = dateOnly(false, 0.5, quotePickedDate);
                                            separacionDeadlineController.text = dateOnly(false, 0, quotePickedDate);
                                            saldoCuotaIniDeadlineController.text = dateOnly(false, plazoCI, quotePickedDate);
                                            pagoContadoDeadlineController.text = dateOnly(false, plazoCI+1, quotePickedDate);
                                            statementsStartDateController.text = dateOnly(false, plazoCI+1, quotePickedDate);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),   
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                  child: Text('Hasta', style: TextStyle(fontSize: 10),),
                                ),
                                textFieldWidget(
                                  dateOnly(false, 0.5, quotePickedDate), Icons.date_range_outlined, false, quoteDeadlineController, false
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ), 
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                  child: Text('Inmueble Nº', style: TextStyle(fontSize: 10),),
                                ),
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 800),
                                  child: textFieldWidget(
                                    loteInfo[1], Icons.house_outlined, false, loteController, false)
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                  child: Text('Etapa', style: TextStyle(fontSize: 10),),
                                ),
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 800),
                                  child: textFieldWidget(
                                    loteInfo[7].toString(), Icons.map_outlined, false, etapaloteController, false)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        children: [                          
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                  child: Text('Área', style: TextStyle(fontSize: 10),),
                                ),
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 800),
                                  child: textFieldWidget(
                                    '${((loteInfo[8].toInt()).toString())} m²', Icons.terrain_outlined, false, arealoteController, false)
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                  child: Text('Precio', style: TextStyle(fontSize: 10),),
                                ),
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 800),
                                  child: textFieldWidget(
                                    (currencyCOP((intLotePrice).toString())), Icons.monetization_on_outlined, false, priceloteController, false)
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      color: fifthColor.withOpacity(0.1),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),                          
                          IconButton(onPressed: (){
                              setState(() {      
                                vlrSeparacion =  stringConverter(vlrSeparacionController.text);
                                vlrSeparacionController.text = (currencyCOP((vlrSeparacion.toInt()).toString()));
                                saldoCuotaIniController.text = (currencyCOP((saldoCI.toInt()).toString()));                             
                              });
                            }, 
                            icon: Icon(Icons.refresh_outlined, color: fifthColor,),
                            alignment: Alignment.centerLeft
                          ),
                          SizedBox(
                            height: 20,
                            child: Text('Cuota inicial: ${((porcCuotaInicial).toInt()).toString()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)
                          ),
                          const SizedBox(
                            height: 15,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text('Cuota inicial = Separación + Saldo de la cuota inicial', style: TextStyle(fontSize: 10,),),
                            )
                          ),
                          SizedBox(
                            height: 15,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text("Plazo: ${((plazoCI*30).toInt()).toString()} días", style: const TextStyle(fontSize: 10,),),
                            )
                          ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: textFieldWidget(
                              (currencyCOP(cuotaInicial.toInt().toString())), Icons.monetization_on_outlined, false, vlrCuotaIniController, false
                            ),
                          ),                          
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: const Text('Separación', style: TextStyle(fontSize: 12),)
                          ),                          
                          Container(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Row(
                              children: [                          
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                      height: 15,
                                      child: Text('Valor', style: TextStyle(fontSize: 10),)),
                                      textFieldWidget(
                                        (currencyCOP((vlrSeparacion.toInt()).toString())), Icons.monetization_on_outlined, false, vlrSeparacionController, true),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                      height: 15,
                                      child: Text('Fecha límite', style: TextStyle(fontSize: 10),)),
                                      textFieldWidget(
                                        dateOnly(false, 0, quotePickedDate), Icons.date_range_outlined, false, separacionDeadlineController, false),
                                    ],
                                  ),
                                ),
                              ]
                            )
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 20,
                            child: Text('Saldo de la cuota inicial', style: TextStyle(fontSize: 12),)
                          ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Row(
                              children: [                          
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                      height: 15,
                                      child: Text('Valor', style: TextStyle(fontSize: 10),)),
                                      textFieldWidget(
                                        (currencyCOP((saldoCI.toInt()).toString())), Icons.monetization_on_outlined, false, saldoCuotaIniController, false),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                      height: 15,
                                      child: Text('Fecha límite', style: TextStyle(fontSize: 10),)),
                                      textFieldWidget(
                                        dateOnly(false, plazoCI, quotePickedDate), Icons.date_range_outlined, false, saldoCuotaIniDeadlineController, false),
                                    ],
                                  ),
                                ),
                    
                              ]
                            )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      color: fourthColor.withOpacity(0.5),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 20,
                            child: Text('Valor por pagar (${((100-porcCuotaInicial).toInt()).toString()}%)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)
                          ),                          
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: textFieldWidget(
                                  (currencyCOP(valorAPagar.toInt().toString())), Icons.monetization_on_outlined, false, vlrPorPagarController, false
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: easyDropdown(paymentMethodList, paymentMethodSelectedItem, (tempPaymentMethod){setState(() {
                                  paymentMethodSelectedItem = tempPaymentMethod!;
                                });}),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 20,
                                child: Text(paymentMethodSelectedItem, style: const TextStyle(fontSize: 12),)
                              ),
                              paymentMethod(paymentMethodSelectedItem),                              
                              const SizedBox(
                                    height: 10,
                              ),
                            ],
                          )
                        ]
                      )
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Nombres", Icons.person_outline, false, nameController, true
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Apellidos", Icons.person_outline, false, lastnameController, true
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        children: [                                          
                          Expanded( 
                            flex: 2,                           
                            child: easyDropdown(genderList, selectedGender, (tempGender){setState(() {
                              selectedGender = tempGender!;
                            });})
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30.0),
                                border: Border.all(width: 1, style: BorderStyle.solid, color: fifthColor.withOpacity(0.1)),                                
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextField(
                                  cursorColor: fifthColor,                              
                                  style: TextStyle(color: fifthColor.withOpacity(0.9)),
                                  controller: birthdayController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    icon: Icon(Icons.cake_outlined, color: fifthColor,),
                                    hintText: "Fecha de nacimiento",                                    
                                  ),
                                  readOnly: true,
                                  onTap: () async{
                                    DateTime? pickeddate = await showDatePicker(
                                      context: context, 
                                      initialDate: DateTime.now().subtract(const Duration(days: 6574)), 
                                      firstDate: DateTime(1900), 
                                      lastDate: DateTime.now().subtract(const Duration(days: 6574)),
                                    );
                                    if(pickeddate != null) {
                                      setState(() {
                                        birthdayController.text = DateFormat('yyyy-MM-dd').format(pickeddate);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),                            
                          ),    
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Ocupación o actividad económica", Icons.work_outline, false, ocupacionController, true
                      ),
                    ),       
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Número telefónico", Icons.phone_android, false, phoneController, true
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: easyDropdown(idtypeList, selectedItemIdtype, (tempType){setState(() {
                                selectedItemIdtype = tempType!;
                              });})
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: textFieldWidget(
                              "Nro documento", Icons.person_pin_outlined, false, idController, true
                            ),
                          ),                          
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                      child: Center(child: Text('Lugar de expedición', style: TextStyle(fontSize: 10),)),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 50,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), border: Border.all(color: fifthColor.withOpacity(0.1))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0, right: 10),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('countries').orderBy('countryName').snapshots(),
                                builder: (context, snapshot) {
                                  List<DropdownMenuItem> countryItems = [];
                                  if (!snapshot.hasData) {
                                    const CircularProgressIndicator();
                                  } else {
                                    final countriesList = snapshot.data?.docs;
                                    for (var countries in countriesList!) {
                                      countryItems.add(
                                        DropdownMenuItem(
                                          value: countries['countryName'],
                                          child: Center(child: Text(countries['countryName'])),
                                        ),
                                      );
                                    }
                                  }
                                  return DropdownButton(
                                    items: countryItems,
                                    hint: Center(child: Text(selectedIssuedCountry)),
                                    underline: Container(),
                                    style: TextStyle(color: fifthColor.withOpacity(0.9),),
                                    onChanged: (countryValue) {
                                      setState(() {
                                        selectedIssuedCountry = countryValue!;
                                        if(selectedIssuedCountry ==  'Colombia'){
                                          countryBool = true;
                                        } else {
                                          countryBool = false;
                                        }
                                      });
                                    },
                                    isExpanded: true,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), border: Border.all(color: fifthColor.withOpacity(0.1))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('cities').orderBy('stateName', descending: true).snapshots(),
                                      builder: (context, snapshot) {
                                        Set<String> stateNames = {};
                                        List<DropdownMenuItem> stateItems = [];
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        } else {
                                          final statesList = snapshot.data?.docs.reversed.toList();
                                          for (var cities in statesList!) {
                                            String stateName = cities['stateName'];
                                            if(countryBool == true){
                                              if (!stateNames.contains(stateName)) {
                                                stateNames.add(stateName);
                                                stateItems.add(
                                                  DropdownMenuItem(
                                                    value: stateName,
                                                    child: Center(child: Text(stateName)),
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (stateName == 'Otro') {
                                                stateItems.add(
                                                  DropdownMenuItem(
                                                    value: stateName,
                                                    child: Center(child: Text(stateName)),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        }
                                        return DropdownButton(
                                          items: stateItems,
                                          hint: Center(child: Text(selectedIssuedState)),
                                          style: TextStyle(color: fifthColor.withOpacity(0.9),),
                                          underline: Container(),
                                          onChanged: (stateValue) {
                                            setState(() {
                                              selectedIssuedState = stateValue!;
                                            });
                                          },
                                          isExpanded: true,
                                        );
                                      },
                                    ),
                                  ),
                                  
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), border: Border.all(color: fifthColor.withOpacity(0.1))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('cities').where('stateName', isEqualTo: selectedIssuedState).orderBy('cityName', descending: true).snapshots(),
                                      builder: (context, snapshot) {
                                        Set<String> cityNames = {};
                                        List<DropdownMenuItem> cityItems = [];
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        } else {
                                          final citiesList = snapshot.data?.docs.reversed.toList();
                                          for (var cities in citiesList!) {
                                            String cityName = cities['cityName'];                                   
                                            if (!cityNames.contains(cityName)) {
                                              cityNames.add(cityName);
                                              cityItems.add(
                                                DropdownMenuItem(
                                                  value: cityName,
                                                  child: Center(child: Text(cityName)),
                                                ),
                                              );
                                            }                                    
                                          }
                                        }
                                        return DropdownButton(
                                          items: cityItems,
                                          hint: Center(child: Text(selectedIssuedCity)),
                                          underline: Container(),
                                          style: TextStyle(color: fifthColor.withOpacity(0.9),),
                                          onChanged: (cityValue) {
                                            setState(() {
                                              selectedIssuedCity = cityValue!;
                                            });
                                          },
                                          isExpanded: true,
                                        );
                                      },
                                    ),
                                  )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Correo electrónico", Icons.email_outlined, false, emailController, true
                      ),
                    ),                    
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Dirección", Icons.location_city_outlined, false, addressController, true
                      ),
                    ),                    
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 50,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), border: Border.all(color: fifthColor.withOpacity(0.1))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0, right: 10),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection('countries').orderBy('countryName').snapshots(),
                                builder: (context, snapshot) {
                                  List<DropdownMenuItem> countryItems = [];
                                  if (!snapshot.hasData) {
                                    const CircularProgressIndicator();
                                  } else {
                                    final countriesList = snapshot.data?.docs;
                                    for (var countries in countriesList!) {
                                      countryItems.add(
                                        DropdownMenuItem(
                                          value: countries['countryName'],
                                          child: Center(child: Text(countries['countryName'])),
                                        ),
                                      );
                                    }
                                  }
                                  return DropdownButton(
                                    items: countryItems,
                                    hint: Center(child: Text(selectedCountry)),
                                    underline: Container(),
                                    style: TextStyle(color: fifthColor.withOpacity(0.9),),
                                    onChanged: (countryValue) {
                                      setState(() {
                                        selectedCountry = countryValue!;
                                        if(selectedCountry ==  'Colombia'){
                                          countryBool = true;
                                        } else {
                                          countryBool = false;
                                        }
                                      });
                                    },
                                    isExpanded: true,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), border: Border.all(color: fifthColor.withOpacity(0.1))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('cities').orderBy('stateName', descending: true).snapshots(),
                                      builder: (context, snapshot) {
                                        Set<String> stateNames = {};
                                        List<DropdownMenuItem> stateItems = [];
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        } else {
                                          final statesList = snapshot.data?.docs.reversed.toList();
                                          for (var cities in statesList!) {
                                            String stateName = cities['stateName'];
                                            if(countryBool == true){
                                              if (!stateNames.contains(stateName)) {
                                                stateNames.add(stateName);
                                                stateItems.add(
                                                  DropdownMenuItem(
                                                    value: stateName,
                                                    child: Center(child: Text(stateName)),
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (stateName == 'Otro') {
                                                stateItems.add(
                                                  DropdownMenuItem(
                                                    value: stateName,
                                                    child: Center(child: Text(stateName)),
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        }
                                        return DropdownButton(
                                          items: stateItems,
                                          hint: Center(child: Text(selectedState)),
                                          underline: Container(),
                                          style: TextStyle(color: fifthColor.withOpacity(0.9),),
                                          onChanged: (stateValue) {
                                            setState(() {
                                              selectedState = stateValue!;
                                            });
                                          },
                                          isExpanded: true,
                                        );
                                      },
                                    ),
                                  ),
                                  
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), border: Border.all(color: fifthColor.withOpacity(0.1))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance.collection('cities').where('stateName', isEqualTo: selectedState).orderBy('cityName', descending: true).snapshots(),
                                      builder: (context, snapshot) {
                                        Set<String> cityNames = {};
                                        List<DropdownMenuItem> cityItems = [];
                                        if (!snapshot.hasData) {
                                          return const CircularProgressIndicator();
                                        } else {
                                          final citiesList = snapshot.data?.docs.reversed.toList();
                                          for (var cities in citiesList!) {
                                            String cityName = cities['cityName'];                                   
                                            if (!cityNames.contains(cityName)) {
                                              cityNames.add(cityName);
                                              cityItems.add(
                                                DropdownMenuItem(
                                                  value: cityName,
                                                  child: Center(child: Text(cityName)),
                                                ),
                                              );
                                            }                                    
                                          }
                                        }
                                        return DropdownButton(
                                          items: cityItems,
                                          hint: Center(child: Text(selectedCity)),
                                          underline: Container(),
                                          style: TextStyle(color: fifthColor.withOpacity(0.9),),
                                          onChanged: (cityValue) {
                                            setState(() {
                                              selectedCity = cityValue!;
                                            });
                                          },
                                          isExpanded: true,
                                        );
                                      },
                                    ),
                                  )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                        "Observaciones", Icons.search_outlined, false, observacionesController, true
                      ),
                    ),  
                    const SizedBox(
                      height: 15,
                    ),                  
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              style: ButtonStyle(fixedSize: MaterialStateProperty.all(const Size(250, 50))),
                              onPressed: () async {                       
                                setState(() {
                                  vlrSeparacion =  stringConverter(vlrSeparacionController.text);
                                  vlrSeparacionController.text = (currencyCOP((vlrSeparacion.toInt()).toString()));
                                  saldoCuotaIniController.text = (currencyCOP((saldoCI.toInt()).toString()));   
                                });
                                if(selectedSeller.isEmpty ||
                                  quoteDateController.text.isEmpty ||
                                  quoteDeadlineController.text.isEmpty || 
                                  priceloteController.text.isEmpty ||
                                  vlrCuotaIniController.text.isEmpty ||
                                  vlrSeparacionController.text.isEmpty ||
                                  separacionDeadlineController.text.isEmpty || 
                                  saldoCuotaIniController.text.isEmpty ||
                                  saldoCuotaIniDeadlineController.text.isEmpty ||
                                  vlrPorPagarController.text.isEmpty ||
                                  paymentMethodSelectedItem.isEmpty ||
                                  pagoContadoDeadlineController.text.isEmpty ||
                                  statementsStartDateController.text.isEmpty ||
                                  selectedNroCuotas.isEmpty || 
                                  vlrCuotaController.text.isEmpty ||  
                                  idController.text.isEmpty || 
                                  nameController.text.isEmpty || 
                                  lastnameController.text.isEmpty || 
                                  selectedGender.isEmpty || 
                                  birthdayController.text.isEmpty || 
                                  ocupacionController.text.isEmpty  || 
                                  phoneController.text.isEmpty || 
                                  selectedItemIdtype.isEmpty || 
                                  selectedIssuedCountry.isEmpty || 
                                  selectedIssuedState.isEmpty || 
                                  selectedIssuedCity.isEmpty ||  
                                  emailController.text.isEmpty || 
                                  addressController.text.isEmpty || 
                                  selectedCountry.isEmpty ||  
                                  selectedState.isEmpty || 
                                  selectedCity.isEmpty
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFGenerator(
                                        seller: selectedSeller,
                                        sellerName: sellerName,
                                        sellerPhone: sellerPhone,
                                        sellerEmail: sellerEmail,
                                        quoteId: idGenerator(quoteCounter),
                                        name: nameController.text,
                                        lastname: lastnameController.text,
                                        phone: phoneController.text,
                                        date: quoteDateController.text,
                                        dueDate: quoteDeadlineController.text,
                                        lote: loteInfo[1],
                                        area: '${((loteInfo[8].toInt()).toString())} m²',
                                        price: priceloteController.text,
                                        porcCuotaIni: '${((porcCuotaInicial.toInt()).toString())}%',
                                        vlrCuotaIni: vlrCuotaIniController.text,
                                        vlrSeparacion: vlrSeparacionController.text,
                                        dueDateSeparacion: separacionDeadlineController.text,
                                        plazoCI: '${(((plazoCI*30).toInt()).toString())} días',
                                        saldoCI: saldoCuotaIniController.text,
                                        dueDateSaldoCI: saldoCuotaIniDeadlineController.text,
                                        porcPorPagar: '${(((100-porcCuotaInicial).toInt()).toString())}%',
                                        vlrPorPagar: vlrPorPagarController.text,
                                        paymentMethod: paymentMethodSelectedItem,
                                        tiempoFinanc: '${(int.parse(selectedNroCuotas))/12} años',
                                        vlrCuota: vlrCuotaController.text,
                                        statementsStartDate: statementsStartDateController.text,
                                        nroCuotas: selectedNroCuotas,
                                        pagoContadoDue: pagoContadoDeadlineController.text,
                                        tem: '${temController.text}%',
                                        observaciones: observacionesController.text,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text("Ver PDF"),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 4,
                            child: ElevatedButton(
                              style: ButtonStyle(fixedSize: MaterialStateProperty.all(const Size(250, 50))),
                              onPressed: () async {                       
                                setState(() {
                                  vlrSeparacion =  stringConverter(vlrSeparacionController.text);
                                  vlrSeparacionController.text = (currencyCOP((vlrSeparacion.toInt()).toString()));
                                  saldoCuotaIniController.text = (currencyCOP((saldoCI.toInt()).toString()));   
                                });
                                if(selectedSeller.isEmpty ||
                                  quoteDateController.text.isEmpty ||
                                  quoteDeadlineController.text.isEmpty || 
                                  priceloteController.text.isEmpty ||
                                  vlrCuotaIniController.text.isEmpty ||
                                  vlrSeparacionController.text.isEmpty ||
                                  separacionDeadlineController.text.isEmpty || 
                                  saldoCuotaIniController.text.isEmpty ||
                                  saldoCuotaIniDeadlineController.text.isEmpty ||
                                  vlrPorPagarController.text.isEmpty ||
                                  paymentMethodSelectedItem.isEmpty ||
                                  pagoContadoDeadlineController.text.isEmpty ||
                                  statementsStartDateController.text.isEmpty ||
                                  selectedNroCuotas.isEmpty || 
                                  vlrCuotaController.text.isEmpty ||  
                                  idController.text.isEmpty || 
                                  nameController.text.isEmpty || 
                                  lastnameController.text.isEmpty || 
                                  selectedGender.isEmpty || 
                                  birthdayController.text.isEmpty || 
                                  ocupacionController.text.isEmpty  || 
                                  phoneController.text.isEmpty || 
                                  selectedItemIdtype.isEmpty || 
                                  selectedIssuedCountry.isEmpty || 
                                  selectedIssuedState.isEmpty || 
                                  selectedIssuedCity.isEmpty ||  
                                  emailController.text.isEmpty || 
                                  addressController.text.isEmpty || 
                                  selectedCountry.isEmpty ||  
                                  selectedState.isEmpty || 
                                  selectedCity.isEmpty
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
                                  await addCustomer(
                                    idController.text,
                                    nameController.text,
                                    lastnameController.text, 
                                    selectedGender,
                                    birthdayController.text,
                                    ocupacionController.text,
                                    phoneController.text,
                                    selectedItemIdtype,
                                    selectedIssuedCountry,
                                    selectedIssuedState,
                                    selectedIssuedCity, 
                                    emailController.text,
                                    addressController.text,
                                    selectedCountry, 
                                    selectedState,
                                    selectedCity,
                                    );
                                  await addQuote(
                                    idGenerator(quoteCounter),
                                    selectedSeller,
                                    quoteDateController.text,
                                    quoteDeadlineController.text, 
                                    loteInfo[1],
                                    loteInfo[7],
                                    '${((loteInfo[8].toInt()).toString())} m²',
                                    priceloteController.text,
                                    porcCuotaInicial,
                                    vlrCuotaIniController.text,
                                    vlrSeparacionController.text,
                                    separacionDeadlineController.text, 
                                    saldoCuotaIniController.text,
                                    saldoCuotaIniDeadlineController.text,
                                    vlrPorPagarController.text, 
                                    paymentMethodSelectedItem,
                                    pagoContadoDeadlineController.text,
                                    statementsStartDateController.text,
                                    int.parse(selectedNroCuotas), 
                                    vlrCuotaController.text,
                                    observacionesController.text,
                                    idController.text,
                                    'EN ESPERA'
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
                        ],
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
      ),
    );
  }

  Future<List> getSeller(String value) async {
    
    QuerySnapshot? querySellers = await db.collection('users').where(FieldPath.documentId, isEqualTo: selectedSeller).get();
    for (var doc in querySellers.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final person = {
        "nameUser": data['nameUser'],
        "uid": doc.id,
        "lastnameUser": data['lastnameUser'],
        "emailUser": data['emailUser'],
        "phoneUser": data['phoneUser'],
      };
      sellers.add(person);
    }
    return sellers;
  }




  double stringConverter(String valorAConvertir){
    String valorSinPuntos = valorAConvertir.replaceAll('\$', '').replaceAll('.', '');
    return double.parse(valorSinPuntos);
  }

  DateTime dateConverter(String stringAConvertir){
    DateTime dateConverted = DateFormat('MM-dd-yyyy').parse(stringAConvertir);
    return dateConverted;
  }

  String idGenerator(int quoteCount){
    quoteCount++;
    String idGenerated = quoteCount.toString().padLeft(5, '0');
    idGenerated = idGenerated+loteInfo[2];
    return idGenerated;
  }

  Widget paymentMethod(String paymentMethodSelection){
    if(paymentMethodSelection == 'Pago de contado'){
      return Row(
        children: [                          
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const SizedBox(
                height: 15,
                child: Text('Valor a pagar', style: TextStyle(fontSize: 10),)),
                textFieldWidget(
                  (currencyCOP(valorAPagar.toInt().toString())), Icons.monetization_on_outlined, false, vlrPorPagarController, false),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                const SizedBox(
                height: 15,
                child: Text('Fecha límite', style: TextStyle(fontSize: 10),)),
                textFieldWidget(
                  dateOnly(false, plazoCI+1, quotePickedDate), Icons.date_range_outlined, false, pagoContadoDeadlineController, false),
              ],
            ),
          ),                    
        ]
      );
    } else {
      return Column(
        children: [
          Row(
            children: [                          
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(
                    height: 15,
                    child: Text('Valor de cada cuota', style: TextStyle(fontSize: 10),)),
                    textFieldWidget(
                      (currencyCOP(valorCuota.toInt().toString())), Icons.monetization_on_outlined, false, vlrCuotaController, false),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(
                    height: 15,
                    child: Text('Financiación a', style: TextStyle(fontSize: 10),)),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: easyDropdown(nroCuotasList, selectedNroCuotas, (tempNroCuotas){setState(() {
                            selectedNroCuotas = tempNroCuotas!;
                          });}),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Text('   meses'),
                        )
                      ],
                    ),
                  ],
                ),
              ),                    
            ]
          ),
          Row(
            children: [                          
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(
                    height: 15,
                    child: Text('TEM', style: TextStyle(fontSize: 10),)),
                    textFieldWidget(
                      '${(vlrTEM.toString())} %', Icons.percent_outlined, false, temController, false),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(
                    height: 15,
                    child: Text('A partir de', style: TextStyle(fontSize: 10),)),
                    textFieldWidget(
                      dateOnly(false, plazoCI+1, quotePickedDate), Icons.date_range_outlined, false, statementsStartDateController, false
                    ),
                  ],
                ),
              ),                    
            ]
          ),
        ],
      );
    }
    
  }

  State<StatefulWidget> createState() => throw UnimplementedError();
}