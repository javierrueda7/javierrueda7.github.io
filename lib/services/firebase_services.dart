import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<Map<String, dynamic>> getCustomerInfo(String id) async {
  
  DocumentSnapshot<Map<String, dynamic>> infoCustomer = await db.collection('customers').doc(id).get();
  
  final Map<String, dynamic> data = infoCustomer.data() as Map<String, dynamic>;
  final customer = {
    "nameCliente": data["nameCliente"],
    "lastnameCliente": data["lastnameCliente"],
    "genderCliente": data["genderCliente"],
    "bdayCliente": data["bdayCliente"],
    "ocupacionCliente": data["ocupacionCliente"],
    "telCliente": data["telCliente"],
    "idTypeCliente": data["idTypeCliente"],
    "idIssueCountryCliente": data["idIssueCountryCliente"],
    "idIssueStateCliente": data["idIssueStateCliente"],
    "idIssueCityCliente": data["idIssueCityCliente"],
    "emailCliente": data["emailCliente"],
    "addressCliente": data["addressCliente"],
    "countryCliente": data["countryCliente"],
    "stateCliente": data["stateCliente"],
    "cityCliente": data["cityCliente"]
  };  
  return customer;
}

Future<Map<String, dynamic>> getLoteInfo(String id) async {
  DocumentSnapshot<Map<String, dynamic>> loteinfo = await db.collection('lotes').doc(id).get();
  
  final Map<String, dynamic> data = loteinfo.data() as Map<String, dynamic>;
  final lote = {
    "loteEtapa": data['loteEtapa'],
    "loteArea": data['loteArea'],
    "loteLinderos": data['loteLinderos'],
  };
  return lote;
}

Future<void> addPlanPagos(String lote, String idPlanPagos, String paymentMethod, double precioIni, double precioFin, double dcto, double valorSeparacion, double porcCI, String estadoPago, double saldoPorPagar, double valorPagado, String idCliente) async{
  await db.collection("planPagos").doc(lote).set({
    "idPlanPagos": idPlanPagos,
    "paymentMethod": paymentMethod,
    "precioIni": precioIni,
    "precioFin": precioFin,
    "dcto": dcto,
    "valorSeparacion": valorSeparacion,
    "porcCI": porcCI,
    "estadoPago": estadoPago,
    "saldoPorPagar": saldoPorPagar,
    "valorPagado": valorPagado,
    "idCliente": idCliente,
    "valorIntereses": 0,
  });
}

Future<void> updatePlanPagos(String lote, double precioIni, double precioFin, double dcto, String estadoPago, double saldoPorPagar, double valorPagado, double valorIntereses) async{
  await db.collection("planPagos").doc(lote).update({
    "precioIni": precioIni,
    "precioFin": precioFin,
    "dcto": dcto,
    "estadoPago": estadoPago,
    "saldoPorPagar": saldoPorPagar,
    "valorPagado": valorPagado,
    "valorIntereses": valorIntereses
  });
}

Future<void> pagosEsperados(String lote, String idPago, double valorPago, String conceptoPago, String fechaPago, String idPlanPagos, String estadoPago) async{
  await db.collection("planPagos").doc(lote).collection("pagosEsperados").doc(idPago).set({
    "valorPago": valorPago,
    "conceptoPago": conceptoPago,
    "fechaPago": fechaPago,
    "idPlanPagos": idPlanPagos,
    "estadoPago": estadoPago
  });
}

Future<void> pagosRealizados(String lote, String idPago, double valorPago, String conceptoPago, String fechaRecibo, String fechaPago, String metodoPago, String nombreCliente, String idCliente, String telCliente, String emailCliente, String dirCliente, String ciudadCliente, String obsPago, String idPlanPagos, double valorIntereses) async{
  await db.collection("pagos").doc(idPago).set({
    "valorPago": valorPago,
    "conceptoPago": conceptoPago,
    "fechaRecibo": fechaRecibo,
    "fechaPago": fechaPago,
    "metodoPago": metodoPago,
    "nombreCliente": nombreCliente,
    "idCliente": idCliente,
    "telCliente": telCliente,
    "emailCliente": emailCliente,
    "dirCliente": dirCliente,
    "ciudadCliente": ciudadCliente,
    "obsPago": obsPago,
    "idPlanPagos": idPlanPagos,
    "valorIntereses": valorIntereses,
    "date": DateTime.now()
  });
}

Future<DateTime> getStartDate(String idPlanPagos) async {
  DocumentSnapshot? doc =
      await db.collection('ordSep').doc(idPlanPagos).get();
  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  final temp = {
    "fecha": data['separacionDate'],
  };
  return DateFormat('dd-MM-yyyy').parse(temp['fecha']);
}

Future<List> getPagos(String lote) async {
  List pagos = [];
  QuerySnapshot? queryPagos = await db.collection('pagos').get();
  for (var doc in queryPagos.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (lote == 'Null' || doc.id.contains(lote)) {
      final pago = {
        "pid": doc.id,
        "valorPago": data['valorPago'],
        "conceptoPago": data['conceptoPago'],
        "fechaRecibo": data['fechaRecibo'],
        "fechaPago": data['fechaPago'],
        "metodoPago": data['metodoPago'],
        "nombreCliente": data['nombreCliente'],
        "idCliente": data['idCliente'],
        "telCliente": data['telCliente'],
        "emailCliente": data['emailCliente'],
        "dirCliente": data['dirCliente'],
        "ciudadCliente": data['ciudadCliente'],
        "obsPago": data['obsPago'],
        "valorIntereses": data['valorIntereses']
      };
      pagos.add(pago);
    }
  }  
  // Sort the matchingDocuments by fechaPago
  pagos.sort((a, b) {
    DateTime dateA = DateFormat('dd-MM-yyyy').parse(a['fechaPago']);
    DateTime dateB = DateFormat('dd-MM-yyyy').parse(b['fechaPago']);
    return dateA.compareTo(dateB);
  });
  return pagos;
}

Future<List> getPagosEsp(String lote) async {
  List<Map<String, dynamic>> matchingDocuments = [];

    final QuerySnapshot pagosSnapshot = await FirebaseFirestore.instance
        .collection('planPagos').doc(lote).collection('pagosEsperados')
        .get();

    for (QueryDocumentSnapshot pagoSnapshot in pagosSnapshot.docs) {
      final Map<String, dynamic> data =
          pagoSnapshot.data() as Map<String, dynamic>;
      
      final pagoEsperado = {
        "lote": lote,
        "idPago": pagoSnapshot.id,
        "idPlan": data['idPlanPagos'],
        "fechaPago": data['fechaPago'],
        "valorPago": data['valorPago'],
        "conceptoPago": data['conceptoPago'],
        "estadoPago": data['estadoPago'],
      };
      matchingDocuments.add(pagoEsperado);        
    }   

    // Sort the matchingDocuments by fechaPago
    matchingDocuments.sort((a, b) {
      DateTime dateA = DateFormat('dd-MM-yyyy').parse(a['fechaPago']);
      DateTime dateB = DateFormat('dd-MM-yyyy').parse(b['fechaPago']);
      return dateA.compareTo(dateB);
    });
    return matchingDocuments;
}

