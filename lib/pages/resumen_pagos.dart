import 'dart:async';

import 'package:albaterrapp/pages/add_payment.dart';
import 'package:albaterrapp/pages/pdf_estadocuenta.dart';
import 'package:albaterrapp/pages/pdf_invoice.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class ResumenPagos extends StatefulWidget {
  final String loteid;
  const ResumenPagos({super.key, required this.loteid});

  @override
  State<ResumenPagos> createState() => _ResumenPagosState();
}

class _ResumenPagosState extends State<ResumenPagos> {
  
  // ignore: prefer_typing_uninitialized_variables
  var timer;
  @override
  void initState() {
    loteid = widget.loteid;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  Future<void> getLote() async {
    DocumentSnapshot? doc =
        await db.collection('lotes').doc(loteid).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final temp = {
      "loteName": data['loteName'],
      "lid": doc.id,    
      "loteState": data['loteState'],
    };
    lote = temp;
  }

  Future<void> getPlanPagos() async {
    DocumentSnapshot? doc =
        await db.collection('planPagos').doc(loteid).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final temp = {
      "precioIni": data['precioIni'].toDouble(),
      "precioFin": data['precioFin'].toDouble(),
      "dcto": data['dcto'].toDouble(),
      "estadoPago": data['estadoPago'],
      "saldoPorPagar": data['saldoPorPagar'].toDouble(),
      "valorPagado": data['valorPagado'].toDouble(),
      "idPlanPagos": data['idPlanPagos'],
      "idCliente": data['idCliente'],
      "paymentMethod": data['paymentMethod'],
      "valorSeparacion": data['valorSeparacion'],
      "valorIntereses": data['valorIntereses']
    };
    planPagos = temp;
  }

  Future<void> getCI(String idPlan) async {
    DocumentSnapshot? doc =
        await db.collection('ordSep').doc(idPlan).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    cuotaIni = data['vlrCILote'].toDouble();
  }

  Future<void> actConcepto() async {
    final firestore = FirebaseFirestore.instance;
    List<dynamic> pagosReal = await getPagos(loteid);    
    double totalPagado = 0;
    String concepto = '';
    for (var pagoR in pagosReal){
      totalPagado = totalPagado + pagoR['valorPago'];
      if(totalPagado <= planPagos['valorSeparacion']){
        concepto = 'SEPARACIÓN';
      } else if(planPagos['paymentMethod'] == 'Financiación directa' && totalPagado <= cuotaIni){
        concepto = 'CUOTA INICIAL';
      } else{
        concepto = 'ABONO SALDO TOTAL';
      }
      await firestore.collection('pagos').doc(pagoR['pid']).update({
        'conceptoPago': concepto,
      });
    }
  }

  double cuotaIni = 0;
  String loteid = '';
  Map<String, dynamic> lote = {};
  Map<String, dynamic> planPagos = {};
  List<dynamic> pagosReal = [];
  List<dynamic> pagosEsp = [];
  DateTime startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    getLote();
    getPlanPagos();
    getCI(planPagos['idPlanPagos']);
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Pagos realizados',
          style: TextStyle(
              color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Stack(
            children: [              
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Card(
                  color: fifthColor.withOpacity(0.4),
                  elevation: 2,
                  child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(maxWidth: 800),
                    width: MediaQuery.of(context).size.width-50,
                    height: 240,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Etapa del pago',
                          style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text( 
                          planPagos['estadoPago'],
                          style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold),
                        ),                    
                        const SizedBox(height: 8),
                        Text(
                          'Precio total',
                          style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text( 
                          currencyCOP((planPagos['precioFin'].toInt()).toString()),
                          style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold),
                        ),                    
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Total abonado',
                                  style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text( 
                                  currencyCOP((planPagos['valorPagado'].toInt()).toString()),
                                  style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Intereses pagados',
                                  style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text( 
                                  currencyCOP((planPagos['valorIntereses'].toInt()).toString()),
                                  style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),      
                          ],
                        ),                    
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Saldo pendiente',
                                  style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currencyCOP((planPagos['saldoPorPagar'].toInt()).toString()),
                                  style: TextStyle(color: fourthColor.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),                                          
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total pagado',
                                  style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text( 
                                  currencyCOP(((planPagos['valorPagado'] + planPagos['valorIntereses']).toInt()).toString()),
                                  style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),                    
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                )
              ),
              Positioned(
                top: 220,
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: ElevatedButton(style: ButtonStyle(
                    minimumSize: WidgetStateProperty.all(const Size(100, 50))),
                    onPressed: () async {
                      pagosReal = await getPagos(loteid);
                      pagosEsp = await getPagosEsp(loteid);
                      startDate = await getStartDate(planPagos['idPlanPagos']);
                      // ignore: use_build_context_synchronously
                      Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFEstadoCuenta(
                            idPlanPagos: planPagos['idPlanPagos'],
                            idCliente: planPagos['idCliente'],
                            lote: lote['loteName'],
                            paymentMethod: planPagos['paymentMethod'],
                            valorInicial: planPagos['precioIni'],
                            descuento: planPagos['dcto'],
                            valorPagado: planPagos['valorPagado'],
                            saldoPorPagar: planPagos['saldoPorPagar'],
                            valorTotal: planPagos['precioFin'],
                            totalIntereses: planPagos['valorIntereses'].toDouble(),
                            pagosEsp: pagosEsp,
                            pagosRea: pagosReal,
                            startDate: startDate,
                          ),
                        ),
                      );
                      setState(() {});
                    }, child: const Text("Estado de cuenta", textAlign: TextAlign.center,)
                  ),
                )
              ),
              Positioned(
                top: 280, // Adjust the value to position the list below the card
                left: 0,
                right: 0,
                bottom: 0,
                child: FutureBuilder(
                  future: getPagos(loteid),
                  builder: ((context, pagosSnapshot) {
                    if (pagosSnapshot.hasData) {
                      return ListView.builder(
                        itemCount: pagosSnapshot.data?.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            onDismissed: (direction) async {
                              await deletePagos(pagosSnapshot.data?[index]['pid'], loteid, pagosSnapshot.data?[index]['valorPago'], pagosSnapshot.data?[index]['valorIntereses']);
                              setState(() {
                                pagosSnapshot.data?.removeAt(index);
                              });
                              obtenerPagosEsperados();
                            },
                            confirmDismiss: (direction) async {
                              bool result = false;
                              result = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Esta seguro de eliminar el pago ${pagosSnapshot.data?[index]['pid']}?"),
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
                                          style: TextStyle(color: Colors.red),
                                        )
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          return Navigator.pop(context, true);
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
                              color: Colors.red,
                              child: const Icon(Icons.delete),
                            ),
                            direction: DismissDirection.endToStart,
                            key: Key(pagosSnapshot.data?[index]['pid']),
                            child: Center(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 800),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Text('Pago ${pagosSnapshot.data?[index]['pid']}', textAlign: TextAlign.end,),
                                      title: Text('Valor pagado: ${currencyCOP((pagosSnapshot.data?[index]['valorPago'].toInt()).toString())}', textAlign: TextAlign.center),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('Fecha de pago: ${pagosSnapshot.data?[index]['fechaPago']}'),
                                          Text('Método de pago: ${pagosSnapshot.data?[index]['metodoPago']}')
                                        ],
                                      ),
                                      onTap: (() async {
                                        String valorEnLetras = await numeroEnLetras(pagosSnapshot.data?[index]['valorPago'].toDouble(), 'pesos');
                                        String intEnLetras = await numeroEnLetras(pagosSnapshot.data?[index]['valorIntereses'].toDouble(), 'pesos');
                                        String totalEnLetras = await numeroEnLetras((pagosSnapshot.data?[index]['valorIntereses'] + pagosSnapshot.data?[index]['valorPago']).toDouble(), 'pesos');
                                          // ignore: use_build_context_synchronously
                                          Navigator.push(
                                            // ignore: use_build_context_synchronously
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PDFInvoice(
                                                lote: lote['loteName'],
                                                recibo: 'No. ${pagosSnapshot.data?[index]['pid']}',                                  
                                                nameCliente: pagosSnapshot.data?[index]['nombreCliente'],
                                                idCliente: pagosSnapshot.data?[index]['idCliente'],
                                                phoneCliente: pagosSnapshot.data?[index]['telCliente'],
                                                addressCliente: pagosSnapshot.data?[index]['dirCliente'],
                                                emailCliente: pagosSnapshot.data?[index]['emailCliente'],
                                                cityCliente: pagosSnapshot.data?[index]['ciudadCliente'],
                                                receiptDate: pagosSnapshot.data?[index]['fechaRecibo'],
                                                paymentDate: pagosSnapshot.data?[index]['fechaPago'],                                  
                                                paymentValue: pagosSnapshot.data?[index]['valorPago'].toDouble(),
                                                interestValue: pagosSnapshot.data?[index]['valorIntereses'].toDouble(),
                                                intValueLetters: intEnLetras,
                                                totalValueLetters: totalEnLetras,
                                                paymentValueLetters: valorEnLetras,
                                                saldoPorPagar: planPagos['saldoPorPagar'],
                                                valorTotal: planPagos['precioFin'],
                                                paymentMethod: pagosSnapshot.data?[index]['metodoPago'],
                                                observaciones: pagosSnapshot.data?[index]['obsPago'],
                                                conceptoPago: pagosSnapshot.data?[index]['conceptoPago'],
                                              ),
                                            ),
                                          );
                                        setState(() {});
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  })
                ),
              ),
              
            ],
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                const AddPaymentPage()
              )
            );
          setState(() {});
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  bool esNumero(String str) {
    return double.tryParse(str) != null;
  }

  Future<void> obtenerPagosEsperados() async {    
    final firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> listaPagos = [];
    // Referencia al documento "L03" en la colección "planPagos"
    DocumentReference documentoRef = FirebaseFirestore.instance.collection('planPagos').doc(loteid);
    DocumentSnapshot documentoSnapshot = await documentoRef.get();

    
    double valorPagado = documentoSnapshot['valorPagado'];
    // Obtener la subcolección "pagosEsperados" del documento "L03"
    QuerySnapshot pagosEsperados = await documentoRef.collection('pagosEsperados').get();

    for (QueryDocumentSnapshot pago in pagosEsperados.docs) {
      String docId = pago.id;
      double valorPago = pago.get('valorPago');

      listaPagos.add({
        'docId': docId,
        'valorPago': valorPago,
      });
    }

    final List<String> ordenEsperado = ['SEP1', 'SEP2', 'CINI', 'TOTAL'];

    listaPagos.sort((a, b) {
      final int indexA = ordenEsperado.indexOf(a['docId']);
      final int indexB = ordenEsperado.indexOf(b['docId']);

      if (indexA == -1 && indexB == -1) {
        // Si ambos no están en ordenEsperado, compara como cadenas de texto
        if (!esNumero(a['docId']) || !esNumero(b['docId'])) {
          return a['docId'].compareTo(b['docId']);
        } else {
          return int.parse(a['docId']) - int.parse(b['docId']);
        }
      } else if (indexA == -1) {
        return 1; // Mover documentos no encontrados al final
      } else if (indexB == -1) {
        return -1; // Mover documentos no encontrados al final
      } else if (indexA != indexB) {
        // Si están en ordenEsperado, compara por su índice en ordenEsperado
        return indexA - indexB;
      } else {
        // Si tienen el mismo índice en ordenEsperado, compara como números
        return int.parse(a['docId']) - int.parse(b['docId']);
      }
    });

    for (int i = 0; i < listaPagos.length; i++) {
      String docId = listaPagos[i]['docId'];
      double valorPago = listaPagos[i]['valorPago'];

      String estadoPago;
      if(valorPagado-valorPago == 0){
        estadoPago = 'PAGO COMPLETO';
        valorPagado = valorPagado - valorPago;
      } else if (valorPagado == 0) {
        estadoPago = 'PAGO PENDIENTE';
      } else if(valorPagado-valorPago < 0){
        estadoPago = 'PAGO INCOMPLETO';
        valorPagado = 0;
      } else if(valorPagado-valorPago > 0){
        estadoPago = 'PAGO COMPLETO';
        valorPagado = valorPagado - valorPago;        
      } else {
        estadoPago = 'N/A';
      }

      await firestore.collection('planPagos').doc(loteid).collection('pagosEsperados').doc(docId).update({
            'estadoPago': estadoPago,
          });
    }
  }
}
