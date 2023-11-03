import 'package:albaterrapp/pages/pagosesperados_page.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ignore: must_be_immutable
class PDFEstadoCuenta extends StatelessWidget {
  final String idPlanPagos;
  final String idCliente;
  final String lote;
  final String paymentMethod;
  final double valorInicial;
  final double descuento;
  final double valorPagado;
  final double saldoPorPagar;
  final double valorTotal;

  PDFEstadoCuenta(
      {super.key,
      required this.idPlanPagos,
      required this.idCliente,
      required this.lote,
      required this.paymentMethod,
      required this.valorInicial,
      required this.descuento,
      required this.valorPagado,
      required this.saldoPorPagar,
      required this.valorTotal,
    });

  void initState() {
    getPagosEsperados();
    getInv();
    getMatchingDocuments();
  }
  
  User? user = FirebaseAuth.instance.currentUser;
  String loggedEmail = '';
  String loggedName = '';

  Future<String> getLoggedName() async {    
    user = FirebaseAuth.instance.currentUser;
    loggedEmail = user!.email!;
    QuerySnapshot loggedSnapshot = await db
        .collection('sellers')
        .where('emailSeller', isEqualTo: loggedEmail)
        .get();
    if (loggedSnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = loggedSnapshot.docs.first;
      loggedName = doc['nameSeller'] + ' ' + doc['lastnameSeller'];
    } else {
      loggedName = 'JAVIER CAMILO RUEDA SERRANO';
    }
    return loggedName;
  }
  
