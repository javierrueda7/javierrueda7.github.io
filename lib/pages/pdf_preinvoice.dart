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
class PDFPreInvoice extends StatelessWidget {
  final String idPlan;  
  final String lote;  
  final String nameCliente;
  final String idCliente;
  final String phoneCliente;  
  final String emailCliente;
  final String paymentDate;  
  final double paymentValue;
  final String paymentValueLetters;
  final String conceptoPago;

  PDFPreInvoice(
      {super.key,
      required this.idPlan,
      required this.lote,
      required this.nameCliente,
      required this.idCliente,
      required this.phoneCliente,
      required this.emailCliente,
      required this.paymentDate,
      required this.paymentValue,
      required this.paymentValueLetters,
      required this.conceptoPago,
    });

  void initState() {
    getInv();
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

  Future<void> getInv() async {
    vision = await getInversionista('vision');
    invertaga = await getInversionista('invertaga');
  }

  Map<String, dynamic> vision = {};
  Map<String, dynamic> invertaga = {};
  Map<String, dynamic> metodoPago = {};
  String savedName = '';

  @override
  Widget build(BuildContext context) {    
    getInv();
    savedName = idPlan + conceptoPago.replaceAll(RegExp(r'[.\s#]'), ''); // Remove dots, spaces, and #
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Recibo de pago',
          style: TextStyle(
              color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: PdfPreview(        
        pdfFileName: 'cobro_${savedName.toLowerCase()}',
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
      pw.Page(
        pageTheme: pw.PageTheme(
          // orientation:  pw.PageOrientation.landscape, //this set the orientation of the content of the page, not the page itself. Which confuses most people
          pageFormat: PdfPageFormat.letter.landscape,
        ),
        build: (context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Image(
                            pw.MemoryImage(
                              byteList3,
                            ),
                            height: 30),
                        pw.Image(
                            pw.MemoryImage(
                              byteList2,
                            ),
                            height: 20),
                        pw.SizedBox(height: 10),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(vision['name'], style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text('NIT ${vision['nit']}', style: const pw.TextStyle(fontSize: 12)),
                          pw.Text(vision['dir'], style: const pw.TextStyle(fontSize: 12)),
                          pw.Text('Tel: ${vision['tel']}', style: const pw.TextStyle(fontSize: 12)),
                          pw.Text('${vision['ciudad']} - Colombia', style: const pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(invertaga['name'], style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.Text('NIT ${invertaga['nit']}', style: const pw.TextStyle(fontSize: 12)),
                          pw.Text(invertaga['dir'], style: const pw.TextStyle(fontSize: 12)),
                          pw.Text('Tel: ${invertaga['tel']}', style: const pw.TextStyle(fontSize: 12)),
                          pw.Text('${invertaga['ciudad']} - Colombia', style: const pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Plan de pago $idPlan - Cobro $conceptoPago', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('Nombre cliente',
                          textAlign: pw.TextAlign.left, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(nameCliente,
                          textAlign: pw.TextAlign.left, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('Fecha',
                          textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                pw.Row(
                  children: [                    
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Teléfono',
                            textAlign: pw.TextAlign.left, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(phoneCliente,
                            textAlign: pw.TextAlign.left, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Email',
                            textAlign: pw.TextAlign.left, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(emailCliente,
                            textAlign: pw.TextAlign.left, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(DateFormat('dd-MM-yyyy').format(DateTime.now()),
                          textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                    ),                    
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text('SE RECUERDA EL PAGO POR CONCEPTO DE: ${conceptoPago.toUpperCase()} CON VALOR DE',
                    textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [                    
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('${paymentValueLetters.toUpperCase()} M/CTE',
                            textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(currencyCOP((paymentValue.toInt()).toString()),
                            textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(                  
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('Concepto',
                            textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('Fecha de pago',
                            textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('Valor',
                            textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(' ',
                            textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(conceptoPago,
                            textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(' ',
                            textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(' ',
                            textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(paymentDate,
                            textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(' ',
                            textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(' ',
                            textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(currencyCOP(paymentValue.toString()),
                            textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(' ',
                            textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            '_______${loggedName.toUpperCase()}_______',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 10, 
                              fontWeight: pw.FontWeight.bold,
                              decoration: pw.TextDecoration.underline
                            ),                            
                          ),
                          pw.Text(
                            'Firma elaborado',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 10, 
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            '_____________________________',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 10, 
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Firma recibido',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 10, 
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();

    return bytes;
  }  
}
