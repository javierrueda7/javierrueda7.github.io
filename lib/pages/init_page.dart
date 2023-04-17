import 'package:albaterrapp/pages/add_quote_page.dart';
import 'package:albaterrapp/pages/existing_quotes.dart';
import 'package:albaterrapp/pages/info_gral.dart';
import 'package:albaterrapp/pages/lotes_page.dart';
import 'package:albaterrapp/pages/pictures_page.dart';
import 'package:albaterrapp/pages/sellers_page.dart';
import 'package:albaterrapp/pages/signin_page.dart';
import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {

  
  User? user = FirebaseAuth.instance.currentUser;
  String loggedEmail = '';
  bool anon = FirebaseAuth.instance.currentUser!.isAnonymous;
  bool userLoggedIn = false;

  void checkLoginState() async {
    userLoggedIn = await checkLogin();
    setState(() {});
  }

  Future<bool> checkLogin() async {
    if (user != null && anon == false) {
      loggedEmail = user!.email!;      
      QuerySnapshot loggedSnapshot = await db.collection('sellers').where('emailSeller', isEqualTo: loggedEmail).get();
      if (loggedSnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = loggedSnapshot.docs.first;    
        if(doc['roleSeller'] == 'Administrador'){
          userLoggedIn = true;
        } else{
          userLoggedIn = false;
        }
      } else {
        if(loggedEmail == 'javieruedase@gmail.com'){
          userLoggedIn = true;
        } else{
          userLoggedIn = false;
        }
      }
    } else {
      userLoggedIn = false;
    }  
    return userLoggedIn;
  }
  
  @override
  void initState() {
    super.initState();
    initEtapas();
    checkLoginState();       
  } 

  Future<void> initEtapas() async {
    etapasInfo = await getEtapas();
  }

  List<dynamic> etapasInfo = [];
  List<String> etapasList = ['Seleccionar Etapa', 'Etapa 1', 'Etapa 2', 'Etapa Premium'];
  String selectedItemEtapa = 'Seleccionar Etapa';
  String imgEtapa = "E00.png";
  Color loteColor = Colors.transparent;
  Color etapaColor = Colors.transparent;
  int currentItem = 0;
  List<dynamic> currentLote = [false, ' ', ' ', 0.0, 0.0, 0.0, 0.0, ' ', 0.0,  0.0, 'null', 'null', 'null'];
  List<dynamic> baseLote = [false, ' ', ' ', 0.0, 0.0, 0.0, 0.0, ' ', 0.0,  0.0, 'null', 'null', 'null'];
  String selectedOption = 'Option 1';

  @override
  Widget build(BuildContext context) {
    setState(() {});  
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: fifthColor,
          elevation: 0,
          foregroundColor: primaryColor,
          centerTitle: true,
          title: const Text(
            "Seleccione el lote de sus sueños", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
          ),
          leading: Visibility(
              visible: userLoggedIn,
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                  child: PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Opción 1',
                        child: Text('Cotizaciones'),                        
                      ),                      
                      const PopupMenuItem(
                        value: 'Opción 2',
                        child: Text('Lotes'),
                      ),
                      const PopupMenuItem(
                        value: 'Opción 3',
                        child: Text('Usuarios'),                        
                      ),
                      const PopupMenuItem(
                        value: 'Opción 4',
                        child: Text('Información general'),                        
                      ),
                      
                    ],
                    onSelected: (value) {
                      if(value == 'Opción 1'){                      
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ExistingQuotes(loteInfo: currentLote, needAll: true, loggedEmail: loggedEmail,)));
                        setState(() {}); 
                      } if(value == 'Opción 2'){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LotesPage(allAccess: userLoggedIn)));
                        setState(() {}); 
                      } if(value == 'Opción 3'){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SellersPage(allAccess: userLoggedIn)));
                        setState(() {}); 
                      } if(value == 'Opción 4'){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const InfoGeneral()));
                        setState(() {}); 
                      }else{
                        setState(() {                          
                        });
                      } 
                    },
                  ),
                  
                  
                  
                  
              ),
            ),
          actions: <Widget>[            
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInPage()));
                    });
                  },
                  child: const Icon(
                    Icons.exit_to_app_outlined
                  ),
                )
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(5),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(            
            gradient: LinearGradient(
              colors: [              
                Color.fromARGB(255, 244, 246, 252),
                Color.fromARGB(255, 222, 224, 227),
                Color.fromARGB(255, 222, 224, 227)
              ],
              begin: Alignment.topCenter, end: Alignment.bottomCenter
            )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                flex: 17,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    gradient: LinearGradient(
                      colors: [              
                        primaryColor,
                        fifthColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter
                    )
                  ),
                  height: MediaQuery.of(context).size.height*2/3,
                  alignment: const Alignment(0, 0),  
                  padding: const EdgeInsets.fromLTRB(
                    0, 0, 0, 0
                  ),
                  child: Stack(
                    alignment: Alignment.center,                    
                    children: [
                      InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.8,
                        maxScale: 4,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[                                         
                            const LoteGeneral(),
                            Image.asset(
                              "assets/images/$imgEtapa",
                              fit: BoxFit.fitHeight, 
                              color: etapaColor,                        
                            ),
                            loteImg(currentLote[11], currentLote[10]),
                            FutureBuilder(
                              future: getLotes(),
                              builder: (
                                (context, snapshot){
                                  if(snapshot.hasData){
                                    return LayoutBuilder(
                                      builder: (context, constraits) {
                                        return FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Stack(
                                            children: List.generate(
                                              67,(index){
                                                return Container(
                                                  alignment: Alignment.center,
                                                  height: constraits.maxHeight,
                                                  width: constraits.maxHeight,
                                                  child: Padding(
                                                    padding: EdgeInsets.fromLTRB((constraits.maxHeight*(snapshot.data?[index]['loteLeft'])),constraits.maxHeight*snapshot.data?[index]['loteTop'],constraits.maxHeight*snapshot.data?[index]['loteRight'],constraits.maxHeight*snapshot.data?[index]['loteBottom']),
                                                    child: SizedBox(
                                                      height:(constraits.maxHeight/7)*0.2,
                                                      width: (constraits.maxHeight/7)*0.67,
                                                      child: Center(
                                                        child: ElevatedButton(                                                      
                                                          onPressed: (){                                                                                                       
                                                            setState(() {
                                                              currentLote[0] = true;
                                                              currentLote[1] = snapshot.data?[index]['loteName'];
                                                              currentLote[2] = snapshot.data?[index]['loteId'];
                                                              currentLote[3] = snapshot.data?[index]['loteLeft'];
                                                              currentLote[4] = snapshot.data?[index]['loteTop'];
                                                              currentLote[5] = snapshot.data?[index]['loteRight'];
                                                              currentLote[6] = snapshot.data?[index]['loteBottom'];
                                                              currentLote[7] = snapshot.data?[index]['loteEtapa'];
                                                              currentLote[8] = snapshot.data?[index]['loteArea'];
                                                              currentLote[9] = snapshot.data?[index]['lotePrice'];
                                                              currentLote[10] = snapshot.data?[index]['loteState'];
                                                              currentLote[11] = snapshot.data?[index]['loteImg']; 
                                                              currentLote[12] = snapshot.data?[index]['loteInfoIMG'];
                                                            });
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            foregroundColor: primaryColor,
                                                            backgroundColor: setColorState(snapshot.data?[index]['loteState']),
                                                            shape: const CircleBorder(),
                                                          ),                                                  
                                                          child: FittedBox(
                                                            fit: BoxFit.scaleDown,
                                                            child: Text(
                                                              (index+1).toString(), maxLines: 1, style: TextStyle(
                                                                fontSize: constraits.maxHeight/7*0.1,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            )
                                          ),
                                        );
                                      }
                                    );                                
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator()
                                    );
                                  }
                                }
                              ),
                            ),                            
                          ],
                        ),
                      ),
                      SizedBox(
                        child: Container(
                          child: loteCard(currentLote, (bool cancelPressed){
                              if(cancelPressed == false){
                                setState(() {
                                  currentLote[0] = false;
                                  currentLote[10] = 'null';
                                });
                              } else {
                                setState(() {
                                });
                              }
                            }, (bool quotePressed){
                              if(quotePressed == true && currentLote[10] == "Disponible"){
                                setState(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AddQuotePage(loteInfo: currentLote)),
                                  );
                                  
                                });
                              } else {
                                setState(() {
                                });
                              }
                            }, (bool quoteExisting){
                              if(quoteExisting == true){
                                setState(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ExistingQuotes(loteInfo: currentLote, needAll: false,loggedEmail: loggedEmail,)),
                                  );                                
                                });
                              } else {
                                setState(() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PicturesPage(loteInfo: currentLote)),
                                  );
                                });
                              }
                            }, userLoggedIn
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Center(
                    child: easyDropdown(etapasList, selectedItemEtapa, (tempItem){
                      setState(() { 
                      selectedItemEtapa = tempItem!;
                      if(selectedItemEtapa == "Etapa Premium"){
                        imgEtapa = "E0P.png";
                        etapaColor = fourthColor.withOpacity(0.8);
                      } else {if(selectedItemEtapa== "Etapa 1"){
                          imgEtapa = "E01.png";
                          etapaColor = fourthColor.withOpacity(0.8);
                        } else {if(selectedItemEtapa== "Etapa 2"){
                            imgEtapa = "E02.png";
                            etapaColor = fourthColor.withOpacity(0.8);
                          } else {
                            imgEtapa = "E00.png";
                            etapaColor = Colors.transparent;
                            }
                          }
                        }
                      },);
                    }),
                  ),
                ),
              ),              
              Expanded(
                flex: 1,
                child: Container()
              ),
            ],
          ),
        ),
                    
      ),
    );
  }

  



  TextButton addAllLotes() {
    return TextButton(
      child: Text(
        "Agregar linderos", 
        style: TextStyle(color: fifthColor.withOpacity(0.8), fontWeight: FontWeight.bold),
      ),
      onPressed: (){
        String tempValue = '';
        for (int i = 1; i <= 67; i++) {          
          if(i < 10){
            tempValue = '0${i.toString()}';            
          } else {
            tempValue = i.toString();
          }
          addLoteImg('L$tempValue');
        }
      },
    );
  }
}

class LoteGeneral extends StatelessWidget {
  const LoteGeneral({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset( 
      "assets/images/lote_general.png", 
      fit: BoxFit.fitHeight,
    );
  }
}