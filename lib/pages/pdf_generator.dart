import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ignore: must_be_immutable
class PDFGenerator extends StatelessWidget {
  final String sellerID;
  final String sellerName;
  final String sellerPhone;
  final String sellerEmail;
  final String quoteId;
  final String name;
  final String lastname;
  final String phone;
  final String date;
  final String dueDate;
  final String lote;
  final String area;
  final String price;
  final String finalPrice;
  final String discount;
  final String porcCuotaIni;
  final String vlrCuotaIni;
  final String vlrSeparacion;
  final String dueDateSeparacion;
  final String saldoSeparacion;
  final String dueDateSaldoSeparacion;
  final String plazoCI;
  final String plazoContado;
  final String saldoCI;
  final String dueDateSaldoCI;
  final String porcPorPagar;
  final String vlrPorPagar;
  final String paymentMethod;
  final String tiempoFinanc;
  final String vlrCuota;
  final String saldoTotalDate;
  final String periodoCuotas;
  final String nroCuotas;
  final String tem;
  final String observaciones;
  final String quoteStage;

  PDFGenerator(
      {super.key,
      required this.sellerID,
      required this.sellerName,
      required this.sellerPhone,
      required this.sellerEmail,
      required this.quoteId,
      required this.name,
      required this.lastname,
      required this.phone,
      required this.date,
      required this.dueDate,
      required this.lote,
      required this.area,
      required this.price,
      required this.finalPrice,
      required this.discount,
      required this.porcCuotaIni,
      required this.vlrCuotaIni,
      required this.vlrSeparacion,
      required this.dueDateSeparacion,
      required this.saldoSeparacion,
      required this.dueDateSaldoSeparacion,
      required this.plazoCI,
      required this.plazoContado,
      required this.saldoCI,
      required this.dueDateSaldoCI,
      required this.porcPorPagar,
      required this.vlrPorPagar,
      required this.paymentMethod,
      required this.tiempoFinanc,
      required this.vlrCuota,
      required this.saldoTotalDate,
      required this.periodoCuotas,
      required this.nroCuotas,
      required this.tem,
      required this.observaciones,
      required this.quoteStage});

  void initState() {
    initCont();
  }

  Map<String, dynamic> infoCont = {};
  String emailAlbaterra = '';
  String phoneAlbaterra = '';
  String webAlbaterra = '';

  Future<Map<String, dynamic>> getInfoContacto() async {
    DocumentSnapshot<Map<String, dynamic>> infoContacto =
        await db.collection('infoproyecto').doc('infoGeneral').get();
    final Map<String, dynamic> data =
        infoContacto.data() as Map<String, dynamic>;
    final contactoInfo = {
      "email": data['email'],
      "phone": data['phone'],
      "web": data['web'],
    };
    return contactoInfo;
  }

  Future<void> initCont() async {
    infoCont = await getInfoContacto();
    emailAlbaterra = infoCont['email'];
    phoneAlbaterra = infoCont['phone'];
    webAlbaterra = infoCont['web'];
  }

  @override
  Widget build(BuildContext context) {
    initCont();
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Vista previa cotización',
          style: TextStyle(
              color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: PdfPreview(
        pdfFileName: 'Cotizacion $quoteId',
        build: (format) => generatePdf(context),
        // You can set the initial page format here
        initialPageFormat: PdfPageFormat.letter.landscape,
      ),
    );
  }

