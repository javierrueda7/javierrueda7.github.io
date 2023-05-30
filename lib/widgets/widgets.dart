import 'package:albaterrapp/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:number_to_character/number_to_character.dart';
import 'package:translator/translator.dart';

bool isClosed = false;

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 260,
    height: 240,
  );
}

Widget loteImg(String imageName, String loteState) {
  Color loteColor = successColor;
  if (loteState == "null") {
    return Container();
  } else {
    return Image.asset(
      'assets/images/$imageName',
      fit: BoxFit.fitHeight,
      color: loteColor,
    );
  }
}

Future<String> numeroEnLetras(double value, String text) async {
  var converter = NumberToCharacterConverter('en');
  final translator = GoogleTranslator();
  int valorEntero = value.toInt();
  String valorIngles = converter.convertInt(valorEntero);
  final valorFinal =
      await translator.translate('$valorIngles $text', from: 'en', to: 'es');
  return valorFinal.text;
}

TextField textFieldWidget(
    String text,
    IconData? icon,
    bool isPasswordType,
    TextEditingController controller,
    bool isEnabled,
    String kbType,
    Function inputChanged) {
  if (kbType == 'name') {
    controller.addListener(() {
      final text = controller.text.toUpperCase();
      if (controller.text != text) {
        controller.value = controller.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }
  return TextField(
      controller: controller,
      obscureText: isPasswordType,
      enableSuggestions: !isPasswordType,
      autocorrect: !isPasswordType,
      cursorColor: fifthColor,
      enabled: isEnabled,
      textAlign: TextAlign.center,
      style: TextStyle(color: fifthColor.withOpacity(0.9)),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: fifthColor,
        ),
        hintText: text,
        hintStyle: TextStyle(color: fifthColor.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: primaryColor.withOpacity(0.2),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: fifthColor.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
                width: 2, style: BorderStyle.solid, color: fifthColor)),
      ),
      keyboardType: kbTypeFinder(kbType),
      inputFormatters: inputFormatFinder(kbType),
      onTap: () {
        // Set the cursor position to the end of the text when the user taps on the TextField
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      },
      onChanged: (String value) {
        inputChanged(value);
      });
}

List<TextInputFormatter> inputFormatFinder(String value) {
  List<TextInputFormatter> inputFormat = [];
  if (value == 'number') {
    inputFormat = <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly];
  } if (value == 'id') {
    inputFormat = [
      FilteringTextInputFormatter.allow(
        RegExp(r'[A-Z0-9]'),
        replacementString: '',
      ),
    ];
  } else {
    inputFormat = [];
  }
  return inputFormat;
}

TextInputType kbTypeFinder(String value) {
  if (value == 'password') {
    return TextInputType.visiblePassword;
  }
  if (value == 'date') {
    return TextInputType.datetime;
  }
  if (value == 'number') {
    return TextInputType.number;
  }
  if (value == 'phone') {
    return TextInputType.phone;
  } else {
    return TextInputType.emailAddress;
  }
}

Container firebaseButton(BuildContext context, String title, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return fifthColor;
              }
              return fifthColor;
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)))),
        child: Text(
          title,
          style: TextStyle(
              color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
        )),
  );
}

class CustomAlertMessage extends StatelessWidget {
  const CustomAlertMessage({
    Key? key,
    required this.errorTitle,
    required this.errorText,
    required this.stateColor,
  }) : super(key: key);

  final String errorTitle;
  final String errorText;
  final Color stateColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        height: 90,
        decoration: BoxDecoration(
          color: stateColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 48,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errorTitle,
                    style: TextStyle(
                      fontSize: 18,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    errorText,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

Widget loteCard(List<dynamic> currentSelection, Function cancelOnPressed,
    Function quoteOnPressed, Function quoteExisting, bool userType) {
  if (currentSelection[0] == true) {
    return Card(
      elevation: 3,
      color: primaryColor.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              height: 8,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  currentSelection[1].toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 230),
                  child: IconButton(
                    onPressed: () {
                      cancelOnPressed(false);
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: dangerColor,
                    ),
                    alignment: Alignment.topRight,
                  ),
                )
              ],
            ),
            loteCardData('Etapa', currentSelection[7].toString()),
            const SizedBox(
              height: 10,
            ),
            loteCardImg(currentSelection[2].toString(),
                currentSelection[12].toString()),
            const SizedBox(
              height: 10,
            ),
            loteCardData('Precio',
                (currencyCOP((currentSelection[9].toInt()).toString()))),
            Container(
              width: 300,
              padding: const EdgeInsets.all(8.0),
              child: userType
                  ? Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextButton(
                              onPressed: () {
                                quoteOnPressed(true);
                              },
                              child: Text(
                                'Cotizar',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: fifthColor),
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextButton(
                              onPressed: () {
                                quoteExisting(true);
                              },
                              child: Text(
                                'Ver más',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: fifthColor.withOpacity(0.5),
                                ),
                              )),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextButton(
                              onPressed: () {
                                quoteOnPressed(true);
                              },
                              child: Text(
                                'Cotizar',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: fifthColor),
                              )),
                        ),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  } else {
    return Container();
  }
}

