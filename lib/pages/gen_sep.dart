import 'package:albaterrapp/pages/pdf_separacion.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_typeahead/flutter_typeahead.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class GenerarSeparacion extends StatefulWidget {
  const GenerarSeparacion({Key? key}) : super(key: key);

  @override
  State<GenerarSeparacion> createState() => _GenerarSeparacionState();
}

class _GenerarSeparacionState extends State<GenerarSeparacion> {
  // ignore: prefer_typing_uninitialized_variables
  var timer;

  @override
  void initState() {
    super.initState();
    initPagos();
    initCuotas();
    initSeller();
    initOcup();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        realtimeDateTime = dateOnly(true, 0, DateTime.now(), false);
      });
    });
    updateNumberWords();
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

  double periodoNumValue = 0;
  Map<String, dynamic> infoPagos = {};
  late int quoteCounter;
  late String qid;
  DateTime quotePickedDate = DateTime.now();
  DateTime sepPickedDate = DateTime.now();
  List<dynamic> loteInfo = [];
  Map<String, dynamic> seller = {};
  List<dynamic> ocupacionList = [];
  String realtimeDateTime = '';
  int totalCuotas = 0;

  double precioFinal = 0;
  double vlrSeparacion = 0;
  double vlrFijoSeparacion = 0;
  double saldoSeparacion = 0;
  double porcCuotaInicial = 0;
  double plazoCI = 0;
  double plazoContado = 0;
  double vlrTEM = 0;
  double dctoContado = 0;
  double dctoCuotas = 0;
  double nroCuotas = 1;
  int maxCuotas = 1;
  double cuotaInicial = 0;
  int periodoCuotas = 1;
  double plazoSaldoSep = 0;

  Future<void> initPagos() async {
    infoPagos = await getInfoProyecto();
    porcCuotaInicial = infoPagos['cuotaInicial'].toDouble();
    plazoCI = infoPagos['plazoCuotaInicial'].toDouble();
    vlrTEM = infoPagos['tem'].toDouble();
    dctoContado = infoPagos['dctoContado'].toDouble();
    plazoContado = infoPagos['plazoContado'].toDouble();
    maxCuotas = infoPagos['maxCuotas'].toInt();
    plazoSaldoSep = infoPagos['plazoSaldoSep'].toDouble();
    nroCuotasList = nroCuotasGenerator(maxCuotas);
    totalSeparacionController.text =
        (currencyCOP((vlrFijoSeparacion.toInt()).toString()));

    getSeller();
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
  Stream<QuerySnapshot>? citiesStream;
  Stream<QuerySnapshot>? sellerStream;
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('quotes');

  TextEditingController letrasPrecioFinalController =
      TextEditingController(text: "");
  TextEditingController letrasSepController = TextEditingController(text: "");
  TextEditingController letrasSaldoCIController =
      TextEditingController(text: "");
  TextEditingController letrasSaldoLoteController =
      TextEditingController(text: "");
  TextEditingController letrasValorCuotasController =
      TextEditingController(text: "");
  TextEditingController letrasVlrPorPagarController =
      TextEditingController(text: "");

  String selectedSeller = 'Seleccione un vendedor';
  String sellerName = '';
  String sellerEmail = '';
  String sellerPhone = '';
  TextEditingController quoteIdController = TextEditingController(text: "");
  TextEditingController quoteDateController = TextEditingController(text: "");
  TextEditingController quoteDeadlineController =
      TextEditingController(text: "");
  String loteId = "";
  TextEditingController loteController = TextEditingController(text: "");
  TextEditingController etapaloteController = TextEditingController(text: "");
  TextEditingController arealoteController = TextEditingController(text: "");
  TextEditingController priceloteController = TextEditingController(text: "");
  TextEditingController precioFinalController = TextEditingController(text: "");
  TextEditingController porcCuotaInicialController =
      TextEditingController(text: "");
  TextEditingController vlrCuotaIniController = TextEditingController(text: "");
  TextEditingController totalSeparacionController =
      TextEditingController(text: "");
  TextEditingController vlrSeparacionController =
      TextEditingController(text: "");
  TextEditingController saldoSeparacionController =
      TextEditingController(text: "");
  TextEditingController separacionDeadlineController =
      TextEditingController(text: "");
  TextEditingController saldoSeparacionDeadlineController =
      TextEditingController(text: "");
  TextEditingController saldoCuotaIniController =
      TextEditingController(text: "");
  TextEditingController saldoCuotaIniDeadlineController =
      TextEditingController(text: "");

  TextEditingController vlrPorPagarController = TextEditingController(text: "");
  TextEditingController saldoTotalDateController =
      TextEditingController(text: "");
  TextEditingController vlrCuotaController = TextEditingController(text: "");
  TextEditingController temController = TextEditingController(text: "");
  TextEditingController observacionesController =
      TextEditingController(text: "");
  TextEditingController quoteStageController = TextEditingController(text: "");

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
  int auxn = 0;
  int nAux = 0;

  @override
  Widget build(BuildContext context) {
    initOcup();
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (isInitialized == false) {
      initPagos();
      selectedSeller = arguments['selectedSeller'];
      sellerName = arguments['sellerName'];
      sellerEmail = arguments['sellerEmail'];
      sellerPhone = arguments['sellerPhone'];
      quoteIdController.text = arguments['quoteId'];
      quotePickedDate =
          DateFormat("dd-MM-yyyy").parse(arguments['separacionDeadline']);
      quoteDateController.text = arguments['quoteDate'];
      quoteDeadlineController.text = arguments['quoteDeadline'];
      loteId = arguments['loteId'];
      loteController.text = arguments['lote'];
      etapaloteController.text = arguments['etapalote'];
      arealoteController.text = arguments['arealote'];
      priceloteController.text = arguments['pricelote'];
      precioFinalController.text = arguments['precioFinal'];
      paymentMethodSelectedItem = arguments['paymentMethod'];
      porcCuotaInicialController.text = arguments['porcCuotaInicial'];
      vlrCuotaIniController.text = arguments['vlrCuotaIni'];
      selectedPeriodoCuotas = arguments['periodoCuotas'];
      selectedNroCuotas = arguments['nroCuotas'];
      vlrSeparacionController.text = arguments['vlrSeparacion'];
      saldoSeparacionController.text = arguments['saldoSeparacion'];
      saldoSeparacion = stringConverter(saldoSeparacionController.text);
      separacionDeadlineController.text = arguments['separacionDeadline'];
      saldoSeparacionDeadlineController.text =
          arguments['saldoSeparacionDeadline'];
      saldoCuotaIniController.text = arguments['saldoCuotaIni'];
      saldoCuotaIniDeadlineController.text = arguments['saldoCuotaIniDeadline'];
      vlrPorPagarController.text = arguments['vlrPorPagar'];
      saldoTotalDateController.text = arguments['saldoTotalDate'];
      vlrCuotaController.text = arguments['vlrCuota'];
      temController.text = arguments['tem'];
      observacionesController.text = arguments['observaciones'];
      quoteStageController.text = arguments['quoteStage'];
      nameController.text = arguments['name'];
      lastnameController.text = arguments['lastname'];
      selectedGender = arguments['gender'];
      birthdayController.text = arguments['birthday'];
      ocupacionController.text = arguments['ocupacion'];
      phoneController.text = arguments['phone'];
      idtypeController.text = arguments['idtype'];
      idController.text = arguments['id'];
      selectedIssuedCountry = arguments['issuedCountry'];
      selectedIssuedState = arguments['issuedState'];
      selectedIssuedCity = arguments['issuedCity'];
      emailController.text = arguments['email'];
      addressController.text = arguments['address'];
      selectedCountry = arguments['country'];
      selectedState = arguments['state'];
      selectedCity = arguments['city'];
      vlrFijoSeparacion =
          saldoSeparacion + stringConverter(vlrSeparacionController.text);
      periodoCalculator(stringConverter(selectedNroCuotas));
      initCuotas();
      updateNumberWords();
    } else {
      isInitialized = true;
    }
    sellerStream = FirebaseFirestore.instance
        .collection('sellers')
        .orderBy('lastnameSeller')
        .snapshots();
    getSeller();
    initCuotas();
    nroCuotasList = nroCuotasGenerator(maxCuotas);
    periodoCalculator(stringConverter(selectedNroCuotas));
    vlrBaseLote = stringConverter(priceloteController.text).toInt();
    precioFinal = vlrBaseLote * ((100 - discountValue()) / 100);
    cuotaInicial = precioFinal * (porcCuotaInicial / 100);
    saldoCI = cuotaInicial - vlrFijoSeparacion;
    valorCuota = valorAPagar / (double.parse(selectedNroCuotas));

    if (nAux <= 5) {
      updateDateSaldo(quotePickedDate);
      nAux++;
    }

    priceloteController.text = (currencyCOP((vlrBaseLote.toInt()).toString()));
    precioFinalController.text =
        (currencyCOP((precioFinal.toInt()).toString()));
    vlrCuotaIniController.text =
        (currencyCOP((cuotaInicial.toInt()).toString()));
    saldoCuotaIniController.text = (currencyCOP((saldoCI.toInt()).toString()));
    vlrCuotaController.text = (currencyCOP((valorCuota.toInt()).toString()));
    vlrPorPagarController.text =
        (currencyCOP((valorAPagar.toInt()).toString()));
    temController.text = '${vlrTEM.toString()}%';
    saldoTotalDateController.text = dateSaldo;

    if (auxn < 10) {
      updateNumberWords();
      auxn++;
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
          'Orden de separación',
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
                    SizedBox(
                      height: 15,
                      child: Center(
                          child: Text('COTIZACIÓN #${quoteIdController.text}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ))),
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
                                        loteController.text,
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
                                        etapaloteController.text,
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
                                        arealoteController.text,
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
                    SizedBox(
                        height: 25,
                        child: Text(
                          'Precio final${isDiscount(discountValue())}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                        height: 20,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: discountText(discountValue()),
                        )),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: textFieldWidget(
                              (currencyCOP((precioFinal.toInt()).toString())),
                              Icons.monetization_on_outlined,
                              false,
                              precioFinalController,
                              false,
                              'number',
                              () {},
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: textFieldWidget(
                                "Valor en letras",
                                Icons.abc_outlined,
                                false,
                                letrasPrecioFinalController,
                                true,
                                'name',
                                () {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //Separacion
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          const SizedBox(
                              height: 25,
                              child: Text(
                                'Separación',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              )),
                          const SizedBox(
                              height: 20,
                              child: Text(
                                'Fecha de separacion)',
                                style: TextStyle(fontSize: 14),
                              )),
                          const SizedBox(
                            height: 10,
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
                                controller: separacionDeadlineController,
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
                                        separacionDeadlineController.text),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2050),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      separacionDeadlineController.text =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                      saldoSeparacionDeadlineController.text =
                                          dateOnly(false, plazoSaldoSep,
                                              pickedDate, false);
                                      saldoCuotaIniDeadlineController.text =
                                          dateOnly(
                                              false, plazoCI, pickedDate, true);
                                      updateDateSaldo(pickedDate);
                                      discountValue();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                              height: 15,
                              child: Text(
                                'Valor de separación',
                                style: TextStyle(fontSize: 14),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: textFieldWidget(
                                  (currencyCOP(
                                      (vlrFijoSeparacion.toInt()).toString())),
                                  Icons.monetization_on_outlined,
                                  false,
                                  totalSeparacionController,
                                  false,
                                  'number',
                                  () {},
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: textFieldWidget(
                                    "Valor en letras",
                                    Icons.abc_outlined,
                                    false,
                                    letrasSepController,
                                    true,
                                    'name',
                                    () {}),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        alignment: Alignment.center,
                        child: const Text('Método de pago',
                            style: TextStyle(
                              fontSize: 16,
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
                          updateDateSaldo(
                              dateConverter(separacionDeadlineController.text));
                          discountValue();
                          updateNumberWords();
                        });
                      }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //Financiación directa
                    paymentMethodSeparacion(paymentMethodSelectedItem),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        alignment: Alignment.center,
                        child: const Text('Asesor comercial',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ))),
                    const SizedBox(
                      height: 10,
                    ),
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
                          const SizedBox(
                            height: 15,
                            child: Text(
                              'Valor total de separación',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                          Container(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: textFieldWidget(
                                  (currencyCOP(
                                      (vlrFijoSeparacion.toInt()).toString())),
                                  Icons.monetization_on_outlined,
                                  false,
                                  totalSeparacionController,
                                  true,
                                  'number', ((String value) {
                                setState(() {
                                  vlrFijoSeparacion = stringConverter(value);
                                  vlrSeparacion = stringConverter(value);
                                  saldoSeparacion =
                                      stringConverter(value) - vlrSeparacion;
                                  vlrSeparacionController.text = (currencyCOP(
                                      (vlrSeparacion.toInt()).toString()));
                                  saldoSeparacionController.text = (currencyCOP(
                                      (saldoSeparacion.toInt()).toString()));
                                  saldoCI =
                                      cuotaInicial - stringConverter(value);
                                  saldoCuotaIniController.text = (currencyCOP(
                                      (saldoCI.toInt()).toString()));
                                  totalSeparacionController.value =
                                      TextEditingValue(
                                    text: (currencyCOP(
                                        (vlrFijoSeparacion.toInt())
                                            .toString())),
                                    selection: TextSelection.collapsed(
                                        offset: (currencyCOP(
                                                (vlrFijoSeparacion.toInt())
                                                    .toString()))
                                            .length),
                                  );
                                  updateNumberWords();
                                });
                              }))),
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
                                            'Valor inicial',
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
                                              stringConverter(value) <=
                                                  vlrFijoSeparacion) {
                                            setState(() {
                                              vlrSeparacion =
                                                  stringConverter(value);
                                              saldoSeparacion =
                                                  vlrFijoSeparacion -
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
                                              updateNumberWords();
                                            });
                                          }
                                          if (stringConverter(value) >=
                                              vlrFijoSeparacion) {
                                            setState(() {
                                              vlrSeparacion = vlrFijoSeparacion;
                                              vlrSeparacionController.text =
                                                  vlrFijoSeparacion
                                                      .toInt()
                                                      .toString();
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
                                              updateNumberWords();
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
                                'email',
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
                                  fixedSize: MaterialStateProperty.all(
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
                                    selectedCity.isEmpty ||
                                    letrasPrecioFinalController.text.isEmpty ||
                                    letrasSepController.text.isEmpty ||
                                    letrasSaldoLoteController.text.isEmpty ||
                                    letrasValorCuotasController.text.isEmpty ||
                                    letrasVlrPorPagarController.text.isEmpty) {
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
                                  updateNumberWords();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFSeparacion(
                                        sellerID: selectedSeller,
                                        sellerName:
                                            '${seller['nameSeller']} ${seller['lastnameSeller']}',
                                        sellerPhone: seller['phoneSeller'],
                                        sellerEmail: seller['emailSeller'],
                                        quoteId: quoteIdController.text,
                                        name: nameController.text,
                                        idCust: idController.text,
                                        idTypeCust: selectedItemIdtype,
                                        lastname: lastnameController.text,
                                        phone: phoneController.text,
                                        address: addressController.text,
                                        email: emailController.text,
                                        city: selectedCity,
                                        date: quoteDateController.text,
                                        dueDate: quoteDeadlineController.text,
                                        lote: loteController.text,
                                        area: arealoteController.text,
                                        price: priceloteController.text,
                                        finalPrice: precioFinalController.text,
                                        letrasFinalPrice:
                                            letrasPrecioFinalController.text,
                                        porcCuotaIni:
                                            '${((porcCuotaInicial.toInt()).toString())}%',
                                        vlrCuotaIni: vlrCuotaIniController.text,
                                        totalSeparacion:
                                            totalSeparacionController.text,
                                        letrasSeparacion:
                                            letrasSepController.text,
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
                                        letrasSaldoCI:
                                            letrasSaldoCIController.text,
                                        saldoCI: saldoCuotaIniController.text,
                                        dueDateSaldoCI:
                                            saldoCuotaIniDeadlineController
                                                .text,
                                        porcPorPagar:
                                            '${(((100 - porcCuotaInicial).toInt()).toString())}%',
                                        vlrPorPagar: vlrPorPagarController.text,
                                        letrasSaldoTotal:
                                            letrasSaldoLoteController.text,
                                        paymentMethod:
                                            paymentMethodSelectedItem,
                                        tiempoFinanc:
                                            '${(int.parse(selectedNroCuotas)) / 12} años',
                                        vlrCuota: vlrCuotaController.text,
                                        letrasVlrCuota:
                                            letrasValorCuotasController.text,
                                        letrasSaldoContado:
                                            letrasVlrPorPagarController.text,
                                        saldoTotalDate:
                                            saldoTotalDateController.text,
                                        periodoCuotas: selectedPeriodoCuotas,
                                        nroCuotas: selectedNroCuotas,
                                        tem: '${temController.text}%',
                                        observaciones:
                                            observacionesController.text,
                                        quoteStage: quoteStageController.text,
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
                                  fixedSize: MaterialStateProperty.all(
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
                                  await updateCustomer(
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
                                  await updateQuote(
                                      quoteIdController.text,
                                      selectedSeller,
                                      quoteDateController.text,
                                      quoteDeadlineController.text,
                                      loteId,
                                      loteController.text,
                                      etapaloteController.text,
                                      arealoteController.text,
                                      vlrBaseLote.toDouble(),
                                      precioFinal,
                                      discountValue(),
                                      porcCuotaInicial,
                                      cuotaInicial,
                                      vlrSeparacion,
                                      separacionDeadlineController.text,
                                      saldoSeparacion,
                                      saldoSeparacionDeadlineController.text,
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
                                      quoteStageController.text);
                                  await addOrdenSep(
                                    "SEP${quoteIdController.text}",
                                    quoteIdController.text,
                                    selectedSeller,
                                    loteId,
                                    vlrBaseLote.toDouble(),
                                    precioFinal,
                                    discountValue(),
                                    porcCuotaInicial,
                                    cuotaInicial,
                                    vlrSeparacion,
                                    separacionDeadlineController.text,
                                    saldoSeparacion,
                                    saldoSeparacionDeadlineController.text,
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
                                  );
                                  cambioEstadoLote(
                                          loteId, quoteStageController.text)
                                      .then((_) {
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
                                "Guardar orden de separación",
                                textAlign: TextAlign.center,
                              ),
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

  Widget paymentMethodSeparacion(String paymentMethodSelection) {
    if (paymentMethodSelection == 'Pago de contado') {
      return Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(children: [
            const SizedBox(
                height: 25,
                child: Text(
                  'Valor restante a pagar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )),
            SizedBox(
                height: 20,
                child: Text(
                  'Fecha límite (${(plazoContado).toInt().toString()} días)',
                  style: const TextStyle(fontSize: 14),
                )),
            const SizedBox(
              height: 10,
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
                  style: TextStyle(color: fifthColor.withOpacity(0.9)),
                  controller: saldoTotalDateController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.date_range_outlined,
                      color: fifthColor,
                    ),
                    hintText: DateFormat('dd-MM-yyyy').format(quotePickedDate),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      locale: const Locale("es", "CO"),
                      context: context,
                      initialDate: dateConverter(saldoTotalDateController.text),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2050),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dateSaldo = DateFormat('dd-MM-yyyy').format(pickedDate);
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
                height: 20,
                child: Text(
                  'Saldo total',
                  style: TextStyle(fontSize: 14),
                )),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: textFieldWidget(
                      (currencyCOP(valorAPagar.toInt().toString())),
                      Icons.monetization_on_outlined,
                      false,
                      vlrPorPagarController,
                      false,
                      'number',
                      () {}),
                ),
                Expanded(
                  flex: 7,
                  child: textFieldWidget("Valor en letras", Icons.abc_outlined,
                      false, letrasVlrPorPagarController, true, 'name', () {}),
                ),
              ],
            ),
          ]));
    } else {
      return Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            const SizedBox(
                height: 25,
                child: Text(
                  'Cuota inicial',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )),
            SizedBox(
                height: 20,
                child: Text(
                  'Fecha límite (${(plazoCI).toInt().toString()} días)',
                  style: const TextStyle(fontSize: 14),
                )),
            const SizedBox(
              height: 10,
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
                  style: TextStyle(color: fifthColor.withOpacity(0.9)),
                  controller: saldoCuotaIniDeadlineController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.date_range_outlined,
                      color: fifthColor,
                    ),
                    hintText: DateFormat('dd-MM-yyyy').format(quotePickedDate),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      locale: const Locale("es", "CO"),
                      context: context,
                      initialDate:
                          dateConverter(saldoCuotaIniDeadlineController.text),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2050),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        saldoCuotaIniDeadlineController.text =
                            DateFormat('dd-MM-yyyy').format(pickedDate);
                        dateSaldo = dateOnly(false, 30, pickedDate, true);
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
                height: 20,
                child: Text(
                  'Saldo cuota inicial',
                  style: TextStyle(fontSize: 14),
                )),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: textFieldWidget(
                      (currencyCOP(saldoCI.toInt().toString())),
                      Icons.monetization_on_outlined,
                      false,
                      saldoCuotaIniController,
                      false,
                      'number',
                      () {}),
                ),
                Expanded(
                  flex: 7,
                  child: textFieldWidget("Valor en letras", Icons.abc_outlined,
                      false, letrasSaldoCIController, true, 'name', () {}),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
                height: 25,
                child: Text(
                  'Saldo total',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                )),
            SizedBox(
                height: 20,
                child: Text(
                  'Valor a financiar (${((100 - porcCuotaInicial).toInt()).toString()}%)',
                  style: const TextStyle(fontSize: 14),
                )),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: textFieldWidget(
                      (currencyCOP(valorAPagar.toInt().toString())),
                      Icons.monetization_on_outlined,
                      false,
                      vlrPorPagarController,
                      false,
                      'number',
                      () {}),
                ),
                Expanded(
                  flex: 7,
                  child: textFieldWidget("Valor en letras", Icons.abc_outlined,
                      false, letrasSaldoLoteController, true, 'name', () {}),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: SizedBox(
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            'repartido en  ',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.right,
                          ),
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: easyDropdown(nroCuotasList, selectedNroCuotas,
                        (tempNroCuotas) {
                      setState(() {
                        selectedNroCuotas = tempNroCuotas!;
                        periodoCalculator(stringConverter(selectedNroCuotas));
                        initCuotas();
                        updateNumberWords();
                      });
                    }),
                  ),
                  const Expanded(
                    flex: 3,
                    child: SizedBox(
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'cuotas',
                            style: TextStyle(fontSize: 14),
                          ),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: SizedBox(
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            'con periodicidad  ',
                            style: TextStyle(fontSize: 14),
                            textAlign: TextAlign.right,
                          ),
                        )),
                  ),
                  Expanded(
                    flex: 3,
                    child:
                        easyDropdown(periodoCuotasList, selectedPeriodoCuotas,
                            (tempPeriodoCuotas) {
                      setState(() {
                        selectedPeriodoCuotas = tempPeriodoCuotas!;
                        nroCuotasGenerator(maxCuotas);
                        selectedNroCuotas = "1";
                        periodoCalculator(stringConverter(selectedNroCuotas));
                        initCuotas();
                        updateNumberWords();
                      });
                    }),
                  ),
                  const Expanded(
                    flex: 2,
                    child: SizedBox(
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'y valor de',
                            style: TextStyle(fontSize: 14),
                          ),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: textFieldWidget(
                      (currencyCOP(valorCuota.toInt().toString())),
                      Icons.monetization_on_outlined,
                      false,
                      vlrCuotaController,
                      false,
                      'number',
                      () {}),
                ),
                Expanded(
                  flex: 7,
                  child: textFieldWidget("Valor en letras", Icons.abc_outlined,
                      false, letrasValorCuotasController, true, 'name', () {}),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
                height: 20,
                child: Text(
                  'Con fecha de inicio',
                  style: TextStyle(fontSize: 14),
                )),
            const SizedBox(
              height: 10,
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
                  style: TextStyle(color: fifthColor.withOpacity(0.9)),
                  controller: saldoTotalDateController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.date_range_outlined,
                      color: fifthColor,
                    ),
                    hintText: DateFormat('dd-MM-yyyy').format(quotePickedDate),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      locale: const Locale("es", "CO"),
                      context: context,
                      initialDate: dateConverter(saldoTotalDateController.text),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2050),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dateSaldo = DateFormat('dd-MM-yyyy').format(pickedDate);
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
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
                        updateNumberWords();
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
                        updateNumberWords();
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
                    textFieldWidget(
                        dateOnly(false, (plazoCI) + 30, quotePickedDate, true),
                        Icons.date_range_outlined,
                        false,
                        saldoTotalDateController,
                        false,
                        'date',
                        () {}),
                  ],
                ),
              ),
            ]),
          ],
        ),
      );
    }
  }

  void updateNumberWords() async {
    letrasSepController.text = await numeroEnLetras(vlrFijoSeparacion, 'pesos');
    letrasSaldoCIController.text = await numeroEnLetras(saldoCI, 'pesos');
    letrasSaldoLoteController.text = await numeroEnLetras(valorAPagar, 'pesos');
    letrasValorCuotasController.text =
        await numeroEnLetras(valorCuota, 'pesos');
    letrasVlrPorPagarController.text =
        await numeroEnLetras(valorAPagar, 'pesos');
    letrasPrecioFinalController.text =
        await numeroEnLetras(precioFinal, 'pesos');
  }

  State<StatefulWidget> createState() => throw UnimplementedError();
}
