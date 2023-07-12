import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ignore: must_be_immutable
class PDFPromesa extends StatelessWidget {
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
  final String loteId;
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
  final List<Map<String, dynamic>> installments;

  PDFPromesa(
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
      required this.loteId,
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
      required this.quoteStage,
      required this.installments});

  void initState() {
    initCont();
    initVision();
    initInvertaga();
    initBanco();
  }

  Map<String, dynamic> infoCont = {};
  Map<String, dynamic> infoInvertaga = {};
  Map<String, dynamic> infoVision = {};
  Map<String, dynamic> infoCustomer = {};
  Map<String, dynamic> infoLote = {};
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

  Future<void> initCustomer(String idValue) async {
    infoCustomer = await getCustomerInfo(idValue);
  }

  Future<void> initLoteInfo(String idValue) async {
    infoLote = await getLoteInfo(idValue);
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
    initCustomer(idCust);    
    initLoteInfo(loteId);
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Vista previa promesa de compra-venta',
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

    final pdf = pw.Document();
    // ignore: use_build_context_synchronously
    final metodoPagoWidget = await metodoPago(paymentMethod, context);

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'CONTRATO DE PROMESA DE COMPRAVENTA POR EL ${lote.toUpperCase()} DEL CONDOMINIO CAMPESTRE ALBATERRA, CELEBRADO ${name.toUpperCase()} ${lastname.toUpperCase()} Y ${infoVision['name']} NIT: ${infoVision['nit']} E ${infoInvertaga['name']} NIT: ${infoInvertaga['nit']}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  const pw.TextSpan(
                    text:
                        'Entre los suscritos, ',
                  ),
                  pw.TextSpan(
                    text: '${name.toUpperCase()} ${lastname.toUpperCase()}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: ', mayor de edad, domiciliado en la ciudad de ${infoCustomer['cityCliente']}, identificado con $idTypeCust $idCust expedido en ${infoCustomer['idIssueCityCliente']}, quien en adelante se denominará EL COMPRADOR , de una parte y, por la otra  '),
                  pw.TextSpan(
                    text: '${infoInvertaga['name']}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: 'sociedad comercial identificada con Nit ${infoInvertaga['nit']}, con domicilio principal en la ciudad de Bucaramanga, representada legalmente por '),
                  pw.TextSpan(
                    text: '${infoInvertaga['nameRep']}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(
                      text:
                          ', identificado con cédula de ciudadanía número ${infoInvertaga['idRep']} y '),
                  pw.TextSpan(
                    text: '${infoVision['name']}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: 'sociedad comercial identificada con Nit ${infoVision['nit']}, con domicilio principal en la ciudad de Bucaramanga, representada legalmente por '),
                  pw.TextSpan(
                    text: '${infoVision['nameRep']}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(
                      text:
                          ', identificado con cédula de ciudadanía número ${infoVision['idRep']}, todo lo cual consta en los certificados de existencia y representación legal expedido por la Cámara de Comercio de Bucaramanga quien en adelante se denominara EL VENDEDOR , hemos convenido celebrar el presente contrato de promesa de compra venta , que se regirá por las siguientes cláusulas: '),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PRIMERA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'OBJETO. - EL VENDEDOR promete vender a EL(LOS) (S) COMPRADOR(ES) y éste(os) se obliga(n) a comprar a aquella el pleno derecho de dominio que tiene y ejerce sobre el siguiente inmueble (junto con sus bienes muebles), el cual se encuentra ubicado en el municipio Piedecuesta, específicamente en la vereda Mesa de Jéridas, predio el EDEN, parcelación Condominio Campestre Albaterra'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: '$lote: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: 'cuenta con un área de ${infoLote['loteArea']} metros cuadrados, y se encuentra alinderado así: ${infoLote['loteLinderos']}'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'EL COMPRADOR manifiesta conocer las reglamentaciones de urbanismo y del medio ambiente, y todas las demás que le sean aplicables y que hayan sido expedidas por las autoridades correspondientes para el inmueble objeto de esta promesa. Así mismo, declara conocer el estado material actual del inmueble, sus áreas y linderos específicos y servidumbres no inscritas, y en tal virtud manifiesta que conoce y acepta la reglamentación vigente en materia de servicios públicos y su disponibilidad, a la cual está sometido el inmueble objeto de la presente promesa de compraventa, así como los usos previstos en los correspondientes reglamentos y normas de urbanismo, en un todo de acuerdo con las previsiones legales y reglamentarias que sean aplicables y renuncia a cualquier proceso de reclamación o indemnización, judicial o extrajudicial ante EL VENDEDOR por estos motivos. '),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'SEGUNDA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'TRADICIÓN. - El inmueble objeto de esta promesa es propiedad exclusiva de EL VENDEDOR, quien lo adquirió mediante dación en pago efectuada en mayor extensión de PROSAC S.A. según escritura pública número 997 de fecha 24 de julio de 2020 de la Notaria Novena del Círculo de Bucaramanga, posteriormente mediante división material en la licencia de parcelación '),
                  pw.TextSpan(
                    text: 'N°68547-1-22-0119',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: ' expedida por la curaduría número uno de Piedecuesta mediante la resolución '),
                  pw.TextSpan(
                    text: '0412',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: ' del 10 de noviembre de 2022, dejando en claro que la protocolización de la propiedad horizontal se encuentra en trámite.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'TERCERA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'POSESIÓN Y LIBERTAD. - EL VENDEDOR declara que posee real y materialmente el inmueble objeto de esta venta, que no ha sido enajenado por acto anterior al presente ni prometido en venta. También garantiza EL VENDEDOR que posee el inmueble en forma regular, pacífica y pública y que el mismo se halla libre de impuestos, hipotecas, gravámenes, demandas, habitación, servidumbres, desmembraciones, usufructo, condiciones resolutorias del dominio, uso, pleitos pendientes, embargos judiciales, censo, anticresis, arrendamiento por escritura pública, movilización, patrimonio de familia, afectación a vivienda familiar y en general libre de cualquier limitación de dominio. '),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO PRIMERO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'El COMPRADOR asume desde la suscripción de la presente promesa, las consecuencias de posibles cambios en la reglamentación relacionada con el uso y destinación del suelo, y todas aquellas referentes al ordenamiento territorial que afecten los Inmuebles prometidos, incluyendo los procedimientos administrativos en curso, o que pueden ser originados en el futuro, tendientes a declarar los Inmuebles como de uso público, a partir de la fecha de suscripción de la presente promesa de compraventa.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO SEGUNDO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'Con la firma de esta promesa de compraventa se formaliza la entrega de la '),
                  pw.TextSpan(
                    text: 'mera tenencia',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: ' del lote de terreno, sin que se permita hacer ningún tipo de mejora o uso del predio, hasta tanto no se haya terminado de cancelar el valor total del lote estipulado en el presente contrato.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'CUARTA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'GASTOS DE ADMINISTRACION: A partir del momento en que el PROMOTOR DEL PROYECTO formalice la entrega de la Parcelación a la Asamblea General de Propietarios, EL COMPRADOR deberán asumir los gastos de administración correspondientes al lote de terreno que adquiere mediante el presente contrato, independiente de si para ese momento se haya firmado la escritura pública de compraventa.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'ADMINISTRACIÓN PROVISIONAL: Mientras el órgano competente no elija al administrador para el condominio, ejercerá como tal el promotor del proyecto, quien podrá contratar con un tercero tal gestión. No obstante, lo indicado en esta cláusula, una vez se haya enajenado un número de bienes privados que representen por lo menos el cincuenta y uno por ciento (51%) de los coeficientes de copropiedad cesará la gestión del promotor del proyecto como administrador provisional.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'QUINTA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'URBANISMO: EL VENDEDOR se compromete a entregar el lote de terreno prometido en venta con las siguientes obras de urbanismo: Punto de agua de perforación tratada, punto de luz en baja tensión, punto de gas y acometida para telecomunicaciones. El conjunto contará con: portería con espacio para recolección de basuras, parqueaderos de visitantes, zona de juegos infantiles, vías internas con placa huella empradizada, vía endurecida desde la carretera principal hasta la portería, zona BBQ, gimnasio al aire libre, parque ecológico, zona Pet Friendly, cancha de tenis, cancha sintética de mini futbol y pérgolas de relajación.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'SEXTA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'ENTREGA DEL URBANISMO Y ZONAS COMUNES: La fecha límite para la entrega del urbanismo y las zonas comunes se establece para el 08 de octubre de 2024, fecha prorrogable por un máximo de 12 meses.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'SÉPTIMA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: 'PRECIO Y FORMA DE PAGO. - El precio del inmueble objeto de esta promesa de compraventa se conviene en la suma de $letrasFinalPrice ($finalPrice) M/CTE, que EL COMPRADOR pagará al VENDEDOR así: '),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            metodoPagoWidget,
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO PRIMERO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'EL COMPRADOR estará obligado a cancelar intereses moratorios a la tasa máxima permitida por la ley, por el cumplimiento tardío de cualquiera de las obligaciones generadas por esta promesa, liquidados por EL  VENDEDOR sobre los saldos de capital incumplidos y por cualquier concepto que deba a EL VENDEDOR desde la fecha en que debió cumplirse la obligación, hasta la de su cumplimiento, dándose aplicación a lo dispuesto en los artículos 1653 del código civil y 884 del código de comercio, para lo cual EL COMPRADOR, manifiesta que renuncia expresamente a ser requerido para ser constituido en mora .  En caso de incurrir en mora en el pago de alguna de las cuotas por un período superior a 30 días calendario, contados a partir del día hábil siguiente de la fecha de pago pactada, EL VENDEDOR dará por incumplida la obligación principal del contrato y ejercerá el derecho de retracto que posee sobre los dineros  consignadas de conformidad a lo dispuesto en la cláusula octava  de este documento y procederá al reembolso de la suma diferencial sin intereses y previo descuento del 4x1000, si existiere, en la cuenta bancaria de una entidad financiera colombiana que deberá indicar el oferente con la suscripción de la oferta.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO SEGUNDO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'EL COMPRADOR manifiesta la posibilidad de realizar el pago total del lote en el plazo de los 60 días calendario contados a partir de la firma del documento de separación, en tal caso EL VENDEDOR se compromete a realizar el recalculo del valor final del lote teniendo en cuentas las características de la nueva forma de pago.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'OCTAVA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'CLÁUSULA DE SANCIÓN POR INCUMPLIMIENTO: La parte que incumpliere las obligaciones expresas de este documento deberá cancelar a la parte cumplida la suma correspondiente al quince por ciento (15%) del valor total de la compra, por lo que este contrato y la sola declaración de incumplimiento por la parte cumplida prestará merito ejecutivo. En caso de que EL COMPRADOR desistan de continuar con el negocio, se retracten o llegaren a incurrir en cualquier tipo de incumplimiento del presente documento, faculta a EL VENDEDOR para que retenga a su favor dicha suma, sin que para ello medie ningún tipo de declaración judicial y se entenderá resuelta de pleno derecho, habilitándolo para adelantar cualquier otro proceso de comercialización sobre los activos objeto de venta en el presente documento.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'En caso de incurrir en mora en el pago de alguna de las cuotas por un período superior a 30 días calendario, contados a partir del día hábil siguiente de la fecha de pago pactada, EL VENDEDOR dará por incumplida la obligación principal del contrato y ejercerá el derecho de retracto que poseen sobre los dineros consignados de conformidad a lo dispuesto en la cláusula de sanción por incumplimiento de este documento y procederá al reembolso de la suma diferencial sin intereses y previo descuento del 4x1000, si existiere, en la cuenta bancaria de una entidad financiera colombiana que deberá indicar LOS COMPRADORES.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'NOVENA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'GASTOS ADMINISTRATIVOS, IMPUESTOS Y CONTRIBUCIONES.- Se conviene expresamente que los impuestos incluido el de valorización y las contribuciones que se lleguen a causar, liquidar o reajustar con posterioridad a la fecha de escrituración del inmueble, estarán a cargo exclusivo de EL COMPRADOR , cualquier otro gasto administrativo que se derive de la administración del inmueble como servicios públicos, administraciones, vigilancia, entre otros, será asumido por EL COMPRADOR a partir de la fecha en que se suscribe el acta de entrega material de los inmuebles.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'EL (LOS) (S) COMPRADOR(ES) se obliga a cancelar a EL VENDEDOR la cuota parte o prorrata que, por concepto del pago del impuesto predial, valorización, otras contribuciones y/o cuotas de administración, le(es) corresponda(n) por la fracción de año o mes, contado a partir de la fecha de la escritura con la cual se dé cumplimiento a la presente promesa de compraventa. EL (LOS) (S) COMPRADOR(ES) deberá pagar el valor de la prorrata antes de la entrega del inmueble. Sin el cumplimiento de este requisito no se suscribirá por parte de EL VENDEDOR la escritura de venta del inmueble.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'DÉCIMA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'GASTOS NOTARIALES: Los gastos notariales serán pagados en la siguiente forma: EL PROMITENTE VENDEDOR pagará el 50% de los gastos notariales por la compraventa y el 100% de la retención en la fuente y el 50 % de los gastos de boleta fiscal y LOS PROMITENTES COMPRADORES pagarán el otro 50% de gastos notariales por la compraventa y el 100% de los gastos de Registro de la Escritura correspondiente en la oficina de registros públicos correspondiente y el otro 50 % de los gastos de boleta fiscal.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'EL PROMITENTE COMPRADOR cancelará directamente a EL PROMITENTE VENDEDOR con anterioridad a la fecha estipulada para la escrituración, en la fecha que éste le indique, el monto correspondiente a los gastos de registros respectivos, a fin de que EL PROMITENTE VENDEDOR cancele estos valores en las entidades pertinentes.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'DÉCIMA PRIMERA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'ENTREGA DEL INMUEBLE La entrega del inmueble se hará por parte de EL VENDEDOR a EL COMPRADOR, el día pactado previo a la cancelación de la última cuota estipulada en la escritura de compraventa del lote.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'EL COMPRADOR, manifiesta que conoce y acepta el inmueble objeto de esta compraventa en el estado y las condiciones en que actualmente se encuentra.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'DÉCIMA SEGUNDA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'ORIGEN DE FONDOS Y DESTINO DE LOS ACTIVOS. - EL COMPRADOR declara que el origen de los recursos con los que promete adquirir el citado inmueble proviene de ocupación, oficio, profesión, actividad o negocio lícito. Los recursos que entreguen no provienen de ninguna actividad ilícita de las contempladas en el Código Penal Colombiano, o en cualquier norma que lo modifique o adicione, también declara (n) que los activos que se pretenden adquirir no tendrán una destinación ilícita. EL VENDEDOR quedará eximido de toda responsabilidad que se derive por información errónea, falsa o inexacta, que EL COMPRADOR le proporcionen para la celebración de este negocio.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'DÉCIMA TERCERA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'ESCRITURA DE COMPRAVENTA. - La escritura pública con la cual se dé cumplimiento a la presente promesa de compraventa se correrá en la Notaría decima del municipio de Bucaramanga, el día -- de -- de --, siempre que para tal fecha EL PROMITENTE VENDEDOR y EL(LOS) PROMITENTE(S) COMPRADOR(ES) estuviere(n) al día en las obligaciones adquiridas por esta promesa. La fecha de la firma de la escritura pública de compraventa, así como la hora para dicho trámite se podrá prorrogar, únicamente de mutuo acuerdo entre las partes, así mismo se podrá cambiar de mutuo acuerdo la notaría estipulada para el mismo. '),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'PARÁGRAFO: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'en caso tal de que la protocolización de la propiedad horizontal que se encuentra en trámite no se haya dado para la fecha pactada anteriormente, se estipulara una nueva fecha no mayor a 15 días hábiles después de terminado dicho trámite.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'DÉCIMA CUARTA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'AUTORIZACIÓN CESIÓN: Ninguna de las partes podrá ceder el presente CONTRATO en todo o en parte, salvo que para el efecto obtenga autorización previa, expresa y escrita de la otra parte.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'DÉCIMA QUINTA: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  const pw.TextSpan(text: 'NOTIFICACIONES. - Para los efectos previstos en esta promesa EL(LOS) (S) COMPRADOR(ES) registra(n) la(s) siguiente(s) dirección(es) y teléfono(s) para hacerle (s) las comunicaciones con aquella relacionadas: '),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(
                    text: 'OBSERVACIONES ADICIONALES: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: observaciones),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: const pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(text: 'EL(LOS) (S) COMPRADOR(ES) Dirección __________________________________ de la ciudad de ________________________ teléfono(s): ________________________ y correo electrónico ________________________________________ .'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: const pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(text: 'Las direcciones del VENDEDOR son:  Visión Ahora S.A.S, carrera 54#73-85 barrio Lagos del Cacique de la ciudad de Bucaramanga, Inversiones Taga S.A.S, carrera 54ª#73-65 barrio lagos el cacique de la ciudad de Bucaramanga. Correo electrónico comercial@albaterra.co y teléfono: 3163411129.'),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.RichText(
              textAlign: pw.TextAlign.justify,
              text: const pw.TextSpan(
                children: <pw.TextSpan>[
                  pw.TextSpan(text: 'Para constancia se firma en dos (2) ejemplares del mismo tenor, a los _________________ (______) días del mes de _________ __________de 20__ '),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('EL VENDEDOR, ', textAlign: pw.TextAlign.justify),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children:[
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children:[
                pw.SizedBox(height: 10),
                pw.Text('Nombre: ________________________', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 30),
                pw.Text('Firma: _________________________', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 10),
                pw.Text('C.C. No. ____________ de _________', textAlign: pw.TextAlign.left),
              ]),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children:[
                pw.SizedBox(height: 10),
                pw.Text('Nombre: ________________________', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 30),                
                pw.Text('Firma: _________________________', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 10),
                pw.Text('C.C. No. ____________ de _________', textAlign: pw.TextAlign.left),
              ]),
            ]),
            pw.SizedBox(height: 20),
            pw.Text('EL COMPRADOR, ', textAlign: pw.TextAlign.justify),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children:[
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children:[
                pw.SizedBox(height: 10),
                pw.Text('Nombre: ________________________', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 30),
                pw.Text('Firma: _________________________', textAlign: pw.TextAlign.left),
                pw.SizedBox(height: 10),
                pw.Text('C.C. No. ____________ de _________', textAlign: pw.TextAlign.left),
              ]),
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

  Future<pw.Widget> metodoPago(String evaluarMetodo, context) async {
  if (evaluarMetodo == 'Pago de contado') {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text('VALOR SALDO: $vlrPorPagar',
            textAlign: pw.TextAlign.justify),
        pw.Text(
            '   1. La suma de ${letrasSeparacion.toUpperCase()} ($totalSeparacion) el día $dueDateSeparacion',
            textAlign: pw.TextAlign.justify),
        pw.Text(
            '   2. La suma de ${letrasSaldoContado.toUpperCase()} ($vlrPorPagar) que corresponde al saldo del lote, en menos de $plazoContado, teniendo como fecha límite el $saldoTotalDate',
            textAlign: pw.TextAlign.justify),
      ],
    );
  } else if (evaluarMetodo == 'Financiación directa') {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text('VALOR CUOTA INICIAL $porcCuotaIni: $vlrCuotaIni',
            textAlign: pw.TextAlign.justify),
        pw.Text('VALOR SALDO $porcPorPagar: $vlrPorPagar',
            textAlign: pw.TextAlign.justify),
        pw.Text(
            '   1. La suma de ${letrasSeparacion.toUpperCase()} ($totalSeparacion) el día $dueDateSeparacion',
            textAlign: pw.TextAlign.justify),
        pw.Text(
            '   2. La suma de ${letrasSaldoCI.toUpperCase()} ($saldoCI) que corresponde al saldo de la cuota inicial del lote ($porcCuotaIni del valor total), en menos de $plazoCI, teniendo como fecha límite el $dueDateSaldoCI',
            textAlign: pw.TextAlign.justify),
        pw.Text(
            '   3. La suma de ${letrasSaldoTotal.toUpperCase()} ($vlrPorPagar) que corresponde al saldo del lote ($porcPorPagar del valor total), en $nroCuotas cuotas con periodicidad ${periodoCuotas.toUpperCase()} por valor de $letrasVlrCuota ($vlrCuota) pagaderas el último día hábil del mes, iniciando el $saldoTotalDate',
            textAlign: pw.TextAlign.justify),
      ],
    );
  } else if (evaluarMetodo == 'Personalizado') {
    final installmentsWidgets = await Future.wait(
      List.generate(installments.length, (index) async {
        final valorPago = installments[index]['valorPago'];
        final fechaPago = installments[index]['fechaPago'];
        final valorLetras = await valorEnLetras(valorPago);

        return pw.Text(
          '   ${index + 1}. La suma de ${valorLetras.toUpperCase()} (${currencyCOP((valorPago.toInt()).toString())}) el día $fechaPago',
          textAlign: pw.TextAlign.justify,
        );
      }),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('VALOR SALDO: $vlrPorPagar', textAlign: pw.TextAlign.justify),
        ...installmentsWidgets,
      ],
    );
  } else {
    return pw.Container();
  }
}


  Future<String> valorEnLetras(double valor) async {
    String rta = await numeroEnLetras(valor, 'pesos');
    return rta;
  }


}
