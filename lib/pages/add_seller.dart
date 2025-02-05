// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddSellerPage extends StatefulWidget {
  const AddSellerPage({super.key});

  @override
  State<AddSellerPage> createState() => _AddSellerPageState();
}

class _AddSellerPageState extends State<AddSellerPage> {
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _lastnameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _phoneTextController = TextEditingController();
  final TextEditingController _addressTextController = TextEditingController();
  final TextEditingController _idTextController = TextEditingController();
  final TextEditingController birthdayController =
      TextEditingController(text: "");
  final TextEditingController startDateController = TextEditingController(
      text: DateFormat('dd-MM-yyyy').format(DateTime.now()));
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('sellers');
  late int sellersCounter;
  String selectedGender = 'Masculino';
  String selectedRole = 'Asesor comercial';
  String selectedStatus = 'Activo';
  List<String> genderList = ['Masculino', 'Femenino', 'Otro'];
  List<String> roleList = ['Asesor comercial', 'Operativo', 'Administrador'];
  List<String> statusList = ['Activo', 'Inactivo'];
  DateTime startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    collectionReference.get().then((QuerySnapshot sellersSnapshot) {
      sellersCounter = sellersSnapshot.size;
    });
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            backgroundColor: fifthColor,
            foregroundColor: primaryColor,
            elevation: 0,
            title: Center(
              child: Text(
                "Agregar miembro de equipo",
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            )),
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
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
                  child: Column(children: <Widget>[
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
                          textAlign: TextAlign.center,
                          cursorColor: fifthColor,
                          style: TextStyle(color: fifthColor.withOpacity(0.9)),
                          controller: startDateController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.date_range_outlined,
                              color: fifthColor,
                            ),
                            hintText:
                                DateFormat('dd-MM-yyyy').format(startDate),
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
                      child: textFieldWidget(
                          "Número de identificación",
                          Icons.badge_outlined,
                          false,
                          _idTextController,
                          true,
                          'id',
                          () {}),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget("Nombres", Icons.person_outline,
                          false, _nameTextController, true, 'name', () {}),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget("Apellidos", Icons.person_outline,
                          false, _lastnameTextController, true, 'name', () {}),
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
                          textAlign: TextAlign.center,
                          cursorColor: fifthColor,
                          style: TextStyle(color: fifthColor.withOpacity(0.9)),
                          controller: birthdayController,
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
                                birthdayController.text =
                                    DateFormat('dd-MM-yyyy').format(pickeddate);
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
                          _phoneTextController,
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
                          _emailTextController,
                          true,
                          'email',
                          () {}),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget(
                          "Ingrese su contraseña",
                          Icons.lock_outline,
                          true,
                          _passwordTextController,
                          true,
                          'password',
                          () {}),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: textFieldWidget("Dirección", Icons.house_outlined,
                          false, _addressTextController, true, 'name', () {}),
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
                            fixedSize:
                                WidgetStateProperty.all(const Size(250, 50))),
                        onPressed: () async {
                          if (_nameTextController.text.isEmpty ||
                              _lastnameTextController.text.isEmpty ||
                              _addressTextController.text.isEmpty ||
                              _phoneTextController.text.isEmpty ||
                              _emailTextController.text.isEmpty ||
                              _idTextController.text.isEmpty) {
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
                            FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: _emailTextController.text,
                                    password: _passwordTextController.text)
                                .then((_) async {
                              await addSellers(
                                idGenerator(sellersCounter),
                                _nameTextController.text,
                                _lastnameTextController.text,
                                _emailTextController.text,
                                _phoneTextController.text,
                                _addressTextController.text,
                                _idTextController.text,
                                birthdayController.text,
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
                                        "Datos almacenados de manera satisfactoria.",
                                    stateColor: successColor,
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }).onError((error, stackTrace) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: CustomAlertMessage(
                                    errorTitle: "Oops!",
                                    errorText:
                                        "Parece que ya existe una cuenta con los datos que ingresaste",
                                    stateColor: Color.fromRGBO(214, 66, 66, 1),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                ),
                              );
                            });
                          }
                        },
                        child: const Text("Guardar"),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ));
  }

  String idGenerator(int userCount) {
    userCount++;
    String idGenerated = userCount.toString().padLeft(3, '0');
    return idGenerated;
  }
}
