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
  final List<dynamic> pagosEsp;
  final List<dynamic> pagosRea;
  final DateTime startDate;

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
      required this.pagosEsp,
      required this.pagosRea,
      required this.startDate,
    });

  void initState() {
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

  Future<String> getClienteName() async {
    DocumentSnapshot? doc =
        await db.collection('customers').doc(idCliente).get();
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final temp = {
      "name": data['nameCliente'],
      "lastName": data['lastnameCliente'],
    };
    return temp['name'] + ' ' + temp['lastName'];
  }

  Future<void> loteIdGen() async {
    String numericPart = lote.replaceAll(RegExp(r'[^0-9]'), ''); // Extract the numeric part
    int numericValue = int.tryParse(numericPart) ?? 0; // Parse the numeric part as an integer
    savedName = "L${numericValue.toString().padLeft(2, '0')}";
    clienteName = await getClienteName();
  }

  Future<void> getInv() async {
    vision = await getInversionista('vision');
    invertaga = await getInversionista('invertaga');
  }

  int totalEsp(List<dynamic> pagosList) {
    double totalValorPago = 0;

    // Get the current date
    DateTime currentDate = DateTime.now();

    for (var pago in pagosEsp) {
      // Parse the fechaPago from the document as a DateTime
      DateTime fechaPago = DateFormat('dd-MM-yyyy').parse(pago['fechaPago']);

      // Check if the fechaPago is on or before the current date
      if (fechaPago.isBefore(currentDate) || fechaPago.isAtSameMomentAs(currentDate)) {
        totalValorPago += pago['valorPago'];
      }
    }

    return totalValorPago.toInt();
  }

  int valorFalt(List<dynamic> pagosList) {
    double totalPago = 0;
    double faltante = 0;

    for (var pago in pagosEsp) {
      if (pago['estadoPago'] == "PAGO COMPLETO") {
        totalPago += pago['valorPago'];
      } if (pago['estadoPago'] == "PAGO INCOMPLETO") {
        totalPago += pago['valorPago'];
      }
    }
    faltante = totalPago - valorPagado;

    return faltante.toInt();
  }

  Map<String, dynamic> vision = {};
  Map<String, dynamic> invertaga = {};
  Map<String, dynamic> metodoPago = {};
  String savedName = '';
  String clienteName = '';
  int valorEsp = 0;

  @override
  Widget build(BuildContext context) {   
    loteIdGen();
    
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
            pw.Text('Nombre del titular: $clienteName'),
            pw.Text('Período del estado de cuenta: ${DateFormat('dd-MM-yyyy').format(startDate)} - ${DateFormat('dd-MM-yyyy').format(DateTime.now())}'),
            pw.Text('Fecha de emisión: ${DateFormat('dd-MM-yyyy').format(DateTime.now())}'),
            pw.SizedBox(height: 10),
            pw.Text('Total pagos recibidos: ${currencyCOP((valorPagado.toInt()).toString())}'),          
            pw.Text('Total pagos esperados hasta la fecha: ${currencyCOP((totalEsp(pagosEsp).toInt()).toString())}'),            
            pw.Text('Porcentaje de pago hasta la fecha: ${100*valorPagado/totalEsp(pagosEsp)}%'),
            pw.SizedBox(height: 10),
            pw.Text('Saldo actual: ${currencyCOP((saldoPorPagar.toInt()).toString())}'),
            pw.SizedBox(height: 10),
            pw.Text('Valor total: ${currencyCOP((valorTotal.toInt()).toString())}'),
            pw.SizedBox(height: 10),

            // Pagos Recibidos
            pw.Header(level: 1, text: 'Pagos Recibidos'),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(context: context, data: <List<String>>[
              <String>['Fecha de Pago', 'Concepto', 'Monto Recibido (\$)', 'Método de Pago'],
              for (var doc1 in pagosRea)
                <String>[
                  doc1['fechaPago'], // Date
                  doc1['conceptoPago'].toUpperCase(), // Concept
                  currencyCOP((doc1['valorPago'].toInt()).toString()), // Amount (formatted as 2 decimal places)
                  doc1['metodoPago'], // Payment Status
                ],
            ]),

            // Pagos Esperados
            pw.Header(level: 1, text: 'Pagos Esperados'),
            // ignore: deprecated_member_use
            pw.Table.fromTextArray(context: context, data: <List<String>>[
              <String>['Fecha de Vencimiento', 'Concepto', 'Monto Esperado (\$)', 'Estado del pago'],
              for (var doc2 in pagosEsp)
                <String>[
                  doc2['fechaPago'], // Date
                  doc2['conceptoPago'].toUpperCase(), // Concept
                  currencyCOP((doc2['valorPago'].toInt()).toString()), // Amount (formatted as 2 decimal places)
                  doc2['estadoPago'] == "PAGO INCOMPLETO" ? "SALDO ${currencyCOP((valorFalt(pagosEsp).toInt()).toString())}" : doc2['estadoPago'], // Payment Status
                ],
            ]),

          ];
        },
      ),
    );

    final bytes = await pdf.save();

    return bytes;
  }  
}
