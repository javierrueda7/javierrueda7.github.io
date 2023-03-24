import 'package:albaterrapp/services/firebase_services.dart';
import 'package:flutter/material.dart';

class EditSellerPage extends StatefulWidget {
  const EditSellerPage({super.key});

  @override
  State<EditSellerPage> createState() =>  _EditSellerPageState();
}

class _EditSellerPageState extends State<EditSellerPage> {

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
        Center(          
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
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
                /*ElevatedButton(
                  onPressed: () async {
                    await addSellers(
                      arguments['uid'],
                      usernameController.text, 
                      nameController.text, 
                      emailController.text, 
                      phoneController.text, 
                      arguments['role'],
                      phoneController.text,
                    ).then((_) {
                      Navigator.pop(context);
                    });
                  },
                  child: const Text("Actualizar"),
                ),*/
              ],
            ),
          ),
        )
    );
  }
}