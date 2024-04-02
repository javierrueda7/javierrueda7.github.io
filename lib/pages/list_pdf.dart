// ignore_for_file: avoid_web_libraries_in_flutter

import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import 'dart:js' as js;

class ListPdf extends StatefulWidget {
  final String lote;
  final String sepId;
  const ListPdf({super.key, required this.lote, required this.sepId});

  @override
  State<ListPdf> createState() => _ListPdfState();
}

class _ListPdfState extends State<ListPdf> {
  
  @override
  void initState() {
    super.initState();
    lote = widget.lote;
    sepId = widget.sepId;
  }

  @override
  void dispose() {    
    super.dispose();
  }

  String lote = '';
  String sepId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(        
        backgroundColor: fifthColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text('PDFs ',
          style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: FutureBuilder(
              future: getPDFList(sepId),
              builder: ((context, pdfSnapshot) {
                if (pdfSnapshot.hasData) {
                  return ListView.builder(
                    itemCount: pdfSnapshot.data?.length,
                    itemBuilder: (context, index) {
                      return Builder(
                        builder: (context) {
                          return ListTile(
                            leading: const Icon(Icons.picture_as_pdf_outlined),
                            title: Text(pdfSnapshot.data?[index]['FileName']!),
                            subtitle: Text(pdfSnapshot.data?[index]['obs']!),
                            trailing: Column(
                              children: [
                                Text(pdfSnapshot.data?[index]['date']!),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        js.context.callMethod('open', [pdfSnapshot.data?[index]['URL'], '_blank']);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: CustomAlertMessage(
                                              errorTitle: "Genial!",
                                              errorText: "Descarga exitosa.",
                                              stateColor: successColor,
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            width: 1200,
                                          ),
                                        );                                    
                                      },
                                      child: const Icon(Icons.remove_red_eye_outlined,
                                          color: Colors.blueAccent),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () async {                                    
                                        bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Eliminar PDF"),
                                              content: Text("¿Está seguro de eliminar el PDF ${pdfSnapshot.data?[index]['FileName']!} del lote $lote?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(false);
                                                  },
                                                  child: const Text("Cancelar"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(true);
                                                  },
                                                  child: const Text("Eliminar"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                                        
                                        if (confirmDelete) {
                                          Reference storageRef = FirebaseStorage.instance
                                              .ref()
                                              .child('Promesas/${pdfSnapshot.data?[index]['FileName']}.pdf');
                                          // Delete the file
                                          await storageRef.delete();
                                          await deletePDF(sepId, pdfSnapshot.data?[index]['FileName']);
                                          setState(() {
                                            pdfSnapshot.data?.removeAt(index);
                                          });                                      
                                        }
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: CustomAlertMessage(
                                              errorTitle: "Eliminado!",
                                              errorText: "PDF eliminado.",
                                              stateColor: infoColor,
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            width: 1200,
                                          ),
                                        );
                                        
                                      },
                                      child: Icon(Icons.delete_outline, color: dangerColor),
                                    ),                          
                                  ],
                                ),
                              ],
                            ),
                            onTap: ((){}),
                          );
                        }
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