  Future<void> getMatchingDocuments() async {

    List<Map<String, dynamic>> matchingDocuments = [];

    final QuerySnapshot pagosSnapshot = await FirebaseFirestore.instance
        .collection('planPagos').doc(savedName).collection('pagosEsperados')
        .get();

    final List<Future<Map<String, dynamic>>> quoteAndCustomerFutures = [];

    for (QueryDocumentSnapshot pagoSnapshot in pagosSnapshot.docs) {
      final Map<String, dynamic> data =
          pagoSnapshot.data() as Map<String, dynamic>;
      quoteAndCustomerFutures.add(fetchQuoteAndCustomer(idPlanPagos));
      
      final pagoEsperado = {
        "lote": savedName,
        "idPago": pagoSnapshot.id,
        "idPlan": idPlanPagos,
        "fechaPago": data['fechaPago'],
        "valorPago": data['valorPago'],
        "conceptoPago": data['conceptoPago'],
        "estadoPago": data['estadoPago'],
      };
      matchingDocuments.add(pagoEsperado);        
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
    pagosEsperadosList = matchingDocuments;
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

  Future<void> getPagosEsperados() async {
    loteIdGen();
    DocumentSnapshot? doc =
        await db.collection('planPagos').doc(savedName).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final temp = {
      "banco": data['banco'],
      "nroCuenta": data['nroCuenta'],  
      "tipoCuenta": data['tipoCuenta'],
    };
    metodoPago = temp;
  }

  void loteIdGen(){
    String numericPart = lote.replaceAll(RegExp(r'[^0-9]'), ''); // Extract the numeric part
    int numericValue = int.tryParse(numericPart) ?? 0; // Parse the numeric part as an integer
    savedName = "L${numericValue.toString().padLeft(2, '0')}";    
  }

  Future<void> getInv() async {
    vision = await getInversionista('vision');
    invertaga = await getInversionista('invertaga');
  }

  Map<String, dynamic> vision = {};
  Map<String, dynamic> invertaga = {};
  Map<String, dynamic> metodoPago = {};
  String savedName = '';
  List<Map<String, dynamic>> pagosEsperadosList = [];

  @override
  Widget build(BuildContext context) {   
    loteIdGen();
    getMatchingDocuments();
    print(pagosEsperadosList);
    
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Estado de cuenta - $lote',
          style: TextStyle(
              color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: PdfPreview(        
        pdfFileName: 'estadocuenta_$idPlanPagos',
        build: (format) => generatePdf(context),
        // You can set the initial page format here
        initialPageFormat: PdfPageFormat.letter.copyWith(
          width: PdfPageFormat.a4.height,
          height: PdfPageFormat.a4.width,
        ),
      ),
    );
  }

  Future<Uint8List> generatePdf(BuildContext context) async {

    final pdf = pw.Document();

    //final ByteData photo1 = await rootBundle.load('assets/images/logo.png');
    //final Uint8List byteList1 = photo1.buffer.asUint8List();
    final ByteData photo2 =
        await rootBundle.load('assets/images/invertaga.png');
    final Uint8List byteList2 = photo2.buffer.asUint8List();
    final ByteData photo3 = await rootBundle.load('assets/images/vision.png');
    final Uint8List byteList3 = photo3.buffer.asUint8List();  

    loggedName = await getLoggedName();  

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32.0),
        build: (pw.Context context) {
          return <pw.Widget>[
            // Encabezado
            pw.Header(
              level: 0,
              child: pw.Text('Estado de Cuenta - $lote',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Número de cuenta: $idPlanPagos'),
            pw.Text('Nombre del titular: Juan Pérez'),
            pw.Text('Período del estado de cuenta: 01/10/2023 - 31/10/2023'),
            pw.Text('Fecha de emisión: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}'),
            pw.SizedBox(height: 10),
            pw.Text('Saldo actual: ${currencyCOP((saldoPorPagar.toInt()).toString())}'),
            pw.SizedBox(height: 10),

            // Pagos Esperados
            pw.Header(level: 1, text: 'Pagos Esperados'),
            pw.Table.fromTextArray(context: context, data: <List<String>>[
              <String>['Fecha de Vencimiento', 'Concepto', 'Monto Esperado (\$)', 'Estado del pago'],
              for (var document in pagosEsperadosList)
                <String>[
                  document['fechaPago'], // Date
                  document['conceptoPago'], // Concept
                  currencyCOP((document['valorPago'].toInt()).toString()), // Amount (formatted as 2 decimal places)
                  document['estadoPago'], // Payment Status
                ],
            ]),

            // Pagos Recibidos
            pw.Header(level: 1, text: 'Pagos Recibidos'),
            pw.Table.fromTextArray(context: context, data: <List<String>>[
              <String>['Fecha de Pago', 'Descripción', 'Monto Recibido (\$)'],
              <String>['05/10/2023', 'Cuota de Préstamo', '500.00'],
              <String>['12/10/2023', 'Tarjeta de Crédito', '100.00'],
              <String>['21/10/2023', 'Alquiler', '800.00'],
              <String>['25/10/2023', 'Electricidad', '75.00'],
              <String>['30/10/2023', 'Teléfono', '50.00'],
            ]),

            // Resumen
            pw.Header(level: 1, text: 'Resumen'),
            pw.Text('Saldo Anterior: \$2,500.00'),
            pw.Text('Total Pagos Esperados: \$1,525.00'),
            pw.Text('Total Pagos Recibidos: \$1,525.00'),
            pw.Text('Saldo Actual: \$1,000.00'),
            pw.SizedBox(height: 10),

            // Transacciones Recientes
            pw.Header(level: 1, text: 'Transacciones Recientes'),
            pw.Table.fromTextArray(context: context, data: <List<String>>[
              <String>['Fecha', 'Descripción', 'Monto (\$)'],
              <String>['05/10/2023', 'Pago de Cuota de Préstamo', '-500.00'],
              <String>['12/10/2023', 'Pago de Tarjeta de Crédito', '-100.00'],
              <String>['21/10/2023', 'Pago de Alquiler', '-800.00'],
              <String>['25/10/2023', 'Pago de Electricidad', '-75.00'],
              <String>['30/10/2023', 'Pago de Teléfono', '-50.00'],
            ]),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    return bytes;
  }  
}