Widget loteCardImg(String loteId, String loteInfoImg) {
  if (loteId != 'L67') {
    return SizedBox(
      height: 250,
      child: InteractiveViewer(
        panEnabled: true,
        minScale: 0.8,
        maxScale: 4,
        child: Image.asset(
          'assets/images/$loteInfoImg',
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  } else {
    return const SizedBox();
  }
}

Row loteCardData(String loteInfo, String loteInfoAnswer) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      const Padding(padding: EdgeInsets.only(left: 5, right: 10)),
      Text(
        '$loteInfo:',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      Text(" $loteInfoAnswer", style: const TextStyle(fontSize: 12)),
      const Padding(padding: EdgeInsets.only(left: 5, right: 5)),
    ],
  );
}

Widget easyDropdown(
    List tempList, String tempSelectedItem, Function tempOnChanged) {
  return Container(
    alignment: Alignment.center,
    height: 50,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
        border: Border.all(color: fifthColor.withOpacity(0.1))),
    child: Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10),
      child: DropdownButton<String>(
        style: TextStyle(color: fifthColor.withOpacity(0.9)),
        borderRadius: BorderRadius.circular(30),
        underline: const SizedBox(),
        hint: Center(child: Text(tempSelectedItem)),
        value: tempSelectedItem,
        items: tempList
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Center(
                      child: Text(
                    item,
                    style: TextStyle(color: fifthColor.withOpacity(0.9)),
                  )),
                ))
            .toList(),
        onChanged: (item) => tempOnChanged(item),
        isExpanded: true,
      ),
    ),
  );
}

String currencyCOP(String initValue) {
  NumberFormat formatoMonedaColombiana =
      NumberFormat.currency(locale: 'es_CO', symbol: '', decimalDigits: 2);

  String newValue = formatoMonedaColombiana.format(double.parse(initValue).toInt()).trim();

  return '\$$newValue';
}

double stringConverter(String valorAConvertir) {
  String valorSinPuntos =
      valorAConvertir.replaceAll('\$', '').replaceAll('.', '');
  return double.parse(valorSinPuntos);
}

String dateOnly(
    bool needTime, double n, DateTime dateSelected, bool needBusinessDay) {
  int tempDiff = 0;
  var finalDate = dateSelected.add(Duration(days: n.toInt()));
  DateFormat getDay = DateFormat('dd');
  DateFormat getWeekDay = DateFormat('E');
  String formattedInitDay = getDay.format(dateSelected);
  String formattedFinalDay = getDay.format(finalDate);
  String formattedFinalWeekDay = getWeekDay.format(finalDate);
  bool initOrFinal = false;

  if (formattedInitDay == formattedFinalDay || n % 30 != 0) {
    if (needBusinessDay == true) {
      if (formattedFinalWeekDay == 'Sat') {
        finalDate = finalDate.add(const Duration(days: 2));
        formattedFinalWeekDay = getWeekDay.format(finalDate);
      }
      if (formattedFinalWeekDay == 'Sun') {
        finalDate = finalDate.add(const Duration(days: 1));
        formattedFinalWeekDay = getWeekDay.format(finalDate);
      } else {
        finalDate = finalDate.add(const Duration(days: 0));
        formattedFinalWeekDay = getWeekDay.format(finalDate);
      }
    } else {
      finalDate = finalDate.add(const Duration(days: 0));
      formattedFinalWeekDay = getWeekDay.format(finalDate);
    }
  } else {
    if (int.parse(formattedInitDay) > int.parse(formattedFinalDay)) {
      tempDiff = int.parse(formattedInitDay) - int.parse(formattedFinalDay);
      initOrFinal = true;
    } else {
      tempDiff = int.parse(formattedFinalDay) - int.parse(formattedInitDay);
      initOrFinal = false;
    }
    if (initOrFinal == true) {
      if (tempDiff > 7) {
        tempDiff = 30 - tempDiff;
        finalDate = finalDate.subtract(Duration(days: tempDiff));
      } else {
        finalDate = finalDate.add(Duration(days: tempDiff));
      }
      formattedFinalWeekDay = getWeekDay.format(finalDate);
    } else {
      if (tempDiff > 7) {
        tempDiff = 30 - tempDiff;
        finalDate = finalDate.add(Duration(days: tempDiff));
      } else {
        finalDate = finalDate.subtract(Duration(days: tempDiff));
      }
      formattedFinalWeekDay = getWeekDay.format(finalDate);
    }

    if (needBusinessDay == true) {
      if (formattedFinalWeekDay == 'Sat') {
        finalDate = finalDate.add(const Duration(days: 2));
        formattedFinalWeekDay = getWeekDay.format(finalDate);
      }
      if (formattedFinalWeekDay == 'Sun') {
        finalDate = finalDate.add(const Duration(days: 1));
        formattedFinalWeekDay = getWeekDay.format(finalDate);
      } else {
        finalDate = finalDate.add(const Duration(days: 0));
        formattedFinalWeekDay = getWeekDay.format(finalDate);
      }
    } else {
      finalDate = finalDate.add(const Duration(days: 0));
      formattedFinalWeekDay = getWeekDay.format(finalDate);
    }
  }

  DateFormat formatter;
  if (needTime == true) {
    formatter = DateFormat('dd MM yyyy hh:mm:ss');
  } else {
    formatter = DateFormat('dd-MM-yyyy');
  }
  String formattedDate = formatter.format(finalDate);
  return formattedDate;
}
