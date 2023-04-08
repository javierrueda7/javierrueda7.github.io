import 'package:flutter/material.dart';


Color primaryColor = const Color.fromARGB(255, 245, 242, 235);
Color secondaryColor = const Color.fromARGB(255, 208, 175, 71);
Color thirdColor = const Color.fromARGB(255, 253, 199, 39);
Color fourthColor = const Color.fromARGB(255, 0, 221, 115);
Color fifthColor = const Color.fromARGB(255, 6, 72, 81);

Color successColor = const Color.fromRGBO(52, 194, 64, 1);
Color warningColor = const Color.fromARGB(255, 250, 159, 71);
Color dangerColor = const Color.fromARGB(255, 214, 66, 66);
Color infoColor = const Color.fromARGB(255, 0, 146, 224);


Color setColorState (String loteState){
  Color loteColor;
  if(loteState == "Disponible"){
    loteColor = infoColor;
  } else{ 
    if(loteState == "Lote separado"){
    loteColor = warningColor;
    } else{
      if(loteState == "null"){
        loteColor = Colors.transparent;
      } else{
        loteColor = dangerColor;
      }
    }
  }
  return loteColor;
}