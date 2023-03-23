import 'package:albaterrapp/pages/add_seller.dart';
import 'package:flutter/material.dart';
import '../services/firebase_services.dart';

class SellersPage extends StatefulWidget {
  const SellersPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SellersPage> createState() => _SellersPageState();
}

class _SellersPageState extends State<SellersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Asesores comerciales'),
        backgroundColor: const Color.fromARGB(255, 86, 135, 109),
      ),
      body: FutureBuilder(
        future: getSellers(),
        builder: ((context, snapshot){
          if(snapshot.hasData){
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index){
                return Dismissible(
                  onDismissed: (direction) async {
                    await deleteSeller(snapshot.data?[index]['sid']);
                    snapshot.data?.removeAt(index);
                    setState(() {});
                  },
                  confirmDismiss: (direction) async {
                    bool result = false;
                    result = await showDialog(
                      context: context, 
                      builder: (context){
                        return AlertDialog(
                          title: Text("Esta seguro de eliminar a ${snapshot.data?[index]['nameSeller']}?"),
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
                  key: Key(snapshot.data?[index]['sid']),
                  child: ListTile(
                    title: Text(snapshot.data?[index]['nameSeller']),
                    onTap: (() async {
                        await Navigator.pushNamed(context, "/edit", arguments: {
                          "username": snapshot.data?[index]['username'],
                          "sid": snapshot.data?[index]['sid'],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSellerPage())); 
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
