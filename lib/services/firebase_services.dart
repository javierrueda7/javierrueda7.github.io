import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getRoles() async {
  List roles = [];
  QuerySnapshot? queryRoles = await db.collection('roles').get();
  for (var docRole in queryRoles.docs){
    final Map<String, dynamic> dataRole = docRole.data() as Map<String, dynamic>;
    final rol = {
      "roleId": dataRole['roleId'],
      "rid": docRole.id,
      "roleName": dataRole['roleName'],
    };
    roles.add(rol);
  }
  return roles;
}

Future<List> getUsers() async {
  List users = [];
  QuerySnapshot? queryUsers = await db.collection('users').get();
  for (var doc in queryUsers.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final person = {
      "nameUser": data['nameUser'],
      "uid": doc.id,
      "lastnameUser": data['lastnameUser'],
      "emailUser": data['emailUser'],
      "phoneUser": data['phoneUser'],
    };
    users.add(person);
  }
  return users;
}

Future<void> addUsers(String uid, String nameUser, String lastnameUser, String emailUser, String phoneUser, String addressUser, String idUser) async {
  await db.collection("users").doc(uid).set({
    "nameUser": nameUser, 
    "lastnameUser": lastnameUser, 
    "emailUser": emailUser, 
    "phoneUser": phoneUser,
    "addressUser": addressUser,
    "idUser": idUser
    }
  );
}

Future<List> getCuotas() async {
  List cuotas = [];
  QuerySnapshot? queryCuotas = await db.collection('infoProyecto').doc('infopagos').collection('infoCuotas').get();
  for (var docCuotas in queryCuotas.docs){
    final Map<String, dynamic> dataCuotas = docCuotas.data() as Map<String, dynamic>;
    final cuota = {
      "periodos": docCuotas.id,
      "dcto": dataCuotas['dcto'],
    };
    cuotas.add(cuota);
  }
  return cuotas;
}

Future<List> getPagoAdicional() async {
  List pagos = [];
  QuerySnapshot? queryPago = await db.collection('infoProyecto').doc('infopagos').collection('pagoAdicional').get();
  for (var docPago in queryPago.docs){
    final Map<String, dynamic> dataPago = docPago.data() as Map<String, dynamic>;
    final pago = {
      "pago": docPago.id,
      "dcto": dataPago['dcto'],
    };
    pagos.add(pago);
  }
  return pagos;
}

Future<Map<String, dynamic>> getInfoProyecto() async {
  DocumentSnapshot<Map<String, dynamic>> infoPagos = await db.collection('infoproyecto').doc('infopagos').get();
  final Map<String, dynamic> data = infoPagos.data() as Map<String, dynamic>;
  final proyectoInfo = {
    "cuotaInicial": data['cuotaInicial'],
    "dctoContado": data['dctoContado'],
    "plazoCuotaInicial": data['plazoCuotaInicial'],
    "tem": data['tem'],
    "valorSeparacion": data['valorSeparacion'],
  };
  return proyectoInfo;
}

Future<void> updateUsers(String? uid, String? newUsername, String? newName, String? newEmail, String? newPhone, String? newRole) async {
  await db.collection("users").doc(uid).set({
    "username": newUsername,
    "name": newName,
    "email": newEmail, 
    "phone": newPhone,
    "role": newRole,
    }
  );
}

Future<void> deleteUsers(String uid) async {
  await db.collection("users").doc(uid).delete();
}

Future<void> addQuote(
  String qid, 
  String sellerID,
  String quoteDate, 
  String quoteDLDate, 
  String loteName, 
  String etapaLote, 
  String areaLote,
  String priceLote,
  double perCILote,
  String vlrCILote,
  String vlrSepLote,
  String sepDLDate, 
  String saldoSepLote,
  String saldoSepDLDate,
  String saldoCILote,
  String saldoCIDLDate, 
  String vlrPorPagarLote,
  String metodoPagoLote,
  String pagoContadoDLLote,
  String statementsStartDateLote,
  int nroCuotasLote,
  String vlrCuotasLote,
  String observacionesLote,
  String clienteID,
  String quoteStage) async {
  await db.collection("quotes").doc(qid).set({
    "sellerID": sellerID,
    "quoteDate": quoteDate,
    "quoteDLDate": quoteDLDate,
    "loteName": loteName, 
    "etapaLote": etapaLote, 
    "areaLote": areaLote, 
    "priceLote": priceLote,
    "perCILote": perCILote,
    "vlrCILote": vlrCILote,
    "vlrSepLote": vlrSepLote,
    "sepDLDate": sepDLDate,
    "saldoSepLote": saldoSepLote,
    "saldoSepDLDate": saldoSepDLDate,
    "saldoCILote": saldoCILote,
    "saldoCIDLDate": saldoCIDLDate,
    "vlrPorPagarLote": vlrPorPagarLote,
    "metodoPagoLote": metodoPagoLote,
    "pagoContadoDLLote": pagoContadoDLLote,
    "statementsStartDateLote": statementsStartDateLote,
    "nroCuotasLote": nroCuotasLote,
    "vlrCuotasLote": vlrCuotasLote,
    "observacionesLote": observacionesLote,
    "clienteID": clienteID,
    "quoteStage": quoteStage
    }
  );
}