Future<void> deletePagos(String pid, String lote, double valor, double valorInt) async {
  await db.collection("pagos").doc(pid).delete();
  
  final DocumentSnapshot doc = await db.collection("planPagos").doc(lote).get();
  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  
  final double saldoPorPagar = (data["saldoPorPagar"] ?? 0) + valor;
  final double valorPagado = (data["valorPagado"] ?? 0) - valor;
  final double valorIntereses = (data["valorIntereses"] ?? 0) - valorInt;
  String estado = data["estadoPago"];
  if (valorPagado < data["valorSeparacion"]){
    estado = 'Pendiente';
    await db.collection("lotes").doc(lote).update({"loteState": 'Lote separado'});
  } else if(data["valorPagado"] == data["precioFin"]){
    estado = 'En proceso';
  }  

  await db.collection("planPagos").doc(lote).update({
    "saldoPorPagar": saldoPorPagar,
    "valorPagado": valorPagado,
    "estadoPago": estado,
    "valorIntereses": valorIntereses
  });
}

Future<void> addBanco(String bid, String banco, String nroCuenta,
    String tipoCuenta, String nit, String nameRep) async {
  await db.collection("infobanco").doc(bid).set({
    "banco": banco,
    "nroCuenta": nroCuenta,
    "tipoCuenta": tipoCuenta,
    "nit": nit,
    "nameRep": nameRep
  });
}

Future<void> updateBanco(String bid, String banco, String nroCuenta,
    String tipoCuenta, String nit, String nameRep) async {
  await db.collection("infobanco").doc(bid).update({
    "banco": banco,
    "nroCuenta": nroCuenta,
    "tipoCuenta": tipoCuenta,
    "nit": nit,
    "nameRep": nameRep
  });
}

Future<void> deleteBank(String bid) async {
  await db.collection("infobanco").doc(bid).delete();  
}

Future<List> getCuentasBanco() async {
  List bancos = [];
  QuerySnapshot? queryBancos = await db.collection('infobanco').get();
  for (var doc in queryBancos.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final bank = {
      "bid": doc.id,
      "banco": data['banco'],
      "nroCuenta": data['nroCuenta'],
      "tipoCuenta": data['tipoCuenta'],
      "nit": data['nit'],
      "nameRep": data['nameRep']
    };
    bancos.add(bank);
  }
  return bancos;
}

Future<List> getSellers() async {
  List sellers = [];
  QuerySnapshot? querySellers = await db.collection('sellers').get();
  for (var doc in querySellers.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (data['statusSeller'] != 'Eliminado') {
      final person = {
        "sid": doc.id,
        "nameSeller": data['nameSeller'],
        "lastnameSeller": data['lastnameSeller'],
        "emailSeller": data['emailSeller'],
        "phoneSeller": data['phoneSeller'],
        "addressSeller": data['addressSeller'],
        "bdSeller": data['bdSeller'],
        "genderSeller": data['genderSeller'],
        "idSeller": data['idSeller'],
        "roleSeller": data['roleSeller'],
        "startDateSeller": data['startDateSeller'],
        "statusSeller": data['statusSeller'],
      };
      sellers.add(person);
    }
  }
  return sellers;
}

Future<void> addSellers(
    String sid,
    String nameSeller,
    String lastnameSeller,
    String emailSeller,
    String phoneSeller,
    String addressSeller,
    String idSeller,
    String bdSeller,
    String genderSeller,
    String startDateSeller,
    String roleSeller,
    String statusSeller) async {
  await db.collection("sellers").doc(sid).set({
    "nameSeller": nameSeller,
    "lastnameSeller": lastnameSeller,
    "emailSeller": emailSeller,
    "phoneSeller": phoneSeller,
    "addressSeller": addressSeller,
    "idSeller": idSeller,
    "bdSeller": bdSeller,
    "genderSeller": genderSeller,
    "startDateSeller": startDateSeller,
    "roleSeller": roleSeller,
    "statusSeller": statusSeller,
    "isDeleted": false,
  });
}

Future<void> updateSellers(
    String sid,
    String nameSeller,
    String lastnameSeller,
    String emailSeller,
    String phoneSeller,
    String addressSeller,
    String idSeller,
    String bdSeller,
    String genderSeller,
    String startDateSeller,
    String roleSeller,
    String statusSeller) async {
  await db.collection("sellers").doc(sid).update({
    "nameSeller": nameSeller,
    "lastnameSeller": lastnameSeller,
    "emailSeller": emailSeller,
    "phoneSeller": phoneSeller,
    "addressSeller": addressSeller,
    "idSeller": idSeller,
    "bdSeller": bdSeller,
    "genderSeller": genderSeller,
    "startDateSeller": startDateSeller,
    "roleSeller": roleSeller,
    "statusSeller": statusSeller,
  });
}

Future<void> statusChangerSellers(String sid, String statusSeller) async {
  await db.collection("sellers").doc(sid).update({
    "statusSeller": statusSeller,
  });
}

Future<double> getPeriodoDiscount(String periodo) async {
  DocumentSnapshot<Map<String, dynamic>> infoDiscount = await db
      .collection('infoproyecto')
      .doc('infopagos')
      .collection('infoCuotas')
      .doc(periodo)
      .get();
  final Map<String, dynamic> dataCuotas =
      infoDiscount.data() as Map<String, dynamic>;
  final cuotaInfo = {
    "dcto": dataCuotas['dcto'],
  };
  return (cuotaInfo['dcto'].toDouble());
}

Future<List> getPagoAdicional() async {
  List pagos = [];
  QuerySnapshot? queryPago = await db
      .collection('infoproyecto')
      .doc('infopagos')
      .collection('pagoAdicional')
      .get();
  for (var docPago in queryPago.docs) {
    final Map<String, dynamic> dataPago =
        docPago.data() as Map<String, dynamic>;
    final pago = {
      "pago": docPago.id,
      "dcto": dataPago['dcto'],
    };
    pagos.add(pago);
  }
  return pagos;
}

