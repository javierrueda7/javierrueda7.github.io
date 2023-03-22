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

Future<double> getPeriodoDiscount(String periodo) async {
  DocumentSnapshot<Map<String, dynamic>> infoDiscount = await db.collection('infoproyecto').doc('infopagos').collection('infoCuotas').doc(periodo).get();
  final Map<String, dynamic> dataCuotas = infoDiscount.data() as Map<String, dynamic>;
  final cuotaInfo = {
      "dcto": dataCuotas['dcto'],
  };
  return (cuotaInfo['dcto'].toDouble());
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
    "plazoContado": data['plazoContado'],
    "tem": data['tem'],
    "valorSeparacion": data['valorSeparacion'],
    "maxCuotas": data['maxCuotas'],
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
  double saldoCILote,
  String saldoCIDLDate, 
  double vlrPorPagarLote,
  String metodoPagoLote,
  String saldoTotalDate,
  int nroCuotasLote,
  double vlrCuotasLote,
  String tem,
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
    "precioFinal": precioFinal,
    "dctoLote": dctoLote,
    "perCILote": perCILote,
    "vlrCILote": vlrCILote,
    "vlrSepLote": vlrSepLote,
    "sepDLDate": sepDLDate,
    "saldoSepLote": saldoSepLote,
    "saldoSepDLDate": saldoSepDLDate,
    "plazoCI": plazoCI,
    "saldoCILote": saldoCILote,
    "saldoCIDLDate": saldoCIDLDate,
    "vlrPorPagarLote": vlrPorPagarLote,
    "metodoPagoLote": metodoPagoLote,
    "saldoTotalDate": saldoTotalDate,
    "nroCuotasLote": nroCuotasLote,
    "vlrCuotasLote": vlrCuotasLote,
    "tem": tem,
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
          "precioFinal": data['precioFinal'],
          "dctoLote": data['dctoLote'],
          "perCILote": data['perCILote'],
          "vlrCILote": data['vlrCILote'],
          "vlrSepLote": data['vlrSepLote'],
          "sepDLDate": data['sepDLDate'],
          "saldoSepLote": data['saldoSepLote'],
          "saldoSepDLDate": data['saldoSepDLDate'],
          "plazoCI": data['plazoCI'],
          "saldoCILote": data['saldoCILote'],
          "saldoCIDLDate": data['saldoCIDLDate'],
          "vlrPorPagarLote": data['vlrPorPagarLote'],
          "metodoPagoLote": data['metodoPagoLote'],
          "saldoTotalDate": data['saldoTotalDate'],
          "nroCuotasLote": data['nroCuotasLote'],
          "vlrCuotasLote": data['vlrCuotasLote'],
          "tem": data['tem'],
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

