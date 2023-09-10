import 'dart:async';
import 'package:albaterrapp/pages/archived_quotes.dart';
import 'package:albaterrapp/pages/pdf_generator.dart';
import 'package:albaterrapp/pages/pdf_promesa.dart';
import 'package:albaterrapp/pages/pdf_separacion.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class ExistingQuotes extends StatefulWidget {
  final List<dynamic> loteInfo;
  final bool needAll;
  final String loggedEmail;
  const ExistingQuotes(
      {Key? key,
      required this.loteInfo,
      required this.needAll,
      required this.loggedEmail})
      : super(key: key);

  @override
  State<ExistingQuotes> createState() => _ExistingQuotesState();
}

class _ExistingQuotesState extends State<ExistingQuotes> {
  int _selectedIndex = 0;
  // ignore: prefer_typing_uninitialized_variables
  var timer;
  
  @override
  void initState() {
    super.initState();
    loteInfo = widget.loteInfo;
    needAll = widget.needAll;
    loggedEmail = widget.loggedEmail;
    loggedManager();
    getSellerId(loggedEmail);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }


  void loggedManager() async {
    managerLogged = await isManager(loggedEmail);
  }

  Future<bool> isManager(String value) async {
    String mainValue = await getGerenteEmail();
    if (value == mainValue || value == 'javieruedase@gmail.com') {
      return true;
    } else {
      return false;
    }
  }
  

  Future<void> getSellerId(String emailSeller) async {    
    final querySnapshot = await db.collection('sellers').where('emailSeller', isEqualTo: emailSeller).get();
    if (querySnapshot.docs.isNotEmpty) {
      final selectedSeller = querySnapshot.docs.first;
      identifiedSeller = selectedSeller['roleSeller'] == 'Asesor comercial' ? selectedSeller.id : 'All';
    } else {
      identifiedSeller = 'All';
    }
  }

  Future<void> llenarInstallments(String loteSel) async {
    CollectionReference collection = FirebaseFirestore.instance.collection('planPagos').doc(loteSel).collection('pagosEsperados');

    // Fetch the documents
    QuerySnapshot querySnapshot = await collection.get();

    // Process each document
    for (var doc in querySnapshot.docs) {
      // Check if the document ID contains 'SEP' or 'TOTAL'
      if (!doc.id.contains('SEP') && !doc.id.contains('TOTAL')) {
        // Extract the fields from the document data
        String conceptoPago = doc.get('conceptoPago');
        String fechaPago = doc.get('fechaPago');
        double valorPago = doc.get('valorPago').toDouble();

        // Create a map for each document, including the document ID
        Map<String, dynamic> installment = {
          'id': doc.id,
          'conceptoPago': conceptoPago,
          'fechaPago': fechaPago,
          'valorPago': valorPago,
        };

        // Add the map to the installments list
        installments.add(installment);
      }
    }
  }

  List<Map<String, dynamic>> installments = [];
  double remainingAmount = 0;
  double totalInstallmentAmount = 0;
  DateTime lastDate = DateTime.now();
  Color amountColor = Colors.black;
  void completo = false;

  Future<String> getGerenteEmail() async {
    final gerenteEmail = await db
        .collection('infoproyecto')
        .doc('infoGeneral')
        .collection('gerenteProyecto')
        .doc('victorOrostegui')
        .get();
    return gerenteEmail.get('email') as String;
  }

  Future<void> updateLoteInfo(String loteId) async {
  loteClicked = await getLoteInfo(loteId);
}