Future<void> updateInv(String inv, String name, String nit, String tel, String dir, String ciudad, String email,
    String nameRep, String idRep, String idLugar) async {
  await db.collection("infoproyecto").doc(inv).update({
    "name": name,
    "nit": nit,    
    "tel": tel,
    "dir": dir,
    "ciudad": ciudad,
    "email": email,
    "nameRep": nameRep,
    "idRep": idRep,
    "idLugar": idLugar,
  });
}

Future<Map<String, dynamic>> getInfoProyecto() async {
  DocumentSnapshot<Map<String, dynamic>> infoPagos =
      await db.collection('infoproyecto').doc('infopagos').get();
  final Map<String, dynamic> data = infoPagos.data() as Map<String, dynamic>;
  final proyectoInfo = {
    "cuotaInicial": data['cuotaInicial'],
    "dctoContado": data['dctoContado'],
    "plazoCuotaInicial": data['plazoCuotaInicial'],
    "plazoContado": data['plazoContado'],
    "tem": data['tem'],
    "valorSeparacion": data['valorSeparacion'],
    "maxCuotas": data['maxCuotas'],
    "plazoSaldoSep": data['plazoSaldoSep'],
  };
  return proyectoInfo;
}

Future<Map<String, dynamic>> getInversionista(String inv) async {
  DocumentSnapshot<Map<String, dynamic>> infoInversionista =
      await db.collection('infoproyecto').doc(inv).get();
  final Map<String, dynamic> data =
      infoInversionista.data() as Map<String, dynamic>;
  final inversionistaInfo = {
    "email": data['email'],
    "idLugar": data['idLugar'],
    "idRep": data['idRep'],
    "name": data['name'],
    "nameRep": data['nameRep'],
    "nit": data['nit'],
    "tel": data['tel'],
    "dir": data['dir'],
    "ciudad": data['ciudad']
  };
  return inversionistaInfo;
}

Future<void> deleteSeller(String sid) async {
  await db.collection("sellers").doc(sid).delete();
}

Future<void> addOrdenSep(
  String oid,
  String sellerID,
  String loteId,
  double priceLote,
  double precioFinal,
  double dctoLote,
  double perCILote,
  double vlrCILote,
  double vlrSepLote,
  String separacionDate,
  double saldoSepLote,
  String promesaDLDate,
  double plazoCI,
  double plazoContado,
  double saldoCILote,
  String saldoCIDLDate,
  double vlrPorPagarLote,
  String metodoPagoLote,
  String saldoTotalDate,
  String periodoCuotasLote,
  int nroCuotasLote,
  double vlrCuotasLote,
  double tem,
  String observacionesLote,
  String clienteID,
) async {
  await db.collection("ordSep").doc(oid).set({
    "sellerID": sellerID,
    "loteId": loteId,
    "priceLote": priceLote,
    "precioFinal": precioFinal,
    "dctoLote": dctoLote,
    "perCILote": perCILote,
    "vlrCILote": vlrCILote,
    "vlrSepLote": vlrSepLote,
    "separacionDate": separacionDate,
    "saldoSepLote": saldoSepLote,
    "promesaDLDate": promesaDLDate,
    "plazoCI": plazoCI,
    "plazoContado": plazoContado,
    "saldoCILote": saldoCILote,
    "saldoCIDLDate": saldoCIDLDate,
    "vlrPorPagarLote": vlrPorPagarLote,
    "metodoPagoLote": metodoPagoLote,
    "saldoTotalDate": saldoTotalDate,
    "periodoCuotasLote": periodoCuotasLote,
    "nroCuotasLote": nroCuotasLote,
    "vlrCuotasLote": vlrCuotasLote,
    "tem": tem,
    "observacionesLote": observacionesLote,
    "clienteID": clienteID,
    "stageSep": "ACTIVA"
  });
}

Future<void> updateCustomerGeneral(
  String qid, String lid, String cid
) async {
  await db.collection("ordSep").doc(qid).update({    
    "clienteID": cid,
  });
  await db.collection("quotes").doc(qid).update({    
    "clienteID": cid,
  });
  await db.collection("planPagos").doc(lid).update({    
    "idCliente": cid,
  });
}

Future<void> updateSepPromesa(
  String oid,  
  String observacionesLote
) async {
  await db.collection("ordSep").doc(oid).update({    
    "observacionesLote": observacionesLote,
    //"stageSep": "PROMESA"
  });
}

Future<void> updateOrdenSep(
  String oid,
  String sellerID,
  String loteId,
  double priceLote,
  double precioFinal,
  double dctoLote,
  double perCILote,
  double vlrCILote,
  double vlrSepLote,
  String separacionDate,
  double saldoSepLote,
  String promesaDLDate,
  double plazoCI,
  double plazoContado,
  double saldoCILote,
  String saldoCIDLDate,
  double vlrPorPagarLote,
  String metodoPagoLote,
  String saldoTotalDate,
  String periodoCuotasLote,
  int nroCuotasLote,
  double vlrCuotasLote,
  double tem,
  String observacionesLote,
  String clienteID,
) async {
  await db.collection("ordSep").doc(oid).update({
    "sellerID": sellerID,
    "loteId": loteId,
    "priceLote": priceLote,
    "precioFinal": precioFinal,
    "dctoLote": dctoLote,
    "perCILote": perCILote,
    "vlrCILote": vlrCILote,
    "vlrSepLote": vlrSepLote,
    "separacionDate": separacionDate,
    "saldoSepLote": saldoSepLote,
    "promesaDLDate": promesaDLDate,
    "plazoCI": plazoCI,
    "plazoContado": plazoContado,
    "saldoCILote": saldoCILote,
    "saldoCIDLDate": saldoCIDLDate,
    "vlrPorPagarLote": vlrPorPagarLote,
    "metodoPagoLote": metodoPagoLote,
    "saldoTotalDate": saldoTotalDate,
    "periodoCuotasLote": periodoCuotasLote,
    "nroCuotasLote": nroCuotasLote,
    "vlrCuotasLote": vlrCuotasLote,
    "tem": tem,
    "observacionesLote": observacionesLote,
    "clienteID": clienteID,
    "stageSep": "ACTIVA"
  });
}

Future<String?> getSepID(String selectedLote) async {
  QuerySnapshot querySnapshot = await db.collection("ordSep").get();

  // Iterate through the documents
  for (DocumentSnapshot doc in querySnapshot.docs) {
    // Check if the document ID contains the value of selectedLote
    if (doc.id.contains(selectedLote)) {
      // Return the document ID
      return doc.id;
    }
  }

  // If no document is found, return null
  return null;
}

