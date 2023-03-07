import 'package:albaterrapp/services/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class CsvReader extends StatefulWidget {
  const CsvReader({super.key});

  @override
  State<CsvReader> createState() => _CsvReaderState();
}

class _CsvReaderState extends State<CsvReader> {
  List<List<dynamic>> _data = [];

  void _loadCsvLotes() async{
    final rawData = await rootBundle.loadString("assets/images/lotes_data.csv");
    List<List<dynamic>> listData =
    const CsvToListConverter().convert(rawData);
    setState(() {
      _data = listData;
    });
    for(int i=0; i<_data.length; i++){      
      addLotes(
        _data[i][0].toString(), 
        _data[i][1].toString(), 
        double.parse(_data[i][2].toString()), 
        double.parse(_data[i][3].toString()), 
        double.parse(_data[i][4].toString()), 
        double.parse(_data[i][5].toString()), 
        _data[i][6].toString(), 
        _data[i][7].toString(), 
        double.parse(_data[i][8].toString()), 
        double.parse(_data[i][9].toString()),
        "${_data[i][0].toString()}.png"
      );
      
    }
  }
  
  void _loadCsvCountries() async{
    final rawData = await rootBundle.loadString("assets/images/world_countries.csv");
    List<List<dynamic>> listData =
    const CsvToListConverter().convert(rawData);
    setState(() {
      _data = listData;
    });
    for(int i=0; i<_data.length; i++){      
      addCountries(
        _data[i][0].toString(), 
      );      
    }
  }

  void _loadCsvColombia() async{
    final rawData = await rootBundle.loadString("assets/images/col_cities.csv");
    List<List<dynamic>> listData =
    const CsvToListConverter().convert(rawData);
    setState(() {
      _data = listData;
    });
    for(int i=0; i<_data.length; i++){      
      addCities(
        _data[i][0].toString(),         
        _data[i][1].toString(), 
      );      
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loadCsvCountries,
              child: const Text('Agregar info países'),
            ),
            const SizedBox(),
            ElevatedButton(
              onPressed: _loadCsvColombia,
              child: const Text('Agregar info Colombia'),
            ),
            const SizedBox(),
            ElevatedButton(
              onPressed: _loadCsvLotes,
              child: const Text('Agregar info lotes'),
            ),
      
          ],
        ),
      ),
    );
  }
}