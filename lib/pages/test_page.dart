import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../utils/color_utils.dart';
import '../widgets/widgets.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  // ignore: prefer_typing_uninitialized_variables
  var timer;
  String realtimeDateTime = '';

  @override
  void initState() {
    super.initState();
    // Start the timer here
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Perform any periodic tasks here
      setState(() {
        // Update any state variables if needed
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    timer.cancel();
    // Dispose the controllers
    for (var controller in amountControllers) {
      controller.dispose();
    }
    for (var controller in dateControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  List<Map<String, dynamic>> installments = [];
  double remainingAmount = 0;
  double totalInstallmentAmount = 0;
  DateTime lastDate = DateTime.now();
  Color amountColor = Colors.black;
  void completo = false;
  double valorAPagar = 100000000;
  int savedCursorPosition = 0; 
  List<TextEditingController> amountControllers = [];
  List<TextEditingController> dateControllers = [];




  Widget installmentForm(List<Map<String, dynamic>> installments) {
    // Initialize controllers for each installment
    amountControllers = List.generate(installments.length, (index) => TextEditingController(text: currencyCOP(installments[index]['valorPago'].toString())));
    dateControllers = List.generate(installments.length, (index) => TextEditingController(text: installments[index]['fechaPago']));

    
    totalInstallmentAmount = installments.fold(0.0, (sum, installment) => sum + installment['valorPago']);

    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        children: [
          Text(
            'Saldo a pagar: ${currencyCOP((valorAPagar.toInt()).toString())}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Valor acumulado: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextSpan(
                  text: currencyCOP(totalInstallmentAmount.toString()),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            itemCount: installments.length,
            itemBuilder: (context, index) {
              dateControllers[index] = TextEditingController(text: installments[index]['fechaPago']);
              amountControllers[index].text = currencyCOP(installments[index]['valorPago'].toString());
               return Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Cuota ${index + 1}',
                        labelStyle: TextStyle(color: fourthColor, fontWeight: FontWeight.bold),
                        prefixIcon: const Icon(Icons.monetization_on_outlined, size: 20,),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      controller: amountControllers[index],
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        // Save the cursor position
                        savedCursorPosition = amountControllers[index].selection.baseOffset;
                        double newValue = double.tryParse(value) ?? 0;
                        setState(() {
                          installments[index]['valorPago'] = newValue;
                          totalInstallmentAmount = installments.fold(0.0, (sum, installment) => sum + installment['valorPago']);
                          calculateRemainingAmount();
                          setAmountColor();                          
                        });
                        amountControllers[index].text = currencyCOP(installments[index]['valorPago'].toString());
                        if (savedCursorPosition <= amountControllers[index].text.length) {
                          amountControllers[index].selection = TextSelection.collapsed(offset: amountControllers[index].text.length);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Fecha de pago',
                        labelStyle: TextStyle(color: fourthColor, fontWeight: FontWeight.bold),
                        prefixIcon: const Icon(Icons.calendar_today, size: 20,),
                      ),
                      keyboardType: TextInputType.datetime,
                      controller: dateControllers[index],
                      textAlign: TextAlign.center,
                      onTap: () async {
                        showDatePickerDialog(index);
                      },

                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          installments.removeAt(index);
                          totalInstallmentAmount = installments.fold(0.0, (sum, installment) => sum + installment['valorPago']);
                          calculateRemainingAmount();
                        });
                      },
                      icon: Icon(Icons.delete_forever_outlined, color: dangerColor,),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              calculateRemainingAmount();
              Map<String, dynamic> newInstallment = {
                'valorPago': remainingAmount,
                'valorPagoController': TextEditingController(text: currencyCOP((remainingAmount.toInt()).toString())),
                'fechaPago': dateOnly(false, 1, lastDate, false),
                'controller': TextEditingController(text: dateOnly(false, 1, lastDate, false)),
              };
              installments.add(newInstallment);
              setState(() {
                totalInstallmentAmount = installments.fold(0.0, (sum, installment) => sum + (installment['valorPago']));
                calculateRemainingAmount();
                setAmountColor();
              });
            },
            child: const Text('Agregar pago'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  void setAmountColor(){
    if(valorAPagar==totalInstallmentAmount){
      amountColor = successColor;
    } else if(valorAPagar<totalInstallmentAmount){
      amountColor = dangerColor;
    } else{
      amountColor = Colors.black;
    }
  }

  void calculateRemainingAmount() {
    remainingAmount = valorAPagar - totalInstallmentAmount;
  }

  void showDatePickerDialog(int index) async {
    DateTime previousDate;
    DateTime firstDate;
    if (index > 0 && installments[index - 1]['fechaPago'] != '') {
      previousDate = DateFormat('dd-MM-yyyy').parse(installments[index - 1]['fechaPago']);
      firstDate = previousDate.add(const Duration(days: 1));
    } else {
      firstDate = DateTime.now();
      previousDate = DateTime(2000);
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: previousDate,
      lastDate: DateTime(2050),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        installments[index]['fechaPago'] = formattedDate;
        lastDate = pickedDate;
      });
      // Update the corresponding TextEditingController with the selected date
      TextEditingController dateController = installments[index]['controller'];
      dateController.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children:[
        installmentForm(installments)
      ])
    );
  }
}