Future<int> getPDFCount(String selectedLote) async {
  int count = 0;
  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("ordSep").doc(selectedLote).collection('pdf').get();

    if (querySnapshot.docs.isEmpty) {
      // You can name the document as per your logic here
    } else {
      count = querySnapshot.docs.length;
      // You can proceed with naming the document using the next possible value
    }
  // ignore: empty_catches
  } catch (e) {
  }
  return count;
}

Future<void> deletePDF(String sid, String pdf) async {
  int value = await getPDFCount(sid);
  await db.collection("ordSep").doc(sid).collection('pdf').doc(pdf).delete().whenComplete(() async {
    if(value <= 1) {
      await db.collection("ordSep").doc(sid).update({
        "PDFbool": false
    });
    }
  });
  
}

Future<void> updatePdfLink(String selectedLote, String pdfLote, String fileName, String obs) async {
  await db.collection("ordSep").doc(selectedLote).update({
    "PDFbool": true
  });
  await db.collection("ordSep").doc(selectedLote).collection('pdf').doc(fileName).set({    
    "PDF": pdfLote,
    "FileName": fileName,
    "Observaciones": obs,
    "date": DateTime.now()
  });
}

Future<List> getPDFList(String sepId) async {
  List pdfs = [];
  QuerySnapshot? queryPDF = await db.collection('ordSep').doc(sepId).collection('pdf').get();
  for (var doc in queryPDF.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // Convert timestamp to DateTime
    DateTime date = (data['date'] as Timestamp).toDate();
    final sep = {
      "pdfID": doc.id,
      "FileName": data['FileName'],
      "URL": data['PDF'],
      "obs": data['Observaciones'],
      "date": date.toString() // Convert DateTime to string
    };
    pdfs.add(sep);
  }
  // Sort the list based on date
  pdfs.sort((a, b) => a['date'].compareTo(b['date']));
  return pdfs;
}


Future<List> getOrdenSep(String loteId, bool allLotes, String sellerId) async {
  List separaciones = [];
  QuerySnapshot? querySeparaciones = await db.collection('ordSep').get();
  for (var doc in querySeparaciones.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if(sellerId == 'All' && data['stageSep']!="LOTE VENDIDO"){
      if (allLotes == false) {
        if (data['loteId'] == loteId) {
          final sep = {
            "sepId": doc.id,
            "sellerID":data['sellerID'],
            "loteId": data['loteId'],
            "priceLote": data['priceLote'],
            "precioFinal": data['precioFinal'],
            "dctoLote": data['dctoLote'],
            "perCILote": data['perCILote'],
            "vlrCILote": data['vlrCILote'],
            "vlrSepLote": data['vlrSepLote'],
            "separacionDate": data['separacionDate'],
            "saldoSepLote": data['saldoSepLote'],
            "promesaDLDate": data['promesaDLDate'],
            "plazoCI": data['plazoCI'],
            "plazoContado": data['plazoContado'],
            "saldoCILote": data['saldoCILote'],
            "saldoCIDLDate": data['saldoCIDLDate'],
            "vlrPorPagarLote": data['vlrPorPagarLote'],
            "metodoPagoLote": data['metodoPagoLote'],
            "saldoTotalDate": data['saldoTotalDate'],
            "periodoCuotasLote": data['periodoCuotasLote'],
            "nroCuotasLote": data['nroCuotasLote'],
            "vlrCuotasLote": data['vlrCuotasLote'],
            "tem": data['tem'],
            "observacionesLote": data['observacionesLote'],
            "clienteID": data['clienteID'],
            "stageSep": data['stageSep'],            
            "PDFbool": data['PDFbool'] == true
          };
          separaciones.add(sep);
        }
      } else {      
        final sep = {
          "sepId": doc.id,
          "sellerID":data['sellerID'],
          "loteId": data['loteId'],
          "priceLote": data['priceLote'],
          "precioFinal": data['precioFinal'],
          "dctoLote": data['dctoLote'],
          "perCILote": data['perCILote'],
          "vlrCILote": data['vlrCILote'],
          "vlrSepLote": data['vlrSepLote'],
          "separacionDate": data['separacionDate'],
          "saldoSepLote": data['saldoSepLote'],
          "promesaDLDate": data['promesaDLDate'],
          "plazoCI": data['plazoCI'],
          "plazoContado": data['plazoContado'],
          "saldoCILote": data['saldoCILote'],
          "saldoCIDLDate": data['saldoCIDLDate'],
          "vlrPorPagarLote": data['vlrPorPagarLote'],
          "metodoPagoLote": data['metodoPagoLote'],
          "saldoTotalDate": data['saldoTotalDate'],
          "periodoCuotasLote": data['periodoCuotasLote'],
          "nroCuotasLote": data['nroCuotasLote'],
          "vlrCuotasLote": data['vlrCuotasLote'],
          "tem": data['tem'],
          "observacionesLote": data['observacionesLote'],
          "clienteID": data['clienteID'],
          "stageSep": data['stageSep'],            
            "PDFbool": data['PDFbool'] == true
        };
        separaciones.add(sep);    
      }
    } else {
      if (allLotes == false && data['stageSep']!="LOTE VENDIDO") {
        if (data['loteId'] == loteId && data['sellerID'] == sellerId) {
          final sep = {
            "sepId": doc.id,
            "sellerID":data['sellerID'],
            "loteId": data['loteId'],
            "priceLote": data['priceLote'],
            "precioFinal": data['precioFinal'],
            "dctoLote": data['dctoLote'],
            "perCILote": data['perCILote'],
            "vlrCILote": data['vlrCILote'],
            "vlrSepLote": data['vlrSepLote'],
            "separacionDate": data['separacionDate'],
            "saldoSepLote": data['saldoSepLote'],
            "promesaDLDate": data['promesaDLDate'],
            "plazoCI": data['plazoCI'],
            "plazoContado": data['plazoContado'],
            "saldoCILote": data['saldoCILote'],
            "saldoCIDLDate": data['saldoCIDLDate'],
            "vlrPorPagarLote": data['vlrPorPagarLote'],
            "metodoPagoLote": data['metodoPagoLote'],
            "saldoTotalDate": data['saldoTotalDate'],
            "periodoCuotasLote": data['periodoCuotasLote'],
            "nroCuotasLote": data['nroCuotasLote'],
            "vlrCuotasLote": data['vlrCuotasLote'],
            "tem": data['tem'],
            "observacionesLote": data['observacionesLote'],
            "clienteID": data['clienteID'],
            "stageSep": data['stageSep'],            
            "PDFbool": data['PDFbool'] == true
          };
          separaciones.add(sep);
        }
      } else {      
        if(data['sellerID'] == sellerId && data['stageSep']!="LOTE VENDIDO"){
          final sep = {
            "sepId": doc.id,
            "sellerID":data['sellerID'],
            "loteId": data['loteId'],
            "priceLote": data['priceLote'],
            "precioFinal": data['precioFinal'],
            "dctoLote": data['dctoLote'],
            "perCILote": data['perCILote'],
            "vlrCILote": data['vlrCILote'],
            "vlrSepLote": data['vlrSepLote'],
            "separacionDate": data['separacionDate'],
            "saldoSepLote": data['saldoSepLote'],
            "promesaDLDate": data['promesaDLDate'],
            "plazoCI": data['plazoCI'],
            "plazoContado": data['plazoContado'],
            "saldoCILote": data['saldoCILote'],
            "saldoCIDLDate": data['saldoCIDLDate'],
            "vlrPorPagarLote": data['vlrPorPagarLote'],
            "metodoPagoLote": data['metodoPagoLote'],
            "saldoTotalDate": data['saldoTotalDate'],
            "periodoCuotasLote": data['periodoCuotasLote'],
            "nroCuotasLote": data['nroCuotasLote'],
            "vlrCuotasLote": data['vlrCuotasLote'],
            "tem": data['tem'],
            "observacionesLote": data['observacionesLote'],
            "clienteID": data['clienteID'],
            "stageSep": data['stageSep'],            
            "PDFbool": data['PDFbool'] == true
          };
          separaciones.add(sep);
        }
      }
    }
  }
  separaciones.sort((a, b) => a['loteId'].compareTo(b['loteId']));
  return separaciones;
}

