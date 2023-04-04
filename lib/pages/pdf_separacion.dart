import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ignore: must_be_immutable
class PDFSeparacion extends StatelessWidget {
  final String sellerID;
  final String sellerName;
  final String sellerPhone;
  final String sellerEmail;
  final String quoteId;
  final String name;
  final String idCust;
  final String idTypeCust;
  final String lastname;
  final String phone;
  final String address;
  final String email;
  final String city;
  final String date;
  final String dueDate;
  final String lote;
  final String area;
  final String price;
  final String finalPrice;
  final String porcCuotaIni;
  final String vlrCuotaIni;
  final String totalSeparacion;
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


  
                                      
  PDFSeparacion({super.key, 
    required this.sellerID,
    required this.sellerName,
    required this.sellerPhone,
    required this.sellerEmail,
    required this.quoteId,
    required this.name,
    required this.idCust,
    required this.idTypeCust,
    required this.lastname,
    required this.phone,
    required this.address,
    required this.email,
    required this.city,
    required this.date,
    required this.dueDate,
    required this.lote,
    required this.area,
    required this.price,
    required this.finalPrice,
    required this.porcCuotaIni,
    required this.vlrCuotaIni,
    required this.totalSeparacion,
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

  String? extractNumbers(String str) {
    RegExp regex = RegExp(r'\d+');
    Match match = regex.firstMatch(str) as Match;
    // ignore: unnecessary_null_comparison
    if (match != null) {
      return match.group(0);
    } else {
      return null;
    }
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
        title: Text('Vista previa cotización', style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),),
      ),
      body: PdfPreview(
        build: (format) => generatePdf(context),
        // You can set the initial page format here
        initialPageFormat: PdfPageFormat.letter,
      ),
    );
  }

  Future<Uint8List> generatePdf(BuildContext context) async {

    final ByteData photo1 = await rootBundle.load('assets/images/logo.png');
    final Uint8List byteList1 = photo1.buffer.asUint8List();
    final ByteData photo2 = await rootBundle.load('assets/images/invertaga.png');
    final Uint8List byteList2 = photo2.buffer.asUint8List();
    final ByteData photo3 = await rootBundle.load('assets/images/vision.png');
    final Uint8List byteList3 = photo3.buffer.asUint8List();
    final ByteData photo4 = await rootBundle.load('assets/images/albaterrashape.png');
    final Uint8List byteList4 = photo4.buffer.asUint8List();


    final pdf = pw.Document();
    

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(height: 20),
                pw.Stack(
                  alignment: pw.Alignment.center,
                  children: [
                    pw.Image(pw.MemoryImage(byteList4,), height: 100),
                    pw.Positioned(
                      top: 55,
                      child: pw.Text(lote, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    )
                ]),
                pw.SizedBox(height: 20),
                pw.Text('ORDEN DE SEPARACIÓN DE UN LOTE DE TERRENO EN EL PROYECTO "CONDOMINIO CAMPESTRE ALBATERRA"', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 20),
                pw.RichText(
                  textAlign: pw.TextAlign.justify,
                  text: pw.TextSpan(                    
                    children: <pw.TextSpan>[
                      const pw.TextSpan(text: 'Por medio del presente documento se realiza la separación de un lote de terreno en el proyecto ',),
                      pw.TextSpan(text: '"Condominio Campestre Albaterra"', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: ', formalizada mediante el pago de '),
                      pw.TextSpan(text: totalSeparacion, style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: '; así mismo las partes establecen la fecha para firma de la promesa de compraventa y la forma de pago del lote.'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Número del lote: $lote', textAlign: pw.TextAlign.left),
                pw.Text('Área del lote: $area', textAlign: pw.TextAlign.left),
                pw.RichText(
                  textAlign: pw.TextAlign.justify,
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'Valor total del lote antes de descuentos:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: price),
                    ],
                  ),
                ),
                pw.RichText(
                  textAlign: pw.TextAlign.justify,
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'FORMA DE PAGO: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: paymentMethod),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('VALOR CUOTA INICIAL $porcCuotaIni: $vlrCuotaIni', textAlign: pw.TextAlign.left),
                pw.Text('VALOR SALDO $porcPorPagar: $vlrPorPagar', textAlign: pw.TextAlign.left),
                pw.Text('   1. La suma de $vlrSeparacion pesos el día de hoy $dueDateSeparacion', textAlign: pw.TextAlign.left),
                pw.Text('   2. La suma de $saldoCI que corresponde al saldo de la cuota inicial del lote ($porcCuotaIni del valor total), en menos de $plazoCI, teniendo como fecha límite el $dueDateSaldoCI', textAlign: pw.TextAlign.left),
                pw.Text('   3. La suma de $vlrPorPagar pesos que corresponde al saldo del lote ($porcPorPagar del valor total), en $nroCuotas cuotas de $vlrCuota pesos pagaderas el último día hábil del mes, iniciando el $saldoTotalDate', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 20),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'Valor final del lote luego de definir forma de pago: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: finalPrice),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('El valor de la separación deberá ser consignado o trasferido a nombre ---Se trae de tabla de datos de promotores del proyecto--- con NIT ---Se trae de tabla de datos de promotores del proyecto---, en alguna de las siguientes cuentas:', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 20),
                pw.Text('---Se trae de tabla de datos de promotores del proyecto---', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 20),
                pw.Text('Al momento del pago indicar como numero de referencia la cedula del comprador, quien deberá enviar soporte de pago al correo: ---Se trae de tabla de datos de promotores del proyecto---', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 20),
                pw.Text('En el evento que se realice el pago con cheque, y éste sea devuelto por causas exclusivas del girador, se procederá de conformidad con el artículo 731 del Código de Comercio. En caso de los cheques de otra plaza y que requiera el pago de comisiones bancarias, estas serán asumidas por el comprador.', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 20),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'PROMESA DE COMPRA VENTA: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: 'Una vez realizada la separación del lote, el comprador se compromete a firmar dentro de los siguientes 5 días calendario, la respectiva promesa de compraventa de lote de terreno del proyecto CONDOMINIO CAMPESTRE ALBATERRA, estableciendo como fecha límite para realizar esta diligencia el día $dueDateSaldoSeparacion. '),
                      pw.TextSpan(text: 'NOTA: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: 'En caso que por fuerza mayor, no se haya realizado el pago total del valor de la separación del lote al momento de la firma de este documento (acordado en el numeral 1 de la FORMA DE PAGO), el comprador presentara al vendedor el documento, recibo o consignación, que soporte el pago del saldo pendiente, previo a la hora y fecha establecida para la firma de la promesa de compraventa.'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'DESISTIMIENTO: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: 'En caso de desistimiento antes de la firma de la promesa de compraventa, el suscrito Comprador '),
                      pw.TextSpan(text: 'ACEPTA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: ' que de los dineros cancelados se le descuente el valor correspondiente al 30% sobre el valor total de la orden de separación. El saldo que quedaré a favor del comprador le será reintegrado dentro de los 20 días siguientes a la notificación de desistimiento.'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'NO ASISTENCIA A FIRMA DE PROMESA DE COMPRAVENTA: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: 'En caso de que el comprador no asista, sin previo aviso, a la cita para realizar la firma de la promesa de compra venta, este '),
                      pw.TextSpan(text: 'ACEPTA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: ' que de los dineros cancelados se le descuente el valor correspondiente al 100% sobre el valor total de la orden de separación.'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'CLÁUSULA DE NO CESIÓN DE DERECHOS: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: 'Las partes del presente contrato/orden de separación, en ninguna circunstancia, podrán ceder las relaciones, acciones y/o derechos derivados de la presente orden de separación total o parcialmente a un tercero, sin el consentimiento escrito de la otra parte.'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'DESCRIPCIÓN GENERAL DEL PROYECTO: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: 'CONDOMINIO CAMPESTRE ALBATERRA contempla 67 lotes entre 1.250 m² y 7.890 m², los cuales se entregarán con punto de agua de perforación tratada, punto de luz en baja tensión, punto de gas y acometida para telecomunicaciones. El conjunto contará con: portería con espacio para recolección de basuras, parqueaderos de visitantes, zona de juegos infantiles, vías internas con placa huella empradizada, vía endurecida desde la carretera principal hasta la portería, zona BBQ, gimnasio al aire libre, parque ecológico, zona Pet Friendly, cancha de tenis, cancha sintética de mini futbol y pérgolas de relajación.'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'CONDOMINIO CAMPESTRE ALBATERRA ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: 'es un proyecto desarrollado por la sociedad comercial '),
                      pw.TextSpan(text: 'INVERTAGA S.A.S.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: ' identificada con NIT 900.429.080-7, representada legalmente por '),
                      pw.TextSpan(text: 'LUIS FERNANDO GARCIA QUINTANILLA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: ', identificado con cédula de ciudadanía número 91.106.047 expedida en Socorro; y la sociedad comercial '),
                      pw.TextSpan(text: 'VISION AHORA S.A.S.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: ' identificada con NIT 900.679.249-6, representada legalmente por '),
                      pw.TextSpan(text: 'CESAR AUGUSTO GARCIA QUINTANILLA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: ' identificado con cédula de ciudadanía número 72.144.717 expedida en Barranquilla.'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Todas las notificaciones se harán al correo electrónico, móvil o dirección registrados en el presente documento.', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 20),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'OBSERVACIONES: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      const pw.TextSpan(text: '----'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('DATOS DEL COMPRADOR', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'Nombre: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: '$name $lastname'),
                    ],
                  ),
                ),
                pw.Text('Firma y huella: _________________________________________', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'Documento de identificación: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: '$idTypeCust $idCust'),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'Dirección: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: address),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'Correo electrónico: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: email),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'Teléfono: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: phone),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'Ciudad: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: city),
                    ],
                  ),
                ),
                pw.RichText(
                  text: pw.TextSpan(
                    children: <pw.TextSpan>[
                      pw.TextSpan(text: 'Fecha: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
                      pw.TextSpan(text: date),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('POR EL VENDEDOR', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 40),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1, 
                      child: pw.Column(children: [
                        pw.Text('_________________________________________', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('VICTOR ALFONSO OROSTEGUI', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('GERENTE DEL PROYECTO', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ])
                    ),
                    pw.Expanded(
                      flex: 1, 
                      child: pw.SizedBox()
                    ),
                    pw.Expanded(
                      flex: 1, 
                      child: pw.Column(children: [
                        pw.Text('_________________________________________', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(sellerName, textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('ASESOR COMERCIAL', textAlign: pw.TextAlign.left, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ])
                    )

                  ]
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