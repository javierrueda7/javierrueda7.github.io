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
  const ExistingQuotes({Key? key, required this.loteInfo, required this.needAll}) : super(key: key);


  @override
  State<ExistingQuotes> createState() => _ExistingQuotesState();
}

class _ExistingQuotesState extends State<ExistingQuotes> {
  
  @override
  void initState() {
    super.initState();    
    loteInfo = widget.loteInfo;
    needAll = widget.needAll;    
  }

  List<dynamic> loteInfo = [];
  bool needAll = true;
  
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
            future: getQuotes(loteInfo[1], needAll),
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
                                    await deleteQuote(snapshot.data?[index]['qid']);
                                    snapshot.data?.removeAt(index);
                                    setState(() {});
                                  },
                                  confirmDismiss: (direction) async {
                                    bool result = false;
                                    result = await showDialog(
                                      context: context, 
                                      builder: (context){
                                        return AlertDialog(
                                          title: Text("Esta seguro de eliminar la cotizacion #${snapshot.data?[index]['qid']}?"),
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
                                    title: Text('Cotización #${snapshot.data?[index]['qid']}'),
                                    subtitle: Text(fullName),
                                    trailing: PopupMenuButton<String>(
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'Opción 1',                                          
                                          child: Text('Ver PDF'),                     
                                        ),                      
                                        const PopupMenuItem(
                                          value: 'Opción 2',
                                          child: Text('Asesores comerciales'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Opción 3',
                                          child: Text('Administradores'),                        
                                        ),                      
                                        const PopupMenuItem(
                                          value: 'Opción 4',
                                          child: Text('Información general'),
                                        ),
                                      ],
                                      onSelected: (value) {
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
                                            tem: '${snapshot.data?[index]['tem'].toString()}%',
                                            observaciones: snapshot.data?[index]['observacionesLote'],
                                            quoteStage: snapshot.data?[index]['quoteStage'],
                                          ),
                                        ));
                                        } if(value == 'Opción 2'){
                                          setState(() {                          
                                          });
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
                                    onTap: (() {}                      
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

  Color stageColor(String value){
    if(value == 'CREADA'){
      return dangerColor;
    } if(value == 'AUTORIZADA'){
      return warningColor;
    } if(value == 'APROBADA'){
      return successColor;
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