Future<List> getPromesa(String loteId, bool allLotes, String sellerId) async {
  List promesa = [];
  QuerySnapshot? queryProm = await db.collection('ordSep').get();
  for (var doc in queryProm.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (sellerId == 'All' && (data['stageSep']=="ACTIVA" || data['stageSep']=="LOTE VENDIDO")){
      if (!allLotes) {
        if (data['loteId'] == loteId) {
          final prom = {
            "sepId": doc.id,
            "sellerID": data['sellerID'],
            "loteId": data['loteId'],
            "clienteID": data['clienteID'],
            "stageSep": data['stageSep'],
            "PdfName": data['FileName'],
            "PdfLink": data['PDF'],            
            "PDFbool": data['PDFbool'] == true
          };
          promesa.add(prom);
        }
      } else {      
        final prom = {
            "sepId": doc.id,
            "sellerID": data['sellerID'],
            "loteId": data['loteId'],
            "clienteID": data['clienteID'],
            "stageSep": data['stageSep'],
            "PdfName": data['FileName'],
            "PdfLink": data['PDF'],            
            "PDFbool": data['PDFbool'] == true
        };
        promesa.add(prom);    
      }
    } else {
      if (!allLotes && (data['stageSep']=="ACTIVA" || data['stageSep']=="LOTE VENDIDO")) {
        if (data['loteId'] == loteId && data['sellerID'] == sellerId) {
          final prom = {
            "sepId": doc.id,
            "sellerID": data['sellerID'],
            "loteId": data['loteId'],
            "clienteID": data['clienteID'],
            "stageSep": data['stageSep'],
            "PdfName": data['FileName'],
            "PdfLink": data['PDF'],            
            "PDFbool": data['PDFbool'] == true
          };
          promesa.add(prom);
        }
      } else {      
        if(data['sellerID'] == sellerId && (data['stageSep']=="ACTIVA" || data['stageSep']=="LOTE VENDIDO")){
          final prom = {
            "sepId": doc.id,
            "sellerID": data['sellerID'],
            "loteId": data['loteId'],
            "clienteID": data['clienteID'],
            "stageSep": data['stageSep'],
            "PdfName": data['FileName'],
            "PdfLink": data['PDF'],            
            "PDFbool": data['PDFbool'] == true
          };
          promesa.add(prom);
        }
      }
    }
  }
  promesa.sort((a, b) => a['loteId'].compareTo(b['loteId']));
  return promesa;
}


Future<void> deleteSep(String oid, String lote) async {
  await db.collection("ordSep").doc(oid).delete();
  CollectionReference paymentsCollection = FirebaseFirestore.instance
    .collection('planPagos')
    .doc(lote)
    .collection('pagosEsperados');

  QuerySnapshot querySnapshot = await paymentsCollection.get();

  for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
    await documentSnapshot.reference.delete();
  }
  await db.collection("planPagos").doc(lote).delete();
}

Future<void> updateQuoteStage(String qid, String quoteStage) async {
  await db.collection("quotes").doc(qid).update({"quoteStage": quoteStage});
}

Future<void> updateQuoteForSep(
    String qid,
    String sellerID,
    String loteId,
    String loteName,
    String etapaLote,
    String areaLote,
    double priceLote,
    double precioFinal,
    double dctoLote,
    double perCILote,
    double vlrCILote,
    double vlrSepLote,
    String sepDLDate,
    double saldoSepLote,
    String saldoSepDLDate,
    double plazoCI,
    double plazoContado,
    double saldoCILote,
    String saldoCIDLDate,
    double vlrPorPagarLote,
    String metodoPagoLote,
    String saldoTotalDate,
    String periodoCuotasLote,
    int nroCuotasLote,
    double vlrCuotasLote,
    double tem,
    String observacionesLote,
    String clienteID,
    String quoteStage) async {
  await db.collection("quotes").doc(qid).update({
    "sellerID": sellerID,
    "loteId": loteId,
    "loteName": loteName,
    "etapaLote": etapaLote,
    "areaLote": areaLote,
    "priceLote": priceLote,
    "precioFinal": precioFinal,
    "dctoLote": dctoLote,
    "perCILote": perCILote,
    "vlrCILote": vlrCILote,
    "vlrSepLote": vlrSepLote,
    "sepDLDate": sepDLDate,
    "saldoSepLote": saldoSepLote,
    "saldoSepDLDate": saldoSepDLDate,
    "plazoCI": plazoCI,
    "plazoContado": plazoContado,
    "saldoCILote": saldoCILote,
    "saldoCIDLDate": saldoCIDLDate,
    "vlrPorPagarLote": vlrPorPagarLote,
    "metodoPagoLote": metodoPagoLote,
    "saldoTotalDate": saldoTotalDate,
    "periodoCuotasLote": periodoCuotasLote,
    "nroCuotasLote": nroCuotasLote,
    "vlrCuotasLote": vlrCuotasLote,
    "tem": tem,
    "observacionesLote": observacionesLote,
    "clienteID": clienteID,
    "quoteStage": quoteStage
  });
}