  Map<String, dynamic> loteClicked = {};
  List<dynamic> loteInfo = [];
  bool needAll = true;
  String loggedEmail = '';
  bool managerLogged = false;
  String identifiedSeller = '';
  String letrasSep = '';
  String letrasSaldoCI = '';
  String letrasSaldoLote = '';
  String letrasValorCuotas = '';
  String letrasVlrPorPagar = '';
  String letrasPrecioFinal = '';
  int vlrFijoSep = 0;
  // ignore: prefer_final_fields
  TextEditingController _observacionesController = TextEditingController(text: '');

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          titleTextString(_selectedIndex),
          style: TextStyle(
              color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          Visibility(
            visible: _selectedIndex == 0,
            child: Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ArchivedQuotes(
                                  loteInfo: loteInfo,
                                  needAll: true,
                                  loggedEmail: loggedEmail,
                                )));
                    setState(() {});
                  },
                  child: const Icon(Icons.archive_outlined),
                )),
          ),
        ],
      ),
      body: Center(
        child: selectedWidget(_selectedIndex, context),
      ),
      bottomNavigationBar: needAll
          ? BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.document_scanner_outlined),
                  label: 'Cotizaciones',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.task_outlined),
                  label: 'Separaciones',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.handshake_outlined),
                  label: 'Promesas',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: (int index) {
                setState(
                  () {
                    _selectedIndex = index;
                  },
                );
              },
            )
          : Visibility(visible: false, child: Container(),),
    );
  }

  String titleTextString(int selOpt) {
    if (selOpt == 0) {
      return 'Cotizaciones existentes${loteVerifier(needAll)}';
    } if (selOpt == 1) {
      return 'Separaciones existentes${loteVerifier(needAll)}';
    } else {
      return '';
    }
  }

  Widget selectedWidget(int selOpt, context) {
    if (selOpt == 0) {
      return widgetCotizaciones(context);
    } if (selOpt == 1) {
      return widgetSeparaciones(context);
    } else {
      return Container();
    }
  }

  Container widgetCotizaciones(context) {   
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: FutureBuilder(
          future: getQuotes(loteInfo[1], needAll, true, identifiedSeller),
          builder: ((context, quotesSnapshot) {
            if (quotesSnapshot.hasData) {
              return ListView.builder(
                itemCount: quotesSnapshot.data?.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: db
                          .collection('customers')
                          .doc(quotesSnapshot.data?[index]['clienteID'])
                          .get(),
                      builder: ((context, custSnapshot) {
                        if (custSnapshot.hasData) {
                          final custData =
                              custSnapshot.data?.data() as Map<String, dynamic>;
                          final name = custData['nameCliente'] ?? '';
                          final lastName = custData['lastnameCliente'] ?? '';
                          final fullName = '$lastName $name';
                          return FutureBuilder(
                              future: db
                                  .collection('sellers')
                                  .doc(quotesSnapshot.data?[index]['sellerID'])
                                  .get(),
                              builder: ((context, sellerSnapshot) {
                                if (sellerSnapshot.hasData) {
                                  final sellerData = sellerSnapshot.data?.data()
                                      as Map<String, dynamic>;
                                  return Dismissible(
                                    onDismissed: (direction) async {
                                      await archiveQuote(
                                          quotesSnapshot.data?[index]['qid']);                                      
                                      setState(() {
                                        quotesSnapshot.data?.removeAt(index);
                                      });
                                    },
                                    confirmDismiss: (direction) async {
                                      bool result = false;
                                      result = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  "Esta seguro de archivar la cotizacion #${quotesSnapshot.data?[index]['qid']}?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      return Navigator.pop(
                                                        context,
                                                        false,
                                                      );
                                                    },
                                                    child: const Text(
                                                      "Cancelar",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )),
                                                TextButton(
                                                  onPressed: () {
                                                    return Navigator.pop(
                                                        context, true);
                                                  },
                                                  child: const Text(
                                                      "Si, estoy seguro"),
                                                ),
                                              ],
                                            );
                                          });
                                      return result;
                                    },
                                    background: Container(
                                      color: Colors.red,
                                      child: const Icon(Icons.delete),
                                    ),
                                    direction: DismissDirection.endToStart,
                                    key: Key(quotesSnapshot.data?[index]['qid']),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                          backgroundColor: stageColor(quotesSnapshot.data?[index]['quoteStage']),
                                          child: Text(
                                            getNumbers(quotesSnapshot.data?[index]['loteId'])!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      title: Text(
                                          'Cotización #${quotesSnapshot.data?[index]['qid']} | ${quotesSnapshot.data?[index]['quoteStage']}'),
                                      subtitle: Text('Cliente: $fullName'),
                                      trailing: PopupMenuButton<String>(
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'Opción 1',
                                            child: Text('Editar cotización'),
                                          ),
                                          PopupMenuItem(
                                            enabled: (managerLogged  && quotesSnapshot.data?[index]
                                                        ['quoteStage'] !=
                                                    'LOTE SEPARADO'),
                                            value: 'Opción 2',
                                            child: Text(quotesSnapshot.data?[index]
                                                        ['quoteStage'] ==
                                                    'LOTE SEPARADO'
                                                ? 'Cancelar separación'
                                                : changeState(quotesSnapshot
                                                .data?[index]['quoteStage'])),
                                          ),
                                        ],
                                        onSelected: (value) async {
                                          await updateLoteInfo(quotesSnapshot.data?[index]['loteId']);                                          
                                          if (value == 'Opción 1') {
                                            if (managerLogged == true) {
                                              if(loteClicked['loteState'] != 'Disponible') {
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: CustomAlertMessage(
                                                      errorTitle: "Oops!",
                                                      errorText:
                                                          "Parece que este lote ya tiene dueño",
                                                      stateColor: Color.fromRGBO(214, 66, 66, 1),
                                                    ),
                                                    behavior: SnackBarBehavior.floating,
                                                    backgroundColor: Colors.transparent,
                                                    elevation: 0,
                                                  ),
                                                );
                                              } else{
                                              // ignore: use_build_context_synchronously
                                                Navigator.pushNamed(
                                                  context, "/editQuote",
                                                  arguments: {
                                                    "selectedSeller": quotesSnapshot
                                                        .data?[index]['sellerID'],
                                                    "sellerName":
                                                        '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                                    "sellerEmail":
                                                        sellerData['emailSeller'],
                                                    "sellerPhone":
                                                        sellerData['phoneSeller'],
                                                    "quoteId": quotesSnapshot.data?[index]
                                                        ['qid'],
                                                    "quoteDate": quotesSnapshot
                                                        .data?[index]['quoteDate'],
                                                    "quoteDeadline":
                                                        quotesSnapshot.data?[index]
                                                            ['quoteDLDate'],
                                                    "loteId": quotesSnapshot.data?[index]
                                                        ['loteId'],
                                                    "lote": quotesSnapshot.data?[index]
                                                        ['loteName'],
                                                    "etapalote": quotesSnapshot
                                                        .data?[index]['etapaLote'],
                                                    "arealote": quotesSnapshot
                                                        .data?[index]['areaLote'],
                                                    "pricelote": (currencyCOP(
                                                        (quotesSnapshot.data?[index]
                                                                    ['priceLote']
                                                                .toInt())
                                                            .toString())),
                                                    "precioFinal": (currencyCOP(
                                                        (quotesSnapshot.data?[index]
                                                                    ['precioFinal']
                                                                .toInt())
                                                            .toString())),
                                                    "paymentMethod":
                                                        quotesSnapshot.data?[index]
                                                            ['metodoPagoLote'],
                                                    "porcCuotaInicial":
                                                        '${quotesSnapshot.data?[index]['perCILote'].toString()}%',
                                                    "vlrCuotaIni": (currencyCOP(
                                                        (quotesSnapshot.data?[index]
                                                                    ['vlrCILote']
                                                                .toInt())
                                                            .toString())),
                                                    "periodoCuotas":
                                                        quotesSnapshot.data?[index]
                                                            ['periodoCuotasLote'],
                                                    "nroCuotas":
                                                        '${quotesSnapshot.data?[index]['nroCuotasLote'].toString()}',
                                                    "vlrSeparacion": (currencyCOP(
                                                        (quotesSnapshot.data?[index]
                                                                    ['vlrSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoSeparacion": (currencyCOP(
                                                        (quotesSnapshot.data?[index]
                                                                    ['saldoSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    "separacionDeadline": quotesSnapshot
                                                        .data?[index]['sepDLDate'],
                                                    "saldoSeparacionDeadline":
                                                        quotesSnapshot.data?[index]
                                                            ['saldoSepDLDate'],
                                                    "saldoCuotaIni": (currencyCOP(
                                                        (quotesSnapshot.data?[index]
                                                                    ['saldoCILote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoCuotaIniDeadline":
                                                        quotesSnapshot.data?[index]
                                                            ['saldoCIDLDate'],
                                                    "vlrPorPagar": (currencyCOP(
                                                        (quotesSnapshot.data?[index][
                                                                    'vlrPorPagarLote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoTotalDate":
                                                        quotesSnapshot.data?[index]
                                                            ['saldoTotalDate'],
                                                    "vlrCuota": (currencyCOP(
                                                        (quotesSnapshot.data?[index][
                                                                    'vlrCuotasLote']
                                                                .toInt())
                                                            .toString())),
                                                    "tem":
                                                        '${quotesSnapshot.data?[index]['tem'].toString()}%',
                                                    "observaciones":
                                                        quotesSnapshot.data?[index]
                                                            ['observacionesLote'],
                                                    "quoteStage": quotesSnapshot
                                                        .data?[index]['quoteStage'],
                                                    "name": custData['nameCliente'],
                                                    "lastname":
                                                        custData['lastnameCliente'],
                                                    "gender":
                                                        custData['genderCliente'],
                                                    "birthday":
                                                        custData['bdayCliente'],
                                                    "ocupacion": custData[
                                                        'ocupacionCliente'],
                                                    "phone": custData['telCliente'],
                                                    "idtype":
                                                        custData['idTypeCliente'],
                                                    "id": quotesSnapshot.data?[index]
                                                        ['clienteID'],
                                                    "issuedCountry": custData[
                                                        'idIssueCountryCliente'],
                                                    "issuedState": custData[
                                                        'idIssueStateCliente'],
                                                    "issuedCity": custData[
                                                        'idIssueCityCliente'],
                                                    "email":
                                                        custData['emailCliente'],
                                                    "address":
                                                        custData['addressCliente'],
                                                    "country":
                                                        custData['countryCliente'],
                                                    "state":
                                                        custData['stateCliente'],
                                                    "city": custData['cityCliente'],
                                                    "cambioEstado": false,
                                                  });
                                                setState(() {});
                                              }
                                            }
                                          }
                                          if (value == 'Opción 2') {
                                            if (quotesSnapshot.data?[index]
                                                    ['quoteStage'] ==
                                                'CREADA' && loteClicked['loteState'] == 'Disponible') {
                                              // ignore: use_build_context_synchronously
                                              await Navigator.pushNamed(
                                                  context, "/genSep",
                                                  arguments: {
                                                    "selectedSeller":
                                                        quotesSnapshot.data?[index]
                                                            ['sellerID'],
                                                    "sellerName":
                                                        '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                                    "sellerEmail": sellerData[
                                                        'emailSeller'],
                                                    "sellerPhone": sellerData[
                                                        'phoneSeller'],
                                                    "quoteId": quotesSnapshot
                                                        .data?[index]['qid'],                                                    
                                                    "loteId": quotesSnapshot
                                                        .data?[index]['loteId'],
                                                    "lote":
                                                        quotesSnapshot.data?[index]
                                                            ['loteName'],
                                                    "etapalote":
                                                        quotesSnapshot.data?[index]
                                                            ['etapaLote'],
                                                    "arealote":
                                                        quotesSnapshot.data?[index]
                                                            ['areaLote'],
                                                    "pricelote": (currencyCOP(
                                                        (quotesSnapshot.data?[index][
                                                                    'priceLote']
                                                                .toInt())
                                                            .toString())),
                                                    "precioFinal": (currencyCOP(
                                                        (quotesSnapshot.data?[index][
                                                                    'precioFinal']
                                                                .toInt())
                                                            .toString())),
                                                    "paymentMethod":
                                                        quotesSnapshot.data?[index]
                                                            ['metodoPagoLote'],
                                                    "porcCuotaInicial":
                                                        '${quotesSnapshot.data?[index]['perCILote'].toString()}%',
                                                    "vlrCuotaIni": (currencyCOP(
                                                        (quotesSnapshot.data?[index][
                                                                    'vlrCILote']
                                                                .toInt())
                                                            .toString())),
                                                    "periodoCuotas": quotesSnapshot
                                                            .data?[index]
                                                        ['periodoCuotasLote'],
                                                    "nroCuotas":
                                                        '${quotesSnapshot.data?[index]['nroCuotasLote'].toString()}',
                                                    "vlrSeparacion":
                                                        (currencyCOP((quotesSnapshot
                                                                .data?[index][
                                                                    'vlrSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoSeparacion":
                                                        (currencyCOP((quotesSnapshot
                                                                .data?[index][
                                                                    'saldoSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    "separacionDeadline":
                                                        quotesSnapshot.data?[index]
                                                            ['sepDLDate'],
                                                    "saldoSeparacionDeadline":
                                                        quotesSnapshot.data?[index]
                                                            ['saldoSepDLDate'],
                                                    "saldoCuotaIni":
                                                        (currencyCOP((quotesSnapshot
                                                                .data?[index][
                                                                    'saldoCILote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoCuotaIniDeadline":
                                                        quotesSnapshot.data?[index]
                                                            ['saldoCIDLDate'],
                                                    "vlrPorPagar": (currencyCOP(
                                                        (quotesSnapshot.data?[index][
                                                                    'vlrPorPagarLote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoTotalDate":
                                                        quotesSnapshot.data?[index]
                                                            ['saldoTotalDate'],
                                                    "vlrCuota": (currencyCOP(
                                                        (quotesSnapshot.data?[index][
                                                                    'vlrCuotasLote']
                                                                .toInt())
                                                            .toString())),
                                                    "tem":
                                                        '${quotesSnapshot.data?[index]['tem'].toString()}%',
                                                    "observaciones": quotesSnapshot
                                                            .data?[index]
                                                        ['observacionesLote'],
                                                    "quoteStage": newState(
                                                        quotesSnapshot.data?[index]
                                                            ['quoteStage']),
                                                    "name":
                                                        custData['nameCliente'],
                                                    "lastname": custData[
                                                        'lastnameCliente'],
                                                    "gender": custData[
                                                        'genderCliente'],
                                                    "birthday":
                                                        custData['bdayCliente'],
                                                    "ocupacion": custData[
                                                        'ocupacionCliente'],
                                                    "phone":
                                                        custData['telCliente'],
                                                    "idtype": custData[
                                                        'idTypeCliente'],
                                                    "id": quotesSnapshot.data?[index]
                                                        ['clienteID'],
                                                    "issuedCountry": custData[
                                                        'idIssueCountryCliente'],
                                                    "issuedState": custData[
                                                        'idIssueStateCliente'],
                                                    "issuedCity": custData[
                                                        'idIssueCityCliente'],
                                                    "email": custData[
                                                        'emailCliente'],
                                                    "address": custData[
                                                        'addressCliente'],
                                                    "country": custData[
                                                        'countryCliente'],
                                                    "state": custData[
                                                        'stateCliente'],
                                                    "city":
                                                        custData['cityCliente'],
                                                    "cambioEstado": true,
                                                  });
                                            } if (quotesSnapshot.data?[index]
                                            ['quoteStage'] ==
                                            'LOTE SEPARADO') {
                                              // ignore: use_build_context_synchronously
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        '¿Estás seguro de que quieres cancelar la separación SEP${quotesSnapshot.data?[index]['qid']}?'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            'Cancelar'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            'Confirmar'),
                                                        onPressed: () {
                                                          updateQuoteStage(
                                                              quotesSnapshot.data?[
                                                                  index]['qid'],
                                                              'AUTORIZADA');
                                                          cancSepLote(quotesSnapshot
                                                                  .data?[index]
                                                              ['loteId']);
                                                          deleteSep(
                                                              quotesSnapshot.data?[index]['qid'], quotesSnapshot.data?[index]['loteId']);
                                                          setState(() {});
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              // ignore: use_build_context_synchronously
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: CustomAlertMessage(
                                                    errorTitle: "Oops!",
                                                    errorText:
                                                        "Parece que este lote ya tiene dueño",
                                                    stateColor: Color.fromRGBO(214, 66, 66, 1),
                                                  ),
                                                  behavior: SnackBarBehavior.floating,
                                                  backgroundColor: Colors.transparent,
                                                  elevation: 0,
                                                ),
                                              );
                                            }
                                          }
                                          if (value == 'Opción 3') {
                                            setState(() {});
                                          }
                                          if (value == 'Opción 4') {
                                            setState(() {});
                                          } else {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                      onTap: (() async {
                                        await updateLoteInfo(quotesSnapshot.data?[index]['loteId']);
                                        // ignore: use_build_context_synchronously
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PDFGenerator(
                                              sellerID:
                                                  quotesSnapshot.data?[index]
                                                      ['sellerID'],
                                              sellerName:
                                                  '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                              sellerPhone: sellerData[
                                                  'phoneSeller'],
                                              sellerEmail: sellerData[
                                                  'emailSeller'],
                                              quoteId: quotesSnapshot
                                                  .data?[index]['qid'],
                                              name:
                                                  custData['nameCliente'],
                                              lastname: custData[
                                                  'lastnameCliente'],
                                              phone:
                                                  custData['telCliente'],
                                              date: quotesSnapshot.data?[index]
                                                  ['quoteDate'],
                                              dueDate:
                                                  quotesSnapshot.data?[index]
                                                      ['quoteDLDate'],
                                              lote: quotesSnapshot.data?[index]
                                                  ['loteName'],
                                              area: quotesSnapshot.data?[index]
                                                  ['areaLote'],
                                              price: (currencyCOP(
                                                  (quotesSnapshot.data?[index][
                                                              'priceLote']
                                                          .toInt())
                                                      .toString())),
                                              finalPrice: (currencyCOP(
                                                  (quotesSnapshot.data?[index][
                                                              'precioFinal']
                                                          .toInt())
                                                      .toString())),
                                              discount:
                                                  '${quotesSnapshot.data?[index]['dctoLote'].toString()}%',
                                              porcCuotaIni:
                                                  '${quotesSnapshot.data?[index]['perCILote'].toString()}%',
                                              vlrCuotaIni: (currencyCOP(
                                                  (quotesSnapshot.data?[index][
                                                              'vlrCILote']
                                                          .toInt())
                                                      .toString())),
                                              vlrSeparacion: (currencyCOP(
                                                  (quotesSnapshot.data?[index][
                                                              'vlrSepLote']
                                                          .toInt())
                                                      .toString())),
                                              dueDateSeparacion:
                                                  quotesSnapshot.data?[index]
                                                      ['sepDLDate'],
                                              saldoSeparacion:
                                                  (currencyCOP((quotesSnapshot
                                                          .data?[index][
                                                              'saldoSepLote']
                                                          .toInt())
                                                      .toString())),
                                              dueDateSaldoSeparacion:
                                                  quotesSnapshot.data?[index]
                                                      ['saldoSepDLDate'],
                                              plazoCI:
                                                  '${(quotesSnapshot.data?[index]['plazoCI'].toInt()).toString()} días',
                                              plazoContado:
                                                  '${(quotesSnapshot.data?[index]['plazoContado'].toInt()).toString()} días',
                                              saldoCI: (currencyCOP(
                                                  (quotesSnapshot.data?[index][
                                                              'saldoCILote']
                                                          .toInt())
                                                      .toString())),
                                              dueDateSaldoCI:
                                                  quotesSnapshot.data?[index]
                                                      ['saldoCIDLDate'],
                                              porcPorPagar:
                                                  '${(100 - quotesSnapshot.data?[index]['perCILote']).toString()}%',
                                              vlrPorPagar: (currencyCOP(
                                                  (quotesSnapshot.data?[index][
                                                              'vlrPorPagarLote']
                                                          .toInt())
                                                      .toString())),
                                              paymentMethod:
                                                  quotesSnapshot.data?[index]
                                                      ['metodoPagoLote'],
                                              tiempoFinanc:
                                                  '${((quotesSnapshot.data?[index]['nroCuotasLote']) / 12).toString()} años',
                                              vlrCuota: (currencyCOP((quotesSnapshot
                                                      .data?[index][
                                                          'vlrCuotasLote']
                                                      .toInt())
                                                  .toString())),
                                              saldoTotalDate:
                                                  quotesSnapshot.data?[index]
                                                      ['saldoTotalDate'],
                                              periodoCuotas: quotesSnapshot
                                                      .data?[index]
                                                  ['periodoCuotasLote'],
                                              nroCuotas: (quotesSnapshot
                                                      .data?[index][
                                                          'nroCuotasLote']
                                                      .toInt())
                                                  .toString(),
                                              tem:
                                                  '${quotesSnapshot.data?[index]['tem'].toString()}%',
                                              observaciones: quotesSnapshot
                                                      .data?[index]
                                                  ['observacionesLote'],
                                              quoteStage:
                                                  quotesSnapshot.data?[index]
                                                      ['quoteStage'],
                                            ),
                                          )
                                        );                                        
                                      }),
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              }));
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }));
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          })),
    );
  }

  Container widgetSeparaciones(context) {   
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: FutureBuilder(
          future: getOrdenSep(loteInfo[2], needAll, identifiedSeller),
          builder: ((context, sepSnapshot) {
            if (sepSnapshot.hasData) {
              return ListView.builder(
                itemCount: sepSnapshot.data?.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: db
                          .collection('customers')
                          .doc(sepSnapshot.data?[index]['clienteID'])
                          .get(),
                      builder: ((context, custSnapshot) {
                        if (custSnapshot.hasData) {
                          final custData =
                              custSnapshot.data?.data() as Map<String, dynamic>;
                          final name = custData['nameCliente'] ?? '';
                          final lastName = custData['lastnameCliente'] ?? '';
                          final fullName = '$lastName $name';
                          return FutureBuilder(
                              future: db
                                  .collection('sellers')
                                  .doc(sepSnapshot.data?[index]['sellerID'])
                                  .get(),
                              builder: ((context, sellerSnapshot) {
                                if (sellerSnapshot.hasData) {
                                  final sellerData = sellerSnapshot.data?.data()
                                      as Map<String, dynamic>;
                                  return Dismissible(
                                    onDismissed: (direction) async {
                                      updateQuoteStage(
                                        sepSnapshot.data?[
                                            index]['sepId'],
                                        'CREADA');
                                      cancSepLote(sepSnapshot
                                              .data?[index]
                                          ['loteId']);
                                      deleteSep(
                                          sepSnapshot.data?[index]['sepId'], sepSnapshot.data?[index]['loteId']);                                      
                                      setState(() {
                                        sepSnapshot.data?.removeAt(index);
                                      });
                                      Navigator.of(context)
                                          .pop();
                                    },
                                    confirmDismiss: (direction) async {
                                      bool result = false;
                                      result = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  "Esta seguro de eliminar la separacion #${sepSnapshot.data?[index]['sepId']}?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      return Navigator.pop(
                                                        context,
                                                        false,
                                                      );
                                                    },
                                                    child: const Text(
                                                      "Cancelar",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    )),
                                                TextButton(
                                                  onPressed: () {
                                                    return Navigator.pop(
                                                        context, true);
                                                  },
                                                  child: const Text(
                                                      "Si, estoy seguro"),
                                                ),
                                              ],
                                            );
                                          });
                                      return result;
                                    },
                                    background: Container(
                                      color: Colors.red,
                                      child: const Icon(Icons.delete),
                                    ),
                                    direction: DismissDirection.endToStart,
                                    key: Key(sepSnapshot.data?[index]['sepId']),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                          backgroundColor: stageColor('LOTE SEPARADO'),
                                          child: Text(
                                            getNumbers(sepSnapshot.data?[index]['loteId'])!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      title: Text(
                                          'Separación #${sepSnapshot.data?[index]['sepId']} | ${sepSnapshot.data?[index]['stageSep']}'),
                                      subtitle: Text('Cliente: $fullName'),
                                      trailing: PopupMenuButton<String>(
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'Opción 1',
                                            child: Text('Editar separación'),
                                          ),
                                          PopupMenuItem(
                                            enabled: managerLogged == true && sepSnapshot.data?[index]['stageSep'] == 'ACTIVA' ? true : false,
                                            value: 'Opción 2',
                                            child: const Text('Generar promesa de compra-venta'),
                                          ),
                                        ],
                                        onSelected: (value) async {
                                          await updateLoteInfo(sepSnapshot.data?[index]['loteId']);
                                          await llenarInstallments(sepSnapshot.data?[index]['loteId']);
                                          setState(() {                                                                                        
                                            vlrFijoSep = sepSnapshot.data?[index]['vlrSepLote'].toInt() + sepSnapshot.data?[index]['saldoSepLote'].toInt();
                                            updateNumberWords(vlrFijoSep.toDouble(), sepSnapshot.data?[index]['saldoCILote'].toDouble(), sepSnapshot.data?[index]['vlrPorPagarLote'].toDouble(), sepSnapshot.data?[index]['vlrCuotasLote'].toDouble(), sepSnapshot.data?[index]['precioFinal'].toDouble());
                                          });
                                          if (value == 'Opción 1') {
                                            if (managerLogged == true && loteClicked['loteState'] == 'Lote separado') {
                                              // ignore: use_build_context_synchronously
                                              await Navigator.pushNamed(
                                                  context, "/genSep",
                                                  arguments: {
                                                    "selectedSeller": sepSnapshot.data?[index]['sellerID'],
                                                    "sellerName": '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                                    "sellerEmail": sellerData['emailSeller'],
                                                    "sellerPhone": sellerData['phoneSeller'],
                                                    "quoteId": sepSnapshot.data?[index]['sepId'],                                                
                                                    "loteId": sepSnapshot.data?[index]['loteId'],
                                                    "lote": loteClicked['loteName'],
                                                    "etapalote": loteClicked['loteEtapa'],
                                                    "arealote": '${loteClicked['loteArea'].toString()} m²',
                                                    "pricelote": (currencyCOP((sepSnapshot.data?[index]['priceLote'].toInt()).toString())),
                                                    "precioFinal": (currencyCOP((sepSnapshot.data?[index]['precioFinal'].toInt()).toString())),
                                                    "paymentMethod": sepSnapshot.data?[index]['metodoPagoLote'],
                                                    "porcCuotaInicial": '${sepSnapshot.data?[index]['perCILote'].toString()}%',
                                                    "vlrCuotaIni": (currencyCOP((sepSnapshot.data?[index]['vlrCILote'].toInt()).toString())),
                                                    "periodoCuotas": sepSnapshot.data?[index]['periodoCuotasLote'],
                                                    "nroCuotas": '${sepSnapshot.data?[index]['nroCuotasLote'].toString()}',
                                                    "vlrSeparacion": (currencyCOP((sepSnapshot.data?[index]['vlrSepLote'].toInt()).toString())),
                                                    "saldoSeparacion": (currencyCOP((sepSnapshot.data?[index]['saldoSepLote'].toInt()).toString())),
                                                    "separacionDeadline": sepSnapshot.data?[index]['separacionDate'],
                                                    "saldoSeparacionDeadline": sepSnapshot.data?[index]['promesaDLDate'],
                                                    "saldoCuotaIni": (currencyCOP((sepSnapshot.data?[index]['saldoCILote'].toInt()).toString())),
                                                    "saldoCuotaIniDeadline":sepSnapshot.data?[index]['saldoCIDLDate'],
                                                    "vlrPorPagar": (currencyCOP((sepSnapshot.data?[index]['vlrPorPagarLote'].toInt()).toString())),
                                                    "saldoTotalDate": sepSnapshot.data?[index]['saldoTotalDate'],
                                                    "vlrCuota": (currencyCOP((sepSnapshot.data?[index]['vlrCuotasLote'].toInt()).toString())),
                                                    "tem": '${sepSnapshot.data?[index]['tem'].toString()}%',
                                                    "observaciones": sepSnapshot.data?[index]['observacionesLote'],
                                                    "quoteStage": 'LOTE SEPARADO',
                                                    "name": custData['nameCliente'],
                                                    "lastname":custData['lastnameCliente'],
                                                    "gender":custData['genderCliente'],
                                                    "birthday": custData['bdayCliente'],
                                                    "ocupacion": custData['ocupacionCliente'],
                                                    "phone": custData['telCliente'],
                                                    "idtype": custData['idTypeCliente'],
                                                    "id": sepSnapshot.data?[index]['clienteID'],
                                                    "issuedCountry": custData['idIssueCountryCliente'],
                                                    "issuedState": custData['idIssueStateCliente'],
                                                    "issuedCity": custData['idIssueCityCliente'],
                                                    "email": custData['emailCliente'],
                                                    "address": custData['addressCliente'],
                                                    "country": custData['countryCliente'],
                                                    "state": custData['stateCliente'],
                                                    "city": custData['cityCliente'],
                                                    "cambioEstado": false,
                                                  });
                                              setState(() {});
                                            } else {
                                              // ignore: use_build_context_synchronously
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: CustomAlertMessage(
                                                    errorTitle: "Oops!",
                                                    errorText:
                                                        "Parece que este lote ya tiene dueño",
                                                    stateColor: Color.fromRGBO(214, 66, 66, 1),
                                                  ),
                                                  behavior: SnackBarBehavior.floating,
                                                  backgroundColor: Colors.transparent,
                                                  elevation: 0,
                                                ),
                                              );
                                            }                                            
                                          } 
                                          if (value == 'Opción 2') {
                                            _observacionesController.text = sepSnapshot.data?[index]['observacionesLote'];
                                            // ignore: use_build_context_synchronously
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  content: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const SizedBox(height: 20),
                                                      TextField(
                                                        controller: _observacionesController,
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
                                                            Icons.search_outlined,
                                                            color: fifthColor,
                                                          ),
                                                          hintText: "Observaciones",
                                                          hintStyle:
                                                              TextStyle(color: fifthColor.withOpacity(0.9)),
                                                          filled: true,
                                                          floatingLabelBehavior: FloatingLabelBehavior.never,
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
                                                        keyboardType: TextInputType.emailAddress,
                                                      ),
                                                      const SizedBox(height: 20),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          updateSepPromesa(sepSnapshot.data?[index]['sepId'], _observacionesController.text);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PDFPromesa(
                                                                sellerID:
                                                                    sepSnapshot.data?[index]
                                                                        ['sellerID'],
                                                                sellerName:
                                                                    '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                                                sellerPhone: sellerData[
                                                                    'phoneSeller'],
                                                                sellerEmail: sellerData[
                                                                    'emailSeller'],
                                                                quoteId: sepSnapshot
                                                                    .data?[index]['sepId'],
                                                                name:
                                                                    custData['nameCliente'],
                                                                idCust: sepSnapshot.data?[index]['clienteID'],
                                                                idTypeCust: custData['idTypeCliente'],
                                                                lastname: custData[
                                                                    'lastnameCliente'],
                                                                phone:
                                                                    custData['telCliente'],
                                                                address: custData['addressCliente'],
                                                                email: custData['emailCliente'],
                                                                city: custData['idIssueCityCliente'],
                                                                date: sepSnapshot.data?[index]
                                                                    ['separacionDate'],
                                                                dueDate:
                                                                    sepSnapshot.data?[index]
                                                                        ['promesaDLDate'],
                                                                lote: loteClicked['loteName'],
                                                                loteId: sepSnapshot.data?[index]['loteId'],
                                                                area: '${loteClicked['loteArea'].toInt().toString()} m²',
                                                                price: (currencyCOP(
                                                                    (sepSnapshot.data?[index][
                                                                                'priceLote']
                                                                            .toInt())
                                                                        .toString())),
                                                                finalPrice: (currencyCOP(
                                                                    (sepSnapshot.data?[index][
                                                                                'precioFinal']
                                                                            .toInt())
                                                                        .toString())),
                                                                letrasFinalPrice:
                                                                  letrasPrecioFinal,        
                                                                porcCuotaIni:
                                                                    '${sepSnapshot.data?[index]['perCILote'].toString()}%',
                                                                vlrCuotaIni: (currencyCOP(
                                                                    (sepSnapshot.data?[index][
                                                                                'vlrCILote']
                                                                            .toInt())
                                                                        .toString())),
                                                                totalSeparacion: (currencyCOP(
                                                                    (vlrFijoSep
                                                                            .toInt())
                                                                        .toString())),
                                                                letrasSeparacion: letrasSep,
                                                                vlrSeparacion: (currencyCOP(
                                                                    (sepSnapshot.data?[index][
                                                                                'vlrSepLote']
                                                                            .toInt())
                                                                        .toString())),
                                                                dueDateSeparacion:
                                                                    sepSnapshot.data?[index]
                                                                        ['separacionDate'],
                                                                saldoSeparacion:
                                                                    (currencyCOP((sepSnapshot
                                                                            .data?[index][
                                                                                'saldoSepLote']
                                                                            .toInt())
                                                                        .toString())),
                                                                dueDateSaldoSeparacion:
                                                                    sepSnapshot.data?[index]
                                                                        ['promesaDLDate'],
                                                                plazoCI:
                                                                    '${(sepSnapshot.data?[index]['plazoCI'].toInt()).toString()} días',
                                                                plazoContado:
                                                                    '${(sepSnapshot.data?[index]['plazoContado'].toInt()).toString()} días',
                                                                letrasSaldoCI: letrasSaldoCI,
                                                                saldoCI: (currencyCOP(
                                                                    (sepSnapshot.data?[index][
                                                                                'saldoCILote']
                                                                            .toInt())
                                                                        .toString())),
                                                                dueDateSaldoCI:
                                                                    sepSnapshot.data?[index]
                                                                        ['saldoCIDLDate'],
                                                                porcPorPagar:
                                                                    '${(100 - sepSnapshot.data?[index]['perCILote']).toString()}%',
                                                                vlrPorPagar: (currencyCOP(
                                                                    (sepSnapshot.data?[index][
                                                                                'vlrPorPagarLote']
                                                                            .toInt())
                                                                        .toString())),
                                                                letrasSaldoTotal: letrasSaldoLote,
                                                                paymentMethod:
                                                                    sepSnapshot.data?[index]
                                                                        ['metodoPagoLote'],
                                                                tiempoFinanc:
                                                                    '${((sepSnapshot.data?[index]['nroCuotasLote']) / 12).toString()} años',
                                                                vlrCuota: (currencyCOP((sepSnapshot
                                                                        .data?[index][
                                                                            'vlrCuotasLote']
                                                                        .toInt())
                                                                    .toString())),
                                                                letrasVlrCuota: letrasValorCuotas,
                                                                letrasSaldoContado: letrasSaldoLote,
                                                                saldoTotalDate:
                                                                    sepSnapshot.data?[index]
                                                                        ['saldoTotalDate'],
                                                                periodoCuotas: sepSnapshot
                                                                        .data?[index]
                                                                    ['periodoCuotasLote'],
                                                                nroCuotas: (sepSnapshot
                                                                        .data?[index][
                                                                            'nroCuotasLote']
                                                                        .toInt())
                                                                    .toString(),
                                                                tem:
                                                                    '${sepSnapshot.data?[index]['tem'].toString()}%',
                                                                observaciones: _observacionesController.text,
                                                                quoteStage:
                                                                    sepSnapshot.data?[index]
                                                                        ['stageSep'],
                                                                installments: installments,
                                                              ),
                                                            ));
                                                        },
                                                        child: const Text('Generar promesa de compra-venta'),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    IconButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      icon: const Icon(Icons.close),
                                                    ),
                                                  ],
                                                );
                                              }
                                            );                                       
                                          } else {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                      onTap: (() async {
                                        await updateLoteInfo(sepSnapshot.data?[index]['loteId']);
                                        await llenarInstallments(sepSnapshot.data?[index]['loteId']);
                                          setState(() {                                                                                        
                                            vlrFijoSep = sepSnapshot.data?[index]['vlrSepLote'].toInt() + sepSnapshot.data?[index]['saldoSepLote'].toInt();
                                            updateNumberWords(vlrFijoSep.toDouble(), sepSnapshot.data?[index]['saldoCILote'].toDouble(), sepSnapshot.data?[index]['vlrPorPagarLote'].toDouble(), sepSnapshot.data?[index]['vlrCuotasLote'].toDouble(), sepSnapshot.data?[index]['precioFinal'].toDouble());
                                          });
                                        // ignore: use_build_context_synchronously
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PDFSeparacion(
                                              sellerID:
                                                  sepSnapshot.data?[index]
                                                      ['sellerID'],
                                              sellerName:
                                                  '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                              sellerPhone: sellerData[
                                                  'phoneSeller'],
                                              sellerEmail: sellerData[
                                                  'emailSeller'],
                                              quoteId: sepSnapshot
                                                  .data?[index]['sepId'],
                                              name:
                                                  custData['nameCliente'],
                                              idCust: sepSnapshot.data?[index]['clienteID'],
                                              idTypeCust: custData['idTypeCliente'],
                                              lastname: custData[
                                                  'lastnameCliente'],
                                              phone:
                                                  custData['telCliente'],
                                              address: custData['addressCliente'],
                                              email: custData['emailCliente'],
                                              city: custData['idIssueCityCliente'],
                                              date: sepSnapshot.data?[index]
                                                  ['separacionDate'],
                                              dueDate:
                                                  sepSnapshot.data?[index]
                                                      ['promesaDLDate'],
                                              lote: loteClicked['loteName'],
                                              area: '${loteClicked['loteArea'].toInt().toString()} m²',
                                              price: (currencyCOP(
                                                  (sepSnapshot.data?[index][
                                                              'priceLote']
                                                          .toInt())
                                                      .toString())),
                                              finalPrice: (currencyCOP(
                                                  (sepSnapshot.data?[index][
                                                              'precioFinal']
                                                          .toInt())
                                                      .toString())),
                                              letrasFinalPrice:
                                                letrasPrecioFinal,        
                                              porcCuotaIni:
                                                  '${sepSnapshot.data?[index]['perCILote'].toString()}%',
                                              vlrCuotaIni: (currencyCOP(
                                                  (sepSnapshot.data?[index][
                                                              'vlrCILote']
                                                          .toInt())
                                                      .toString())),
                                              totalSeparacion: (currencyCOP(
                                                  (vlrFijoSep
                                                          .toInt())
                                                      .toString())),
                                              letrasSeparacion: letrasSep,
                                              vlrSeparacion: (currencyCOP(
                                                  (sepSnapshot.data?[index][
                                                              'vlrSepLote']
                                                          .toInt())
                                                      .toString())),
                                              dueDateSeparacion:
                                                  sepSnapshot.data?[index]
                                                      ['separacionDate'],
                                              saldoSeparacion:
                                                  (currencyCOP((sepSnapshot
                                                          .data?[index][
                                                              'saldoSepLote']
                                                          .toInt())
                                                      .toString())),
                                              dueDateSaldoSeparacion:
                                                  sepSnapshot.data?[index]
                                                      ['promesaDLDate'],
                                              plazoCI:
                                                  '${(sepSnapshot.data?[index]['plazoCI'].toInt()).toString()} días',
                                              plazoContado:
                                                  '${(sepSnapshot.data?[index]['plazoContado'].toInt()).toString()} días',
                                              letrasSaldoCI: letrasSaldoCI,
                                              saldoCI: (currencyCOP(
                                                  (sepSnapshot.data?[index][
                                                              'saldoCILote']
                                                          .toInt())
                                                      .toString())),
                                              dueDateSaldoCI:
                                                  sepSnapshot.data?[index]
                                                      ['saldoCIDLDate'],
                                              porcPorPagar:
                                                  '${(100 - sepSnapshot.data?[index]['perCILote']).toString()}%',
                                              vlrPorPagar: (currencyCOP(
                                                  (sepSnapshot.data?[index][
                                                              'vlrPorPagarLote']
                                                          .toInt())
                                                      .toString())),
                                              letrasSaldoTotal: letrasSaldoLote,
                                              paymentMethod:
                                                  sepSnapshot.data?[index]
                                                      ['metodoPagoLote'],
                                              tiempoFinanc:
                                                  '${((sepSnapshot.data?[index]['nroCuotasLote']) / 12).toString()} años',
                                              vlrCuota: (currencyCOP((sepSnapshot
                                                      .data?[index][
                                                          'vlrCuotasLote']
                                                      .toInt())
                                                  .toString())),
                                              letrasVlrCuota: letrasValorCuotas,
                                              letrasSaldoContado: letrasSaldoLote,
                                              saldoTotalDate:
                                                  sepSnapshot.data?[index]
                                                      ['saldoTotalDate'],
                                              periodoCuotas: sepSnapshot
                                                      .data?[index]
                                                  ['periodoCuotasLote'],
                                              nroCuotas: (sepSnapshot
                                                      .data?[index][
                                                          'nroCuotasLote']
                                                      .toInt())
                                                  .toString(),
                                              tem:
                                                  '${sepSnapshot.data?[index]['tem'].toString()}%',
                                              observaciones: sepSnapshot
                                                      .data?[index]
                                                  ['observacionesLote'],
                                              quoteStage:
                                                  sepSnapshot.data?[index]
                                                      ['stageSep'],
                                              installments: installments,
                                            ),
                                          )
                                        );
                                      }),
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              }));
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }));
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          })),
    );
  }

  Future<Map<String, dynamic>> getLoteInfo(String lid) async {

    DocumentSnapshot<Map<String, dynamic>> infoLote = await db.collection('lotes').doc(lid).get();
    final Map<String, dynamic> data = infoLote.data() as Map<String, dynamic>;
    final lote = {
      "loteName": data['loteName'],      
      "loteEtapa": data['loteEtapa'],
      "loteArea": data['loteArea'],
      "lotePrice": data['lotePrice'],
      "loteState": data['loteState'],
      "loteLinderos": data['loteLinderos'],
    };
    return lote;  
  }

  void updateNumberWords(double vlrFijoSeparacion, double saldoCI, double valorAPagar, double valorCuota, double precioFinal) async {
    letrasSep = await numeroEnLetras(vlrFijoSeparacion, 'pesos');
    letrasSaldoCI = await numeroEnLetras(saldoCI, 'pesos');
    letrasSaldoLote = await numeroEnLetras(valorAPagar, 'pesos');
    letrasValorCuotas =
        await numeroEnLetras(valorCuota, 'pesos');
    letrasVlrPorPagar =
        await numeroEnLetras(valorAPagar, 'pesos');
    letrasPrecioFinal =
        await numeroEnLetras(precioFinal, 'pesos');
  }

  String newState(String value) {
    if (value == 'AUTORIZADA' || value == 'CREADA') {
      return 'LOTE SEPARADO';
    } else {
      return 'LOTE SEPARADO';
    }
  }

  String changeState(String value) {
    if (value == 'AUTORIZADA' || value == 'CREADA') {
      return 'Generar separación';
    } else {
      return 'Lote separado';
    }
  }

  Color stageColor(String value) {
    if (value == 'AUTORIZADA' || value == 'CREADA') {
      return infoColor;
    }
    if (value == 'LOTE SEPARADO') {
      return separadoColor;
    } else {
      return vendidoColor;
    }
  }

  String loteVerifier(bool value) {
    if (value == true) {
      return '';
    } else {
      return ' ${loteInfo[1]}';
    }
  } 
}


