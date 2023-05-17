import 'dart:async';

import 'package:albaterrapp/pages/add_payment.dart';
import 'package:albaterrapp/pages/pdf_invoice.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class ResumenPagos extends StatefulWidget {
  final String loteid;
  const ResumenPagos({Key? key, required this.loteid}) : super(key: key);

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
      "precioIni": data['precioIni'],
      "precioFin": data['precioFin'],
      "dcto": data['dcto'],
      "estadoPago": data['estadoPago'],
      "saldoPorPagar": data['saldoPorPagar'],
      "valorPagado": data['valorPagado']
    };
    planPagos = temp;
  }

  String loteid = '';
  Map<String, dynamic> lote = {};
  Map<String, dynamic> planPagos = {};

  @override
  Widget build(BuildContext context) {
    getLote();
    getPlanPagos();
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
                    height: 180,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Column(
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
                                  'Valor pagado',
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Saldo pendiente',
                                  style: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currencyCOP((planPagos['saldoPorPagar'].toInt()).toString()),
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
                top: 200, // Adjust the value to position the list below the card
                left: 0,
                right: 0,
                bottom: 0,
                child: FutureBuilder(
                  future: getPagos(loteid),
                  builder: ((context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data?.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            onDismissed: (direction) async {
                              await deletePagos(snapshot.data?[index]['pid'], loteid, snapshot.data?[index]['valorPago']);
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
                                      "Esta seguro de eliminar el pago ${snapshot.data?[index]['pid']}?"),
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
                            key: Key(snapshot.data?[index]['pid']),
                            child: ListTile(
                              leading: Text('Pago ${snapshot.data?[index]['pid']}'),
                              title: Text('Valor pagado: ${currencyCOP((snapshot.data?[index]['valorPago'].toInt()).toString())}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fecha de pago: ${snapshot.data?[index]['fechaPago']}'),
                                  Text('Método de pago: ${snapshot.data?[index]['metodoPago']}')
                                ],
                              ),
                              onTap: (() async {
                                String valorEnLetras = await numeroEnLetras(snapshot.data?[index]['valorPago'], 'pesos');
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFInvoice(
                                        lote: lote['loteName'],
                                        recibo: 'No. ${snapshot.data?[index]['pid']}',                                  
                                        nameCliente: snapshot.data?[index]['nombreCliente'],
                                        idCliente: snapshot.data?[index]['idCliente'],
                                        phoneCliente: snapshot.data?[index]['telCliente'],
                                        addressCliente: snapshot.data?[index]['dirCliente'],
                                        emailCliente: snapshot.data?[index]['emailCliente'],
                                        cityCliente: snapshot.data?[index]['ciudadCliente'],
                                        receiptDate: snapshot.data?[index]['fechaRecibo'],
                                        paymentDate: snapshot.data?[index]['fechaPago'],                                  
                                        paymentValue: snapshot.data?[index]['valorPago'],
                                        paymentValueLetters: valorEnLetras,
                                        saldoPorPagar: planPagos['saldoPorPagar'],
                                        valorTotal: planPagos['precioFin'],
                                        paymentMethod: snapshot.data?[index]['metodoPago'],
                                        observaciones: snapshot.data?[index]['obsPago'],
                                        conceptoPago: snapshot.data?[index]['conceptoPago'],
                                      ),
                                    ),
                                  );
                                setState(() {});
                              }),
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
}
