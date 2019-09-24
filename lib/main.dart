import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const API_URL = 'https://api.hgbrasil.com/finance?key=1f9af6ac';

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        )
      )
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

Future<Map> getData() async {
  http.Response response = await http.get(API_URL);
  return json.decode(response.body);
}

class _HomeState extends State<Home> {


  final _realController = TextEditingController();
  final _dollarController = TextEditingController();
  final _euroController = TextEditingController();

  void _realChange(String real) {
    if (real.isEmpty) {
      this._cleanFields();
      return;
    }
    var realField = double.parse(real);
    _dollarController.text = (realField/_dollar).toStringAsFixed(2);
    _euroController.text = (realField/_euro).toStringAsFixed(2);
  }

  void _dollarChange(String dollar) {
    if (dollar.isEmpty) {
      this._cleanFields();
      return;
    }
    var dollarField = double.parse(dollar);
    _realController.text = (dollarField * _dollar).toStringAsFixed(2);
    _euroController.text = (dollarField * _dollar / _euro).toStringAsFixed(2);
  }

  void _euroChange(String euro) {
      if (euro.isEmpty) {
        this._cleanFields();
        return;
      }
      var euroField = double.parse(euro);
      _realController.text = (_euro * euroField).toStringAsFixed(2);
      _dollarController.text = (euroField * _euro / _dollar).toStringAsFixed(2);
  }

  void _cleanFields() {
    _euroController.clear();
    _dollarController.clear();
    _realController.clear();
  }


  double _dollar;
  double _euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: this._cleanFields
          ),
        ],
        title:
            Text("Currency Calculator", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return SpinKitRipple(
                color: Colors.amber,
                size: 200.0,
              );
            default:
              if (snapshot.hasError) {
                print(snapshot.hasError);
                return renderLoadDataView("Erro ao carregar os dados", true);
              } else {
                _dollar = snapshot.data['results']['currencies']['USD']['buy'];
                _euro = snapshot.data['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on, size: 150, color: Colors.amber),
                      Divider(),
                      buildTextField(
                        label: "Real",
                        prefix: "R\$ ",
                        controller: _realController,
                        onChange: this._realChange
                      ),
                      Divider(),
                      buildTextField(
                        label: "Dollar",
                        prefix: "US\$ ",
                        controller: _dollarController,
                        onChange: this._dollarChange
                      ),
                      Divider(),
                      buildTextField(
                        label: "Euro",
                        prefix: "€ ",
                        controller: _euroController,
                        onChange: this._euroChange
                      ),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Center renderLoadDataView(String text, bool isError) {
  return Center(
    child: Text(text,
      style: TextStyle(
          color: isError == true ? Colors.red : Colors.amber,
          fontSize: 25.0
      ),
      textAlign: TextAlign.center,
    ),
  );
}

Widget buildTextField({
  String label,
  String prefix,
  TextEditingController controller,
  Function onChange
}){
  return TextField(
    controller: controller,
    onChanged: onChange,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.amber,
        fontSize: 25.0,
      ),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25.0
    ),
  );
}