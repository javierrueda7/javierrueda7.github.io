import 'dart:async';
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

  DateTime startDate = DateTime.now(); // Fecha de inicio del rango
  DateTime endDate= DateTime.now();   // Fecha de fin del rango

  TextEditingController startDateController = TextEditingController(text: "");
  TextEditingController endDateController = TextEditingController(text: "");


  Future<List> getMatchingDocuments() async {
    List matchingDocuments = [];

    QuerySnapshot planPagosSnapshot = await FirebaseFirestore.instance
        .collection('planPagos')
        .get();

    for (QueryDocumentSnapshot planPagoSnapshot in planPagosSnapshot.docs) {
      String planPagoId = planPagoSnapshot.id; // Get the document ID
      CollectionReference pagosEsperadosRef =
          planPagoSnapshot.reference.collection('pagosEsperados');

      QuerySnapshot pagosSnapshot = await pagosEsperadosRef.get();

      for (QueryDocumentSnapshot pagoSnapshot in pagosSnapshot.docs) {        
        final Map<String, dynamic> data = pagoSnapshot.data() as Map<String, dynamic>;
        String fechaPagoString = data['fechaPago']; // Get the fechaPago as string
        DateTime fechaPago = DateFormat('dd-MM-yyyy').parse(fechaPagoString);

        if (fechaPago.isAfter(startDate) && fechaPago.isBefore(endDate)) {
          final pagoEsperado = {
            "lote": planPagoId,
            "idPago": pagoSnapshot.id,
            "idPlan": data['idPlanPagos'],
            "fechaPago": data['fechaPago'],
            "valorPago": data['valorPago'],
            "conceptoPago": data['conceptoPago'],
          };
          matchingDocuments.add(pagoEsperado); // Add the planPago document if pagosEsperados match
        }
      }
    }
    matchingDocuments.sort((a, b) {
      DateTime dateA = DateFormat('dd-MM-yyyy').parse(a['fechaPago']);
      DateTime dateB = DateFormat('dd-MM-yyyy').parse(b['fechaPago']);
      return dateA.compareTo(dateB);
    });

    return matchingDocuments;
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
                                    lastDate: DateTime.now(),
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
                      return const Text('No se encontraron pagos en el rango seleccionado.');
                    }
                
                    return Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                              
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: fourthColor,
                              child: Text(
                                getNumbers(snapshot.data?[index]['lote'])!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                              )
                            ),
                            title: Text('Valor: ${currencyCOP((snapshot.data?[index]['valorPago'].toInt()).toString())}'),
                            subtitle: Text('Fecha: ${snapshot.data?[index]['fechaPago']}'),
                            trailing: Text('Concepto: ${snapshot.data?[index]['idPago']}'),
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
    );
  }
}