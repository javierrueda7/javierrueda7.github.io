// ignore_for_file: use_build_context_synchronously

import 'package:albaterrapp/pages/pdf_generator.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_typeahead/flutter_typeahead.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class AddQuotePage extends StatefulWidget {
  final List<dynamic> loteInfo;
  const AddQuotePage({super.key, required this.loteInfo});

  @override
  State<AddQuotePage> createState() => _AddQuotePageState();
}

class _AddQuotePageState extends State<AddQuotePage> {
  // ignore: prefer_typing_uninitialized_variables
  var timer;

  @override
  void initState() {
    super.initState();
    loteInfo = widget.loteInfo;
    initPagos();
    initCuotas();
    initSeller();
    initOcup();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        realtimeDateTime = dateOnly(true, 0, DateTime.now(), false);
      });
    });
  }

  @override
  void dispose() {    
    ocupacionController.dispose();
    timer.cancel(); //cancel the periodic task
    timer; //clear the timer variable
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

  double periodoNumValue = 0;
  Map<String, dynamic> infoPagos = {};
  late int quoteCounter;
  late String qid;
  DateTime quotePickedDate = DateTime.now();
  List<dynamic> loteInfo = [];
  Map<String, dynamic> seller = {};
  List<dynamic> ocupacionList = [];
  String realtimeDateTime = '';
  int totalCuotas = 0;

  double precioFinal = 0;
  double vlrSeparacion = 10000000;
  double vlrFijoSeparacion = 0;
  double saldoSeparacion = 0;
  double porcCuotaInicial = 0;
  double plazoCI = 0;
  double plazoContado = 0;
  double plazoSaldoSep = 0;
  double vlrTEM = 0;
  double dctoContado = 0;
  double dctoCuotas = 0;
  double nroCuotas = 1;
  int maxCuotas = 1;
  double cuotaInicial = 0;
  int periodoCuotas = 1;

  Future<void> initPagos() async {
    infoPagos = await getInfoProyecto();
    vlrFijoSeparacion = infoPagos['valorSeparacion'].toDouble();
    porcCuotaInicial = infoPagos['cuotaInicial'].toDouble();
    plazoCI = infoPagos['plazoCuotaInicial'].toDouble();
    vlrTEM = infoPagos['tem'].toDouble();
    dctoContado = infoPagos['dctoContado'].toDouble();
    plazoContado = infoPagos['plazoContado'].toDouble();
    maxCuotas = infoPagos['maxCuotas'].toInt();
    plazoSaldoSep = infoPagos['plazoSaldoSep'].toDouble();
    sellerStream = FirebaseFirestore.instance
        .collection('sellers')
        .orderBy('lastnameSeller')
        .snapshots();
  }

  Future<void> initSeller() async {
    sellerStream = FirebaseFirestore.instance
        .collection('sellers')
        .orderBy('lastnameSeller')
        .snapshots();
    getSeller();
  }

  Future<void> initCuotas() async {
    dctoCuotas = await getPeriodoDiscount(periodoCuotas.toString());
  }

  late int vlrBaseLote;
  late double saldoCI;
  late double valorAPagar;
  late double valorCuota;
  late String dateSaldo;
  List<String> nroCuotasList = [''];
  String selectedNroCuotas = '1';
  String selectedPeriodoCuotas = 'Mensual';
  List<String> idtypeList = ['CC', 'CE', 'Pasaporte', 'NIT'];
  String selectedItemIdtype = 'CC';
  List<String> genderList = ['Masculino', 'Femenino', 'Otro'];
  bool countryBool = true;
  List countries = [];
  List<String> periodoCuotasList = [
    'Semanal',
    'Quincenal',
    'Mensual',
    'Bimestral',
    'Trimestral',
    'Cuatrimestral',
    'Semestral',
    'Anual'
  ];
  List<String> paymentMethodList = ['Pago de contado', 'Financiación directa'];
  String paymentMethodSelectedItem = 'Pago de contado';
  Stream<QuerySnapshot>? sellerStream;
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('quotes');

  String selectedSeller = '';
  String sellerName = '';
  String sellerEmail = '';
  String sellerPhone = '';
  TextEditingController quoteDateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
  TextEditingController quoteDeadlineController =
      TextEditingController(text: dateOnly(false, 15, DateTime.now(), false));
  String loteId = "";
  TextEditingController loteController = TextEditingController(text: "");
  TextEditingController etapaloteController = TextEditingController(text: "");
  TextEditingController arealoteController = TextEditingController(text: "");
  TextEditingController priceloteController = TextEditingController(text: "");
  TextEditingController precioFinalController = TextEditingController(text: "");
  TextEditingController porcCuotaInicialController =
      TextEditingController(text: "");
  TextEditingController vlrCuotaIniController = TextEditingController(text: "");
  TextEditingController nroCuotasController = TextEditingController(text: "");
  TextEditingController vlrSeparacionController =
      TextEditingController(text: "\$10.000.000");
  TextEditingController saldoSeparacionController =
      TextEditingController(text: "\$0");
  TextEditingController separacionDeadlineController =
      TextEditingController(text: dateOnly(false, 0, DateTime.now(), false));
  TextEditingController saldoSeparacionDeadlineController =
      TextEditingController(text: dateOnly(false, 7, DateTime.now(), false));
  TextEditingController saldoCuotaIniController =
      TextEditingController(text: "");
  TextEditingController saldoCuotaIniDeadlineController =
      TextEditingController(text: dateOnly(false, 120, DateTime.now(), true));

  TextEditingController vlrPorPagarController = TextEditingController(text: "");
  TextEditingController saldoTotalDateController =
      TextEditingController(text: "");
  TextEditingController vlrCuotaController = TextEditingController(text: "");
  TextEditingController temController = TextEditingController(text: "");
  TextEditingController observacionesController =
      TextEditingController(text: "");

  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController lastnameController = TextEditingController(text: "");
  String selectedGender = 'Masculino';
  TextEditingController birthdayController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController idtypeController = TextEditingController(text: "");
  TextEditingController idController = TextEditingController(text: "");
  String selectedIssuedCountry = 'Colombia';
  String selectedIssuedState = 'Santander';
  String selectedIssuedCity = 'Bucaramanga';
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  String selectedCountry = 'Colombia';
  String selectedState = 'Santander';
  String selectedCity = 'Bucaramanga';
  int nAux = 0;

  @override
  Widget build(BuildContext context) {
    collectionReference.get().then((QuerySnapshot quotesSnapshot) {
      quoteCounter = quotesSnapshot.size;
    });
    getSeller();
    initOcup();
    initPagos();
    initCuotas();
    initSeller();
    nroCuotasList = nroCuotasGenerator(maxCuotas);
    periodoCalculator(stringConverter(selectedNroCuotas));
    vlrBaseLote = loteInfo[9].toInt();
    precioFinal = vlrBaseLote * ((100 - discountValue()) / 100);

    if (nAux <= 5) {
      updateDateSaldo(quotePickedDate);
      nAux++;
    }
    cuotaInicial = precioFinal * (porcCuotaInicial / 100);
    saldoCI = cuotaInicial - vlrFijoSeparacion;
    valorCuota = valorAPagar / (double.parse(selectedNroCuotas));
    saldoSeparacion = vlrFijoSeparacion - vlrSeparacion;

    priceloteController.text = (currencyCOP((vlrBaseLote.toInt()).toString()));
    precioFinalController.text =
        (currencyCOP((precioFinal.toInt()).toString()));
    vlrCuotaIniController.text =
        (currencyCOP((cuotaInicial.toInt()).toString()));
    saldoCuotaIniController.text = (currencyCOP((saldoCI.toInt()).toString()));
    vlrCuotaController.text = (currencyCOP((valorCuota.toInt()).toString()));
    vlrPorPagarController.text =
        (currencyCOP((valorAPagar.toInt()).toString()));
    saldoSeparacionController.text =
        (currencyCOP((saldoSeparacion.toInt()).toString()));

    temController.text = '${vlrTEM.toString()}%';
    saldoTotalDateController.text = dateSaldo;
    sellerStream = FirebaseFirestore.instance
        .collection('sellers')
        .orderBy('lastnameSeller')
        .snapshots();

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Nueva cotización ${loteInfo[1]}',
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
                      constraints: const BoxConstraints(maxWidth: 800),
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(90),
                          border:
                              Border.all(color: fifthColor.withOpacity(0.1))),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: sellerStream,
                          builder: (context, sellersSnapshot) {
                            List<DropdownMenuItem> sellerItems = [];
                            if (!sellersSnapshot.hasData) {
                              const CircularProgressIndicator();
                            } else {
                              final sellersList = sellersSnapshot.data?.docs;
                              for (var sellers in sellersList!) {
                                if (sellers['roleSeller'] ==
                                        'Asesor comercial' &&
                                    sellers['statusSeller'] == 'Activo') {
                                  sellerItems.add(
                                    DropdownMenuItem(
                                      value: sellers.id,
                                      child: Center(
                                          child: Text(
                                              '${sellers['nameSeller']} ${sellers['lastnameSeller']}')),
                                    ),
                                  );
                                }
                              }
                            }
                            return DropdownButton(
                              items: sellerItems,
                              hint: Center(
                                  child: Text(selectedSeller != ''
                                      ? '${seller['nameSeller']} ${seller['lastnameSeller']}'
                                      : 'Seleccione un vendedor')),
                              underline: Container(),
                              style: TextStyle(
                                color: fifthColor.withOpacity(0.9),
                              ),
                              onChanged: (sellerValue) {
                                setState(() {
                                  selectedSeller = sellerValue!;
                                  getSeller();
                                });
                              },
                              isExpanded: true,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 15,
                      child: Center(
                          child: Text('Vigencia cotización',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ))),
                    ),
                    const SizedBox(
                      height: 10,
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
                                  child: Text(
                                    'Desde',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                                Container(
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
                                      textAlign: TextAlign.center,
                                      cursorColor: fifthColor,
                                      style: TextStyle(
                                          color: fifthColor.withOpacity(0.9)),
                                      controller: quoteDateController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(
                                          Icons.date_range_outlined,
                                          color: fifthColor,
                                        ),
                                        hintText: DateFormat('dd-MM-yyyy')
                                            .format(quotePickedDate),
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          locale: const Locale("es", "CO"),
                                          context: context,
                                          initialDate: dateConverter(
                                              quoteDateController.text),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                        );
                                        if (pickedDate != null) {
                                          setState(() {
                                            quoteDateController.text =
                                                DateFormat('dd-MM-yyyy')
                                                    .format(pickedDate);
                                            quoteDeadlineController.text =
                                                dateOnly(false, 15, pickedDate,
                                                    true);
                                            separacionDeadlineController.text =
                                                dateOnly(false, 0, pickedDate,
                                                    false);
                                            saldoSeparacionDeadlineController
                                                    .text =
                                                dateOnly(false, plazoSaldoSep,
                                                    pickedDate, false);
                                            saldoCuotaIniDeadlineController
                                                    .text =
                                                dateOnly(false, plazoCI,
                                                    pickedDate, true);
                                            updateDateSaldo(pickedDate);
                                            discountValue();
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
                                  child: Text(
                                    'Hasta',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                                Container(
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
                                      textAlign: TextAlign.center,
                                      cursorColor: fifthColor,
                                      style: TextStyle(
                                          color: fifthColor.withOpacity(0.9)),
                                      controller: quoteDeadlineController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(
                                          Icons.date_range_outlined,
                                          color: fifthColor,
                                        ),
                                        hintText: DateFormat('dd-MM-yyyy')
                                            .format(quotePickedDate),
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          locale: const Locale("es", "CO"),
                                          context: context,
                                          initialDate: dateConverter(
                                              quoteDeadlineController.text),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2050),
                                        );
                                        if (pickedDate != null) {
                                          setState(() {
                                            quoteDeadlineController.text =
                                                DateFormat('dd-MM-yyyy')
                                                    .format(pickedDate);
                                          });
                                        }
                                      },
                                    ),
                                  ),
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
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                  child: Text(
                                    'Inmueble Nº',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                                Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 800),
                                    child: textFieldWidget(
                                        loteInfo[1],
                                        Icons.house_outlined,
                                        false,
                                        loteController,
                                        false,
                                        'email',
                                        () {})),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                  child: Text(
                                    'Etapa',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                                Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 800),
                                    child: textFieldWidget(
                                        loteInfo[7].toString(),
                                        Icons.map_outlined,
                                        false,
                                        etapaloteController,
                                        false,
                                        'email',
                                        () {})),
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
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                  child: Text(
                                    'Área',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                                Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 800),
                                    child: textFieldWidget(
                                        '${((loteInfo[8].toInt()).toString())} m²',
                                        Icons.straighten_outlined,
                                        false,
                                        arealoteController,
                                        false,
                                        'number',
                                        () {})),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                  child: Text(
                                    'Precio',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                                Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 800),
                                    child: textFieldWidget(
                                        (currencyCOP((vlrBaseLote).toString())),
                                        Icons.monetization_on_outlined,
                                        false,
                                        priceloteController,
                                        false,
                                        'number',
                                        () {})),
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
                      //Container de separación
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              alignment: Alignment.center,
                              child: const Text('Separación',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ))),
                          Container(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: Row(children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                          height: 15,
                                          child: Text(
                                            'Valor',
                                            style: TextStyle(fontSize: 10),
                                          )),
                                      textFieldWidget(
                                        (currencyCOP((vlrSeparacion.toInt())
                                            .toString())),
                                        Icons.monetization_on_outlined,
                                        false,
                                        vlrSeparacionController,
                                        true,
                                        'number',
                                        (String value) {
                                          if (value.isEmpty ||
                                              stringConverter(value) <
                                                  10000000) {
                                            setState(() {
                                              vlrSeparacion =
                                                  stringConverter(value);
                                              saldoSeparacion = 10000000 -
                                                  stringConverter(value);
                                              saldoSeparacionController.text =
                                                  (currencyCOP(
                                                      (saldoSeparacion.toInt())
                                                          .toString()));
                                              saldoCuotaIniController.text =
                                                  (currencyCOP((saldoCI.toInt())
                                                      .toString()));
                                              vlrSeparacionController.value =
                                                  TextEditingValue(
                                                text: (currencyCOP(
                                                    (vlrSeparacion.toInt())
                                                        .toString())),
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset: (currencyCOP(
                                                                (vlrSeparacion
                                                                        .toInt())
                                                                    .toString()))
                                                            .length),
                                              );
                                            });
                                          }
                                          if (stringConverter(value) >=
                                              10000000) {
                                            setState(() {
                                              vlrSeparacion = 10000000;
                                              vlrSeparacionController.text =
                                                  "10000000";
                                              saldoSeparacion = 0;
                                              saldoSeparacionController.text =
                                                  (currencyCOP(
                                                      (saldoSeparacion.toInt())
                                                          .toString()));
                                              vlrSeparacionController.value =
                                                  TextEditingValue(
                                                text: (currencyCOP(
                                                    (vlrSeparacion.toInt())
                                                        .toString())),
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset: (currencyCOP(
                                                                (vlrSeparacion
                                                                        .toInt())
                                                                    .toString()))
                                                            .length),
                                              );
                                            });
                                          }
                                        },
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
                                          child: Text(
                                            'Fecha límite',
                                            style: TextStyle(fontSize: 10),
                                          )),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          border: Border.all(
                                              width: 1,
                                              style: BorderStyle.solid,
                                              color:
                                                  fifthColor.withOpacity(0.1)),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            cursorColor: fifthColor,
                                            style: TextStyle(
                                                color: fifthColor
                                                    .withOpacity(0.9)),
                                            controller:
                                                separacionDeadlineController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              icon: Icon(
                                                Icons.date_range_outlined,
                                                color: fifthColor,
                                              ),
                                              hintText: DateFormat('dd-MM-yyyy')
                                                  .format(quotePickedDate),
                                            ),
                                            readOnly: true,
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                locale:
                                                    const Locale("es", "CO"),
                                                context: context,
                                                initialDate: dateConverter(
                                                    separacionDeadlineController
                                                        .text),
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2050),
                                              );
                                              if (pickedDate != null) {
                                                setState(() {
                                                  separacionDeadlineController
                                                          .text =
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(pickedDate);
                                                  saldoSeparacionDeadlineController
                                                          .text =
                                                      dateOnly(
                                                          false,
                                                          plazoSaldoSep,
                                                          pickedDate,
                                                          false);
                                                  saldoCuotaIniDeadlineController
                                                          .text =
                                                      dateOnly(false, plazoCI,
                                                          pickedDate, true);
                                                  updateDateSaldo(pickedDate);
                                                  discountValue();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: Row(children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                          height: 15,
                                          child: Text(
                                            'Saldo separación',
                                            style: TextStyle(fontSize: 10),
                                          )),
                                      textFieldWidget(
                                        (currencyCOP((saldoSeparacion.toInt())
                                            .toString())),
                                        Icons.monetization_on_outlined,
                                        false,
                                        saldoSeparacionController,
                                        false,
                                        'number',
                                        () {},
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
                                          child: Text(
                                            'Fecha límite saldo separación',
                                            style: TextStyle(fontSize: 10),
                                          )),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          border: Border.all(
                                              width: 1,
                                              style: BorderStyle.solid,
                                              color:
                                                  fifthColor.withOpacity(0.1)),
                                        ),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: TextField(
                                            textAlign: TextAlign.center,
                                            cursorColor: fifthColor,
                                            style: TextStyle(
                                                color: fifthColor
                                                    .withOpacity(0.9)),
                                            controller:
                                                saldoSeparacionDeadlineController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              icon: Icon(
                                                Icons.date_range_outlined,
                                                color: fifthColor,
                                              ),
                                              hintText: DateFormat('dd-MM-yyyy')
                                                  .format(quotePickedDate),
                                            ),
                                            readOnly: true,
                                            onTap: () async {
                                              DateTime? pickedDate =
                                                  await showDatePicker(
                                                locale:
                                                    const Locale("es", "CO"),
                                                context: context,
                                                initialDate: dateConverter(
                                                    saldoSeparacionDeadlineController
                                                        .text),
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2050),
                                              );
                                              if (pickedDate != null) {
                                                setState(() {
                                                  saldoSeparacionDeadlineController
                                                          .text =
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(pickedDate);
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ])),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: const Text('Método de pago',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ))),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: easyDropdown(
                          paymentMethodList, paymentMethodSelectedItem,
                          (tempPaymentMethod) {
                        setState(() {
                          paymentMethodSelectedItem = tempPaymentMethod!;
                          nroCuotasGenerator(maxCuotas);
                          selectedNroCuotas = "1";
                          periodoCalculator(stringConverter(selectedNroCuotas));
                          initCuotas();
                          updateDateSaldo(
                              dateConverter(separacionDeadlineController.text));
                          discountValue();
                        });
                      }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    paymentMethod(paymentMethodSelectedItem),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      thickness: 5,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
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
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                          "Observaciones",
                          Icons.search_outlined,
                          false,
                          observacionesController,
                          true,
                          'email',
                          () {}),
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
                              style: ButtonStyle(
                                  fixedSize: WidgetStateProperty.all(
                                      const Size(250, 50))),
                              onPressed: () async {
                                setState(() {
                                  vlrSeparacion = stringConverter(
                                      vlrSeparacionController.text);
                                  vlrSeparacionController.text = (currencyCOP(
                                      (vlrSeparacion.toInt()).toString()));
                                  saldoCuotaIniController.text = (currencyCOP(
                                      (saldoCI.toInt()).toString()));
                                });
                                if (selectedSeller.isEmpty ||
                                    quoteDateController.text.isEmpty ||
                                    quoteDeadlineController.text.isEmpty ||
                                    priceloteController.text.isEmpty ||
                                    vlrCuotaIniController.text.isEmpty ||
                                    vlrSeparacionController.text.isEmpty ||
                                    separacionDeadlineController.text.isEmpty ||
                                    saldoCuotaIniController.text.isEmpty ||
                                    saldoCuotaIniDeadlineController
                                        .text.isEmpty ||
                                    vlrPorPagarController.text.isEmpty ||
                                    paymentMethodSelectedItem.isEmpty ||
                                    saldoTotalDateController.text.isEmpty ||
                                    selectedNroCuotas.isEmpty ||
                                    vlrCuotaController.text.isEmpty ||
                                    idController.text.isEmpty ||
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFGenerator(
                                        sellerID: selectedSeller,
                                        sellerName:
                                            '${seller['nameSeller']} ${seller['lastnameSeller']}',
                                        sellerPhone: seller['phoneSeller'],
                                        sellerEmail: seller['emailSeller'],
                                        quoteId: idGenerator(quoteCounter),
                                        name: nameController.text,
                                        lastname: lastnameController.text,
                                        phone: phoneController.text,
                                        date: quoteDateController.text,
                                        dueDate: quoteDeadlineController.text,
                                        lote: loteInfo[1],
                                        area:
                                            '${((loteInfo[8].toInt()).toString())} m²',
                                        price: priceloteController.text,
                                        finalPrice: precioFinalController.text,
                                        discount:
                                            '${discountValue().toString()}%',
                                        porcCuotaIni:
                                            '${((porcCuotaInicial.toInt()).toString())}%',
                                        vlrCuotaIni: vlrCuotaIniController.text,
                                        vlrSeparacion:
                                            vlrSeparacionController.text,
                                        dueDateSeparacion:
                                            separacionDeadlineController.text,
                                        saldoSeparacion:
                                            saldoSeparacionController.text,
                                        dueDateSaldoSeparacion:
                                            saldoSeparacionDeadlineController
                                                .text,
                                        plazoCI:
                                            '${(((plazoCI).toInt()).toString())} días',
                                        plazoContado:
                                            '${(((plazoContado).toInt()).toString())} días',
                                        saldoCI: saldoCuotaIniController.text,
                                        dueDateSaldoCI:
                                            saldoCuotaIniDeadlineController
                                                .text,
                                        porcPorPagar:
                                            '${(((100 - porcCuotaInicial).toInt()).toString())}%',
                                        vlrPorPagar: vlrPorPagarController.text,
                                        paymentMethod:
                                            paymentMethodSelectedItem,
                                        tiempoFinanc:
                                            '${(int.parse(selectedNroCuotas)) / 12} años',
                                        vlrCuota: vlrCuotaController.text,
                                        saldoTotalDate:
                                            saldoTotalDateController.text,
                                        periodoCuotas: selectedPeriodoCuotas,
                                        nroCuotas: selectedNroCuotas,
                                        tem: temController.text,
                                        observaciones:
                                            observacionesController.text,
                                        quoteStage: 'CREADA',
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
                              style: ButtonStyle(
                                  fixedSize: WidgetStateProperty.all(
                                      const Size(250, 50))),
                              onPressed: () async {
                                setState(() {
                                  vlrSeparacion = stringConverter(
                                      vlrSeparacionController.text);
                                  vlrSeparacionController.text = (currencyCOP(
                                      (vlrSeparacion.toInt()).toString()));
                                  saldoCuotaIniController.text = (currencyCOP(
                                      (saldoCI.toInt()).toString()));
                                });
                                if (selectedSeller.isEmpty ||
                                    quoteDateController.text.isEmpty ||
                                    quoteDeadlineController.text.isEmpty ||
                                    priceloteController.text.isEmpty ||
                                    vlrCuotaIniController.text.isEmpty ||
                                    vlrSeparacionController.text.isEmpty ||
                                    separacionDeadlineController.text.isEmpty ||
                                    saldoCuotaIniController.text.isEmpty ||
                                    saldoCuotaIniDeadlineController
                                        .text.isEmpty ||
                                    vlrPorPagarController.text.isEmpty ||
                                    paymentMethodSelectedItem.isEmpty ||
                                    saldoTotalDateController.text.isEmpty ||
                                    selectedNroCuotas.isEmpty ||
                                    vlrCuotaController.text.isEmpty ||
                                    idController.text.isEmpty ||
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
                                          loteInfo[2],
                                          loteInfo[1],
                                          loteInfo[7],
                                          '${((loteInfo[8].toInt()).toString())} m²',
                                          vlrBaseLote.toDouble(),
                                          precioFinal.toDouble(),
                                          discountValue(),
                                          porcCuotaInicial,
                                          cuotaInicial,
                                          vlrSeparacion,
                                          separacionDeadlineController.text,
                                          saldoSeparacion,
                                          saldoSeparacionDeadlineController
                                              .text,
                                          plazoCI,
                                          plazoContado,
                                          saldoCI,
                                          saldoCuotaIniDeadlineController.text,
                                          valorAPagar,
                                          paymentMethodSelectedItem,
                                          saldoTotalDateController.text,
                                          selectedPeriodoCuotas,
                                          int.parse(selectedNroCuotas),
                                          valorCuota,
                                          vlrTEM,
                                          observacionesController.text,
                                          idController.text,
                                          'CREADA')
                                      .then((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: CustomAlertMessage(
                                          errorTitle: "Genial!",
                                          errorText:
                                              "Datos almacenados de manera satisfactoria.",
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

  Future<void> getSeller() async {
    DocumentSnapshot? doc =
        await db.collection('sellers').doc(selectedSeller).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final temp = {
      "nameSeller": data['nameSeller'],
      "sid": doc.id,
      "lastnameSeller": data['lastnameSeller'],
      "emailSeller": data['emailSeller'],
      "phoneSeller": data['phoneSeller'],
    };
    seller = temp;
  }

  Future<List> getCuotas() async {
    List cuotas = [];
    QuerySnapshot? queryCuotas = await db
        .collection('infoProyecto')
        .doc('infopagos')
        .collection('infoCuotas')
        .get();
    for (var docCuotas in queryCuotas.docs) {
      final Map<String, dynamic> dataCuotas =
          docCuotas.data() as Map<String, dynamic>;
      final cuota = {
        "periodos": docCuotas.id,
        "dcto": dataCuotas['dcto'],
      };
      cuotas.add(cuota);
    }
    return cuotas;
  }

  Widget discountText(double discountValue) {
    if (discountValue != 0) {
      return Text(
        'Ahorro: ${currencyCOP(((vlrBaseLote - precioFinal).toInt()).toString())}',
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: successColor),
        textAlign: TextAlign.center,
      );
    } else {
      return Container();
    }
  }

  double stringConverter(String valorAConvertir) {
    String valorSinPuntos =
        valorAConvertir.replaceAll('\$', '').replaceAll('.', '');
    return double.parse(valorSinPuntos);
  }

  DateTime dateConverter(String stringAConvertir) {
    DateTime dateConverted = DateFormat('dd-MM-yyyy').parse(stringAConvertir);
    return dateConverted;
  }

  String idGenerator(int quoteCount) {
    quoteCount++;
    String idGenerated = quoteCount.toString().padLeft(5, '0');
    idGenerated = idGenerated + loteInfo[2];
    return idGenerated;
  }

  String isDiscount(double value) {
    String tempText;
    if (value != 0) {
      tempText = ' (${value.toString()}% de dcto)';
    } else {
      tempText = '';
    }
    return tempText;
  }

  void updateDateSaldo(DateTime pickedDate) {
    if (paymentMethodSelectedItem == 'Pago de contado') {
      dateSaldo = dateOnly(false, plazoContado, pickedDate, true);
    } else {
      dateSaldo = dateOnly(false, plazoCI + 30, pickedDate, true);
    }
  }

  double discountValue() {
    if (paymentMethodSelectedItem == 'Pago de contado') {
      valorAPagar = precioFinal - vlrFijoSeparacion;
      return dctoContado;
    } else {
      valorAPagar = precioFinal - cuotaInicial;
      return dctoCuotas;
    }
  }

  void getPeriodicidad() {
    if (selectedPeriodoCuotas == 'Semanal') {
      periodoNumValue = 0.25;
    }
    if (selectedPeriodoCuotas == 'Quincenal') {
      periodoNumValue = 0.5;
    }
    if (selectedPeriodoCuotas == 'Mensual') {
      periodoNumValue = 1;
    }
    if (selectedPeriodoCuotas == 'Bimestral') {
      periodoNumValue = 2;
    }
    if (selectedPeriodoCuotas == 'Trimestral') {
      periodoNumValue = 3;
    }
    if (selectedPeriodoCuotas == 'Cuatrimestral') {
      periodoNumValue = 4;
    }
    if (selectedPeriodoCuotas == 'Semestral') {
      periodoNumValue = 6;
    }
    if (selectedPeriodoCuotas == 'Anual') {
      periodoNumValue = 12;
    } else {
      periodoNumValue = periodoNumValue;
    }
  }

  List<String> nroCuotasGenerator(int n) {
    getPeriodicidad();
    n = n ~/ periodoNumValue;
    totalCuotas = n;
    List<String> tempList = [];
    for (int i = 1; i <= n; i++) {
      tempList.add('$i');
    }
    return tempList;
  }

  void periodoCalculator(double n) {
    double value = n / totalCuotas;
    if (value > 0 && value <= 0.17) {
      periodoCuotas = 1;
    } else {
      if (value > 0.17 && value <= 0.34) {
        periodoCuotas = 2;
      } else {
        if (value > 0.34 && value <= 0.53) {
          periodoCuotas = 3;
        } else {
          if (value > 0.53 && value <= 0.67) {
            periodoCuotas = 4;
          } else {
            if (value > 0.67 && value <= 0.84) {
              periodoCuotas = 5;
            } else {
              periodoCuotas = 6;
            }
          }
        }
      }
    }
  }

  Widget paymentMethod(String paymentMethodSelection) {
    if (paymentMethodSelection == 'Pago de contado') {
      return Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            SizedBox(
                height: 20,
                child: Text(
                  'Precio final${isDiscount(discountValue())}',
                  style: const TextStyle(fontSize: 14),
                )),
            SizedBox(
                height: 20,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: discountText(discountValue()),
                )),
            Container(
              child: textFieldWidget(
                  (currencyCOP(precioFinal.toInt().toString())),
                  Icons.monetization_on_outlined,
                  false,
                  precioFinalController,
                  false,
                  'number',
                  () {}),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(
                        height: 20,
                        child: Text(
                          'Valor restante a pagar',
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        )),
                    textFieldWidget(
                        (currencyCOP(valorAPagar.toInt().toString())),
                        Icons.monetization_on_outlined,
                        false,
                        vlrPorPagarController,
                        false,
                        'number',
                        () {}),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    SizedBox(
                        height: 20,
                        child: Text(
                          'Fecha límite (${plazoContado.toInt().toString()} días)',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        )),
                    Container(
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
                          textAlign: TextAlign.center,
                          cursorColor: fifthColor,
                          style: TextStyle(color: fifthColor.withOpacity(0.9)),
                          controller: saldoTotalDateController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.date_range_outlined,
                              color: fifthColor,
                            ),
                            hintText: DateFormat('dd-MM-yyyy')
                                .format(quotePickedDate),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              locale: const Locale("es", "CO"),
                              context: context,
                              initialDate:
                                  dateConverter(saldoTotalDateController.text),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2050),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dateSaldo =
                                    DateFormat('dd-MM-yyyy').format(pickedDate);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      );
    } else {
      return Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            SizedBox(
                height: 20,
                child: Text(
                  'Precio final${isDiscount(discountValue())}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                )),
            SizedBox(
                height: 20,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: discountText(discountValue()),
                )),
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: textFieldWidget(
                  (currencyCOP(precioFinal.toInt().toString())),
                  Icons.monetization_on_outlined,
                  false,
                  precioFinalController,
                  false,
                  'number',
                  () {}),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
                height: 20,
                child: Text(
                  'Cuota inicial (${((porcCuotaInicial).toInt()).toString()}%)',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                )),
            const SizedBox(
                height: 20,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Cuota inicial = Separación + Saldo cuota inicial',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                )),
            Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: textFieldWidget(
                  (currencyCOP(cuotaInicial.toInt().toString())),
                  Icons.monetization_on_outlined,
                  false,
                  vlrCuotaIniController,
                  false,
                  'number',
                  () {}),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(
                        height: 20,
                        child: Text(
                          'Saldo cuota inicial',
                          style: TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        )),
                    textFieldWidget(
                        (currencyCOP(saldoCI.toInt().toString())),
                        Icons.monetization_on_outlined,
                        false,
                        saldoCuotaIniController,
                        false,
                        'number',
                        () {}),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    SizedBox(
                        height: 20,
                        child: Text(
                          'Fecha límite (${(plazoCI).toInt().toString()} días)',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        )),
                    Container(
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
                          textAlign: TextAlign.center,
                          cursorColor: fifthColor,
                          style: TextStyle(color: fifthColor.withOpacity(0.9)),
                          controller: saldoCuotaIniDeadlineController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.date_range_outlined,
                              color: fifthColor,
                            ),
                            hintText: DateFormat('dd-MM-yyyy')
                                .format(quotePickedDate),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              locale: const Locale("es", "CO"),
                              context: context,
                              initialDate: dateConverter(
                                  saldoCuotaIniDeadlineController.text),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2050),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                saldoCuotaIniDeadlineController.text =
                                    DateFormat('dd-MM-yyyy').format(pickedDate);
                                dateSaldo =
                                    dateOnly(false, 30, pickedDate, true);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
                height: 20,
                child: Text(
                  'Valor por pagar (${((100 - porcCuotaInicial).toInt()).toString()}%)',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                )),
            textFieldWidget(
                (currencyCOP(valorAPagar.toInt().toString())),
                Icons.monetization_on_outlined,
                false,
                vlrPorPagarController,
                false,
                'number',
                () {}),
            const SizedBox(
              height: 10,
            ),
            Row(children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    const SizedBox(
                        height: 15,
                        child: Text(
                          'Valor de cada cuota',
                          style: TextStyle(fontSize: 10),
                        )),
                    textFieldWidget(
                        (currencyCOP(valorCuota.toInt().toString())),
                        Icons.monetization_on_outlined,
                        false,
                        vlrCuotaController,
                        false,
                        'number',
                        () {}),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    const SizedBox(
                        height: 15,
                        child: Text(
                          'Periodicidad',
                          style: TextStyle(fontSize: 10),
                        )),
                    easyDropdown(periodoCuotasList, selectedPeriodoCuotas,
                        (tempPeriodoCuotas) {
                      setState(() {
                        selectedPeriodoCuotas = tempPeriodoCuotas!;
                        nroCuotasGenerator(maxCuotas);
                        selectedNroCuotas = "1";
                        periodoCalculator(stringConverter(selectedNroCuotas));
                        initCuotas();
                      });
                    }),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    const SizedBox(
                        height: 15,
                        child: Text(
                          'Nro Cuotas',
                          style: TextStyle(fontSize: 10),
                        )),
                    easyDropdown(nroCuotasList, selectedNroCuotas,
                        (tempNroCuotas) {
                      setState(() {
                        selectedNroCuotas = tempNroCuotas!;
                        periodoCalculator(stringConverter(selectedNroCuotas));
                        initCuotas();
                      });
                    }),
                  ],
                ),
              ),
            ]),
            Row(children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(
                        height: 15,
                        child: Text(
                          'Intereses',
                          style: TextStyle(fontSize: 10),
                        )),
                    textFieldWidget(
                        '${(vlrTEM.toString())} %',
                        Icons.percent_outlined,
                        false,
                        temController,
                        false,
                        'number',
                        () {}),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(
                        height: 15,
                        child: Text(
                          'A partir de',
                          style: TextStyle(fontSize: 10),
                        )),
                    Container(
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
                          textAlign: TextAlign.center,
                          cursorColor: fifthColor,
                          style: TextStyle(color: fifthColor.withOpacity(0.9)),
                          controller: saldoTotalDateController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.date_range_outlined,
                              color: fifthColor,
                            ),
                            hintText: DateFormat('dd-MM-yyyy')
                                .format(quotePickedDate),
                          ),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              locale: const Locale("es", "CO"),
                              context: context,
                              initialDate:
                                  dateConverter(saldoTotalDateController.text),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2050),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                dateSaldo =
                                    DateFormat('dd-MM-yyyy').format(pickedDate);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      );
    }
  }

  State<StatefulWidget> createState() => throw UnimplementedError();
}
