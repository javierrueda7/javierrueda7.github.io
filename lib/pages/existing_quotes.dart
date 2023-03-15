import 'package:albaterrapp/services/firebase_services.dart';
import 'package:albaterrapp/utils/color_utils.dart';
import 'package:albaterrapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ExistingQuotes extends StatefulWidget {
  final List<dynamic> loteInfo;
  const ExistingQuotes({Key? key, required this.loteInfo}) : super(key: key);


  @override
  State<ExistingQuotes> createState() => _ExistingQuotesState();
}

class _ExistingQuotesState extends State<ExistingQuotes> {
  
  @override
  void initState() {
    super.initState();    
    loteInfo = widget.loteInfo;    
  }
  
  List<dynamic> loteInfo = [];
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}