Future<void> updateQuote(
    String qid,
    String sellerID,
    String quoteDate,
    String quoteDLDate,
    String loteId,
    String loteName,
    String etapaLote,
    String areaLote,
    double priceLote,
    double precioFinal,
    double dctoLote,
    double perCILote,
    double vlrCILote,
    double vlrSepLote,
    String sepDLDate,
    double saldoSepLote,
    String saldoSepDLDate,
    double plazoCI,
    double plazoContado,
    double saldoCILote,
    String saldoCIDLDate,
    double vlrPorPagarLote,
    String metodoPagoLote,
    String saldoTotalDate,
    String periodoCuotasLote,
    int nroCuotasLote,
    double vlrCuotasLote,
    double tem,
    String observacionesLote,
    String clienteID,
    String quoteStage) async {
  await db.collection("quotes").doc(qid).update({
    "sellerID": sellerID,
    "quoteDate": quoteDate,
    "quoteDLDate": quoteDLDate,
    "loteId": loteId,
    "loteName": loteName,
    "etapaLote": etapaLote,
    "areaLote": areaLote,
    "priceLote": priceLote,
    "precioFinal": precioFinal,
    "dctoLote": dctoLote,
    "perCILote": perCILote,
    "vlrCILote": vlrCILote,
    "vlrSepLote": vlrSepLote,
    "sepDLDate": sepDLDate,
    "saldoSepLote": saldoSepLote,
    "saldoSepDLDate": saldoSepDLDate,
    "plazoCI": plazoCI,
    "plazoContado": plazoContado,
    "saldoCILote": saldoCILote,
    "saldoCIDLDate": saldoCIDLDate,
    "vlrPorPagarLote": vlrPorPagarLote,
    "metodoPagoLote": metodoPagoLote,
    "saldoTotalDate": saldoTotalDate,
    "periodoCuotasLote": periodoCuotasLote,
    "nroCuotasLote": nroCuotasLote,
    "vlrCuotasLote": vlrCuotasLote,
    "tem": tem,
    "observacionesLote": observacionesLote,
    "clienteID": clienteID,
    "quoteStage": quoteStage
  });
}

Future<void> addQuote(
    String qid,
    String sellerID,
    String quoteDate,
    String quoteDLDate,
    String loteId,
    String loteName,
    String etapaLote,
    String areaLote,
    double priceLote,
    double precioFinal,
    double dctoLote,
    double perCILote,
    double vlrCILote,
    double vlrSepLote,
    String sepDLDate,
    double saldoSepLote,
    String saldoSepDLDate,
    double plazoCI,
    double plazoContado,
    double saldoCILote,
    String saldoCIDLDate,
    double vlrPorPagarLote,
    String metodoPagoLote,
    String saldoTotalDate,
    String periodoCuotasLote,
    int nroCuotasLote,
    double vlrCuotasLote,
    double tem,
    String observacionesLote,
    String clienteID,
    String quoteStage) async {
  await db.collection("quotes").doc(qid).set({
    "sellerID": sellerID,
    "quoteDate": quoteDate,
    "quoteDLDate": quoteDLDate,
    "loteId": loteId,
    "loteName": loteName,
    "etapaLote": etapaLote,
    "areaLote": areaLote,
    "priceLote": priceLote,
    "precioFinal": precioFinal,
    "dctoLote": dctoLote,
    "perCILote": perCILote,
    "vlrCILote": vlrCILote,
    "vlrSepLote": vlrSepLote,
    "sepDLDate": sepDLDate,
    "saldoSepLote": saldoSepLote,
    "saldoSepDLDate": saldoSepDLDate,
    "plazoCI": plazoCI,
    "plazoContado": plazoContado,
    "saldoCILote": saldoCILote,
    "saldoCIDLDate": saldoCIDLDate,
    "vlrPorPagarLote": vlrPorPagarLote,
    "metodoPagoLote": metodoPagoLote,
    "saldoTotalDate": saldoTotalDate,
    "periodoCuotasLote": periodoCuotasLote,
    "nroCuotasLote": nroCuotasLote,
    "vlrCuotasLote": vlrCuotasLote,
    "tem": tem,
    "observacionesLote": observacionesLote,
    "clienteID": clienteID,
    "quoteStage": quoteStage,
    "isActive": true,
  });
}

