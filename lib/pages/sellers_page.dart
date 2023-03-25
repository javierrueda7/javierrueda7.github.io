import 'package:albaterrapp/pages/add_seller.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:flutter/material.dart';
import '../services/firebase_services.dart';

class SellersPage extends StatefulWidget {
  final bool allAccess;
  const SellersPage({
    Key? key, required this.allAccess
  }) : super(key: key);

  @override
  State<SellersPage> createState() => _SellersPageState();
}

class _SellersPageState extends State<SellersPage> {

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
        title: Text('Miembros del equipo',
          style: TextStyle(color: primaryColor,fontSize: 18, fontWeight: FontWeight.bold),),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FutureBuilder(
            future: getSellers(),
            builder: ((context, snapshot){
              if(snapshot.hasData){
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index){
                    return allAccess ? Dismissible(
                      onDismissed: (direction) async {
                        await statusChangerSellers(snapshot.data?[index]['sid'], setStatus(snapshot.data?[index]['statusSeller']));
                        snapshot.data?.removeAt(index);
                        setState(() {});
                      },
                      confirmDismiss: (direction) async {
                        bool result = false;
                        result = await showDialog(
                          context: context, 
                          builder: (context){
                            return AlertDialog(
                              title: Text("Esta seguro de ${setStatusString(snapshot.data?[index]['statusSeller'])} a ${snapshot.data?[index]['nameSeller']} ${snapshot.data?[index]['lastnameSeller']}?"),
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
                        child: const Icon(Icons.power_settings_new_outlined),
                      ),
                      direction: DismissDirection.endToStart,
                      key: Key(snapshot.data?[index]['sid']),
                      child: ListTile(
                        title: Text('${snapshot.data?[index]['nameSeller']} ${snapshot.data?[index]['lastnameSeller']}'),
                        subtitle: Text(snapshot.data?[index]['roleSeller']),
                        trailing: Text(snapshot.data?[index]['statusSeller']),
                        tileColor: setStatusColor(snapshot.data?[index]['statusSeller']),
                        onTap: (() async {
                          if(allAccess == true){
                            await Navigator.pushNamed(context, "/editSeller", arguments: {
                              "sid": snapshot.data?[index]['sid'],
                              "nameSeller": snapshot.data?[index]['nameSeller'],                              
                              "lastnameSeller": snapshot.data?[index]['lastnameSeller'],
                              "emailSeller": snapshot.data?[index]['emailSeller'],
                              "phoneSeller": snapshot.data?[index]['phoneSeller'],
                              "addressSeller": snapshot.data?[index]['addressSeller'],
                              "bdSeller": snapshot.data?[index]['bdSeller'],
                              "genderSeller": snapshot.data?[index]['genderSeller'],
                              "idSeller": snapshot.data?[index]['idSeller'],
                              "roleSeller": snapshot.data?[index]['roleSeller'],
                              "startDateSeller": snapshot.data?[index]['startDateSeller'],
                              "statusSeller": snapshot.data?[index]['statusSeller'],
                            });
                            setState(() {});
                          } else {
                            setState(() {});
                          }
                        }
                      ),
                    ),
                  )
                  : ListTile(
                      title: Text('${snapshot.data?[index]['nameSeller']} ${snapshot.data?[index]['lastnameSeller']}'),
                      subtitle: Text(snapshot.data?[index]['roleSeller']),
                      trailing: Text(snapshot.data?[index]['statusSeller']),
                      tileColor: setStatusColor(snapshot.data?[index]['statusSeller']),
                      onTap: (() async {
                        await Navigator.pushNamed(context, "/editSeller", arguments: {
                          "sid": snapshot.data?[index]['sid'],
                          "nameSeller": snapshot.data?[index]['nameSeller'],                              
                          "lastnameSeller": snapshot.data?[index]['lastnameSeller'],
                          "emailSeller": snapshot.data?[index]['emailSeller'],
                          "phoneSeller": snapshot.data?[index]['phoneSeller'],
                          "addressSeller": snapshot.data?[index]['addressSeller'],
                          "bdSeller": snapshot.data?[index]['bdSeller'],
                          "genderSeller": snapshot.data?[index]['genderSeller'],
                          "idSeller": snapshot.data?[index]['idSeller'],
                          "roleSeller": snapshot.data?[index]['roleSeller'],
                          "startDateSeller": snapshot.data?[index]['startDateSeller'],
                          "statusSeller": snapshot.data?[index]['statusSeller'],
                        });
                        setState(() {});
                      }),
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
        ),
      ),
      floatingActionButton: Visibility(
        visible: allAccess,
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSellerPage())); 
            setState(() {});
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Color setStatusColor(String value){
    if(value == "Activo"){
      return fifthColor.withOpacity(0);
    } else{
      return fifthColor.withOpacity(0.2);
    }
  }

  String setStatus(String value){
    if(value == "Activo"){
      return 'Inactivo';
    } else{
      return 'Activo';
    }
  }

  String setStatusString(String value){
    if(value == "Activo"){
      return 'inactivar';
    } else{
      return 'activar';
    }
  }
}
