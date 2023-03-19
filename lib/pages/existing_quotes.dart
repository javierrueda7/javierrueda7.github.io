import 'package:albaterrapp/pages/add_seller.dart';
import 'package:albaterrapp/pages/pdf_generator.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
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
        title: Text('Cotizaciones existentes ${loteInfo[1]}', 
          style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),),
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
                            future: db.collection('users').doc(snapshot.data?[index]['sellerID']).get(),
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
                                    leading: Text(snapshot.data?[index]['loteName']),
                                    title: Text(fullName),
                                    subtitle: Text('Cotización #${snapshot.data?[index]['qid']}'),
                                    onTap: (() async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PDFGenerator(
                                            seller: snapshot.data?[index]['sellerID'],
                                            sellerName: '${sellerData['nameUser']} ${sellerData['lastnameUser']}',
                                            sellerPhone: sellerData['phoneUser'],
                                            sellerEmail: sellerData['emailUser'],
                                            quoteId: snapshot.data?[index]['qid'],
                                            name: custData['nameCliente'],
                                            lastname: custData['lastnameCliente'],
                                            phone: custData['telCliente'],
                                            date: snapshot.data?[index]['quoteDate'],
                                            dueDate: snapshot.data?[index]['quoteDLDate'],
                                            lote: snapshot.data?[index]['loteName'],
                                            area: snapshot.data?[index]['areaLote'],
                                            price: snapshot.data?[index]['priceLote'],
                                            porcCuotaIni: '${snapshot.data?[index]['perCILote'].toString()}',
                                            vlrCuotaIni: snapshot.data?[index]['vlrCILote'],
                                            vlrSeparacion: snapshot.data?[index]['vlrSepLote'],
                                            dueDateSeparacion: snapshot.data?[index]['sepDLDate'],
                                            saldoSeparacion: snapshot.data?[index]['saldoSepLote'],
                                            dueDateSaldoSeparacion: snapshot.data?[index]['saldoSepDLDate'],
                                            plazoCI: '120 días',
                                            saldoCI: snapshot.data?[index]['saldoCILote'],
                                            dueDateSaldoCI: snapshot.data?[index]['saldoCIDLDate'],
                                            porcPorPagar: '70%',
                                            vlrPorPagar: snapshot.data?[index]['vlrPorPagarLote'],
                                            paymentMethod: snapshot.data?[index]['metodoPagoLote'],
                                            tiempoFinanc: '${((snapshot.data?[index]['nroCuotasLote'])/12).toString()} años',
                                            vlrCuota: snapshot.data?[index]['vlrCuotasLote'],
                                            statementsStartDate: snapshot.data?[index]['statementsStartDateLote'],
                                            nroCuotas: '${snapshot.data?[index]['nroCuotasLote'].toString()}',
                                            pagoContadoDue: snapshot.data?[index]['pagoContadoDLLote'],
                                            tem: '0.0%',
                                            observaciones: snapshot.data?[index]['observacionesLote'],
                                          ),
                                        ),
                                      );                                      
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
        floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSellerPage())); 
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

