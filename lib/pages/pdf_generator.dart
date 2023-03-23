import 'package:albaterrapp/services/firebase_services.dart';
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
  final String porcCuotaIni;
  final String vlrCuotaIni;
  final String vlrSeparacion;
  final String dueDateSeparacion;
  final String saldoSeparacion;
  final String dueDateSaldoSeparacion;
  final String plazoCI;
  final String saldoCI;
  final String dueDateSaldoCI;
  final String porcPorPagar;
  final String vlrPorPagar;
  final String paymentMethod;
  final String tiempoFinanc;
  final String vlrCuota;
  final String saldoTotalDate;
  final String nroCuotas;
  final String tem;
  final String observaciones;
  final String quoteStage;


  
                                      
  PDFGenerator({super.key, 
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
    required this.porcCuotaIni,
    required this.vlrCuotaIni,
    required this.vlrSeparacion,
    required this.dueDateSeparacion,
    required this.saldoSeparacion,
    required this.dueDateSaldoSeparacion,
    required this.plazoCI,
    required this.saldoCI,
    required this.dueDateSaldoCI,
    required this.porcPorPagar,
    required this.vlrPorPagar,
    required this.paymentMethod,
    required this.tiempoFinanc,
    required this.vlrCuota,
    required this.saldoTotalDate,
    required this.nroCuotas,
    required this.tem,
    required this.observaciones,
    required this.quoteStage  
  });

  void initState() {      
    initCont();   
  }

  Map<String, dynamic> infoCont = {};
  String emailAlbaterra = '';
  String phoneAlbaterra = '';
  String webAlbaterra = '';

  Future<Map<String, dynamic>> getInfoContacto() async {
    DocumentSnapshot<Map<String, dynamic>> infoContacto = await db.collection('infoproyecto').doc('infoGeneral').get();
    final Map<String, dynamic> data = infoContacto.data() as Map<String, dynamic>;
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
    return PdfPreview(
      build: (format) => generatePdf(context),
      // You can set the initial page format here
      initialPageFormat: PdfPageFormat.letter,
    );
  }

  Future<Uint8List> generatePdf(BuildContext context) async {

    final ByteData photo1 = await rootBundle.load('assets/images/logo.png');
    final Uint8List byteList1 = photo1.buffer.asUint8List();
    final ByteData photo2 = await rootBundle.load('assets/images/invertaga.png');
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
                        pw.Image(pw.MemoryImage(byteList1,), height: 60),
                        pw.Text('COTIZACIÓN: $quoteId', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text(quoteStage, style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Image(pw.MemoryImage(byteList2,), height: 20),
                        pw.Image(pw.MemoryImage(byteList3,), height: 30),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [                            
                            pw.Text(phoneAlbaterra, style: const pw.TextStyle(fontSize: 10)),
                            pw.Text(' | '),
                            pw.Text(emailAlbaterra, style: const pw.TextStyle(fontSize: 10)),
                            pw.Text(' | '),
                            pw.Text(webAlbaterra, style: const pw.TextStyle(fontSize: 10)),
                          ]
                          
                          )
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(headerCount: 0,
                  context: context,
                  data: [
                    ['Nombre', '$name $lastname', 'Teléfono', phone, 'Fecha de cotización', date],
                    ['Inmueble Nº', lote, 'Área', area, 'Valido hasta', dueDate],
                    ['Valor inicial', price],
                    ['Valor final', finalPrice],               
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(cellAlignment: pw.Alignment.center,
                  context: context,
                  data: [
                    ['PAGADERA ASÍ'],        
                  ],
                ),
                pw.SizedBox(height: 20),
                metodoPago(paymentMethod, context),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  context: context,
                  data: [
                    ['OBSERVACIONES'],                    
                    [observaciones],                   
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  context: context,
                  data: [
                    ['Asesor comercial', 'Teléfono', 'Correo electrónico'],                    
                    [sellerName, sellerPhone, sellerEmail],                   
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

  pw.Widget metodoPago(String evaluarMetodo, context){
    if(evaluarMetodo == 'Pago de contado'){
      return pw.Table.fromTextArray(headerCount: 0,
        context: context,
        data: [
          ['Pago de contado', 'Valor', 'Plazo'],
          ['Separación', vlrSeparacion, dueDateSeparacion],
          ['Saldo separación', saldoSeparacion, dueDateSaldoSeparacion],
          ['Saldo', vlrPorPagar, saldoTotalDate],                        
        ],
      );                
    } else{
      return pw.Column(
        children: [
          pw.Table.fromTextArray(headerCount: 0,
            context: context,
            data: [
              ['Cuota inicial ($porcCuotaIni)', vlrCuotaIni, 'Plazo'],
              ['Separación', vlrSeparacion, dueDateSeparacion],
              ['Saldo separación', saldoSeparacion, dueDateSaldoSeparacion],
              ['Saldo cuota inicial ($plazoCI)', saldoCI, dueDateSaldoCI], 
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(headerCount: 0,
            context: context,
            data: [
              ['Financiación directa', '', 'A partir de', saldoTotalDate],
              ['Valor a pagar ($porcPorPagar)', vlrPorPagar, 'Valor cuota', vlrCuota],
              ['Nº cuotas', nroCuotas, 'Intereses', tem],              
            ],
          )
        ],
      );
    }
  }
}