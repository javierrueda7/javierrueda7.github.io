import 'package:albaterrapp/pages/add_payment.dart';
import 'package:albaterrapp/pages/edit_banco_page.dart';
import 'package:albaterrapp/pages/edit_lote.dart';
import 'package:albaterrapp/pages/edit_sep.dart';
import 'package:albaterrapp/pages/gen_sep.dart';
import 'package:albaterrapp/pages/edit_quote.dart';
import 'package:albaterrapp/pages/edit_seller_page.dart';
import 'package:albaterrapp/pages/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:albaterrapp/firebase_options.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';

// Pages

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [Locale('es'), Locale('en')],
      title: 'Albaterrapp',
      initialRoute: '/',
      routes: {
        '/': (context) => const SignInPage(),
        '/editSeller': (context) => const EditSellerPage(),
        '/editQuote': (context) => const EditQuotePage(),
        '/editLote': (context) => const EditLotePage(),
        '/editBanco': (context) => const EditBancoPage(),
        '/genSep': (context) => const GenerarSeparacion(),
        '/editSep': (context) => const EditarSeparacion(),
        '/addPayment': (context) => const AddPaymentPage(),
      },
    );
  }
}
