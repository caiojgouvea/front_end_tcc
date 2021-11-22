import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ConexaoProvider extends ChangeNotifier {
  List<dynamic> listaDatas = [];

  void setarListaDatas(String dataInicialInf, String dataFinalInf) {
    DateTime dataInicial = new DateFormat('dd/MM/yyyy').parse(dataInicialInf);
    DateTime dataFinal = new DateFormat('dd/MM/yyyy').parse(dataFinalInf);

    var listaCompletaDatas = getDaysInBetween(dataInicial, dataFinal);
    List<dynamic> listaTemp = [];
    for (int i = 0; i < listaCompletaDatas.length; i++) {
      String d =
          DateFormat('yyyy-MM-dd').format(listaCompletaDatas.elementAt(i));
      listaTemp.add(d);
    }
    listaDatas = listaTemp;
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  Future<List<dynamic>> previsaoRandomForest() async {
    Map<String, dynamic> datas = <String, dynamic>{'data': listaDatas};
    var body = jsonEncode(datas);
    final response = await http.post(
      Uri.parse('http://192.168.1.14:5000/predict/randomforest'),
      body: body,
      headers: {
        'Content-type': 'application/json; charset=UTF-8',
        'Access-Control-Allow-Origin': '*'
      },
    );
    return json.decode(response.body)['NUMERO DE MORTES'] as List;
  }

  Future<List<dynamic>> previsaoGrandientBoost() async {
    Map<String, dynamic> datas = <String, dynamic>{'data': listaDatas};
    var body = jsonEncode(datas);
    final response = await http.post(
      Uri.parse('http://192.168.1.14:5000/predict/gradientboost'),
      body: body,
      headers: {
        'Content-type': 'application/json; charset=UTF-8',
        'Access-Control-Allow-Origin': '*'
      },
    );
    return json.decode(response.body)['NUMERO DE MORTES'] as List;
  }
}
