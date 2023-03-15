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
      "name": data['name'],
      "uid": doc.id,
      "username": data['username'],
      "email": data['email'],
      "phone": data['phone'],
      "role": data['role'],
    };
    users.add(person);
  }
  return users;
}

Future<void> addUsers(String username, String name, String email, String phone, String role) async {
  await db.collection("users").add({
    "username": username, 
    "name": name, 
    "email": email, 
    "phone": phone,
    "role": role,
    }
  );
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
  String saldoCILote,
  String saldoCIDLDate, 
  String vlrPorPagarLote,
  String metodoPagoLote,
  String pagoContadoDLLote,
  String statementsStartDateLote,
  int nroCuotasLote,
  String vlrCuotasLote,
  String clienteID,
  String quoteStage) async {
  await db.collection("quotes").doc(qid).set({
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
    "saldoCILote": saldoCILote,
    "saldoCIDLDate": saldoCIDLDate,
    "vlrPorPagarLote": vlrPorPagarLote,
    "metodoPagoLote": metodoPagoLote,
    "pagoContadoDLLote": pagoContadoDLLote,
    "statementsStartDateLote": statementsStartDateLote,
    "nroCuotasLote": nroCuotasLote,
    "vlrCuotasLote": vlrCuotasLote,
    "clienteID": clienteID,
    "quoteStage": quoteStage
    }
  );
}

Future<void> addCustomer(
  String clienteID,
  String nameCliente, 
  String lastnameCliente, 
  String genderCliente, 
  String bdayCliente, 
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

