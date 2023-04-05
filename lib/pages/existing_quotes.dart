import 'package:albaterrapp/pages/pdf_generator.dart';
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
  const ExistingQuotes({Key? key, required this.loteInfo, required this.needAll, required this.loggedEmail}) : super(key: key);


  @override
  State<ExistingQuotes> createState() => _ExistingQuotesState();
}

class _ExistingQuotesState extends State<ExistingQuotes> {
  
  @override
  void initState() {
    super.initState();    
    loteInfo = widget.loteInfo;
    needAll = widget.needAll;
    loggedEmail = widget.loggedEmail;
    loggedManager();
  }

  void loggedManager() async{
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

Future<String> getGerenteEmail() async {  
  final gerenteEmail = await db.collection('infoproyecto').doc('infoGeneral').collection('gerenteProyecto').doc('victorOrostegui').get();
  return gerenteEmail.get('email') as String;
}


  List<dynamic> loteInfo = [];
  bool needAll = true;
  String loggedEmail = '';
  bool managerLogged = false;
  
    @override
  Widget build(BuildContext context) {    
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Cotizaciones existentes${loteVerifier(needAll)}', style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: FutureBuilder(
            future: getQuotes(loteInfo[1], needAll, true),
            builder: ((context, snapshot){
              if(snapshot.hasData){
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index){                      
                    return FutureBuilder(
                      future: db.collection('customers').doc(snapshot.data?[index]['clienteID']).get(),
                      builder: ((context, custSnapshot) {
                        if(custSnapshot.hasData){
                          final custData = custSnapshot.data?.data() as Map<String, dynamic>;
                          final name = custData['nameCliente'] ?? '';
                          final lastName = custData['lastnameCliente'] ?? '';
                          final fullName = '$name $lastName';
                          return FutureBuilder(
                            future: db.collection('sellers').doc(snapshot.data?[index]['sellerID']).get(),
                            builder: ((context, sellerSnapshot) {
                              if(sellerSnapshot.hasData){
                                final sellerData = sellerSnapshot.data?.data() as Map<String, dynamic>;                                                            
                                return Dismissible(
                                  onDismissed: (direction) async {
                                    await archiveQuote(snapshot.data?[index]['qid']);
                                    snapshot.data?.removeAt(index);
                                    setState(() {});
                                  },
                                  confirmDismiss: (direction) async {
                                    bool result = false;
                                    result = await showDialog(
                                      context: context, 
                                      builder: (context){
                                        return AlertDialog(
                                          title: Text("Esta seguro de archivar la cotizacion #${snapshot.data?[index]['qid']}?"),
                                          actions: [
                                            TextButton(onPressed: (){
                                              return Navigator.pop(
                                                context, 
                                                false,
                                              );
                                            }, 
                                            child: const Text("Cancelar",
                                              style: TextStyle(color: Colors.red),
                                            )
                                            ),
                                            TextButton(onPressed: (){
                                              return Navigator.pop(
                                                context, 
                                                true
                                              );
                                            }, 
                                            child: const Text("Si, estoy seguro"),
                                            ),
                                          ],
                                        );
                                      }
                                    );
                                    return result;
                                  },
                                  background: Container(
                                    color:Colors.red,
                                    child: const Icon(Icons.delete),
                                  ),
                                  direction: DismissDirection.endToStart,
                                  key: Key(snapshot.data?[index]['qid']),
                                  child: ListTile(
                                    leading: CircleAvatar(backgroundColor: stageColor(snapshot.data?[index]['quoteStage']), child: Text(getNumbers(snapshot.data?[index]['loteName'])!, textAlign: TextAlign.center, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),)),
                                    title: Text('${snapshot.data?[index]['loteName']} | Cotización #${snapshot.data?[index]['qid']} | ${snapshot.data?[index]['quoteStage']}'),
                                    subtitle: Text(fullName),
                                    trailing: PopupMenuButton<String>(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'Opción 1',                                          
                                          child: Text('Ver PDF'),                     
                                        ),                      
                                        PopupMenuItem(
                                          enabled: managerLogged,
                                          value: 'Opción 2',
                                          child: Text(changeState(snapshot.data?[index]['quoteStage'])),
                                        ),
                                      ],
                                      onSelected: (value) async {
                                        if(value == 'Opción 1'){                     
                                         Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => PDFGenerator(
                                            sellerID: snapshot.data?[index]['sellerID'],
                                            sellerName: '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                            sellerPhone: sellerData['phoneSeller'],
                                            sellerEmail: sellerData['emailSeller'],
                                            quoteId: snapshot.data?[index]['qid'],
                                            name: custData['nameCliente'],
                                            lastname: custData['lastnameCliente'],
                                            phone: custData['telCliente'],
                                            date: snapshot.data?[index]['quoteDate'],
                                            dueDate: snapshot.data?[index]['quoteDLDate'],
                                            lote: snapshot.data?[index]['loteName'],
                                            area: snapshot.data?[index]['areaLote'],
                                            price: (currencyCOP((snapshot.data?[index]['priceLote'].toInt()).toString())),
                                            finalPrice: (currencyCOP((snapshot.data?[index]['precioFinal'].toInt()).toString())),
                                            porcCuotaIni: '${snapshot.data?[index]['perCILote'].toString()}%',
                                            vlrCuotaIni: (currencyCOP((snapshot.data?[index]['vlrCILote'].toInt()).toString())),
                                            vlrSeparacion: (currencyCOP((snapshot.data?[index]['vlrSepLote'].toInt()).toString())),
                                            dueDateSeparacion: snapshot.data?[index]['sepDLDate'],
                                            saldoSeparacion: (currencyCOP((snapshot.data?[index]['saldoSepLote'].toInt()).toString())),
                                            dueDateSaldoSeparacion: snapshot.data?[index]['saldoSepDLDate'],
                                            plazoCI: '${(snapshot.data?[index]['plazoCI'].toInt()).toString()} días',
                                            saldoCI: (currencyCOP((snapshot.data?[index]['saldoCILote'].toInt()).toString())),
                                            dueDateSaldoCI: snapshot.data?[index]['saldoCIDLDate'],
                                            porcPorPagar: '${(100-snapshot.data?[index]['perCILote']).toString()}%',
                                            vlrPorPagar: (currencyCOP((snapshot.data?[index]['vlrPorPagarLote'].toInt()).toString())),
                                            paymentMethod: snapshot.data?[index]['metodoPagoLote'],
                                            tiempoFinanc: '${((snapshot.data?[index]['nroCuotasLote'])/12).toString()} años',
                                            vlrCuota: (currencyCOP((snapshot.data?[index]['vlrCuotasLote'].toInt()).toString())),
                                            saldoTotalDate: snapshot.data?[index]['saldoTotalDate'],
                                            nroCuotas: (snapshot.data?[index]['nroCuotasLote'].toInt()).toString(),
                                            tem: '${snapshot.data?[index]['tem'].toString()}',
                                            observaciones: snapshot.data?[index]['observacionesLote'],
                                            quoteStage: snapshot.data?[index]['quoteStage'],
                                          ),
                                        ));
                                        } if(value == 'Opción 2'){
                                          if(snapshot.data?[index]['quoteStage'] == 'CREADA'){
                                            await Navigator.pushNamed(context, "/editQuote", arguments: {
                                              "selectedSeller": snapshot.data?[index]['sellerID'],
                                              "sellerName": '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                              "sellerEmail": sellerData['emailSeller'],
                                              "sellerPhone": sellerData['phoneSeller'],
                                              "quoteId": snapshot.data?[index]['qid'],
                                              "quoteDate": snapshot.data?[index]['quoteDate'],
                                              "quoteDeadline": snapshot.data?[index]['quoteDLDate'],
                                              "lote": snapshot.data?[index]['loteName'],
                                              "etapalote": snapshot.data?[index]['etapaLote'],
                                              "arealote": snapshot.data?[index]['areaLote'],
                                              "pricelote": (currencyCOP((snapshot.data?[index]['priceLote'].toInt()).toString())),
                                              "precioFinal": (currencyCOP((snapshot.data?[index]['precioFinal'].toInt()).toString())),
                                              "paymentMethod": snapshot.data?[index]['metodoPagoLote'],
                                              "porcCuotaInicial": '${snapshot.data?[index]['perCILote'].toString()}%',
                                              "vlrCuotaIni": (currencyCOP((snapshot.data?[index]['vlrCILote'].toInt()).toString())),
                                              "nroCuotas": '${snapshot.data?[index]['nroCuotasLote'].toString()}',
                                              "vlrSeparacion": (currencyCOP((snapshot.data?[index]['vlrSepLote'].toInt()).toString())),
                                              "saldoSeparacion": (currencyCOP((snapshot.data?[index]['saldoSepLote'].toInt()).toString())),
                                              "separacionDeadline": snapshot.data?[index]['sepDLDate'],
                                              "saldoSeparacionDeadline": snapshot.data?[index]['saldoSepDLDate'],
                                              "saldoCuotaIni": (currencyCOP((snapshot.data?[index]['saldoCILote'].toInt()).toString())),
                                              "saldoCuotaIniDeadline": snapshot.data?[index]['saldoCIDLDate'],
                                              "vlrPorPagar": (currencyCOP((snapshot.data?[index]['vlrPorPagarLote'].toInt()).toString())),
                                              "saldoTotalDate": snapshot.data?[index]['saldoTotalDate'],
                                              "vlrCuota": (currencyCOP((snapshot.data?[index]['vlrCuotasLote'].toInt()).toString())),
                                              "tem": '${snapshot.data?[index]['tem'].toString()}%',
                                              "observaciones": snapshot.data?[index]['observacionesLote'],
                                              "quoteStage": newState(snapshot.data?[index]['quoteStage']),
                                              "name": custData['nameCliente'],
                                              "lastname": custData['lastnameCliente'],
                                              "gender": custData['genderCliente'],
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
                                              "cambioEstado": true,
                                            });
                                          }
                                          if(snapshot.data?[index]['quoteStage'] == 'AUTORIZADA'){
                                            // ignore: use_build_context_synchronously
                                            await Navigator.pushNamed(context, "/genSep", arguments: {
                                              "selectedSeller": snapshot.data?[index]['sellerID'],
                                              "sellerName": '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                              "sellerEmail": sellerData['emailSeller'],
                                              "sellerPhone": sellerData['phoneSeller'],
                                              "quoteId": snapshot.data?[index]['qid'],
                                              "quoteDate": snapshot.data?[index]['quoteDate'],
                                              "quoteDeadline": snapshot.data?[index]['quoteDLDate'],
                                              "lote": snapshot.data?[index]['loteName'],
                                              "etapalote": snapshot.data?[index]['etapaLote'],
                                              "arealote": snapshot.data?[index]['areaLote'],
                                              "pricelote": (currencyCOP((snapshot.data?[index]['priceLote'].toInt()).toString())),
                                              "precioFinal": (currencyCOP((snapshot.data?[index]['precioFinal'].toInt()).toString())),
                                              "paymentMethod": snapshot.data?[index]['metodoPagoLote'],
                                              "porcCuotaInicial": '${snapshot.data?[index]['perCILote'].toString()}%',
                                              "vlrCuotaIni": (currencyCOP((snapshot.data?[index]['vlrCILote'].toInt()).toString())),
                                              "nroCuotas": '${snapshot.data?[index]['nroCuotasLote'].toString()}',
                                              "vlrSeparacion": (currencyCOP((snapshot.data?[index]['vlrSepLote'].toInt()).toString())),
                                              "saldoSeparacion": (currencyCOP((snapshot.data?[index]['saldoSepLote'].toInt()).toString())),
                                              "separacionDeadline": snapshot.data?[index]['sepDLDate'],
                                              "saldoSeparacionDeadline": snapshot.data?[index]['saldoSepDLDate'],
                                              "saldoCuotaIni": (currencyCOP((snapshot.data?[index]['saldoCILote'].toInt()).toString())),
                                              "saldoCuotaIniDeadline": snapshot.data?[index]['saldoCIDLDate'],
                                              "vlrPorPagar": (currencyCOP((snapshot.data?[index]['vlrPorPagarLote'].toInt()).toString())),
                                              "saldoTotalDate": snapshot.data?[index]['saldoTotalDate'],
                                              "vlrCuota": (currencyCOP((snapshot.data?[index]['vlrCuotasLote'].toInt()).toString())),
                                              "tem": '${snapshot.data?[index]['tem'].toString()}%',
                                              "observaciones": snapshot.data?[index]['observacionesLote'],
                                              "quoteStage": newState(snapshot.data?[index]['quoteStage']),
                                              "name": custData['nameCliente'],
                                              "lastname": custData['lastnameCliente'],
                                              "gender": custData['genderCliente'],
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
                                              "cambioEstado": true,
                                            });
                                          } else {
                                            setState(() {                          
                                            });
                                          } 
                                        
                                        } if(value == 'Opción 3'){
                                          setState(() {                          
                                          });
                                        } if(value == 'Opción 4'){
                                          setState(() {                          
                                          });
                                        } else{
                                          setState(() {                          
                                          });
                                        } 
                                      },
                                    ),
                                    onTap: (() async {
                                      if(managerLogged == true){
                                        await Navigator.pushNamed(context, "/editQuote", arguments: {
                                          "selectedSeller": snapshot.data?[index]['sellerID'],
                                          "sellerName": '${sellerData['nameSeller']} ${sellerData['lastnameSeller']}',
                                          "sellerEmail": sellerData['emailSeller'],
                                          "sellerPhone": sellerData['phoneSeller'],
                                          "quoteId": snapshot.data?[index]['qid'],
                                          "quoteDate": snapshot.data?[index]['quoteDate'],
                                          "quoteDeadline": snapshot.data?[index]['quoteDLDate'],
                                          "lote": snapshot.data?[index]['loteName'],
                                          "etapalote": snapshot.data?[index]['etapaLote'],
                                          "arealote": snapshot.data?[index]['areaLote'],
                                          "pricelote": (currencyCOP((snapshot.data?[index]['priceLote'].toInt()).toString())),
                                          "precioFinal": (currencyCOP((snapshot.data?[index]['precioFinal'].toInt()).toString())),
                                          "paymentMethod": snapshot.data?[index]['metodoPagoLote'],
                                          "porcCuotaInicial": '${snapshot.data?[index]['perCILote'].toString()}%',
                                          "vlrCuotaIni": (currencyCOP((snapshot.data?[index]['vlrCILote'].toInt()).toString())),
                                          "nroCuotas": '${snapshot.data?[index]['nroCuotasLote'].toString()}',
                                          "vlrSeparacion": (currencyCOP((snapshot.data?[index]['vlrSepLote'].toInt()).toString())),
                                          "saldoSeparacion": (currencyCOP((snapshot.data?[index]['saldoSepLote'].toInt()).toString())),
                                          "separacionDeadline": snapshot.data?[index]['sepDLDate'],
                                          "saldoSeparacionDeadline": snapshot.data?[index]['saldoSepDLDate'],
                                          "saldoCuotaIni": (currencyCOP((snapshot.data?[index]['saldoCILote'].toInt()).toString())),
                                          "saldoCuotaIniDeadline": snapshot.data?[index]['saldoCIDLDate'],
                                          "vlrPorPagar": (currencyCOP((snapshot.data?[index]['vlrPorPagarLote'].toInt()).toString())),
                                          "saldoTotalDate": snapshot.data?[index]['saldoTotalDate'],
                                          "vlrCuota": (currencyCOP((snapshot.data?[index]['vlrCuotasLote'].toInt()).toString())),
                                          "tem": '${snapshot.data?[index]['tem'].toString()}%',
                                          "observaciones": snapshot.data?[index]['observacionesLote'],
                                          "quoteStage": snapshot.data?[index]['quoteStage'],
                                          "name": custData['nameCliente'],
                                          "lastname": custData['lastnameCliente'],
                                          "gender": custData['genderCliente'],
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
                                        setState(() {});
                                      }
                                    }                      
                                    ),
                                  ),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            })
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      })
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
            )
          ),
        )
      ),
    );
  }

  String newState(String value){
    if(value == 'CREADA'){
      return 'AUTORIZADA';
    } if(value == 'AUTORIZADA'){
      return 'LOTE SEPARADO';
    } else {
      return 'LOTE SEPARADO';
    }
  }

  String changeState(String value){
    if(value == 'CREADA'){
      return 'Autorizar cotización';
    } if(value == 'AUTORIZADA'){
      return 'Generar separación';
    } else {
      return 'Lote separado';
    }
  }

  Color stageColor(String value){
    if(value == 'CREADA'){
      return dangerColor;
    } if(value == 'AUTORIZADA'){
      return warningColor;
    } else{
      return infoColor;
    }
  }

  String loteVerifier(bool value){
    if(value == true){
      return  '';
    } else {
      return ' ${loteInfo[1]}';
    }
  }

  String? getNumbers(String value){
    final RegExp regex = RegExp(r'\d+');
    final String? loteNumber = regex.stringMatch(value);
    return loteNumber;
  }
}

