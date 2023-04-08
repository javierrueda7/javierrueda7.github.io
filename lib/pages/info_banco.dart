import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class InfoBancos extends StatefulWidget {  
  const InfoBancos({Key? key}) : super(key: key);


  @override
  State<InfoBancos> createState() => _InfoBancosState();
}

class _InfoBancosState extends State<InfoBancos> {
  
  @override
  void initState() {
    super.initState();
  }  
  
  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text('Cuentas bancarias', style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: FutureBuilder(
            future: getCuentasBanco(),
            builder: ((context, snapshot){
              if(snapshot.hasData){
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index){                      
                    return Dismissible(
                      onDismissed: (direction) async {
                        await archiveQuote(snapshot.data?[index]['bid']);
                        snapshot.data?.removeAt(index);
                        setState(() {});
                      },
                      confirmDismiss: (direction) async {
                        bool result = false;
                        result = await showDialog(
                          context: context, 
                          builder: (context){
                            return AlertDialog(
                              title: Text("Esta seguro de archivar la cuenta ${snapshot.data?[index]['bid']}?"),
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
                      key: Key(snapshot.data?[index]['bid']),
                      child: ListTile(
                        leading: const Icon(Icons.monetization_on_outlined),
                        title: Text(snapshot.data?[index]['bid']),                        
                        onTap: (() async {                          
                          setState(() {});                          
                        }                      
                        ),
                      ),                                
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }  
}

