import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFGenerator extends StatelessWidget {
  final String seller;
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
      build: (format) => generatePdf(format as String, context),
      // You can set the initial page format here
      initialPageFormat: PdfPageFormat.letter,
    );
  }

  Future<Uint8List> generatePdf(String format, BuildContext context) async {
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
                        pw.Text('SELLER: $seller', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('QUOTE ID: $quoteId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('DATE: $date'),
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
                          pw.Text('Customer Information', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Name: $name $lastname'),
                          pw.Text('Phone: $phone'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Property Information', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Lote: $lote'),
                          pw.Text('Area: $area m²'),
                          pw.Text('Price: \$$price'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  context: context,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  data: [
                    ['Initial Payment', ''],
                    ['Percentage of Initial Payment', '$porcCuotaIni%'],
                    ['Amount of Initial Payment', '\$$vlrCuotaIni'],
                    ['Reservation Fee', '\$$vlrSeparacion'],
                    ['Due Date Reservation Fee', dueDateSeparacion],
                    ['Term of the Initial Payment', '$plazoCI months'],
                    ['Balance of the Initial Payment', '\$$saldoCI'],
                    ['Due Date Balance of the Initial Payment', dueDateSaldoCI],
                    ['Percentage Pending to Pay', '$porcPorPagar%'],
                    ['Amount Pending to Pay', '\$$vlrPorPagar'],
                  ],
                ),
                pw.SizedBox(height: 20),
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
}