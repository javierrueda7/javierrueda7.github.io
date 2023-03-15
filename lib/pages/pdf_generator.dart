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
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('VENDEDOR: $seller', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('COTIZACIÓN: $quoteId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('FECHA: $date'),
                      ],
                    ),
                    pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Información del cliente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Nombre: $name $lastname'),
                          pw.Text('Teléfono: $phone'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Información del inmueble', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Lote: $lote'),
                          pw.Text('Área: $area m²'),
                          pw.Text('Precio: $price'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  context: context,
                  data: [
                    ['Nombre', '$name $lastname', 'Teléfono', phone, 'Fecha de cotización', date],
                    ['Inmueble Nº', lote, 'Área', area, '', ''],
                    ['Precio', price, '', '', 'Valido hasta', dueDate],
                    ['Cuota inicial $porcCuotaIni', 'Valor en pesos', vlrCuotaIni, '', '', ''],                    
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  context: context,
                  data: [
                    ['PAGADERA ASÍ'],
                    ['Cuota inicial', '', '', 'Tiempos'],
                    ['Separación', '', vlrSeparacion, dueDateSeparacion],
                    [plazoCI, 'Saldo restante de la cuota inicial', saldoCI, dueDateSaldoCI],                   
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
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Payment Information', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Payment Method: $paymentMethod'),
                          pw.Text('Financing Time: $tiempoFinanc months'),
                          pw.Text('Monthly Payment: \$$vlrCuota'),
                          pw.Text('Number of Payments: $nroCuotas'),
                          pw.Text('Statement Start Date: $statementsStartDate'),
                          pw.Text('Cash Payment Due: $pagoContadoDue'),
                          pw.Text('TEM: $tem'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Información adicional', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Observaciones: $observaciones'),
                        ]
                      )
                    )
                  ]
                )              
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
      return pw.Table.fromTextArray(
        context: context,
        data: [
          ['PAGO DE CONTADO', 'Plazo hasta', pagoContadoDue],
          ['Valor a pagar', porcPorPagar, vlrPorPagar],                        
        ],
      );                
    } else{
      return pw.Table.fromTextArray(
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