import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_typeahead/flutter_typeahead.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class EditCustomerPage extends StatefulWidget {
  const EditCustomerPage({Key? key}) : super(key: key);

  @override
  State<EditCustomerPage> createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  // ignore: prefer_typing_uninitialized_variables
  var timer;

  @override
  void initState() {
    super.initState();    
    initOcup();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        realtimeDateTime = dateOnly(true, 0, DateTime.now(), false);
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); //cancel the periodic task
    timer; //clear the timer variable
    ocupacionController.dispose();
    super.dispose();
  }

  final TextEditingController ocupacionController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<List<String>> getSuggestions(String query) async {
    // Get the saved ocupaciones from Firebase
    List<String>? savedOcupaciones = await getOcupaciones();
    // Filter the suggestions based on the query
    List<String> filteredOcupaciones = savedOcupaciones
        .where((ocupacion) =>
            ocupacion.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return filteredOcupaciones;
  }

  Future<void> saveOcupacion(String ocupacion) async {
    // Save the new ocupacion to Firebase
    await guardarOcupacion(ocupacion);
  }

  Future<void> initOcup() async {
    ocupacionList = await getOcupaciones();
  }

  late String qid;
  DateTime quotePickedDate = DateTime.now();
  List<dynamic> loteInfo = [];
  List<dynamic> ocupacionList = [];
  String realtimeDateTime = '';  
  List<String> idtypeList = ['CC', 'CE', 'Pasaporte', 'NIT'];
  String selectedItemIdtype = 'CC';
  List<String> genderList = ['Masculino', 'Femenino', 'Otro'];
  bool countryBool = true;
  List countries = [];
  Stream<QuerySnapshot>? citiesStream;
  Stream<QuerySnapshot>? sellerStream;
  String loteId = "";
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController lastnameController = TextEditingController(text: "");
  String selectedGender = '';
  TextEditingController birthdayController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController idtypeController = TextEditingController(text: "");
  TextEditingController idController = TextEditingController(text: "");
  String selectedIssuedCountry = '';
  String selectedIssuedState = '';
  String selectedIssuedCity = '';
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  String selectedCountry = '';
  String selectedState = '';
  String selectedCity = '';
  bool isInitialized = false;
  bool cambioEstado = false;
  int nAux = 0;
  String lastId = '';

  @override
  Widget build(BuildContext context) {
    initOcup();
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (isInitialized == false) {
      nameController.text = arguments['name'];
      lastnameController.text = arguments['lastname'];
      selectedGender = arguments['gender'];
      birthdayController.text = arguments['birthday'];
      ocupacionController.text = arguments['ocupacion'];
      phoneController.text = arguments['phone'];
      idtypeController.text = arguments['idtype'];
      idController.text = arguments['id'];
      lastId = arguments['id'];
      selectedIssuedCountry = arguments['issuedCountry'];
      selectedIssuedState = arguments['issuedState'];
      selectedIssuedCity = arguments['issuedCity'];
      emailController.text = arguments['email'];
      addressController.text = arguments['address'];
      selectedCountry = arguments['country'];
      selectedState = arguments['state'];
      selectedCity = arguments['city'];   
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
        title: Text(
          'Cotización $qid',
          style: TextStyle(
              color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
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
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [                    
                    Container(
                        alignment: Alignment.center,
                        child: const Text('Información del cliente',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ))),
                    const SizedBox(
                      height: 10,
                    ),
                    Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget("Nombres", Icons.person_outline,
                              false, nameController, true, 'name', () {}),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget("Apellidos", Icons.person_outline,
                              false, lastnameController, true, 'name', () {}),
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
                                  child: easyDropdown(genderList, selectedGender,
                                      (tempGender) {
                                    setState(() {
                                      selectedGender = tempGender!;
                                    });
                                  })),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(
                                        width: 1,
                                        style: BorderStyle.solid,
                                        color: fifthColor.withOpacity(0.1)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: TextField(
                                      cursorColor: fifthColor,
                                      style: TextStyle(
                                          color: fifthColor.withOpacity(0.9)),
                                      controller: birthdayController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(
                                          Icons.cake_outlined,
                                          color: fifthColor,
                                        ),
                                        hintText: "Fecha de nacimiento",
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        DateTime? pickeddate = await showDatePicker(
                                          locale: const Locale("es", "CO"),
                                          context: context,
                                          initialDate: DateTime.now()
                                              .subtract(const Duration(days: 6574)),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now()
                                              .subtract(const Duration(days: 6574)),
                                        );
                                        if (pickeddate != null) {
                                          setState(() {
                                            birthdayController.text =
                                                DateFormat('dd-MM-yyyy')
                                                    .format(pickeddate);
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
                          child: Column(
                            children: [
                              TypeAheadFormField<String>(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: ocupacionController,
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(color: fifthColor.withOpacity(0.9)),
                                  decoration: InputDecoration(
                                    prefixIcon:
                                        Icon(Icons.work_outline, color: fifthColor),
                                    hintText: 'Ocupación o actividad económica',
                                    hintStyle: TextStyle(
                                        color: fifthColor.withOpacity(0.9)),
                                    filled: true,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.never,
                                    fillColor: primaryColor.withOpacity(0.2),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        borderSide: BorderSide(
                                            width: 1,
                                            style: BorderStyle.solid,
                                            color: fifthColor.withOpacity(0.1))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        borderSide: BorderSide(
                                            width: 2,
                                            style: BorderStyle.solid,
                                            color: fifthColor)),
                                  ),
                                ),
                                suggestionsCallback: getSuggestions,
                                onSuggestionSelected: (ocupacion) {
                                  ocupacionController.text = ocupacion;
                                },
                                onSaved: (ocupacion) async {
                                  // Save the ocupacion to Firebase if it's a new value
                                  if (!ocupacionList.contains(ocupacion)) {
                                    saveOcupacion(ocupacion!);
                                  }
                                },
                                itemBuilder: (context, ocupacion) {
                                  return ListTile(
                                    title: Text(ocupacion),
                                  );
                                },
                                noItemsFoundBuilder: (context) {
                                  return const SizedBox.shrink();
                                },
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
                              "Número telefónico",
                              Icons.phone_android,
                              false,
                              phoneController,
                              true,
                              'phone',
                              () {}),
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
                                    child: easyDropdown(
                                        idtypeList, selectedItemIdtype, (tempType) {
                                  setState(() {
                                    selectedItemIdtype = tempType!;
                                  });
                                })),
                              ),
                              Expanded(
                                flex: 2,
                                child: textFieldWidget(
                                    "Nro documento",
                                    Icons.badge_outlined,
                                    false,
                                    idController,
                                    true,
                                    'id',
                                    () {}),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                          child: Center(
                              child: Text(
                            'Lugar de expedición',
                            style: TextStyle(fontSize: 10),
                          )),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(90),
                                    border: Border.all(
                                        color: fifthColor.withOpacity(0.1))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10.0, right: 10),
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('countries')
                                        .orderBy('countryName')
                                        .snapshots(),
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
                                              child: Center(
                                                  child: Text(
                                                      countries['countryName'])),
                                            ),
                                          );
                                        }
                                      }
                                      return DropdownButton(
                                        items: countryItems,
                                        hint: Center(
                                            child: Text(selectedIssuedCountry)),
                                        underline: Container(),
                                        style: TextStyle(
                                          color: fifthColor.withOpacity(0.9),
                                        ),
                                        onChanged: (countryValue) {
                                          setState(() {
                                            selectedIssuedCountry = countryValue!;
                                            if (selectedIssuedCountry ==
                                                'Colombia') {
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
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(90),
                                          border: Border.all(
                                              color: fifthColor.withOpacity(0.1))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10),
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('cities')
                                              .orderBy('stateName',
                                                  descending: true)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            Set<String> stateNames = {};
                                            List<DropdownMenuItem> stateItems = [];
                                            if (!snapshot.hasData) {
                                              return const CircularProgressIndicator();
                                            } else {
                                              final statesList = snapshot
                                                  .data?.docs.reversed
                                                  .toList();
                                              for (var cities in statesList!) {
                                                String stateName =
                                                    cities['stateName'];
                                                if (countryBool == true) {
                                                  if (!stateNames
                                                      .contains(stateName)) {
                                                    stateNames.add(stateName);
                                                    stateItems.add(
                                                      DropdownMenuItem(
                                                        value: stateName,
                                                        child: Center(
                                                            child: Text(stateName)),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  if (stateName == 'Otro') {
                                                    stateItems.add(
                                                      DropdownMenuItem(
                                                        value: stateName,
                                                        child: Center(
                                                            child: Text(stateName)),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            }
                                            return DropdownButton(
                                              items: stateItems,
                                              hint: Center(
                                                  child: Text(selectedIssuedState)),
                                              style: TextStyle(
                                                color: fifthColor.withOpacity(0.9),
                                              ),
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
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(90),
                                            border: Border.all(
                                                color:
                                                    fifthColor.withOpacity(0.1))),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 10),
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('cities')
                                                .where('stateName',
                                                    isEqualTo: selectedIssuedState)
                                                .orderBy('cityName',
                                                    descending: true)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              Set<String> cityNames = {};
                                              List<DropdownMenuItem> cityItems = [];
                                              if (!snapshot.hasData) {
                                                return const CircularProgressIndicator();
                                              } else {
                                                final citiesList = snapshot
                                                    .data?.docs.reversed
                                                    .toList();
                                                for (var cities in citiesList!) {
                                                  String cityName =
                                                      cities['cityName'];
                                                  if (!cityNames
                                                      .contains(cityName)) {
                                                    cityNames.add(cityName);
                                                    cityItems.add(
                                                      DropdownMenuItem(
                                                        value: cityName,
                                                        child: Center(
                                                            child: Text(cityName)),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                              return DropdownButton(
                                                items: cityItems,
                                                hint: Center(
                                                    child:
                                                        Text(selectedIssuedCity)),
                                                underline: Container(),
                                                style: TextStyle(
                                                  color:
                                                      fifthColor.withOpacity(0.9),
                                                ),
                                                onChanged: (cityValue) {
                                                  setState(() {
                                                    selectedIssuedCity = cityValue!;
                                                  });
                                                },
                                                isExpanded: true,
                                              );
                                            },
                                          ),
                                        )),
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
                              "Correo electrónico",
                              Icons.email_outlined,
                              false,
                              emailController,
                              true,
                              'email',
                              () {}),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: textFieldWidget(
                              "Dirección",
                              Icons.location_city_outlined,
                              false,
                              addressController,
                              true,
                              'name',
                              () {}),
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
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(90),
                                    border: Border.all(
                                        color: fifthColor.withOpacity(0.1))),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10.0, right: 10),
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('countries')
                                        .orderBy('countryName')
                                        .snapshots(),
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
                                              child: Center(
                                                  child: Text(
                                                      countries['countryName'])),
                                            ),
                                          );
                                        }
                                      }
                                      return DropdownButton(
                                        items: countryItems,
                                        hint: Center(child: Text(selectedCountry)),
                                        underline: Container(),
                                        style: TextStyle(
                                          color: fifthColor.withOpacity(0.9),
                                        ),
                                        onChanged: (countryValue) {
                                          setState(() {
                                            selectedCountry = countryValue!;
                                            if (selectedCountry == 'Colombia') {
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
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(90),
                                          border: Border.all(
                                              color: fifthColor.withOpacity(0.1))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10),
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('cities')
                                              .orderBy('stateName',
                                                  descending: true)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            Set<String> stateNames = {};
                                            List<DropdownMenuItem> stateItems = [];
                                            if (!snapshot.hasData) {
                                              return const CircularProgressIndicator();
                                            } else {
                                              final statesList = snapshot
                                                  .data?.docs.reversed
                                                  .toList();
                                              for (var cities in statesList!) {
                                                String stateName =
                                                    cities['stateName'];
                                                if (countryBool == true) {
                                                  if (!stateNames
                                                      .contains(stateName)) {
                                                    stateNames.add(stateName);
                                                    stateItems.add(
                                                      DropdownMenuItem(
                                                        value: stateName,
                                                        child: Center(
                                                            child: Text(stateName)),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  if (stateName == 'Otro') {
                                                    stateItems.add(
                                                      DropdownMenuItem(
                                                        value: stateName,
                                                        child: Center(
                                                            child: Text(stateName)),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            }
                                            return DropdownButton(
                                              items: stateItems,
                                              hint: Center(
                                                  child: Text(selectedState)),
                                              underline: Container(),
                                              style: TextStyle(
                                                color: fifthColor.withOpacity(0.9),
                                              ),
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
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(90),
                                            border: Border.all(
                                                color:
                                                    fifthColor.withOpacity(0.1))),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 10),
                                          child: StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('cities')
                                                .where('stateName',
                                                    isEqualTo: selectedState)
                                                .orderBy('cityName',
                                                    descending: true)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              Set<String> cityNames = {};
                                              List<DropdownMenuItem> cityItems = [];
                                              if (!snapshot.hasData) {
                                                return const CircularProgressIndicator();
                                              } else {
                                                final citiesList = snapshot
                                                    .data?.docs.reversed
                                                    .toList();
                                                for (var cities in citiesList!) {
                                                  String cityName =
                                                      cities['cityName'];
                                                  if (!cityNames
                                                      .contains(cityName)) {
                                                    cityNames.add(cityName);
                                                    cityItems.add(
                                                      DropdownMenuItem(
                                                        value: cityName,
                                                        child: Center(
                                                            child: Text(cityName)),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                              return DropdownButton(
                                                items: cityItems,
                                                hint: Center(
                                                    child: Text(selectedCity)),
                                                underline: Container(),
                                                style: TextStyle(
                                                  color:
                                                      fifthColor.withOpacity(0.9),
                                                ),
                                                onChanged: (cityValue) {
                                                  setState(() {
                                                    selectedCity = cityValue!;
                                                  });
                                                },
                                                isExpanded: true,
                                              );
                                            },
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Center(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all(
                                      const Size(250, 50))),
                              onPressed: () async {                                
                                if (idController.text.isEmpty ||
                                    nameController.text.isEmpty ||
                                    lastnameController.text.isEmpty ||
                                    selectedGender.isEmpty ||
                                    birthdayController.text.isEmpty ||
                                    ocupacionController.text.isEmpty ||
                                    phoneController.text.isEmpty ||
                                    selectedItemIdtype.isEmpty ||
                                    selectedIssuedCountry.isEmpty ||
                                    selectedIssuedState.isEmpty ||
                                    selectedIssuedCity.isEmpty ||
                                    emailController.text.isEmpty ||
                                    addressController.text.isEmpty ||
                                    selectedCountry.isEmpty ||
                                    selectedState.isEmpty ||
                                    selectedCity.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: CustomAlertMessage(
                                        errorTitle: "Oops!",
                                        errorText:
                                            "Verifique que todos los campos se hayan llenado correctamente.",
                                        stateColor: dangerColor,
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                    ),
                                  );
                                } else {
                                  if (!ocupacionList
                                      .contains(ocupacionController.text)) {
                                    saveOcupacion(ocupacionController.text);
                                  }
                                  await db.collection("ordSep").doc(qid).update({    
                                    "clienteID": idController.text,
                                  });
                                  await db.collection("quotes").doc(qid).update({    
                                    "clienteID": idController.text,
                                  });
                                  await db.collection("planPagos").doc(loteId).update({    
                                    "idCliente": idController.text,
                                  });                              
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
                                  await db.collection("customers").doc(lastId).delete().then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: CustomAlertMessage(
                                          errorTitle: "Genial!",
                                          errorText:
                                              "Datos actualizados de manera satisfactoria.",
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
                              child: const Text(
                                "Actualizar cliente",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
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


  DateTime dateConverter(String stringAConvertir) {
    DateTime dateConverted = DateFormat('dd-MM-yyyy').parse(stringAConvertir);
    return dateConverted;
  }


  State<StatefulWidget> createState() => throw UnimplementedError();
}
