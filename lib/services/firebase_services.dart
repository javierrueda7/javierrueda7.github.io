import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<void> addPlanPagos(String lote, String idPlanPagos, double precioIni, double precioFin, double dcto, double valorSeparacion, double porcCI, String estadoPago, double saldoPorPagar, double valorPagado) async{
  await db.collection("planPagos").doc(lote).set({
    "idPlanPagos": idPlanPagos,
    "precioIni": precioIni,
    "precioFin": precioFin,
    "dcto": dcto,
    "valorSeparacion": valorSeparacion,
    "porcCI": porcCI,
    "estadoPago": estadoPago,
    "saldoPorPagar": saldoPorPagar,
    "valorPagado": valorPagado
  });
}

Future<void> updatePlanPagos(String lote, double precioIni, double precioFin, double dcto, String estadoPago, double saldoPorPagar, double valorPagado) async{
  await db.collection("planPagos").doc(lote).update({
    "precioIni": precioIni,
    "precioFin": precioFin,
    "dcto": dcto,
    "estadoPago": estadoPago,
    "saldoPorPagar": saldoPorPagar,
    "valorPagado": valorPagado
  });
}

Future<void> pagosEsperados(String lote, String idPago, double valorPago, String conceptoPago, String fechaPago) async{
  await db.collection("planPagos").doc(lote).collection("pagosEsperados").doc(idPago).set({
    "valorPago": valorPago,
    "conceptoPago": conceptoPago,
    "fechaPago": fechaPago,
  });
}

Future<void> pagosRealizados(String lote, String idPago, double valorPago, String conceptoPago, String fechaRecibo, String fechaPago, String metodoPago, String nombreCliente, String idCliente, String telCliente, String emailCliente, String dirCliente, String ciudadCliente, String obsPago) async{
  await db.collection("planPagos").doc(lote).collection("pagosRealizados").doc(idPago).set({
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
    "obsPago": obsPago
  });
}

Future<List> getPagos(String lote) async{
  List pagos = [];
  QuerySnapshot? queryPagos = await db.collection('planPagos').doc(lote).collection('pagosRealizados').get();
  for (var doc in queryPagos.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
      "obsPago": data['obsPago']
    };
    pagos.add(pago);
  }
  return pagos;
}

Future<void> deletePagos(String pid, String lote, double valor) async {
  await db.collection("planPagos").doc(lote).collection('pagosRealizados').doc(pid).delete();
  
  final DocumentSnapshot doc = await db.collection("planPagos").doc(lote).get();
  final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  
  final double saldoPorPagar = (data["saldoPorPagar"] ?? 0) + valor;
  final double valorPagado = (data["valorPagado"] ?? 0) - valor;
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

Future<List> getOrdenSep(String loteId, bool allLotes, String sellerId) async {
  List separaciones = [];
  QuerySnapshot? querySeparaciones = await db.collection('ordSep').get();
  for (var doc in querySeparaciones.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if(sellerId == 'All'){
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
            "stageSep": data['stageSep']
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
          "stageSep": data['stageSep']
        };
        separaciones.add(sep);    
      }
    } else {
      if (allLotes == false) {
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
            "stageSep": data['stageSep']
          };
          separaciones.add(sep);
        }
      } else {      
        if(data['sellerID'] == sellerId){
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
            "stageSep": data['stageSep']
          };
          separaciones.add(sep);
        }
      }
    }
  }
  return separaciones;
}

Future<void> deleteSep(String oid) async {
  await db.collection("ordSep").doc(oid).delete();
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

Future<void> cambioEstadoLote(String idLote, String statusLote) async {
  String tempState = 'Disponible';
  if (statusLote == 'LOTE SEPARADO') {
    tempState = 'Lote separado';
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
