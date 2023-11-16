import 'dart:async';
import 'package:albaterrapp/pages/add_payment.dart';
import 'package:albaterrapp/pages/pdf_preinvoice.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/color_utils.dart';

class PagosEsperados extends StatefulWidget {
  const PagosEsperados({super.key});

  @override
  State<PagosEsperados> createState() => _PagosEsperadosState();
}

class _PagosEsperadosState extends State<PagosEsperados> {
  
  @override
  void initState() {
    super.initState();
    startDateController.text = DateFormat('dd-MM-yyyy').format(startDate);
    endDateController.text = DateFormat('dd-MM-yyyy').format(endDate);
  }

  @override
  void dispose() {    
    super.dispose();
  }

  DateTime dateConverter(String stringAConvertir) {
    DateTime dateConverted = DateFormat('dd-MM-yyyy').parse(stringAConvertir);
    return dateConverted;
  }

  DateTime startDate = DateTime((DateTime.now()).year, (DateTime.now()).month, 1); // Fecha de inicio del rango
  DateTime endDate= DateTime((DateTime.now()).year, (DateTime.now()).month + 1, 0);   // Fecha de fin del rango

  TextEditingController startDateController = TextEditingController(text: "");
  TextEditingController endDateController = TextEditingController(text: "");


  Future<List<Map<String, dynamic>>> getMatchingDocuments() async {
    List<Map<String, dynamic>> matchingDocuments = [];

    final QuerySnapshot planPagosSnapshot = await FirebaseFirestore.instance
        .collection('planPagos')
        .get();

    final List<Future<Map<String, dynamic>>> quoteAndCustomerFutures = [];

    for (QueryDocumentSnapshot planPagoSnapshot in planPagosSnapshot.docs) {
      final String planPagoId = planPagoSnapshot.id;

      final CollectionReference pagosEsperadosRef =
          planPagoSnapshot.reference.collection('pagosEsperados');

      final QuerySnapshot pagosSnapshot = await pagosEsperadosRef.get();

      for (QueryDocumentSnapshot pagoSnapshot in pagosSnapshot.docs) {
        final Map<String, dynamic> data =
            pagoSnapshot.data() as Map<String, dynamic>;
        final String fechaPagoString = data['fechaPago'];
        final DateTime fechaPago =
            DateFormat('dd-MM-yyyy').parse(fechaPagoString);

        // Collect the planPago IDs for concurrent fetching
        final String idPlanPagos = data['idPlanPagos'];
        quoteAndCustomerFutures.add(fetchQuoteAndCustomer(idPlanPagos));

        if (fechaPago.isAfter(startDate) && fechaPago.isBefore(endDate)) {
          final pagoEsperado = {
            "lote": planPagoId,
            "idPago": pagoSnapshot.id,
            "idPlan": idPlanPagos,
            "fechaPago": data['fechaPago'],
            "valorPago": data['valorPago'],
            "conceptoPago": data['conceptoPago'],
          };
          matchingDocuments.add(pagoEsperado);
        }
      }
    }

    // Wait for all quoteSnap and customer data to be fetched
    final List<Map<String, dynamic>> quoteAndCustomerData =
        await Future.wait(quoteAndCustomerFutures);

    // Combine quoteSnap and customer data into matchingDocuments
    for (int i = 0; i < matchingDocuments.length; i++) {
      final Map<String, dynamic> matchingDocument = matchingDocuments[i];
      final Map<String, dynamic> quoteSnapData = quoteAndCustomerData[i]['quoteSnap'];
      final Map<String, dynamic> customerData = quoteAndCustomerData[i]['customer'];

      matchingDocument["idCliente"] = quoteSnapData["clienteID"];
      matchingDocument["nameCliente"] =
          "${customerData["nameCliente"]} ${customerData["lastnameCliente"]}";
      matchingDocument["telCliente"] = customerData["telCliente"];
      matchingDocument["emailCliente"] = customerData["emailCliente"];
    }

    // Sort the matchingDocuments by fechaPago
    matchingDocuments.sort((a, b) {
      DateTime dateA = DateFormat('dd-MM-yyyy').parse(a['fechaPago']);
      DateTime dateB = DateFormat('dd-MM-yyyy').parse(b['fechaPago']);
      return dateA.compareTo(dateB);
    });

    return matchingDocuments;
  }