  Future<Uint8List> generatePdf(BuildContext context) async {
    final ByteData photo1 = await rootBundle.load('assets/images/logo.png');
    final Uint8List byteList1 = photo1.buffer.asUint8List();
    final ByteData photo2 =
        await rootBundle.load('assets/images/invertaga.png');
    final Uint8List byteList2 = photo2.buffer.asUint8List();
    final ByteData photo3 = await rootBundle.load('assets/images/vision.png');
    final Uint8List byteList3 = photo3.buffer.asUint8List();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
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
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Image(
                            pw.MemoryImage(
                              byteList1,
                            ),
                            height: 60),
                        pw.Text('COTIZACIÓN: $quoteId',
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text(quoteStage,
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Image(
                            pw.MemoryImage(
                              byteList2,
                            ),
                            height: 20),
                        pw.Image(
                            pw.MemoryImage(
                              byteList3,
                            ),
                            height: 30),
                        pw.SizedBox(height: 10),
                        pw.Row(children: [
                          pw.Text(phoneAlbaterra,
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(' | '),
                          pw.Text(emailAlbaterra,
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(' | '),
                          pw.Text(webAlbaterra,
                              style: const pw.TextStyle(fontSize: 10)),
                        ])
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('Fecha de cotización: $date',
                          textAlign: pw.TextAlign.left),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('Valido hasta: $dueDate',
                          textAlign: pw.TextAlign.right),
                    ),
                  ],
                ),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('Nombre: $name $lastname',
                          textAlign: pw.TextAlign.left),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('Teléfono: $phone',
                          textAlign: pw.TextAlign.left),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Inmueble Nº: $lote',
                              textAlign: pw.TextAlign.left),
                          pw.SizedBox(height: 5),
                          pw.Text('Área: $area', textAlign: pw.TextAlign.left),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Valor inicial: $price',
                              textAlign: pw.TextAlign.left),
                          pw.SizedBox(height: 5),
                          pw.RichText(
                            textAlign: pw.TextAlign.left,
                            text: pw.TextSpan(
                              children: <pw.TextSpan>[
                                pw.TextSpan(text: 'Valor final: $finalPrice '),
                                pw.TextSpan(
                                  text: '($discount dcto)',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                metodoPago(paymentMethod, context),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          'OBSERVACIONES',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(observaciones, textAlign: pw.TextAlign.left),
                      ]),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Asesor comercial',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(sellerName, textAlign: pw.TextAlign.left),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Teléfono',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(sellerPhone, textAlign: pw.TextAlign.center),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Correo electrónico',
                            textAlign: pw.TextAlign.left,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(sellerEmail, textAlign: pw.TextAlign.center),
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

  pw.Widget separacionContadoWidget(String saldo){
    if(saldoSeparacion == '\$0'){
      return pw.Row(
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 15),
                pw.Text('Separación', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 5),
                pw.Text('Saldo total ($plazoContado)',
                    textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Total',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
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
                  'Valor',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(vlrSeparacion, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(vlrPorPagar, textAlign: pw.TextAlign.center),
                pw.Divider(thickness: 1),
                pw.Text(
                  finalPrice,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
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
                  'Fecha límite de pago',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(dueDateSeparacion, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(saldoTotalDate, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 30),
              ],
            ),
          ),
        ],
      );
    } else {
      return pw.Row(
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 15),
                pw.Text('Separación', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 5),
                pw.Text('Saldo separación', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 5),
                pw.Text('Saldo total ($plazoContado)',
                    textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Total',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
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
                  'Valor',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(vlrSeparacion, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(saldoSeparacion, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(vlrPorPagar, textAlign: pw.TextAlign.center),
                pw.Divider(thickness: 1),
                pw.Text(
                  finalPrice,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
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
                  'Fecha límite de pago',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(dueDateSeparacion, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(dueDateSaldoSeparacion,
                    textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(saldoTotalDate, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 30),
              ],
            ),
          ),
        ],
      );
    }
  }

  pw.Widget separacionFinancWidget(String saldo){
    if(saldoSeparacion == '\$0'){
      return pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Cuota inicial ($porcCuotaIni)',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Separación', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 5),
                pw.Text('Saldo cuota inicial ($plazoCI)',
                    textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 15),
                pw.Text(
                  'Total',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
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
                  'Valor',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(vlrSeparacion, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(saldoCI, textAlign: pw.TextAlign.center),
                pw.Divider(thickness: 1),
                pw.Text(
                  vlrCuotaIni,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
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
                  'Fecha límite de pago',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(dueDateSeparacion, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(dueDateSaldoCI, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 30),
              ],
            ),
          ),
        ],
      );
    } else {
      return pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Cuota inicial ($porcCuotaIni)',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Separación', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 5),
                pw.Text('Saldo separación', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 5),
                pw.Text('Saldo cuota inicial ($plazoCI)',
                    textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 15),
                pw.Text(
                  'Total',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
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
                  'Valor',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(vlrSeparacion, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(saldoSeparacion, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(saldoCI, textAlign: pw.TextAlign.center),
                pw.Divider(thickness: 1),
                pw.Text(
                  vlrCuotaIni,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
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
                  'Fecha límite de pago',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(dueDateSeparacion, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(dueDateSaldoSeparacion,
                    textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 5),
                pw.Text(dueDateSaldoCI, textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 30),
              ],
            ),
          ),
        ],
      );
    }
  }

  pw.Widget metodoPago(String evaluarMetodo, context) {
    if (evaluarMetodo == 'Pago de contado') {
      return pw.Column(children: [
        pw.Text(
          'FORMA DE PAGO',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'PAGO DE CONTADO',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        separacionContadoWidget(saldoSeparacion),
      ]);
    } else {
      return pw.Column(
        children: [
          pw.Text(
            'FORMA DE PAGO',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'FINANCIACIÓN DIRECTA',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          separacionFinancWidget(saldoSeparacion),
          pw.SizedBox(height: 20),
          pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Saldo financiado ($porcPorPagar)',
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                        '$nroCuotas cuota(s) ${periodoCuotas.toLowerCase()}(es)',
                        textAlign: pw.TextAlign.left),
                    pw.SizedBox(height: 5),
                    pw.Text('Intereses $tem', textAlign: pw.TextAlign.left),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      'Total',
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
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
                      'Valor',
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(vlrCuota, textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: 5),
                    pw.Text('\$0', textAlign: pw.TextAlign.center),
                    pw.Divider(thickness: 1),
                    pw.Text(
                      vlrPorPagar,
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
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
                      'A partir de',
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(saldoTotalDate, textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
  }
}
