import 'package:albaterrapp/services/firebase_services.dart';
import 'package:flutter/material.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({super.key});

  @override
  State<EditUserPage> createState() =>  _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {

  TextEditingController usernameController = TextEditingController(text: "");
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController roleController = TextEditingController(text: "");

  
  @override
  Widget build(BuildContext context) {

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;

    usernameController.text = arguments['username'];
    nameController.text = arguments['name'];
    emailController.text = arguments['email'];
    phoneController.text = arguments['phone'];
    roleController.text = arguments['role'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar usuario'),
      ),
      body: 
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: "Nombre de usuario:",
                    hintText: 'Ingrese su nuevo username',
                  ),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nombre completo:",
                    hintText: 'Ingrese su nombre completo',
                  ),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Correo electronico:",
                    hintText: 'Ingrese su nuevo correo electronico',
                  ),
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Telefono:",
                    hintText: 'Ingrese su nuevo telefono',
                  ),
                ),
                TextFormField(
                  enabled: false,
                  controller: roleController,
                  decoration: const InputDecoration(labelText: "Rol:",
                    hintText: 'Ingrese su nuevo rol',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await updateUsers(
                      arguments['uid'],
                      usernameController.text, 
                      nameController.text, 
                      emailController.text, 
                      phoneController.text, 
                      arguments['role'],
                    ).then((_) {
                      Navigator.pop(context);
                    });
                  },
                  child: const Text("Actualizar"),
                ),
              ],
            ),
          ),
        )
    );
  }
}