  Future<Map<String, dynamic>> fetchQuoteAndCustomer(String idPlanPagos) async {
    final DocumentSnapshot<Map<String, dynamic>> quoteSnap =
        await db.collection('quotes').doc(idPlanPagos).get();

    final Map<String, dynamic> customer =
        await getCustomerInfo(quoteSnap["clienteID"]);

    return {
      'quoteSnap': quoteSnap.data(),
      'customer': customer,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(        
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text('PAGOS ESPERADOS',
          style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        /*actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {                
                actConcepto();                
              },
              child: const Icon(Icons.today_outlined),
            )
          ),
        ],*/
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Color.fromARGB(255, 244, 246, 252),
            Color.fromARGB(255, 222, 224, 227),
            Color.fromARGB(255, 222, 224, 227)
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [ 
                    Expanded(
                      flex: 1,
                      child: Column(                    
                        children: [  
                          const SizedBox(
                            height: 20,
                          ),                    
                          const SizedBox(
                            height: 15,
                            child: Text(
                              'Desde',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: fifthColor.withOpacity(0.1)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextField(
                                textAlign: TextAlign.center,
                                cursorColor: fifthColor,
                                style: TextStyle(
                                    color: fifthColor.withOpacity(0.9)),
                                controller: startDateController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: Icon(
                                    Icons.date_range_outlined,
                                    color: fifthColor,
                                  ),
                                  hintText: DateFormat('dd-MM-yyyy')
                                      .format(DateTime.now()),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate =
                                      await showDatePicker(
                                    locale: const Locale("es", "CO"),
                                    context: context,
                                    initialDate: dateConverter(
                                        startDateController.text),
                                    firstDate: DateTime(1900),
                                    lastDate: dateConverter(
                                    endDateController.text),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      startDateController.text =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                      startDate = dateConverter(startDateController.text);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(                        
                            height: 15,
                            child: Text(
                              'Hasta',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30.0),
                              border: Border.all(
                                  width: 1,
                                  style: BorderStyle.solid,
                                  color: fifthColor.withOpacity(0.1)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextField(
                                textAlign: TextAlign.center,
                                cursorColor: fifthColor,
                                style: TextStyle(
                                    color: fifthColor.withOpacity(0.9)),
                                controller: endDateController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: Icon(
                                    Icons.date_range_outlined,
                                    color: fifthColor,
                                  ),
                                  hintText: DateFormat('dd-MM-yyyy')
                                      .format(DateTime.now()),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  DateTime? pickedDate =
                                      await showDatePicker(
                                    locale: const Locale("es", "CO"),
                                    context: context,
                                    initialDate: dateConverter(
                                        endDateController.text),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2050),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      endDateController.text =
                                          DateFormat('dd-MM-yyyy')
                                              .format(pickedDate);
                                      endDate = dateConverter(endDateController.text);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FutureBuilder(
                  future: getMatchingDocuments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Column(
                        children: [
                          SizedBox(height: 20),
                          Text('No se encontraron pagos en el rango seleccionado.'),
                        ],
                      );
                    }
                
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          String conceptoText = '';
                          var idPago = snapshot.data?[index]['idPago'];
                          if (idPago == 'SEP1') {
                            conceptoText = 'Abono de separación #1';
                          } else if (idPago == 'SEP2') {
                            conceptoText = 'Abono de separación #2';
                          } else if (idPago == 'TOTAL') {
                            conceptoText = 'Pago total';
                          } else if (idPago == 'CINI') {
                            conceptoText = 'Abono de cuota inicial';
                          } else{
                            conceptoText = 'Cuota #$idPago';
                          }
                          return ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: fourthColor,
                                  child: Text(
                                    getNumbers(snapshot.data?[index]['lote'])!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ),
                              ],
                            ),
                            title: Column(
                              children: [
                                Text('Valor: ${currencyCOP((snapshot.data?[index]['valorPago'].toInt()).toString())}'),
                                Text('Fecha: ${snapshot.data?[index]['fechaPago']}'),
                              ],
                            ),
                            subtitle: Column(
                              children: [
                                Text('Concepto: $conceptoText', style: const TextStyle(fontSize: 10),),
                                Text('Cliente: ${snapshot.data?[index]['nameCliente']}', style: const TextStyle(fontSize: 10),)
                              ],
                            ),
                            trailing: IconButton(
                              onPressed:  (() async {
                                String valorEnLetras = await numeroEnLetras(snapshot.data?[index]['valorPago'].toDouble(), 'pesos');
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PDFPreInvoice(
                                      idPlan: snapshot.data?[index]['idPlan'],
                                      lote: getNumbers(snapshot.data?[index]['lote'])!,                                
                                      nameCliente: snapshot.data?[index]['nameCliente'],
                                      idCliente: snapshot.data?[index]['idCliente'],
                                      phoneCliente: snapshot.data?[index]['telCliente'],
                                      emailCliente: snapshot.data?[index]['emailCliente'],                                        
                                      paymentDate: snapshot.data?[index]['fechaPago'],                                  
                                      paymentValue: snapshot.data?[index]['valorPago'].toDouble(),
                                      paymentValueLetters: valorEnLetras,
                                      conceptoPago: conceptoText,
                                    ),
                                  ),
                                );
                                setState(() {});
                              }), 
                              icon: const Icon(Icons.picture_as_pdf_outlined)
                            ),
                            onTap: ( (){}/*() async {
                              String valorEnLetras = await numeroEnLetras(snapshot.data?[index]['valorPago'].toDouble(), 'pesos');
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPaymentPage(
                                    idPlan: snapshot.data?[index]['idPlan'],
                                    lote: getNumbers(snapshot.data?[index]['lote'])!,                                
                                    nameCliente: snapshot.data?[index]['nameCliente'],
                                    idCliente: snapshot.data?[index]['idCliente'],
                                    phoneCliente: snapshot.data?[index]['telCliente'],
                                    emailCliente: snapshot.data?[index]['emailCliente'],                                        
                                    paymentDate: snapshot.data?[index]['fechaPago'],                                  
                                    paymentValue: snapshot.data?[index]['valorPago'].toDouble(),
                                    paymentValueLetters: valorEnLetras,
                                    conceptoPago: conceptoText,
                                  ),
                                ),
                              );
                              setState(() {});                      
                              }*/
                            ),
                            // Display other relevant information about the document
                            // ...
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                const AddPaymentPage()));
          setState(() {});          
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  void updatePagosWithPlanIds() async {
    final firestore = FirebaseFirestore.instance;

    // Query the planPagos collection to retrieve doc.id and idPlanPagos
    final planPagosQuery = await firestore.collection('planPagos').get();

    // Query the pagos collection
    final pagosQuery = await firestore.collection('pagos').get();

    // Loop through each document in planPagos
    for (final planPagosDoc in planPagosQuery.docs) {
      final idLoteAux = planPagosDoc.id;
      final idPPAux = planPagosDoc['idPlanPagos'];      

      // Loop through each document in pagos
      for (final pagosDoc in pagosQuery.docs) {
        final pagosData = pagosDoc.id;

        // Compare doc.id in pagos with idPlanPagos from planPagos
        if (pagosData.contains(idLoteAux)) {
          // Update the idPlanPagos field in the pagos document
          await firestore.collection('pagos').doc(pagosDoc.id).update({
            'idPlanPagos': idPPAux,
          });
        }
      }
    }
  }

  /*Future<void> obtenerPagosEsperados() async {
    List<Map<String, dynamic>> listaPagos = [];
    // Referencia al documento "L03" en la colección "planPagos"
    DocumentReference documentoL03Ref = FirebaseFirestore.instance.collection('planPagos').doc('L67');
    DocumentSnapshot documentoL03Snapshot = await documentoL03Ref.get();

    
    double valorPagado = documentoL03Snapshot['valorPagado'];
    // Obtener la subcolección "pagosEsperados" del documento "L03"
    QuerySnapshot pagosEsperados = await documentoL03Ref.collection('pagosEsperados').get();

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

      // Manejar documentos no encontrados en ordenEsperado
      if (indexA == -1 && indexB == -1) {
        return a['docId'].compareTo(b['docId']);
      } else if (indexA == -1) {
        return 1; // Mover documentos no encontrados al final
      } else if (indexB == -1) {
        return -1; // Mover documentos no encontrados al final
      } else {
        return indexA - indexB;
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

    }
  }*/

  bool esNumero(String str) {
    return double.tryParse(str) != null;
  }

  Future<void> actConcepto() async {
    final firestore = FirebaseFirestore.instance;  
    final QuerySnapshot planPagosSnapshot =
      await FirebaseFirestore.instance.collection('planPagos').get();

    for (QueryDocumentSnapshot document in planPagosSnapshot.docs) {
      final String tempLoteId = document.id;
      List<dynamic> pagosReal = await getPagos(tempLoteId);
      DocumentReference documentoRef = FirebaseFirestore.instance.collection('planPagos').doc(tempLoteId);
      DocumentSnapshot documentoSnapshot = await documentoRef.get();
      DocumentReference ordSep = FirebaseFirestore.instance.collection('ordSep').doc(documentoSnapshot['idPlanPagos']);
      DocumentSnapshot ordSepTemp = await ordSep.get();
      cuotaIni = ordSepTemp['vlrCILote'].toInt();
      double totalPagado = 0;
      String concepto = '';
      for (var pagoR in pagosReal){
        totalPagado = totalPagado + pagoR['valorPago'];
        if(totalPagado <= documentoSnapshot['valorSeparacion']){
          concepto = 'SEPARACIÓN';
        } else if(documentoSnapshot['paymentMethod'] == 'Financiación directa' && totalPagado <= cuotaIni){
          concepto = 'CUOTA INICIAL';
        } else{
          concepto = 'ABONO SALDO TOTAL';
        }
        await firestore.collection('pagos').doc(pagoR['pid']).update({
          'conceptoPago': concepto,
        });
      }
    }
  }

  int cuotaIni = 0;

  Future<void> ajustarPagosEsperados() async {
    final firestore = FirebaseFirestore.instance;  
    final QuerySnapshot planPagosSnapshot =
      await FirebaseFirestore.instance.collection('planPagos').get();

    for (QueryDocumentSnapshot document in planPagosSnapshot.docs) {
      final String tempLoteId = document.id;
      List<Map<String, dynamic>> listaPagos = [];

      DocumentReference documentoRef = FirebaseFirestore.instance.collection('planPagos').doc(tempLoteId);
      DocumentSnapshot documentoSnapshot = await documentoRef.get();
      
      
      double valorPagado = documentoSnapshot['valorPagado'];
      double saldoPorPagar = documentoSnapshot['saldoPorPagar'];
      double precioFin = documentoSnapshot['precioFin'];
      String idPlanPagos = documentoSnapshot['idPlanPagos'];

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
        
        if(saldoPorPagar<1){
          estadoPago = 'PAGO COMPLETO';
        } else if(valorPagado-valorPago == 0){
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
        
        await firestore.collection('planPagos').doc(tempLoteId).collection('pagosEsperados').doc(docId).update({
          'estadoPago': estadoPago,
        });
      }
      if(saldoPorPagar<1){
        await firestore.collection('planPagos').doc(tempLoteId).update({
          'saldoPorPagar': 0,
          'estadoPago': 'Completo',
          'valorPagado': precioFin.toInt(),
          'precioFin': precioFin.toInt()
        });
        await db.collection("lotes").doc(tempLoteId).update({"loteState": 'Lote vendido'});
        await db.collection("quotes").doc(idPlanPagos).update({"quoteStage": 'LOTE VENDIDO', "precioFinal": precioFin.toInt()});
        await db.collection("ordSep").doc(idPlanPagos).update({"stageSep": 'LOTE VENDIDO', "precioFinal": precioFin.toInt()});
      }
    }
  }
}