Future<List> getQuotes(String loteName, bool allLotes, bool archive, String sellerId) async {
  List quotes = [];
  QuerySnapshot? queryQuotes = await db.collection('quotes').get();
  for (var doc in queryQuotes.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if(sellerId == 'All'){
      if (allLotes == false) {
        if (data['loteName'] == loteName && data['isActive'] == archive) {          
          final quote = {
            "qid": doc.id,
            "sellerID": data['sellerID'],
            "quoteDate": data['quoteDate'],
            "quoteDLDate": data['quoteDLDate'],
            "loteId": data['loteId'],
            "loteName": data['loteName'],
            "etapaLote": data['etapaLote'],
            "areaLote": data['areaLote'],
            "priceLote": data['priceLote'],
            "precioFinal": data['precioFinal'],
            "dctoLote": data['dctoLote'],
            "perCILote": data['perCILote'],
            "vlrCILote": data['vlrCILote'],
            "vlrSepLote": data['vlrSepLote'],
            "sepDLDate": data['sepDLDate'],
            "saldoSepLote": data['saldoSepLote'],
            "saldoSepDLDate": data['saldoSepDLDate'],
            "plazoCI": data['plazoCI'],
            "plazoContado": data['plazoContado'],
            "saldoCILote": data['saldoCILote'],
            "saldoCIDLDate": data['saldoCIDLDate'],
            "vlrPorPagarLote": data['vlrPorPagarLote'],
            "metodoPagoLote": data['metodoPagoLote'],
            "saldoTotalDate": data['saldoTotalDate'],
            "periodoCuotasLote": data['periodoCuotasLote'],
            "nroCuotasLote": data['nroCuotasLote'],
            "vlrCuotasLote": data['vlrCuotasLote'],
            "tem": data['tem'],
            "observacionesLote": data['observacionesLote'],
            "clienteID": data['clienteID'],
            "quoteStage": data['quoteStage'],
            "isActive": data['isActive'],
          };
          quotes.add(quote);                    
        }
      } else {
        if (data['isActive'] == archive) {
          if(data['quoteStage'] == 'AUTORIZADA' || data['quoteStage'] == 'CREADA' )  {
            final quote = {
              "qid": doc.id,
              "sellerID": data['sellerID'],
              "quoteDate": data['quoteDate'],
              "quoteDLDate": data['quoteDLDate'],
              "loteId": data['loteId'],
              "loteName": data['loteName'],
              "etapaLote": data['etapaLote'],
              "areaLote": data['areaLote'],
              "priceLote": data['priceLote'],
              "precioFinal": data['precioFinal'],
              "dctoLote": data['dctoLote'],
              "perCILote": data['perCILote'],
              "vlrCILote": data['vlrCILote'],
              "vlrSepLote": data['vlrSepLote'],
              "sepDLDate": data['sepDLDate'],
              "saldoSepLote": data['saldoSepLote'],
              "saldoSepDLDate": data['saldoSepDLDate'],
              "plazoCI": data['plazoCI'],
              "plazoContado": data['plazoContado'],
              "saldoCILote": data['saldoCILote'],
              "saldoCIDLDate": data['saldoCIDLDate'],
              "vlrPorPagarLote": data['vlrPorPagarLote'],
              "metodoPagoLote": data['metodoPagoLote'],
              "saldoTotalDate": data['saldoTotalDate'],
              "periodoCuotasLote": data['periodoCuotasLote'],
              "nroCuotasLote": data['nroCuotasLote'],
              "vlrCuotasLote": data['vlrCuotasLote'],
              "tem": data['tem'],
              "observacionesLote": data['observacionesLote'],
              "clienteID": data['clienteID'],
              "quoteStage": data['quoteStage'],
              "isActive": data['isActive'],
            };
            quotes.add(quote);
          }
        }
      }
    } else {
      if (allLotes == false) {
        if (data['loteName'] == loteName && data['isActive'] == archive && data['sellerID'] == sellerId) {
          final quote = {
            "qid": doc.id,
            "sellerID": data['sellerID'],
            "quoteDate": data['quoteDate'],
            "quoteDLDate": data['quoteDLDate'],
            "loteId": data['loteId'],
            "loteName": data['loteName'],
            "etapaLote": data['etapaLote'],
            "areaLote": data['areaLote'],
            "priceLote": data['priceLote'],
            "precioFinal": data['precioFinal'],
            "dctoLote": data['dctoLote'],
            "perCILote": data['perCILote'],
            "vlrCILote": data['vlrCILote'],
            "vlrSepLote": data['vlrSepLote'],
            "sepDLDate": data['sepDLDate'],
            "saldoSepLote": data['saldoSepLote'],
            "saldoSepDLDate": data['saldoSepDLDate'],
            "plazoCI": data['plazoCI'],
            "plazoContado": data['plazoContado'],
            "saldoCILote": data['saldoCILote'],
            "saldoCIDLDate": data['saldoCIDLDate'],
            "vlrPorPagarLote": data['vlrPorPagarLote'],
            "metodoPagoLote": data['metodoPagoLote'],
            "saldoTotalDate": data['saldoTotalDate'],
            "periodoCuotasLote": data['periodoCuotasLote'],
            "nroCuotasLote": data['nroCuotasLote'],
            "vlrCuotasLote": data['vlrCuotasLote'],
            "tem": data['tem'],
            "observacionesLote": data['observacionesLote'],
            "clienteID": data['clienteID'],
            "quoteStage": data['quoteStage'],
            "isActive": data['isActive'],
          };
          quotes.add(quote);
        }
      } else {
        if (data['isActive'] == archive && data['sellerID'] == sellerId) {
          if(data['quoteStage'] == 'AUTORIZADA' || data['quoteStage'] == 'CREADA' )  {
            final quote = {
              "qid": doc.id,
              "sellerID": data['sellerID'],
              "quoteDate": data['quoteDate'],
              "quoteDLDate": data['quoteDLDate'],
              "loteId": data['loteId'],
              "loteName": data['loteName'],
              "etapaLote": data['etapaLote'],
              "areaLote": data['areaLote'],
              "priceLote": data['priceLote'],
              "precioFinal": data['precioFinal'],
              "dctoLote": data['dctoLote'],
              "perCILote": data['perCILote'],
              "vlrCILote": data['vlrCILote'],
              "vlrSepLote": data['vlrSepLote'],
              "sepDLDate": data['sepDLDate'],
              "saldoSepLote": data['saldoSepLote'],
              "saldoSepDLDate": data['saldoSepDLDate'],
              "plazoCI": data['plazoCI'],
              "plazoContado": data['plazoContado'],
              "saldoCILote": data['saldoCILote'],
              "saldoCIDLDate": data['saldoCIDLDate'],
              "vlrPorPagarLote": data['vlrPorPagarLote'],
              "metodoPagoLote": data['metodoPagoLote'],
              "saldoTotalDate": data['saldoTotalDate'],
              "periodoCuotasLote": data['periodoCuotasLote'],
              "nroCuotasLote": data['nroCuotasLote'],
              "vlrCuotasLote": data['vlrCuotasLote'],
              "tem": data['tem'],
              "observacionesLote": data['observacionesLote'],
              "clienteID": data['clienteID'],
              "quoteStage": data['quoteStage'],
              "isActive": data['isActive'],
            };
            quotes.add(quote);
          }
        }
      }
    }
  }
  quotes.sort((a, b) => a['loteId'].compareTo(b['loteId']));
  return quotes;
}

Future<void> archiveQuote(String qid) async {
  await db.collection("quotes").doc(qid).update({'isActive': false});
}

Future<void> activateQuote(String qid) async {
  await db.collection("quotes").doc(qid).update({'isActive': true});
}

Future<void> updateCustomer(
    String clienteID,
    String nameCliente,
    String lastnameCliente,
    String genderCliente,
    String bdayCliente,
    String ocupacionCliente,
    String telCliente,
    String idTypeCliente,
    String idIssueCountryCliente,
    String idIssueStateCliente,
    String idIssueCityCliente,
    String emailCliente,
    String addressCliente,
    String countryCliente,
    String stateCliente,
    String cityCliente) async {
  await db.collection("customers").doc(clienteID).update({
    "nameCliente": nameCliente,
    "lastnameCliente": lastnameCliente,
    "genderCliente": genderCliente,
    "bdayCliente": bdayCliente,
    "ocupacionCliente": ocupacionCliente,
    "telCliente": telCliente,
    "idTypeCliente": idTypeCliente,
    "idIssueCountryCliente": idIssueCountryCliente,
    "idIssueStateCliente": idIssueStateCliente,
    "idIssueCityCliente": idIssueCityCliente,
    "emailCliente": emailCliente,
    "addressCliente": addressCliente,
    "countryCliente": countryCliente,
    "stateCliente": stateCliente,
    "cityCliente": cityCliente,
  });
}