Future<List> getQuotes(String loteName, bool allLotes) async {
  List quotes = [];
  QuerySnapshot? queryQuotes = await db.collection('quotes').get();
  for (var doc in queryQuotes.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if (allLotes == false) {
      if (data['loteName'] == loteName && data['quoteStage'] == 'EN ESPERA') {
        final quote = {
          "qid": doc.id,
          "sellerID": data['sellerID'],
          "quoteDate": data['quoteDate'],
          "quoteDLDate": data['quoteDLDate'],
          "loteName": data['loteName'],
          "etapaLote": data['etapaLote'],
          "areaLote": data['areaLote'],
          "priceLote": data['priceLote'],
          "perCILote": data['perCILote'],
          "vlrCILote": data['vlrCILote'],
          "vlrSepLote": data['vlrSepLote'],
          "sepDLDate": data['sepDLDate'],
          "saldoSepLote": data['saldoSepLote'],
          "saldoSepDLDate": data['saldoSepDLDate'],
          "saldoCILote": data['saldoCILote'],
          "saldoCIDLDate": data['saldoCIDLDate'],
          "vlrPorPagarLote": data['vlrPorPagarLote'],
          "metodoPagoLote": data['metodoPagoLote'],
          "pagoContadoDLLote": data['pagoContadoDLLote'],
          "statementsStartDateLote": data['statementsStartDateLote'],
          "nroCuotasLote": data['nroCuotasLote'],
          "vlrCuotasLote": data['vlrCuotasLote'],
          "observacionesLote": data['observacionesLote'],
          "clienteID": data['clienteID'],
          "quoteStage": data['quoteStage'],
        };
        quotes.add(quote);
      }
    } else {
      final quote = {
          "qid": doc.id,
          "sellerID": data['sellerID'],
          "quoteDate": data['quoteDate'],
          "quoteDLDate": data['quoteDLDate'],
          "loteName": data['loteName'],
          "etapaLote": data['etapaLote'],
          "areaLote": data['areaLote'],
          "priceLote": data['priceLote'],
          "perCILote": data['perCILote'],
          "vlrCILote": data['vlrCILote'],
          "vlrSepLote": data['vlrSepLote'],
          "sepDLDate": data['sepDLDate'],
          "saldoSepLote": data['saldoSepLote'],
          "saldoSepDLDate": data['saldoSepDLDate'],
          "saldoCILote": data['saldoCILote'],
          "saldoCIDLDate": data['saldoCIDLDate'],
          "vlrPorPagarLote": data['vlrPorPagarLote'],
          "metodoPagoLote": data['metodoPagoLote'],
          "pagoContadoDLLote": data['pagoContadoDLLote'],
          "statementsStartDateLote": data['statementsStartDateLote'],
          "nroCuotasLote": data['nroCuotasLote'],
          "vlrCuotasLote": data['vlrCuotasLote'],
          "observacionesLote": data['observacionesLote'],
          "clienteID": data['clienteID'],
          "quoteStage": data['quoteStage'],
        };
        quotes.add(quote);
    }
  }
  return quotes;
}

Future<void> deleteQuote(String qid) async {
  await db.collection("quotes").doc(qid).delete();
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
    }
  );
}

Future<List> getCustomers() async {
  List customers = [];
  QuerySnapshot? queryCustomers = await db.collection('customers').get();
  for (var doc in queryCustomers.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final customer = {
      "clienteID":doc.id,
      "nameCliente":data["nameCliente"],
      "lastnameCliente":data["lastnameCliente"],
      "genderCliente":data["genderCliente"],
      "bdayCliente":data["bdayCliente"],
      "telCliente":data["telCliente"],
      "idTypeCliente":data["idTypeCliente"],
      "idIssueCountryCliente":data["idIssueCountryCliente"],
      "idIssueStateCliente":data["idIssueStateCliente"],
      "idIssueCityCliente":data["idIssueCityCliente"],
      "emailCliente":data["emailCliente"],
      "addressCliente":data["addressCliente"],
      "countryCliente":data["countryCliente"],
      "stateCliente":data["stateCliente"],
      "cityCliente":data["cityCliente"]      
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
      "loteTop":	data['loteTop'],
      "loteRight":	data['loteRight'],
      "loteBottom":	data['loteBottom'],
      "loteEtapa": data['loteEtapa'],
      "loteArea": data['loteArea'],
      "lotePrice": data['lotePrice'],
      "loteState": data['loteState'],
      "loteImg": data['loteImg'],
    };
    lotes.add(lote);
  }
  return lotes;
}

Future<void> addLotes(String idLote, String loteName, double loteLeft, double	loteTop, double	loteRight, double	loteBottom,
 String loteEtapa, String loteState, double loteArea, double lotePrice, String loteImg) async {
  await db.collection("lotes").doc(idLote).set({
    "loteName": loteName,
    "loteLeft": loteLeft,
    "loteTop":	loteTop,
    "loteRight":	loteRight,
    "loteBottom":	loteBottom, 
    "loteEtapa": loteEtapa, 
    "loteState": loteState,
    "loteArea": loteArea, 
    "lotePrice": lotePrice,    
    "loteImg": loteImg,
    }
  );
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

Future<void> addCountries(String countryName,) async {
  await db.collection("countries").add({
    "countryName": countryName, 
    }
  );
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
    }
  );
}

Future<List> getCities() async {
  List cities = [];
  
  QuerySnapshot? queryCities = await db.collection('cities').get();
  for (var doc in queryCities.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final city = {
      if(data['stateName']!= 'Otros'){
        "cityName": data['cityName'],
        "ciid": doc.id,
        "stateName": data['stateName'],
        "countryName": "Colombia"
      } else{
        "cityName":data['cityName'],
        "ciid": doc.id,
        "stateName": data['stateName'],
        "countryName": "Otros"
      }
    };
    cities.add(city);
  }
  return cities;
}

