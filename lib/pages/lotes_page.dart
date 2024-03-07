import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firebase_services.dart';

class LotesPage extends StatefulWidget {
  final bool allAccess;
  const LotesPage({super.key, required this.allAccess});

  @override
  State<LotesPage> createState() => _LotesPageState();
}

class _LotesPageState extends State<LotesPage> {
  @override
  void initState() {
    super.initState();
    allAccess = widget.allAccess;
  }

  bool allAccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Lotes',
          style: TextStyle(
              color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FutureBuilder(
              future: getLotes(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: SizedBox(width: 100, child: Text(snapshot.data?[index]['loteState'])),
                        title: Text(snapshot.data?[index]['loteName']),
                        trailing: snapshot.data?[index]['loteState'] == 'Disponible'
                        ? Text(currencyCOP((snapshot.data?[index]['lotePrice'].toInt()).toString()))
                        : FutureBuilder<double>(
                          future: getFinalPrice(snapshot.data?[index]['loteId']),
                          builder: (context, AsyncSnapshot<double> priceSnapshot) {
                            if (priceSnapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (priceSnapshot.hasError) {
                              return const Text('Error');
                            } else {
                              double price = priceSnapshot.data ?? 0.0;
                              return Text(currencyCOP(price.toString()));
                            }
                          },
                        ),
                        tileColor:
                            setStatusColor(snapshot.data?[index]['loteState']),
                        onTap: (() async {
                          if (allAccess == true) {
                            // ignore: use_build_context_synchronously
                            await Navigator.pushNamed(context, "/editLote",
                                arguments: {
                                  "loteId": snapshot.data?[index]['loteId'],
                                  "loteName": snapshot.data?[index]['loteName'],
                                  "loteEtapa": snapshot.data?[index]
                                      ['loteEtapa'],
                                  "loteArea": snapshot.data?[index]['loteArea'],
                                  "lotePrice": snapshot.data?[index]
                                      ['lotePrice'],
                                  "loteState": snapshot.data?[index]
                                      ['loteState'],
                                  "loteLinderos": snapshot.data?[index]
                                      ['loteLinderos'],
                                });
                            setState(() {});
                          } else {
                            setState(() {});
                          }
                        }),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })),
        ),
      ),
    );
  }

  Color setStatusColor(String value) {
    if (value == "Disponible") {
      return Colors.white;
    }
    if (value == "Lote separado") {
      return separadoColor;
    } else {
      return vendidoColor;
    }
  }

  String setStatus(String value) {
    if (value == "Activo") {
      return 'Inactivo';
    } else {
      return 'Activo';
    }
  }

  String setStatusString(String value) {
    if (value == "Activo") {
      return 'inactivar';
    } else {
      return 'activar';
    }
  }
  
  Future<String?> getIdPlanPagos(String idLote) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('ordSep')
          .where('loteId', isEqualTo: idLote)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return null; // Return null if no matching document is found
      }
    } catch (e) {
      return null;
    }
  }

  Future<double> getFinalPrice(String idLote) async {
    String? idPlanPagos = await getIdPlanPagos(idLote);
    double precio = 0;

    if (idPlanPagos != null) {
      DocumentSnapshot? doc = await FirebaseFirestore.instance
          .collection('ordSep')
          .doc(idPlanPagos)
          .get();
      precio = doc['precioFinal'].toDouble();
      return precio;

      // Use the retrieved document ('doc') as needed
    }
    else{
      return precio;
    }
  }

}
