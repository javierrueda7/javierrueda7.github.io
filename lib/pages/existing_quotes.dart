import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';

FirebaseFirestore db = FirebaseFirestore.instance;

class ExistingQuotes extends StatefulWidget {
  final List<dynamic> loteInfo;
  const ExistingQuotes({Key? key, required this.loteInfo}) : super(key: key);


  @override
  State<ExistingQuotes> createState() => _ExistingQuotesState();
}

class _ExistingQuotesState extends State<ExistingQuotes> {
  
  @override
  void initState() {
    super.initState();    
    loteInfo = widget.loteInfo;    
  }

  List<dynamic> loteInfo = [];
  
    @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Cotizaciones existentes ${loteInfo[1]}', 
          style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),

          child: FutureBuilder(
            future: getQuotes(loteInfo[1]),
            builder: ((context, snapshot){
              if(snapshot.hasData){
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index){
                    return FutureBuilder(
                      future: db.collection('customers').doc(snapshot.data?[index]['clienteID']).get(),
                      builder: ((context, custSnapshot) {
                        if(custSnapshot.hasData){
                          final custData = custSnapshot.data?.data() as Map<String, dynamic>;
                          final name = custData['nameCliente'] ?? '';
                          final lastName = custData['lastnameCliente'] ?? '';
                          final fullName = '$name $lastName';
                          return Dismissible(
                            onDismissed: (direction) async {
                              await deleteUsers(snapshot.data?[index]['qid']);
                              snapshot.data?.removeAt(index);
                              setState(() {});
                            },
                            confirmDismiss: (direction) async {
                              bool result = false;
                              result = await showDialog(
                                context: context, 
                                builder: (context){
                                  return AlertDialog(
                                    title: Text("Esta seguro de eliminar la cotizacion #${snapshot.data?[index]['qid']}?"),
                                    actions: [
                                      TextButton(onPressed: (){
                                        return Navigator.pop(
                                          context, 
                                          false,
                                        );
                                      }, 
                                      child: const Text("Cancelar",
                                        style: TextStyle(color: Colors.red),
                                      )
                                      ),
                                      TextButton(onPressed: (){
                                        return Navigator.pop(
                                          context, 
                                          true
                                        );
                                      }, 
                                      child: const Text("Si, estoy seguro"),
                                      ),
                                    ],
                                  );
                                }
                              );
                              return result;
                            },
                            background: Container(
                              color:Colors.red,
                              child: const Icon(Icons.delete),
                            ),
                            direction: DismissDirection.endToStart,
                            key: Key(snapshot.data?[index]['qid']),
                            child: ListTile(
                              leading: Text(snapshot.data?[index]['loteName']),
                              title: Text(fullName),
                              subtitle: Text('Cotización #${snapshot.data?[index]['qid']}'),
                              onTap: (() async {
                                await Navigator.pushNamed(context, "/edit", arguments: {
                                  "username": snapshot.data?[index]['username'],
                                  "uid": snapshot.data?[index]['uid'],
                                  "name": snapshot.data?[index]['name'],
                                  "email": snapshot.data?[index]['email'],
                                  "phone": snapshot.data?[index]['phone'],
                                  "role": snapshot.data?[index]['role'],
                                });
                                setState(() {});
                              }
                              ),
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      })
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
            )
          ),
        )
        ),


    );
  }
}

Future<String> getSpecificCustomer(String idCliente) async {
  List customers = [];
  String temp = '';
  QuerySnapshot? queryCustomers = await db.collection('customers').get();
  for (var doc in queryCustomers.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    if(doc.id == idCliente){
      final customer = {
        "clienteID":doc.id,
        "nameCliente":data["nameCliente"],
        "lastnameCliente":data["lastnameCliente"],
        "genderCliente":data["genderCliente"],
        "bdayCliente":data["bdayCliente"],
        "telCliente":data["telCliente"],
        "idTypeCliente":data["idTypeCliente"],
        "idIssueCountryCliente":data["idIssueCountryCliente"],
        "idIssueStateCliente":data["idIssueStateCliente"],
        "idIssueCityCliente":data["idIssueCityCliente"],
        "emailCliente":data["emailCliente"],
        "addressCliente":data["addressCliente"],
        "countryCliente":data["countryCliente"],
        "stateCliente":data["stateCliente"],
        "cityCliente":data["cityCliente"]      
      };
      customers.add(customer);
      temp = '${customer['nameCliente']} ${customer['lastnameCliente']}';
    }
  }
  return temp;
}