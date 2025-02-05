import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditSellerPage extends StatefulWidget {
  const EditSellerPage({super.key});

  @override
  State<EditSellerPage> createState() => _EditSellerPageState();
}

class _EditSellerPageState extends State<EditSellerPage> {
  @override
  void initState() {
    super.initState();
  }

  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController lastnameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  TextEditingController bdController = TextEditingController(text: "");
  TextEditingController genderController = TextEditingController(text: "");
  TextEditingController idController = TextEditingController(text: "");
  TextEditingController roleController = TextEditingController(text: "");
  TextEditingController startDateController = TextEditingController(text: "");
  TextEditingController statusController = TextEditingController(text: "");

  String selectedGender = '';
  String selectedRole = '';
  String selectedStatus = '';
  String sid = '';
  List<String> genderList = ['Masculino', 'Femenino', 'Otro'];
  List<String> roleList = ['Asesor comercial', 'Operativo', 'Administrador'];
  List<String> statusList = ['Activo', 'Inactivo'];
  bool isInitialized = false;

  @override
  Widget build(BuildContext context) {
    Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (isInitialized == false) {
      sid = arguments['sid'];
      nameController.text = arguments['nameSeller'];
      lastnameController.text = arguments['lastnameSeller'];
      emailController.text = arguments['emailSeller'];
      phoneController.text = arguments['phoneSeller'];
      addressController.text = arguments['addressSeller'];
      bdController.text = arguments['bdSeller'];
      idController.text = arguments['idSeller'];
      startDateController.text = arguments['startDateSeller'];
      selectedStatus = arguments['statusSeller'];
      selectedGender = arguments['genderSeller'];
      selectedRole = arguments['roleSeller'];
    } else {
      isInitialized = true;
    }

    isInitialized = true;

    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: fifthColor,
          foregroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Editar usuario',
            style: TextStyle(
                color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                              '¿Está seguro de que quiere eliminar el usuario ${nameController.text} ${lastnameController.text}?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Confirmar'),
                              onPressed: () {
                                statusChangerSellers(sid, 'Eliminado');
                                Navigator.of(context).pop();
                                setState(() {});
                                Navigator.of(context).pop();
                                setState(() {});
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                  ),
                )),
          ],
        ),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color.fromARGB(255, 244, 246, 252),
              Color.fromARGB(255, 222, 224, 227),
              Color.fromARGB(255, 222, 224, 227)
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                              width: 1,
                              style: BorderStyle.solid,
                              color: fifthColor.withOpacity(0.1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: TextField(
                            enabled: false,
                            cursorColor: fifthColor,
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: fifthColor.withOpacity(0.9)),
                            controller: startDateController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.date_range_outlined,
                                color: fifthColor,
                              ),
                              hintText: startDateController.text,
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? startPickedDate = await showDatePicker(
                                locale: const Locale("es", "CO"),
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (startPickedDate != null) {
                                setState(() {
                                  startDateController.text =
                                      DateFormat('dd-MM-yyyy')
                                          .format(startPickedDate);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget("Nombres", Icons.person_outline,
                            false, nameController, true, 'name', () {}),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                            "Apellidos",
                            Icons.person_outline,
                            false,
                            lastnameController,
                            true,
                            'name',
                            () {}),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                              width: 1,
                              style: BorderStyle.solid,
                              color: fifthColor.withOpacity(0.1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: TextField(
                            enabled: false,
                            textAlign: TextAlign.center,
                            cursorColor: fifthColor,
                            style:
                                TextStyle(color: fifthColor.withOpacity(0.9)),
                            controller: bdController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.cake_outlined,
                                color: fifthColor,
                              ),
                              hintText: "Fecha de nacimiento",
                            ),
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickeddate = await showDatePicker(
                                locale: const Locale("es", "CO"),
                                context: context,
                                initialDate: DateTime.now()
                                    .subtract(const Duration(days: 6574)),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now()
                                    .subtract(const Duration(days: 6574)),
                              );
                              if (pickeddate != null) {
                                setState(() {
                                  bdController.text = DateFormat('dd-MM-yyyy')
                                      .format(pickeddate);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: easyDropdown(genderList, selectedGender,
                            (tempGender) {
                          setState(() {
                            selectedGender = tempGender!;
                          });
                        }),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                            "Teléfono",
                            Icons.phone_android_outlined,
                            false,
                            phoneController,
                            true,
                            'phone',
                            () {}),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                            "Correo electrónico",
                            Icons.email_outlined,
                            false,
                            emailController,
                            false,
                            'email',
                            () {}),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: textFieldWidget(
                            "Dirección",
                            Icons.house_outlined,
                            false,
                            addressController,
                            true,
                            'name',
                            () {}),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: easyDropdown(roleList, selectedRole,
                                  (tempRole) {
                                setState(() {
                                  selectedRole = tempRole!;
                                });
                              }),
                            ),
                            Expanded(
                              flex: 1,
                              child: easyDropdown(statusList, selectedStatus,
                                  (tempStatus) {
                                setState(() {
                                  selectedStatus = tempStatus!;
                                });
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: ElevatedButton(
                          style: ButtonStyle(
                              fixedSize: WidgetStateProperty.all(
                                  const Size(250, 50))),
                          onPressed: () async {
                            if (nameController.text.isEmpty ||
                                lastnameController.text.isEmpty ||
                                addressController.text.isEmpty ||
                                phoneController.text.isEmpty ||
                                emailController.text.isEmpty ||
                                idController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: CustomAlertMessage(
                                    errorTitle: "Oops!",
                                    errorText:
                                        "Verifique que todos los campos se hayan llenado correctamente.",
                                    stateColor: dangerColor,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              );
                            } else {
                              await updateSellers(
                                sid,
                                nameController.text,
                                lastnameController.text,
                                emailController.text,
                                phoneController.text,
                                addressController.text,
                                idController.text,
                                bdController.text,
                                selectedGender,
                                startDateController.text,
                                selectedRole,
                                selectedStatus,
                              );
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: CustomAlertMessage(
                                    errorTitle: "Genial!",
                                    errorText:
                                        "Datos actualizados de manera satisfactoria.",
                                    stateColor: successColor,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }
                          },
                          child: const Text("Actualizar"),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
