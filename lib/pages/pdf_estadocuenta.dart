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

  Map<String, dynamic> infoInvertaga = {};
  Map<String, dynamic> infoVision = {};

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

  Future<void> ordSepAct() async {
    DocumentReference doc = FirebaseFirestore.instance.collection('ordSep').doc(idPlanPagos);
    DocumentSnapshot doc1 = await doc.get();
    cuotaIni = doc1['vlrCILote'].toDouble();
    vlrPorPagar = doc1['vlrPorPagarLote'].toDouble();
    nroCuotas = doc1['nroCuotasLote'];
  }

  Map<String, dynamic> vision = {};
  Map<String, dynamic> invertaga = {};
  Map<String, dynamic> metodoPago = {};
  String savedName = '';
  String clienteName = '';
  int valorEsp = 0;
  int counter = 0;
  double cuotaIni = 0;
  double vlrPorPagar = 0;
  int nroCuotas = 0;

  pw.Widget buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children:[ 
          pw.Text('Carrera 54#73-85 2piso, 3164449510, visionahora@hotmail.com', style: const pw.TextStyle(fontSize: 8)),
          pw.Text('Carrera 54#73-65, 6076344876, invertaga@hotmail.com', style: const pw.TextStyle(fontSize: 8))
          ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {   
    loteIdGen();
    getInv();
    ordSepAct();
    
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

    final ByteData photo1 = await rootBundle.load('assets/images/logo.png');
    final Uint8List byteList1 = photo1.buffer.asUint8List();
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
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Image(
                          pw.MemoryImage(
                            byteList3,
                          ),
                          height: 30),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(vision['name'], style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text('NIT ${vision['nit']}', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Image(
                            pw.MemoryImage(
                              byteList2,
                            ),
                            height: 20),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(invertaga['name'], style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text('NIT ${invertaga['nit']}', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Image(
                      pw.MemoryImage(
                        byteList1,
                      ),
                      height: 100
                    ),
                    pw.Text('CONDOMINIO CAMPESTRE ALBATERRA PH', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Divider(thickness: 1),
                    pw.Text('INFORMACIÓN DEL INMUEBLE', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ]
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('COMPRADOR: $clienteName', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('FECHA: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('NÚMERO DE IDENTIFICACIÓN: $idCliente', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(lote.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['VALOR TOTAL', 'VALOR CUOTA INICIAL', 'VALOR SALDO TOTAL', 'NÚMERO DE CUOTAS', 'VALOR PAGADO EN CUOTAS'],
                  [currencyCOP((valorTotal.toInt()).toString()), currencyCOP((cuotaIni.toInt()).toString()), currencyCOP((vlrPorPagar.toInt()).toString()), nroCuotas, currencyCOP((valorPagado.toInt()).toString())],
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('ESTADO DE CARTERA', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ]
                ),
              ),
              pw.SizedBox(height: 10),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['ITEM', 'FECHA', 'DESCRIPCIÓN', 'DÍA DE PAGO', 'VALOR PAGADO'],
                  for (var doc1 in pagosRea)
                    [
                      (++counter).toString(),
                      doc1['fechaRecibo'], // Date
                      doc1['conceptoPago'].toUpperCase(), // Concept
                      doc1['fechaPago'], // Payment Status
                      currencyCOP((doc1['valorPago'].toInt()).toString()) // Amount (formatted as 2 decimal places)
                    ],
                  ['', '', '', 'TOTAL', currencyCOP((valorPagado.toInt()).toString())],
                  ['', '', 'VALOR TOTAL', '', currencyCOP((valorTotal.toInt()).toString())],
                  ['', '', 'VALOR PAGADO', '', currencyCOP((valorPagado.toInt()).toString())],
                  ['', '', 'SALDO', '', currencyCOP((saldoPorPagar.toInt()).toString())],
                ],
              ),
              pw.SizedBox(height: 60),
              pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'VICTOR ALFONSO OROSTEGUI P.',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 10, 
                              fontWeight: pw.FontWeight.bold,
                            ),                            
                          ),
                          pw.Text(
                            'GERENTE CONDOMINIO CAMPESTRE',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'ALBATERRA PH',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 10,
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
                            'LAURA MELISSA AGUDELO V.',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontSize: 10, 
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'AUX. CARTERA CONDOMINIO',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 10,
                            ),
                          ),
                          pw.Text(
                            'CAMPESTRE ALBATERRA PH',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              

          ];
        },
        footer: buildFooter,
      ),
    );

    final bytes = await pdf.save();

    return bytes;
  }  
}
