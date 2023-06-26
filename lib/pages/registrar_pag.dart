import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class registra_pag extends StatefulWidget {
  final String name;
  registra_pag(this.name, {super.key});

  @override
  State<registra_pag> createState() => _registra_pagState();
}

class _registra_pagState extends State<registra_pag> {
  final _no_cliente = TextEditingController(text: "40040");
  final _password = TextEditingController();
  String _cliente_nombre = "";
  String _cliente_pago = "";
  String _cliente_paquete = "Paquete:";
  String _cliente_numero = "";
  String _nom = "";
  String _pag = "";
  String _paq = "";
  String _especial = "1";
  bool _marca = false;
  bool _firstPress = true;

  void _cambio(String nombre, String paquete, String pago, String cliente) {
    setState(() {
      _cliente_nombre = nombre;
      _cliente_paquete = paquete;
      _cliente_pago = pago;
      _nom = nombre;
      _paq = paquete;
      _pag = pago;
      _especial = "1";
      _cliente_numero = cliente;
      _marca = false;
      _no_cliente.text = cliente;
    });
  }

  Future<void> _scanner() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (barcodeScanRes == "-1") {
    } else {
      var result = barcodeScanRes.substring(2, 12);
      setState(() {
        _no_cliente.text = result;
      });
    }
  }

  Future<void> buscar(String cliente, BuildContext context) async {
    final url = Uri.https('3132.digitalnetags.com.mx',
        '/pagos_app/api_flutter.php', {'q': '{http}'});
    EasyLoading.show(status: 'Cargando...');
    http.Response response =
        await http.post(url, body: {'no_cliente': cliente});
    final data = jsonDecode(response.body);
    final error = data.toString();

    if (error == "error") {
      EasyLoading.dismiss();

      var nombre = "";
      var paquete = "";
      var pago = "";

      // ignore: use_build_context_synchronously
      Alert(
        context: context,
        type: AlertType.warning,
        title: "EL NUMERO DE CLIENTE NO SE ENCONTRO",
        desc: "Vuelva a intentar",
        buttons: [
          DialogButton(
            // ignore: sort_child_properties_last
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
      _cambio(nombre, paquete, pago, cliente);

      // ignore: use_build_context_synchronously
    } else {
      var nom = data["nombre"];
      var paq = data['paquete'];
      var pag = data['pago'];

      var nombre = nom.toString();
      var paquete = paq.toString();
      var pago = pag.toString();

      _cambio(nombre, paquete, pago, cliente);
      EasyLoading.dismiss();
    }
  }

  Future<void> _realizar_Pago(String cli_numero, String cli_tipo,
      String cli_pago, BuildContext context) async {
    final url1 = Uri.https('3132.digitalnetags.com.mx',
        '/pagos_app/api_activar.php', {'q': '{http}'});

    EasyLoading.show(status: 'Cargando...');
    http.Response response1 = await http.post(url1, body: {
      'no_cliente': cli_numero,
      'tipo_pago': cli_tipo,
      'dineros': cli_pago,
      'zona': widget.name,
    });
    final data1 = jsonDecode(response1.body);
    final respuesta_pago = data1['status'].toString();

    if (respuesta_pago == "error4") {
    } else if (respuesta_pago == "error1") {
      setState(() {
        _firstPress = true;
      });
      EasyLoading.dismiss();
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Alert(
        context: context,
        type: AlertType.error,
        title: "Oops!",
        desc: data1['mensaje'].toString(),
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            width: 120,
            child: const Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
      var nombre = "";
      var paquete = "";
      var pago = "";
      var cliente = "40040";
      _cambio(nombre, paquete, pago, cliente);
    } else {
      Navigator.pop(context);
      EasyLoading.dismiss();
      setState(() {
        _firstPress = true;
      });
      // ignore: use_build_context_synchronously
      Alert(
        context: context,
        type: AlertType.success,
        title: "Exito!!",
        desc: data1['mensaje'].toString(),
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            width: 120,
            child: const Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
      var nombre = "";
      var paquete = "";
      var pago = "";
      var cliente = "40040";
      _cambio(nombre, paquete, pago, cliente);
    }
  }

  Widget _checkbox() {
    if (_cliente_nombre == "") {
      return Container(
        padding: const EdgeInsets.only(top: 5),
        child: CheckboxListTile(
            value: _marca, title: const Text("Pago Especial"), onChanged: null),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(top: 20),
        child: CheckboxListTile(
          value: _marca,
          title: const Text("Pago Especial"),
          onChanged: (marca) {
            if (_marca == false) {
              Alert(
                context: context,
                type: AlertType.info,
                title: "Pago Especial?",
                desc: "Confirmar pago especial al titular:\n" + _cliente_nombre,
                buttons: [
                  DialogButton(
                    color: Colors.red,
                    onPressed: () {
                      _12meses(_cliente_paquete, _cliente_pago);
                    },
                    width: 120,
                    child: const Text(
                      "12M",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  DialogButton(
                    color: Colors.green,
                    onPressed: () {
                      _6meses(_cliente_paquete, _cliente_pago);
                    },
                    width: 120,
                    child: const Text(
                      "6M",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ],
              ).show();
            } else {
              setState(() {
                _especial = "1";
                _cliente_paquete = _paq;
                _cliente_pago = _pag;
              });
            }
            setState(() {
              _marca = marca!;
            });
          },
        ),
      );
    }
  }

  void _6meses(String paquete, String pago) {
    var pago_num = double.tryParse(pago);
    var pago_6 = pago_num! * 6;
    setState(() {
      _especial = "6";
      _cliente_paquete = "Pago especial 6 Meses de " + paquete;
      _cliente_pago = pago_6.toString();
    });
    Navigator.pop(context);
  }

  void _12meses(String paquete, String pago) {
    _especial = "12";
    var pago_num = double.tryParse(pago);
    var pago_12 = pago_num! * 12;
    setState(() {
      _cliente_paquete = "Pago especial 12 Meses de " + paquete;
      _cliente_pago = pago_12.toString();
    });
    Navigator.pop(context);
  }

  Widget _boton() {
    if (_cliente_nombre == "") {
      return Container(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: MaterialButton(
            minWidth: 100,
            height: 40,
            onPressed: () {},
            color: const Color.fromARGB(255, 222, 0, 0),
            child: const Text(
              "REGISTRAR",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
          child: MaterialButton(
            minWidth: 100,
            height: 40,
            onPressed: () {
              Alert(
                context: context,
                type: AlertType.info,
                title: "Confirmacion!",
                desc:
                    "Confirmar pago de \$$_cliente_pago \nTitular: $_cliente_nombre",
                buttons: [
                  DialogButton(
                    color: Colors.red,
                    onPressed: () async {
                      if (_firstPress) {
                        Navigator.pop(context);
                      }
                    },
                    width: 120,
                    child: const Text(
                      "No",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  DialogButton(
                    color: Colors.green,
                    onPressed: () async {
                      if (_firstPress) {
                        setState(() {
                          _firstPress = false;
                        });
                        _realizar_Pago(
                            _cliente_numero, _especial, _cliente_pago, context);
                      }
                    },
                    width: 120,
                    child: const Text(
                      "SI",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                ],
              ).show();
            },
            color: const Color.fromARGB(255, 47, 167, 109),
            child: const Text(
              "REGISTRAR",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: const Text(
              "Registrar un pago",
              style: TextStyle(
                  color: Color.fromARGB(140, 0, 0, 0),
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 20),
            child: const Center(
              child: Text(
                "Numero de cliente",
                style: TextStyle(
                    color: Color.fromARGB(132, 0, 0, 0),
                    fontSize: 15.0,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: TextFormField(
              onFieldSubmitted: (value) {
                buscar(_no_cliente.text, context);
              },
              maxLength: 10,
              keyboardType: TextInputType.number,
              controller: _no_cliente,
              style: const TextStyle(
                color: Color.fromARGB(255, 2, 137, 255),
              ),
              decoration: InputDecoration(
                  suffixIconColor: const Color.fromARGB(255, 2, 137, 255),
                  suffixIcon: GestureDetector(
                      onTap: () {
                        buscar(_no_cliente.text, context);
                      },
                      child: const Icon(Icons.search))),
            ),
          ),
          Center(
            child: MaterialButton(
              minWidth: 300,
              height: 40,
              onPressed: () {
                _scanner();
              },
              color: Color.fromARGB(255, 2, 137, 255),
              child: const Text(
                "Escanea el Codigo",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.only(top: 5),
              child: Text("Nombre: " + _cliente_nombre),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: Text(_cliente_paquete),
          ),
          _checkbox(),
          Container(
            padding: const EdgeInsets.only(top: 5),
            child: Center(child: Text('\$' + _cliente_pago)),
          ),
          _boton(),
        ],
      ),
    );
  }
}
