import 'dart:async';

import 'package:albaterrapp/pages/archived_quotes.dart';
import 'package:albaterrapp/pages/pdf_generator.dart';
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

  Future<String> getGerenteEmail() async {
    final gerenteEmail = await db
        .collection('infoproyecto')
        .doc('infoGeneral')
        .collection('gerenteProyecto')
        .doc('victorOrostegui')
        .get();
    return gerenteEmail.get('email') as String;
  }

  void updateLoteInfo(String lid) async {
    loteClicked = await getLoteInfo(lid);
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
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: db
                          .collection('customers')
                          .doc(snapshot.data?[index]['clienteID'])
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
                                  .doc(snapshot.data?[index]['sellerID'])
                                  .get(),
                              builder: ((context, sellerSnapshot) {
                                if (sellerSnapshot.hasData) {
                                  final sellerData = sellerSnapshot.data?.data()
                                      as Map<String, dynamic>;
                                  return Dismissible(
                                    onDismissed: (direction) async {
                                      await archiveQuote(
                                          snapshot.data?[index]['qid']);
                                      snapshot.data?.removeAt(index);
                                      setState(() {});
                                    },
                                    confirmDismiss: (direction) async {
                                      bool result = false;
                                      result = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  "Esta seguro de archivar la cotizacion #${snapshot.data?[index]['qid']}?"),
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
                                    key: Key(snapshot.data?[index]['qid']),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                          backgroundColor: stageColor(snapshot.data?[index]['quoteStage']),
                                          child: Text(
                                            getNumbers(snapshot.data?[index]['loteName'])!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      title: Text(
                                          'Cotización #${snapshot.data?[index]['qid']} | ${snapshot.data?[index]['quoteStage']}'),
                                      subtitle: Text('Cliente: $fullName'),
                                      trailing: PopupMenuButton<String>(
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'Opción 1',
                                            child: Text('Ver PDF'),
                                          ),
                                          PopupMenuItem(
                                            enabled: (managerLogged  && snapshot.data?[index]
                                                        ['quoteStage'] !=
                                                    'LOTE SEPARADO'),
                                            value: 'Opción 2',
                                            child: Text(snapshot.data?[index]
                                                        ['quoteStage'] ==
                                                    'LOTE SEPARADO'
                                                ? 'Cancelar separación'
                                                : changeState(snapshot
                                                .data?[index]['quoteStage'])),
                                          ),
                                        ],
                                        onSelected: (value) async {
                                          setState(() {updateLoteInfo(snapshot.data?[index]['loteId']);});
                                          if (value == 'Opción 1') {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PDFGenerator(
                                                    sellerID:
                                                        snapshot.data?[index]
                                                            ['sellerID'],
                                                    sellerName:
                                                        '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                                    sellerPhone: sellerData[
                                                        'phoneSeller'],
                                                    sellerEmail: sellerData[
                                                        'emailSeller'],
                                                    quoteId: snapshot
                                                        .data?[index]['qid'],
                                                    name:
                                                        custData['nameCliente'],
                                                    lastname: custData[
                                                        'lastnameCliente'],
                                                    phone:
                                                        custData['telCliente'],
                                                    date: snapshot.data?[index]
                                                        ['quoteDate'],
                                                    dueDate:
                                                        snapshot.data?[index]
                                                            ['quoteDLDate'],
                                                    lote: snapshot.data?[index]
                                                        ['loteName'],
                                                    area: snapshot.data?[index]
                                                        ['areaLote'],
                                                    price: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'priceLote']
                                                                .toInt())
                                                            .toString())),
                                                    finalPrice: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'precioFinal']
                                                                .toInt())
                                                            .toString())),
                                                    discount:
                                                        '${snapshot.data?[index]['dctoLote'].toString()}%',
                                                    porcCuotaIni:
                                                        '${snapshot.data?[index]['perCILote'].toString()}%',
                                                    vlrCuotaIni: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrCILote']
                                                                .toInt())
                                                            .toString())),
                                                    vlrSeparacion: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    dueDateSeparacion:
                                                        snapshot.data?[index]
                                                            ['sepDLDate'],
                                                    saldoSeparacion:
                                                        (currencyCOP((snapshot
                                                                .data?[index][
                                                                    'saldoSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    dueDateSaldoSeparacion:
                                                        snapshot.data?[index]
                                                            ['saldoSepDLDate'],
                                                    plazoCI:
                                                        '${(snapshot.data?[index]['plazoCI'].toInt()).toString()} días',
                                                    plazoContado:
                                                        '${(snapshot.data?[index]['plazoContado'].toInt()).toString()} días',
                                                    saldoCI: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'saldoCILote']
                                                                .toInt())
                                                            .toString())),
                                                    dueDateSaldoCI:
                                                        snapshot.data?[index]
                                                            ['saldoCIDLDate'],
                                                    porcPorPagar:
                                                        '${(100 - snapshot.data?[index]['perCILote']).toString()}%',
                                                    vlrPorPagar: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrPorPagarLote']
                                                                .toInt())
                                                            .toString())),
                                                    paymentMethod:
                                                        snapshot.data?[index]
                                                            ['metodoPagoLote'],
                                                    tiempoFinanc:
                                                        '${((snapshot.data?[index]['nroCuotasLote']) / 12).toString()} años',
                                                    vlrCuota: (currencyCOP((snapshot
                                                            .data?[index][
                                                                'vlrCuotasLote']
                                                            .toInt())
                                                        .toString())),
                                                    saldoTotalDate:
                                                        snapshot.data?[index]
                                                            ['saldoTotalDate'],
                                                    periodoCuotas: snapshot
                                                            .data?[index]
                                                        ['periodoCuotasLote'],
                                                    nroCuotas: (snapshot
                                                            .data?[index][
                                                                'nroCuotasLote']
                                                            .toInt())
                                                        .toString(),
                                                    tem:
                                                        '${snapshot.data?[index]['tem'].toString()}%',
                                                    observaciones: snapshot
                                                            .data?[index]
                                                        ['observacionesLote'],
                                                    quoteStage:
                                                        snapshot.data?[index]
                                                            ['quoteStage'],
                                                  ),
                                                ));
                                          }
                                          if (value == 'Opción 2') {
                                            if (snapshot.data?[index]
                                                    ['quoteStage'] ==
                                                'CREADA') {
                                              await Navigator.pushNamed(
                                                  context, "/editQuote",
                                                  arguments: {
                                                    "selectedSeller":
                                                        snapshot.data?[index]
                                                            ['sellerID'],
                                                    "sellerName":
                                                        '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                                    "sellerEmail": sellerData[
                                                        'emailSeller'],
                                                    "sellerPhone": sellerData[
                                                        'phoneSeller'],
                                                    "quoteId": snapshot
                                                        .data?[index]['qid'],
                                                    "quoteDate":
                                                        snapshot.data?[index]
                                                            ['quoteDate'],
                                                    "quoteDeadline":
                                                        snapshot.data?[index]
                                                            ['quoteDLDate'],
                                                    "loteId": snapshot
                                                        .data?[index]['loteId'],
                                                    "lote":
                                                        snapshot.data?[index]
                                                            ['loteName'],
                                                    "etapalote":
                                                        snapshot.data?[index]
                                                            ['etapaLote'],
                                                    "arealote":
                                                        snapshot.data?[index]
                                                            ['areaLote'],
                                                    "pricelote": (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'priceLote']
                                                                .toInt())
                                                            .toString())),
                                                    "precioFinal": (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'precioFinal']
                                                                .toInt())
                                                            .toString())),
                                                    "paymentMethod":
                                                        snapshot.data?[index]
                                                            ['metodoPagoLote'],
                                                    "porcCuotaInicial":
                                                        '${snapshot.data?[index]['perCILote'].toString()}%',
                                                    "vlrCuotaIni": (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrCILote']
                                                                .toInt())
                                                            .toString())),
                                                    "periodoCuotas": snapshot
                                                            .data?[index]
                                                        ['periodoCuotasLote'],
                                                    "nroCuotas":
                                                        '${snapshot.data?[index]['nroCuotasLote'].toString()}',
                                                    "vlrSeparacion":
                                                        (currencyCOP((snapshot
                                                                .data?[index][
                                                                    'vlrSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoSeparacion":
                                                        (currencyCOP((snapshot
                                                                .data?[index][
                                                                    'saldoSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    "separacionDeadline":
                                                        snapshot.data?[index]
                                                            ['sepDLDate'],
                                                    "saldoSeparacionDeadline":
                                                        snapshot.data?[index]
                                                            ['saldoSepDLDate'],
                                                    "saldoCuotaIni":
                                                        (currencyCOP((snapshot
                                                                .data?[index][
                                                                    'saldoCILote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoCuotaIniDeadline":
                                                        snapshot.data?[index]
                                                            ['saldoCIDLDate'],
                                                    "vlrPorPagar": (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrPorPagarLote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoTotalDate":
                                                        snapshot.data?[index]
                                                            ['saldoTotalDate'],
                                                    "vlrCuota": (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrCuotasLote']
                                                                .toInt())
                                                            .toString())),
                                                    "tem":
                                                        '${snapshot.data?[index]['tem'].toString()}%',
                                                    "observaciones": snapshot
                                                            .data?[index]
                                                        ['observacionesLote'],
                                                    "quoteStage": newState(
                                                        snapshot.data?[index]
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
                                                    "id": snapshot.data?[index]
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
                                            }
                                            if (snapshot.data?[index]
                                                    ['quoteStage'] ==
                                                'AUTORIZADA' && loteClicked['loteState'] == 'Disponible') {
                                              // ignore: use_build_context_synchronously
                                              await Navigator.pushNamed(
                                                  context, "/genSep",
                                                  arguments: {
                                                    "selectedSeller":
                                                        snapshot.data?[index]
                                                            ['sellerID'],
                                                    "sellerName":
                                                        '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                                    "sellerEmail": sellerData[
                                                        'emailSeller'],
                                                    "sellerPhone": sellerData[
                                                        'phoneSeller'],
                                                    "quoteId": snapshot
                                                        .data?[index]['qid'],
                                                    "quoteDate":
                                                        snapshot.data?[index]
                                                            ['quoteDate'],
                                                    "quoteDeadline":
                                                        snapshot.data?[index]
                                                            ['quoteDLDate'],
                                                    "loteId": snapshot
                                                        .data?[index]['loteId'],
                                                    "lote":
                                                        snapshot.data?[index]
                                                            ['loteName'],
                                                    "etapalote":
                                                        snapshot.data?[index]
                                                            ['etapaLote'],
                                                    "arealote":
                                                        snapshot.data?[index]
                                                            ['areaLote'],
                                                    "pricelote": (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'priceLote']
                                                                .toInt())
                                                            .toString())),
                                                    "precioFinal": (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'precioFinal']
                                                                .toInt())
                                                            .toString())),
                                                    "paymentMethod":
                                                        snapshot.data?[index]
                                                            ['metodoPagoLote'],
                                                    "porcCuotaInicial":
                                                        '${snapshot.data?[index]['perCILote'].toString()}%',
                                                    "vlrCuotaIni": (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrCILote']
                                                                .toInt())
                                                            .toString())),
                                                    "periodoCuotas": snapshot
                                                            .data?[index]
                                                        ['periodoCuotasLote'],
                                                    "nroCuotas":
                                                        '${snapshot.data?[index]['nroCuotasLote'].toString()}',
                                                    "vlrSeparacion":
                                                        (currencyCOP((snapshot
                                                                .data?[index][
                                                                    'vlrSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoSeparacion":
                                                        (currencyCOP((snapshot
                                                                .data?[index][
                                                                    'saldoSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    "separacionDeadline":
                                                        snapshot.data?[index]
                                                            ['sepDLDate'],
                                                    "saldoSeparacionDeadline":
                                                        snapshot.data?[index]
                                                            ['saldoSepDLDate'],
                                                    "saldoCuotaIni":
                                                        (currencyCOP((snapshot
                                                                .data?[index][
                                                                    'saldoCILote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoCuotaIniDeadline":
                                                        snapshot.data?[index]
                                                            ['saldoCIDLDate'],
                                                    "vlrPorPagar": (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrPorPagarLote']
                                                                .toInt())
                                                            .toString())),
                                                    "saldoTotalDate":
                                                        snapshot.data?[index]
                                                            ['saldoTotalDate'],
                                                    "vlrCuota": (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrCuotasLote']
                                                                .toInt())
                                                            .toString())),
                                                    "tem":
                                                        '${snapshot.data?[index]['tem'].toString()}%',
                                                    "observaciones": snapshot
                                                            .data?[index]
                                                        ['observacionesLote'],
                                                    "quoteStage": newState(
                                                        snapshot.data?[index]
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
                                                    "id": snapshot.data?[index]
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
                                            } if (snapshot.data?[index]
                                            ['quoteStage'] ==
                                            'LOTE SEPARADO') {
                                              // ignore: use_build_context_synchronously
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        '¿Estás seguro de que quieres cancelar la separación SEP${snapshot.data?[index]['qid']}?'),
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
                                                              snapshot.data?[
                                                                  index]['qid'],
                                                              'AUTORIZADA');
                                                          cancSepLote(snapshot
                                                                  .data?[index]
                                                              ['loteId']);
                                                          deleteSep(
                                                              "SEP${snapshot.data?[index]['qid']}");
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
                                      onTap: (() {
                                        setState(() { updateLoteInfo(snapshot.data?[index]['loteId']);});
                                        if (managerLogged == true) {
                                          if(loteClicked['loteState'] != 'Disponible') {
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
                                                "selectedSeller": snapshot
                                                    .data?[index]['sellerID'],
                                                "sellerName":
                                                    '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                                "sellerEmail":
                                                    sellerData['emailSeller'],
                                                "sellerPhone":
                                                    sellerData['phoneSeller'],
                                                "quoteId": snapshot.data?[index]
                                                    ['qid'],
                                                "quoteDate": snapshot
                                                    .data?[index]['quoteDate'],
                                                "quoteDeadline":
                                                    snapshot.data?[index]
                                                        ['quoteDLDate'],
                                                "loteId": snapshot.data?[index]
                                                    ['loteId'],
                                                "lote": snapshot.data?[index]
                                                    ['loteName'],
                                                "etapalote": snapshot
                                                    .data?[index]['etapaLote'],
                                                "arealote": snapshot
                                                    .data?[index]['areaLote'],
                                                "pricelote": (currencyCOP(
                                                    (snapshot.data?[index]
                                                                ['priceLote']
                                                            .toInt())
                                                        .toString())),
                                                "precioFinal": (currencyCOP(
                                                    (snapshot.data?[index]
                                                                ['precioFinal']
                                                            .toInt())
                                                        .toString())),
                                                "paymentMethod":
                                                    snapshot.data?[index]
                                                        ['metodoPagoLote'],
                                                "porcCuotaInicial":
                                                    '${snapshot.data?[index]['perCILote'].toString()}%',
                                                "vlrCuotaIni": (currencyCOP(
                                                    (snapshot.data?[index]
                                                                ['vlrCILote']
                                                            .toInt())
                                                        .toString())),
                                                "periodoCuotas":
                                                    snapshot.data?[index]
                                                        ['periodoCuotasLote'],
                                                "nroCuotas":
                                                    '${snapshot.data?[index]['nroCuotasLote'].toString()}',
                                                "vlrSeparacion": (currencyCOP(
                                                    (snapshot.data?[index]
                                                                ['vlrSepLote']
                                                            .toInt())
                                                        .toString())),
                                                "saldoSeparacion": (currencyCOP(
                                                    (snapshot.data?[index]
                                                                ['saldoSepLote']
                                                            .toInt())
                                                        .toString())),
                                                "separacionDeadline": snapshot
                                                    .data?[index]['sepDLDate'],
                                                "saldoSeparacionDeadline":
                                                    snapshot.data?[index]
                                                        ['saldoSepDLDate'],
                                                "saldoCuotaIni": (currencyCOP(
                                                    (snapshot.data?[index]
                                                                ['saldoCILote']
                                                            .toInt())
                                                        .toString())),
                                                "saldoCuotaIniDeadline":
                                                    snapshot.data?[index]
                                                        ['saldoCIDLDate'],
                                                "vlrPorPagar": (currencyCOP(
                                                    (snapshot.data?[index][
                                                                'vlrPorPagarLote']
                                                            .toInt())
                                                        .toString())),
                                                "saldoTotalDate":
                                                    snapshot.data?[index]
                                                        ['saldoTotalDate'],
                                                "vlrCuota": (currencyCOP(
                                                    (snapshot.data?[index][
                                                                'vlrCuotasLote']
                                                            .toInt())
                                                        .toString())),
                                                "tem":
                                                    '${snapshot.data?[index]['tem'].toString()}%',
                                                "observaciones":
                                                    snapshot.data?[index]
                                                        ['observacionesLote'],
                                                "quoteStage": snapshot
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
                                                "id": snapshot.data?[index]
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
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return FutureBuilder(
                      future: db
                          .collection('customers')
                          .doc(snapshot.data?[index]['clienteID'])
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
                                  .doc(snapshot.data?[index]['sellerID'])
                                  .get(),
                              builder: ((context, sellerSnapshot) {
                                if (sellerSnapshot.hasData) {
                                  final sellerData = sellerSnapshot.data?.data()
                                      as Map<String, dynamic>;
                                  return Dismissible(
                                    onDismissed: (direction) async {
                                      updateQuoteStage(
                                        snapshot.data?[
                                            index]['quoteId'],
                                        'AUTORIZADA');
                                      cancSepLote(snapshot
                                              .data?[index]
                                          ['loteId']);
                                      deleteSep(
                                          snapshot.data?[index]['sepId']);
                                      setState(() {});
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
                                                  "Esta seguro de eliminar la separacion #${snapshot.data?[index]['sepId']}?"),
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
                                    key: Key(snapshot.data?[index]['sepId']),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                          backgroundColor: stageColor('LOTE SEPARADO'),
                                          child: Text(
                                            getNumbers(snapshot.data?[index]['loteId'])!,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      title: Text(
                                          'Separación #${snapshot.data?[index]['sepId']} | ${snapshot.data?[index]['stageSep']}'),
                                      subtitle: Text('Cliente: $fullName'),
                                      trailing: PopupMenuButton<String>(
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'Opción 1',
                                            child: Text('Ver PDF'),
                                          ),
                                          /*PopupMenuItem(
                                            enabled: managerLogged,
                                            value: 'Opción 2',
                                            child: Text(snapshot.data?[index]
                                                        ['quoteStage'] ==
                                                    'LOTE SEPARADO'
                                                ? 'Cancelar separación'
                                                : changeState(snapshot
                                                .data?[index]['quoteStage'])),
                                          ),*/
                                        ],
                                        onSelected: (value) async {
                                          updateLoteInfo(snapshot.data?[index]['loteId']);
                                          vlrFijoSep = snapshot.data?[index]['vlrSepLote'].toInt() + snapshot.data?[index]['saldoSepLote'].toInt();
                                          updateNumberWords(vlrFijoSep.toDouble(), snapshot.data?[index]['saldoCILote'], snapshot.data?[index]['vlrPorPagarLote'], snapshot.data?[index]['vlrCuotasLote'], snapshot.data?[index]['precioFinal'].toDouble());
                                          if (value == 'Opción 1') {
                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PDFSeparacion(
                                                    sellerID:
                                                        snapshot.data?[index]
                                                            ['sellerID'],
                                                    sellerName:
                                                        '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                                    sellerPhone: sellerData[
                                                        'phoneSeller'],
                                                    sellerEmail: sellerData[
                                                        'emailSeller'],
                                                    quoteId: snapshot
                                                        .data?[index]['sepId'],
                                                    name:
                                                        custData['nameCliente'],
                                                    idCust: snapshot.data?[index]['clienteID'],
                                                    idTypeCust: custData['idTypeCliente'],
                                                    lastname: custData[
                                                        'lastnameCliente'],
                                                    phone:
                                                        custData['telCliente'],
                                                    address: custData['addressCliente'],
                                                    email: custData['emailCliente'],
                                                    city: custData['idIssueCityCliente'],
                                                    date: snapshot.data?[index]
                                                        ['separacionDate'],
                                                    dueDate:
                                                        snapshot.data?[index]
                                                            ['promesaDLDate'],
                                                    lote: loteClicked['loteName'],
                                                    area: '${loteClicked['loteArea'].toInt().toString()} m²',
                                                    price: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'priceLote']
                                                                .toInt())
                                                            .toString())),
                                                    finalPrice: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'precioFinal']
                                                                .toInt())
                                                            .toString())),
                                                    letrasFinalPrice:
                                                      letrasPrecioFinal,        
                                                    porcCuotaIni:
                                                        '${snapshot.data?[index]['perCILote'].toString()}%',
                                                    vlrCuotaIni: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrCILote']
                                                                .toInt())
                                                            .toString())),
                                                    totalSeparacion: (currencyCOP(
                                                        (vlrFijoSep
                                                                .toInt())
                                                            .toString())),
                                                    letrasSeparacion: letrasSep,
                                                    vlrSeparacion: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    dueDateSeparacion:
                                                        snapshot.data?[index]
                                                            ['separacionDate'],
                                                    saldoSeparacion:
                                                        (currencyCOP((snapshot
                                                                .data?[index][
                                                                    'saldoSepLote']
                                                                .toInt())
                                                            .toString())),
                                                    dueDateSaldoSeparacion:
                                                        snapshot.data?[index]
                                                            ['promesaDLDate'],
                                                    plazoCI:
                                                        '${(snapshot.data?[index]['plazoCI'].toInt()).toString()} días',
                                                    plazoContado:
                                                        '${(snapshot.data?[index]['plazoContado'].toInt()).toString()} días',
                                                    letrasSaldoCI: letrasSaldoCI,
                                                    saldoCI: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'saldoCILote']
                                                                .toInt())
                                                            .toString())),
                                                    dueDateSaldoCI:
                                                        snapshot.data?[index]
                                                            ['saldoCIDLDate'],
                                                    porcPorPagar:
                                                        '${(100 - snapshot.data?[index]['perCILote']).toString()}%',
                                                    vlrPorPagar: (currencyCOP(
                                                        (snapshot.data?[index][
                                                                    'vlrPorPagarLote']
                                                                .toInt())
                                                            .toString())),
                                                    letrasSaldoTotal: letrasSaldoLote,
                                                    paymentMethod:
                                                        snapshot.data?[index]
                                                            ['metodoPagoLote'],
                                                    tiempoFinanc:
                                                        '${((snapshot.data?[index]['nroCuotasLote']) / 12).toString()} años',
                                                    vlrCuota: (currencyCOP((snapshot
                                                            .data?[index][
                                                                'vlrCuotasLote']
                                                            .toInt())
                                                        .toString())),
                                                    letrasVlrCuota: letrasValorCuotas,
                                                    letrasSaldoContado: letrasSaldoLote,
                                                    saldoTotalDate:
                                                        snapshot.data?[index]
                                                            ['saldoTotalDate'],
                                                    periodoCuotas: snapshot
                                                            .data?[index]
                                                        ['periodoCuotasLote'],
                                                    nroCuotas: (snapshot
                                                            .data?[index][
                                                                'nroCuotasLote']
                                                            .toInt())
                                                        .toString(),
                                                    tem:
                                                        '${snapshot.data?[index]['tem'].toString()}%',
                                                    observaciones: snapshot
                                                            .data?[index]
                                                        ['observacionesLote'],
                                                    quoteStage:
                                                        snapshot.data?[index]
                                                            ['stageSep'],
                                                  ),
                                                ));
                                          } else {
                                            setState(() {});
                                          }
                                        },
                                      ),
                                      onTap: (() async {
                                        setState(() {updateLoteInfo(snapshot.data?[index]['loteId']);});
                                        if (managerLogged == true && loteClicked['loteState'] == 'Lote separado') {
                                          // ignore: use_build_context_synchronously
                                          Navigator.pushNamed(
                                              context, "/editSep",
                                              arguments: {
                                                "selectedSeller": snapshot.data?[index]['sellerID'],
                                                "sellerName": '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                                "sellerEmail": sellerData['emailSeller'],
                                                "sellerPhone": sellerData['phoneSeller'],
                                                "quoteId": snapshot.data?[index]['quoteId'],
                                                "sepId": snapshot.data?[index]['sepId'],
                                                "loteId": snapshot.data?[index]['loteId'],
                                                "lote": loteClicked['loteName'],
                                                "etapalote": loteClicked['loteEtapa'],
                                                "arealote": '${loteClicked['loteArea'].toString()} m²',
                                                "pricelote": (currencyCOP((snapshot.data?[index]['priceLote'].toInt()).toString())),
                                                "precioFinal": (currencyCOP((snapshot.data?[index]['precioFinal'].toInt()).toString())),
                                                "paymentMethod": snapshot.data?[index]['metodoPagoLote'],
                                                "porcCuotaInicial": '${snapshot.data?[index]['perCILote'].toString()}%',
                                                "vlrCuotaIni": (currencyCOP((snapshot.data?[index]['vlrCILote'].toInt()).toString())),
                                                "periodoCuotas": snapshot.data?[index]['periodoCuotasLote'],
                                                "nroCuotas": '${snapshot.data?[index]['nroCuotasLote'].toString()}',
                                                "vlrSeparacion": (currencyCOP((snapshot.data?[index]['vlrSepLote'].toInt()).toString())),
                                                "saldoSeparacion": (currencyCOP((snapshot.data?[index]['saldoSepLote'].toInt()).toString())),
                                                "separacionDate": snapshot.data?[index]['separacionDate'],
                                                "promesaDLDate": snapshot.data?[index]['promesaDLDate'],
                                                "saldoCuotaIni": (currencyCOP((snapshot.data?[index]['saldoCILote'].toInt()).toString())),
                                                "saldoCuotaIniDeadline":snapshot.data?[index]['saldoCIDLDate'],
                                                "vlrPorPagar": (currencyCOP((snapshot.data?[index]['vlrPorPagarLote'].toInt()).toString())),
                                                "saldoTotalDate": snapshot.data?[index]['saldoTotalDate'],
                                                "vlrCuota": (currencyCOP((snapshot.data?[index]['vlrCuotasLote'].toInt()).toString())),
                                                "tem": '${snapshot.data?[index]['tem'].toString()}%',
                                                "observaciones": snapshot.data?[index]['observacionesLote'],
                                                "stageSep": snapshot.data?[index]['stageSep'],
                                                "name": custData['nameCliente'],
                                                "lastname":custData['lastnameCliente'],
                                                "gender":custData['genderCliente'],
                                                "birthday": custData['bdayCliente'],
                                                "ocupacion": custData['ocupacionCliente'],
                                                "phone": custData['telCliente'],
                                                "idtype": custData['idTypeCliente'],
                                                "id": snapshot.data?[index]['clienteID'],
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
    if (value == 'CREADA') {
      return 'AUTORIZADA';
    }
    if (value == 'AUTORIZADA') {
      return 'LOTE SEPARADO';
    } else {
      return 'LOTE SEPARADO';
    }
  }

  String changeState(String value) {
    if (value == 'CREADA') {
      return 'Autorizar cotización';
    }
    if (value == 'AUTORIZADA') {
      return 'Generar separación';
    } else {
      return 'Lote separado';
    }
  }

  Color stageColor(String value) {
    if (value == 'CREADA') {
      return dangerColor;
    }
    if (value == 'AUTORIZADA') {
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

  String? getNumbers(String value) {
    final RegExp regex = RegExp(r'\d+');
    final String? loteNumber = regex.stringMatch(value);
    return loteNumber;
  }
}


