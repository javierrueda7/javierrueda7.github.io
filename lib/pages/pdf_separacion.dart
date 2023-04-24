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
  final String letrasFinalPrice;
  final String porcCuotaIni;
  final String vlrCuotaIni;
  final String totalSeparacion;
  final String letrasSeparacion;
  final String vlrSeparacion;
  final String dueDateSeparacion;
  final String saldoSeparacion;
  final String dueDateSaldoSeparacion;
  final String plazoCI;
  final String plazoContado;
  final String letrasSaldoCI;
  final String saldoCI;
  final String dueDateSaldoCI;
  final String porcPorPagar;
  final String vlrPorPagar;
  final String letrasSaldoTotal;
  final String paymentMethod;
  final String tiempoFinanc;
  final String vlrCuota;
  final String letrasVlrCuota;
  final String letrasSaldoContado;
  final String saldoTotalDate;
  final String periodoCuotas;
  final String nroCuotas;
  final String tem;
  final String observaciones;
  final String quoteStage;

  PDFSeparacion(
      {super.key,
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
      required this.letrasFinalPrice,
      required this.vlrCuotaIni,
      required this.totalSeparacion,
      required this.letrasSeparacion,
      required this.vlrSeparacion,
      required this.dueDateSeparacion,
      required this.saldoSeparacion,
      required this.dueDateSaldoSeparacion,
      required this.plazoCI,
      required this.plazoContado,
      required this.letrasSaldoCI,
      required this.saldoCI,
      required this.dueDateSaldoCI,
      required this.porcPorPagar,
      required this.vlrPorPagar,
      required this.letrasSaldoTotal,
      required this.paymentMethod,
      required this.tiempoFinanc,
      required this.vlrCuota,
      required this.letrasVlrCuota,
      required this.letrasSaldoContado,
      required this.saldoTotalDate,
      required this.periodoCuotas,
      required this.nroCuotas,
      required this.tem,
      required this.observaciones,
      required this.quoteStage});

  void initState() {
    initCont();
    initVision();
    initInvertaga();
    initBanco();
  }

  Map<String, dynamic> infoCont = {};
  Map<String, dynamic> infoInvertaga = {};
  Map<String, dynamic> infoVision = {};
  List<String> bancos = [];
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

  Future<List<String>> getCuentasBanco() async {
    List<String> bancosText = [];
    QuerySnapshot? queryBancos = await db.collection('infobanco').get();
    for (var doc in queryBancos.docs) {
      if (doc.id.contains('VISION')) {
        // filter by doc.id containing "Vision"
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final bank = {
          "bid": doc.id,
          "banco": data['banco'],
          "nroCuenta": data['nroCuenta'],
          "tipoCuenta": data['tipoCuenta'],
          "nit": data['nit'],
          "nameRep": data['nameRep']
        };
        String bankText =
            "Cuenta ${(bank['tipoCuenta']).toLowerCase()} del banco ${bank['banco']} No. ${bank['nroCuenta']}";
        bancosText.add(bankText);
      }
    }
    return bancosText;
  }

  Future<void> initBanco() async {
    bancos = await getCuentasBanco();
  }

  Future<void> initVision() async {
    infoVision = await getInversionista('vision');
  }

  Future<void> initInvertaga() async {
    infoInvertaga = await getInversionista('invertaga');
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
    initVision();
    initInvertaga();
    initBanco();
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
        build: (format) => generatePdf(context),
        // You can set the initial page format here
        initialPageFormat: PdfPageFormat.letter,
      ),
    );
  }

  Future<Uint8List> generatePdf(BuildContext context) async {
    final ByteData photo =
        await rootBundle.load('assets/images/albaterrashape.png');
    final Uint8List byteList = photo.buffer.asUint8List();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.SizedBox(height: 20),
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Stack(alignment: pw.Alignment.center, children: [
                pw.Image(
                    pw.MemoryImage(
                      byteList,
                    ),
                    height: 100),
                pw.Positioned(
                  top: 55,
                  child: pw.Text(lote,
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                )
              ]),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                'ORDEN DE SEPARACIÓN DE UN LOTE DE TERRENO EN EL PROYECTO "CONDOMINIO CAMPESTRE ALBATERRA"',
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center),
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  const pw.TextSpan(
                    text:
                        'Por medio del presente documento se realiza la separación de un lote de terreno en el proyecto ',
                  ),
                  pw.TextSpan(
                    text: '"Condominio Campestre Albaterra"',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: ', formalizada mediante el pago de '),
                  pw.TextSpan(
                    text: totalSeparacion,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(
                      text:
                          '; así mismo las partes establecen la fecha para firma de la promesa de compraventa y la forma de pago del lote.'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Número del lote: $lote', textAlign: pw.TextAlign.justify),
            pw.Text('Área del lote: $area', textAlign: pw.TextAlign.justify),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'Valor total del lote antes de descuentos:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: price),
                ],
              ),
            ),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'FORMA DE PAGO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: paymentMethod),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            metodoPago(paymentMethod, context),
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text:
                        'Valor final del lote luego de definir forma de pago: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: "$letrasFinalPrice ($finalPrice)"),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                'El valor de la separación deberá ser consignado o trasferido a nombre ${infoVision['name']} con NIT ${infoVision['nit']}, en alguna de las siguientes cuentas:',
                textAlign: pw.TextAlign.justify),
            pw.SizedBox(height: 20),
            cuentasDisponibles(context),
            pw.SizedBox(height: 20),
            pw.Text(
                'Al momento del pago indicar como numero de referencia la cedula del comprador, quien deberá enviar soporte de pago al correo: $emailAlbaterra',
                textAlign: pw.TextAlign.justify),
            pw.SizedBox(height: 20),
            pw.Text(
                'En el evento que se realice el pago con cheque, y éste sea devuelto por causas exclusivas del girador, se procederá de conformidad con el artículo 731 del Código de Comercio. En caso de los cheques de otra plaza y que requiera el pago de comisiones bancarias, estas serán asumidas por el comprador.',
                textAlign: pw.TextAlign.justify),
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PROMESA DE COMPRA VENTA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(
                      text:
                          'Una vez realizada la separación del lote, el comprador se compromete a firmar dentro de los siguientes 5 días calendario, la respectiva promesa de compraventa de lote de terreno del proyecto CONDOMINIO CAMPESTRE ALBATERRA, estableciendo como fecha límite para realizar esta diligencia el día $dueDateSaldoSeparacion. '),
                  pw.TextSpan(
                    text: 'NOTA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(
                      text:
                          'En caso que por fuerza mayor, no se haya realizado el pago total del valor de la separación del lote al momento de la firma de este documento (acordado en el numeral 1 de la FORMA DE PAGO), el comprador presentara al vendedor el documento, recibo o consignación, que soporte el pago del saldo pendiente, previo a la hora y fecha establecida para la firma de la promesa de compraventa.'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'DESISTIMIENTO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(
                      text:
                          'En caso de desistimiento antes de la firma de la promesa de compraventa, el suscrito Comprador '),
                  pw.TextSpan(
                    text: 'ACEPTA',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(
                      text:
                          ' que de los dineros cancelados se le descuente el valor correspondiente al 30% sobre el valor total de la orden de separación. El saldo que quedaré a favor del comprador le será reintegrado dentro de los 20 días siguientes a la notificación de desistimiento.'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'NO ASISTENCIA A FIRMA DE PROMESA DE COMPRAVENTA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(
                      text:
                          'En caso de que el comprador no asista, sin previo aviso, a la cita para realizar la firma de la promesa de compra venta, este '),
                  pw.TextSpan(
                    text: 'ACEPTA',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(
                      text:
                          ' que de los dineros cancelados se le descuente el valor correspondiente al 100% sobre el valor total de la orden de separación.'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'CLÁUSULA DE NO CESIÓN DE DERECHOS: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(
                      text:
                          'Las partes del presente contrato/orden de separación, en ninguna circunstancia, podrán ceder las relaciones, acciones y/o derechos derivados de la presente orden de separación total o parcialmente a un tercero, sin el consentimiento escrito de la otra parte.'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'DESCRIPCIÓN GENERAL DEL PROYECTO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(
                      text:
                          'CONDOMINIO CAMPESTRE ALBATERRA contempla 67 lotes entre 1.250 m² y 7.890 m², los cuales se entregarán con punto de agua de perforación tratada, punto de luz en baja tensión, punto de gas y acometida para telecomunicaciones. El conjunto contará con: portería con espacio para recolección de basuras, parqueaderos de visitantes, zona de juegos infantiles, vías internas con placa huella empradizada, vía endurecida desde la carretera principal hasta la portería, zona BBQ, gimnasio al aire libre, parque ecológico, zona Pet Friendly, cancha de tenis, cancha sintética de mini futbol y pérgolas de relajación.'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'CONDOMINIO CAMPESTRE ALBATERRA ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(
                      text:
                          'es un proyecto desarrollado por la sociedad comercial '),
                  pw.TextSpan(
                    text: infoInvertaga['name'],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(
                      text:
                          ' identificada con NIT ${infoInvertaga['nit']}, representada legalmente por '),
                  pw.TextSpan(
                    text: infoInvertaga['nameRep'],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(
                      text:
                          ', identificado con cédula de ciudadanía número ${infoInvertaga['idRep']} expedida en ${infoInvertaga['idLugar']}; y la sociedad comercial '),
                  pw.TextSpan(
                    text: infoVision['name'],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(
                      text:
                          ' identificada con NIT ${infoVision['nit']}, representada legalmente por '),
                  pw.TextSpan(
                    text: infoVision['nameRep'],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(
                      text:
                          ' identificado con cédula de ciudadanía número ${infoVision['idRep']} expedida en ${infoVision['idLugar']}.'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
                'Todas las notificaciones se harán al correo electrónico, móvil o dirección registrados en el presente documento.',
                textAlign: pw.TextAlign.justify),
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'OBSERVACIONES: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: observaciones),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('DATOS DEL COMPRADOR',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'Nombre: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: '$name $lastname'),
                ],
              ),
            ),
            pw.SizedBox(height: 60),
            pw.Text('Firma y huella: _______________________',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.RichText(
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'Documento de identificación: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: '$idTypeCust $idCust'),
                ],
              ),
            ),
            pw.RichText(
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'Dirección: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: address),
                ],
              ),
            ),
            pw.RichText(
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'Correo electrónico: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: email),
                ],
              ),
            ),
            pw.RichText(
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'Teléfono: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: phone),
                ],
              ),
            ),
            pw.RichText(
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'Ciudad: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: city),
                ],
              ),
            ),
            pw.RichText(
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'Fecha: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: date),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('POR EL VENDEDOR',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 60),
            pw.Row(children: [
              pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text('VICTOR ALFONSO OROSTEGUI',
                            textAlign: pw.TextAlign.left,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text('GERENTE DEL PROYECTO',
                            textAlign: pw.TextAlign.left,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ])),
              pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(sellerName,
                            textAlign: pw.TextAlign.center,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text('ASESOR COMERCIAL',
                            textAlign: pw.TextAlign.right,
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ]))
            ]),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    return bytes;
  }

  pw.Widget cuentasDisponibles(context) {
    int n = bancos.length;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < n; i++)
          pw.Text(bancos[i], textAlign: pw.TextAlign.justify)
      ],
    );
  }

  pw.Widget metodoPago(String evaluarMetodo, context) {
    if (evaluarMetodo == 'Pago de contado') {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text('VALOR SALDO: $vlrPorPagar',
                textAlign: pw.TextAlign.justify),
            pw.Text(
                '   1. La suma de $letrasSeparacion ($totalSeparacion) el día $dueDateSeparacion',
                textAlign: pw.TextAlign.justify),
            pw.Text(
                '   2. La suma de $letrasSaldoContado ($vlrPorPagar) que corresponde al saldo del lote, en menos de $plazoContado, teniendo como fecha límite el $saldoTotalDate',
                textAlign: pw.TextAlign.justify),
          ]);
    } else {
      return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text('VALOR CUOTA INICIAL $porcCuotaIni: $vlrCuotaIni',
                textAlign: pw.TextAlign.justify),
            pw.Text('VALOR SALDO $porcPorPagar: $vlrPorPagar',
                textAlign: pw.TextAlign.justify),
            pw.Text(
                '   1. La suma de $letrasSeparacion ($totalSeparacion) el día $dueDateSeparacion',
                textAlign: pw.TextAlign.justify),
            pw.Text(
                '   2. La suma de $letrasSaldoCI ($saldoCI) que corresponde al saldo de la cuota inicial del lote ($porcCuotaIni del valor total), en menos de $plazoCI, teniendo como fecha límite el $dueDateSaldoCI',
                textAlign: pw.TextAlign.justify),
            pw.Text(
                '   3. La suma de $letrasSaldoTotal ($vlrPorPagar) que corresponde al saldo del lote ($porcPorPagar del valor total), en $nroCuotas cuotas con periodicidad ${periodoCuotas.toUpperCase()} por valor de $letrasVlrCuota ($vlrCuota) pagaderas el último día hábil del mes, iniciando el $saldoTotalDate',
                textAlign: pw.TextAlign.justify),
          ]);
    }
  }
}
