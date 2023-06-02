import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  List<Map<String, dynamic>> installments = [];
  double precioFinal = 0;
  double remainingAmount = 0;
  double totalInstallmentAmount = 0;
  DateTime lastDate = DateTime.now();
  Color amountColor = Colors.black;
  void completo = false;

  void calculateRemainingAmount() {    
    remainingAmount = precioFinal - totalInstallmentAmount;
  }

  void printAllPayments() {
    print('Payment Details:');
    for (var i = 0; i < installments.length; i++) {
      final payment = installments[i];
      print('Payment ${i + 1}:');
      print('Amount: ${payment['amount']}');
      print('Date: ${payment['date']}');
      print(remainingAmount);
    }
  }

  void showDatePickerDialog(int index) async {
  DateTime previousDate;
  DateTime firstDate;
  if (index > 0 && installments[index - 1]['date'] != '') {
    previousDate = DateFormat('dd-MM-yyyy').parse(installments[index - 1]['date']);
    firstDate = previousDate.add(Duration(days: 1));
  } else {
    firstDate = DateTime.now();
    previousDate = DateTime.now();
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
      installments[index]['date'] = formattedDate;
    });
    // Update the corresponding TextEditingController with the selected date
    TextEditingController dateController = installments[index]['controller'];
    dateController.text = formattedDate;
  }
}





  DateTime dateConverter(String stringAConvertir) {
    DateTime dateConverted = DateFormat('dd-MM-yyyy').parse(stringAConvertir);
    return dateConverted;
  }

  void setAmountColor(){
    if(precioFinal==totalInstallmentAmount){
      amountColor = successColor;
    } else if(precioFinal<totalInstallmentAmount){
      amountColor = dangerColor;
    } else{
      amountColor = Colors.black;
    }
  }

  Widget installmentForm() {
  return Container(
    alignment: Alignment.center,
    constraints: const BoxConstraints(maxWidth: 800),
    child: Column(
      children: [
        Text(
          'Total Amount: ${currencyCOP((precioFinal.toInt()).toString())}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Suma actual de las cuotas: ',
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
            TextEditingController dateController = installments[index]['controller'];
            TextEditingController amountController = installments[index]['amountController'];
            return Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Cuota ${index+1}',
                      labelStyle: TextStyle(color: fourthColor, fontWeight: FontWeight.bold),
                      prefixIcon: const Icon(Icons.monetization_on_outlined, size: 20,),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    controller: amountController,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      double newValue = double.tryParse(value) ?? 0;
                      setState(() {
                        installments[index]['amount'] = newValue;
                        totalInstallmentAmount = installments.fold(0.0, (sum, installment) => sum + installment['amount']);
                        calculateRemainingAmount();
                        setAmountColor();
                        amountController.value = TextEditingValue(
                          text: (currencyCOP((newValue.toInt()).toString())),
                          selection: TextSelection.collapsed(offset: (currencyCOP((newValue.toInt()).toString())).length),
                        );
                      });
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
                    controller: dateController,
                    textAlign: TextAlign.center,
                    onTap: () {
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
                        totalInstallmentAmount = installments.fold(0.0, (sum, installment) => sum + installment['amount']);
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
              'amount': remainingAmount,
              'amountController': TextEditingController(text: currencyCOP((remainingAmount.toInt()).toString())),
              'date': '',
              'controller': TextEditingController(text: ''),
            };
            installments.add(newInstallment);
            setState(() {
              totalInstallmentAmount = installments.fold(0.0, (sum, installment) => sum + (installment['amount']));
              calculateRemainingAmount();
            });
          },
          child: const Text('Agregar pago'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: precioFinal == totalInstallmentAmount ? printAllPayments : () {
            
          },
          child: const Text('Print Payments'),
        ),
      ],
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    precioFinal = 10000000; // Set the total amount here
    setAmountColor();
    calculateRemainingAmount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Installment Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: installmentForm(),
      ),
    );
  }
}
