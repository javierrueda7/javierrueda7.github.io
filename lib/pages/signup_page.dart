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
  double totalAmount = 0;
  double remainingAmount = 0;
  double totalInstallmentAmount = 0;
  DateTime lastDate = DateTime.now();

  void calculateRemainingAmount() {    
    remainingAmount = totalAmount - totalInstallmentAmount;
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
    final currentDate = installments[index]['date'] != ''
        ? DateFormat('dd-MM-yyyy').parse(installments[index]['date'])
        : DateTime.now();

    if (index > 0) {
      lastDate = DateFormat('dd-MM-yyyy').parse(installments[index - 1]['date']);
    } else {
      lastDate = DateTime(1900);
    }

    final pickedDate = await showDatePicker(
      locale: const Locale("es", "CO"),
      context: context,
      initialDate: currentDate,
      firstDate: lastDate.add(const Duration(days: 1)),
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

  Widget installmentForm() {
    return Column(
      children: [
        Text(
          'Total Amount: ${currencyCOP((totalAmount.toInt()).toString())}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Suma actual de las cuotas: ${currencyCOP(totalInstallmentAmount.toString())}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          itemCount: installments.length,
          itemBuilder: (context, index) {
            TextEditingController amountController = installments[index]['controller'];
            double installmentAmount = double.tryParse(amountController.text) ?? 0.0;

            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Payment Amount',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    controller: amountController,
                    onChanged: (value) {
                      double newValue = double.tryParse(value) ?? 0.0;
                      if (newValue > remainingAmount) {
                        // If the entered value exceeds the total amount, set it to the total amount
                        value = remainingAmount.toString();
                        newValue = remainingAmount;
                      }
                      setState(() {
                        totalInstallmentAmount = installments.fold(0.0, (sum, installment) => sum + double.tryParse(installment['controller'].text) ?? 0.0);
                        calculateRemainingAmount();
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Payment Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.datetime,
                    controller: installments[index]['controller'],
                    onTap: () {
                      showDatePickerDialog(index);
                    },
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Map<String, dynamic> newInstallment = {
              'amount': installments[index]['controller'],
              'date': '',
              'controller': TextEditingController(text: DateFormat('dd-MM-yyyy').format(DateTime.now())),
            };
            installments.add(newInstallment);
            setState(() {
              totalInstallmentAmount = installments.fold(0.0, (sum, installment) => sum + double.tryParse(installment['controller'].text) ?? 0.0);
              calculateRemainingAmount();
            });
          },
          child: const Text('Add Payment'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: printAllPayments,
          child: const Text('Print Payments'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    totalAmount = 100; // Set the total amount here
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
