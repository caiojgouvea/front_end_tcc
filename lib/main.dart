import 'package:flutter/material.dart';
import 'package:flutter_tcc_aplicacao/controller/conexao_api_controller.dart';
import 'package:flutter_tcc_aplicacao/modelos/dados_modelo.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ConexaoProvider()),
      ],
      child: MaterialApp(
        title: 'COVID-19 PREVISÕES DE OBITOS',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool dadosInformados = false;
  var data = <DadosModelo>[];
  final _formKey = GlobalKey<FormState>();
  var maskFormatter = new MaskTextInputFormatter(
      mask: '##/##/####', filter: {"#": RegExp(r'[0-9]')});
  String dataInicial = '';
  String dataFinal = '';
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  @override
  Widget build(BuildContext context) {
    var chartWidget = new SfCartesianChart(
      primaryXAxis: DateTimeAxis(dateFormat: DateFormat('dd/MM')),
      primaryYAxis: NumericAxis(numberFormat: NumberFormat.compact()),
      tooltipBehavior: _tooltipBehavior,
      series: <ChartSeries>[
        LineSeries<DadosModelo, DateTime>(
            name: 'Mortes Por Covid19',
            dataSource: data,
            xValueMapper: (DadosModelo dados, _) => dados.ano,
            yValueMapper: (DadosModelo dados, _) => dados.mortes)
      ],
    );

    ConexaoProvider provider = Provider.of<ConexaoProvider>(context);
    List<dynamic> numeroMortes = [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text('PREVISÕES DE OBITOS POR COVID19'),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              (dadosInformados == true
                  ? chartWidget
                  : Container()), // WIDGET DE GRAFICO
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 160,
                    height: 60,
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 5, left: 5),
                        hintText: 'Data Inicial',
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      inputFormatters: [maskFormatter],
                      maxLength: 10,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Data Inicial Não Informada!';
                        } else {
                          dataInicial = value;
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(width: 25),
                  Text("/"),
                  Container(width: 25),
                  Container(
                    width: 160,
                    height: 60,
                    child: TextFormField(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 5, left: 5),
                        hintText: 'Data Final',
                        border: OutlineInputBorder(),
                        counterText: "",
                      ),
                      inputFormatters: [maskFormatter],
                      maxLength: 10,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Data Final Não Informada!';
                        } else {
                          dataFinal = value;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Text(
                'ESCOLHA O ALGORITMO DE PREVISÃO',
                style: Theme.of(context).textTheme.headline4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      elevation: 5,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        provider.setarListaDatas(dataInicial, dataFinal);
                        numeroMortes = await provider.previsaoRandomForest();
                        data = getDados(numeroMortes, provider.listaDatas);
                        setState(() {
                          dadosInformados = true;
                        });
                      }
                    },
                    child: Text('RANDOM FOREST'),
                  ),
                  Container(width: 70),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      elevation: 5,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        provider.setarListaDatas(dataInicial, dataFinal);
                        numeroMortes = await provider.previsaoGrandientBoost();
                        data = getDados(numeroMortes, provider.listaDatas);
                        setState(() {
                          dadosInformados = true;
                        });
                      }
                    },
                    child: Text('GRADIENT BOOST'),
                  ),
                  Container(width: 70),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      elevation: 5,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        provider.setarListaDatas(dataInicial, dataFinal);
                        numeroMortes = await provider.previsaoGrandientBoost();
                        data = getDados(numeroMortes, provider.listaDatas);
                        setState(() {
                          dadosInformados = true;
                        });
                      }
                    },
                    child: Text('PROPHET'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DadosModelo> getDados(List<dynamic> listaRetorno, List<dynamic> data) {
    var lista = <DadosModelo>[];

    for (int i = 0; i < listaRetorno.length; i++) {
      String d = data.elementAt(i).toString();
      double m = double.parse(listaRetorno.elementAt(i).toString());
      var dm = new DadosModelo(new DateFormat('yyyy-MM-dd').parse(d), m);
      lista.add(dm);
    }
    return lista;
  }
}
