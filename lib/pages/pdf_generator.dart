
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFGenerator extends StatelessWidget {
  final String seller;
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
  final String statementsStartDate;
  final String nroCuotas;
  final String pagoContadoDue;
  final String tem;
  final String observaciones;


  
                                      
  const PDFGenerator({super.key, 
    required this.seller,
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
    required this.statementsStartDate,
    required this.nroCuotas,
    required this.pagoContadoDue,
    required this.tem,
    required this.observaciones    
  });

  @override
  Widget build(BuildContext context) {
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
                        pw.Text('COTIZACIÓN: $quoteId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),                        
                      ],
                    ),
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('FECHA: ${dateOnly(false, 0, DateTime.now(), false)}'),
                        pw.Image(pw.MemoryImage(byteList2,), height: 20),
                        pw.Image(pw.MemoryImage(byteList3,), height: 30),
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
                    ['Precio', price, 'Cuota inicial', '${(double.parse(porcCuotaIni).toInt()).toString()}%', 'Valor en pesos', vlrCuotaIni],
                                        
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(cellAlignment: pw.Alignment.center,
                  context: context,
                  data: [
                    ['PAGADERA ASÍ'],        
                  ],
                ),  
                pw.Table.fromTextArray(headerCount: 0,
                  context: context,
                  data: [
                    ['Cuota inicial ($plazoCI)', 'Valor', 'Tiempos'],
                    ['Separación', vlrSeparacion, dueDateSeparacion],
                    ['Saldo restante de la cuota inicial', saldoCI, dueDateSaldoCI],                   
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
          ['Método de pago', 'Valor a pagar ($porcPorPagar)', 'Plazo de pago hasta'],
          ['Pago de contado', vlrPorPagar, pagoContadoDue],                        
        ],
      );                
    } else{
      return pw.Table.fromTextArray(headerCount: 0,
        context: context,
        data: [
          ['FINANCIACIÓN DIRECTA', '', '', 'Financiado a', tiempoFinanc, 'A partir de', statementsStartDate],
          ['Valor a pagar', porcPorPagar, vlrPorPagar, '', '', 'Valor cuota', vlrCuota],
          ['Nº cuotas', nroCuotas, 'TEM', tem],              
        ],
      );
    }
  }
}