Future<void> addCustomer(
    String clienteID,
    String nameCliente,
    String lastnameCliente,
    String genderCliente,
    String bdayCliente,
    String ocupacionCliente,
    String telCliente,
    String idTypeCliente,
    String idIssueCountryCliente,
    String idIssueStateCliente,
    String idIssueCityCliente,
    String emailCliente,
    String addressCliente,
    String countryCliente,
    String stateCliente,
    String cityCliente) async {
  await db.collection("customers").doc(clienteID).set({
    "nameCliente": nameCliente,
    "lastnameCliente": lastnameCliente,
    "genderCliente": genderCliente,
    "bdayCliente": bdayCliente,
    "ocupacionCliente": ocupacionCliente,
    "telCliente": telCliente,
    "idTypeCliente": idTypeCliente,
    "idIssueCountryCliente": idIssueCountryCliente,
    "idIssueStateCliente": idIssueStateCliente,
    "idIssueCityCliente": idIssueCityCliente,
    "emailCliente": emailCliente,
    "addressCliente": addressCliente,
    "countryCliente": countryCliente,
    "stateCliente": stateCliente,
    "cityCliente": cityCliente,
  });
}

Future<List> getCustomers() async {
  List customers = [];
  QuerySnapshot? queryCustomers = await db.collection('customers').get();
  for (var doc in queryCustomers.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final customer = {
      "clienteID": doc.id,
      "nameCliente": data["nameCliente"],
      "lastnameCliente": data["lastnameCliente"],
      "genderCliente": data["genderCliente"],
      "bdayCliente": data["bdayCliente"],
      "ocupacionCliente": data["ocupacionCliente"],
      "telCliente": data["telCliente"],
      "idTypeCliente": data["idTypeCliente"],
      "idIssueCountryCliente": data["idIssueCountryCliente"],
      "idIssueStateCliente": data["idIssueStateCliente"],
      "idIssueCityCliente": data["idIssueCityCliente"],
      "emailCliente": data["emailCliente"],
      "addressCliente": data["addressCliente"],
      "countryCliente": data["countryCliente"],
      "stateCliente": data["stateCliente"],
      "cityCliente": data["cityCliente"]
    };
    customers.add(customer);
  }
  return customers;
}

Future<List> getLotes() async {
  List lotes = [];
  QuerySnapshot? queryLotes = await db.collection('lotes').get();
  for (var doc in queryLotes.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final lote = {
      "loteName": data['loteName'],
      "loteId": doc.id,
      "loteLeft": data['loteLeft'],
      "loteTop": data['loteTop'],
      "loteRight": data['loteRight'],
      "loteBottom": data['loteBottom'],
      "loteEtapa": data['loteEtapa'],
      "loteArea": data['loteArea'],
      "lotePrice": data['lotePrice'],
      "loteState": data['loteState'],
      "loteImg": data['loteImg'],
      "loteInfoIMG": data['loteInfoIMG'],
      "loteLinderos": data['loteLinderos'],
    };
    lotes.add(lote);
  }
  return lotes;
}



Future<void> addLotes(
    String idLote,
    String loteName,
    double loteLeft,
    double loteTop,
    double loteRight,
    double loteBottom,
    String loteEtapa,
    String loteState,
    double loteArea,
    double lotePrice,
    String loteImg) async {
  await db.collection("lotes").doc(idLote).set({
    "loteName": loteName,
    "loteLeft": loteLeft,
    "loteTop": loteTop,
    "loteRight": loteRight,
    "loteBottom": loteBottom,
    "loteEtapa": loteEtapa,
    "loteState": loteState,
    "loteArea": loteArea,
    "lotePrice": lotePrice,
    "loteImg": loteImg,
  });
}

Future<void> updateLote(
    String idLote, double lotePrice, String loteLinderos) async {
  await db.collection("lotes").doc(idLote).update({
    "lotePrice": lotePrice,
    "loteLinderos": loteLinderos,
  });
}

Future<void> cambioEstadoLote(String idLote, String statusLote, bool cambioEst) async {
  String tempState = 'Disponible';
  if (statusLote == 'LOTE SEPARADO' ) {
    tempState = 'Lote separado';
  } else if(cambioEst == false){
    tempState = statusLote;
  } else {
    tempState = 'Lote vendido';
  }
  await db.collection("lotes").doc(idLote).update({"loteState": tempState});
}

Future<void> cancSepLote(String idLote) async {
  await db.collection("lotes").doc(idLote).update({"loteState": 'Disponible'});
}

Future<void> addLoteImg(String idLote) async {
  await db.collection("lotes").doc(idLote).update({
    "loteLinderos": 'Linderos',
  });
}

Future<List> getEtapas() async {
  List etapas = [];
  QuerySnapshot? queryLotes = await db.collection('etapas').get();
  for (var doc in queryLotes.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final etapa = {
      "etapaName": data['etapaName'],
      "etapaId": doc.id,
      "infoEtapa": data['infoEtapa'],
      "imgEtapa": data['imgEtapa'],
    };
    etapas.add(etapa);
  }
  return etapas;
}

Future<void> addCountries(
  String countryName,
) async {
  await db.collection("countries").add({
    "countryName": countryName,
  });
}

Future<List> getCountries() async {
  List countries = [];
  QuerySnapshot? queryCountries = await db.collection('countries').get();
  for (var doc in queryCountries.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final country = {
      "countryName": data['countryName'],
      "cid": doc.id,
    };
    countries.add(country);
  }
  return countries;
}

Future<void> addCities(String cityName, String stateName) async {
  await db.collection("cities").add({
    "cityName": cityName,
    "stateName": stateName,
  });
}

Future<List> getCities() async {
  List cities = [];

  QuerySnapshot? queryCities = await db.collection('cities').get();
  for (var doc in queryCities.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final city = {
      if (data['stateName'] != 'Otros')
        {
          "cityName": data['cityName'],
          "ciid": doc.id,
          "stateName": data['stateName'],
          "countryName": "Colombia"
        }
      else
        {
          "cityName": data['cityName'],
          "ciid": doc.id,
          "stateName": data['stateName'],
          "countryName": "Otros"
        }
    };
    cities.add(city);
  }
  return cities;
}

Future<List<String>> getOcupaciones() async {
  List<String> ocupaciones = [];
  QuerySnapshot? queryOcupaciones = await db.collection('ocupaciones').get();
  for (var doc in queryOcupaciones.docs) {
    ocupaciones.add(doc.id);
  }
  return ocupaciones;
}

Future<void> guardarOcupacion(String ocupacion) async {
  await db.collection("ocupaciones").doc(ocupacion.toUpperCase()).set({});
}
