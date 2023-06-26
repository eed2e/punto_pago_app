import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:prueba_puntopago/menu.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectivityAppWrapper(
      app: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: MyCustomForm(),
        ),
        builder: EasyLoading.init(),
      ),
    );
  }
}

// Crea un Widget Form
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class User {
  final String name;
  final String nuevo;

  User({required this.name, required this.nuevo});
}

// Crea una clase State correspondiente. Esta clase contendrá los datos relacionados con
// el formulario.
class MyCustomFormState extends State<MyCustomForm> {
  // Crea una clave global que identificará de manera única el widget Form
  // y nos permita validar el formulario
  //
  // Nota: Esto es un GlobalKey<FormState>, no un GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscureText = true;
  String _token = "";
  String _numero = "";

  void loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = (prefs.getString('token') ?? "lectura");
      _numero = (prefs.getString('numero') ?? "lectura");

      if (_token != "lectura") {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => MyStatefulWidget()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadCounter();
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final url = Uri.https(
        '3132xxx.pagosdigitalnet.com', '/prueba_api.php', {'q': '{http}'});
    EasyLoading.show(status: 'Cargando...');

    http.Response response =
        await http.post(url, body: {'user': email, 'pass': password});
    final data = jsonDecode(response.body);
    final row = data.toString();
    if (row == "error") {
      EasyLoading.dismiss();
      // ignore: use_build_context_synchronously
      Alert(
        context: context,
        type: AlertType.error,
        title: "USUARIO O CONTRASEÑA INCORRECTA",
        desc: "Favor de Volver a Intentar",
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            width: 120,
            child: const Text(
              "Aceptar",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ).show();
    } else {
      var nam = data["nombre"];
      var nuev = data["nuevo"];
      prefs.setString('token', nam);
      prefs.setString('numero', nuev);

      EasyLoading.dismiss();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyStatefulWidget()));
    }
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Crea un widget Form usando el _formKey que creamos anteriormente
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              'assets/logo.png',
            ),
            const Text(
              "PUNTO DE PAGO",
              style: TextStyle(
                  color: Color.fromARGB(132, 0, 0, 0),
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.only(top: 30.0),
              child: TextFormField(
                controller: _email,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por Favor Introducsa El Usuario';
                  }
                  return null;
                },
                style: const TextStyle(color: Color.fromARGB(255, 2, 137, 255)),
                decoration: const InputDecoration(
                  label: Text.rich(
                    TextSpan(
                      // ignore: prefer_const_literals_to_create_immutables
                      children: <InlineSpan>[
                        WidgetSpan(
                          child: Text(
                            'Usuario',
                          ),
                        ),
                        WidgetSpan(
                          child: Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            TextFormField(
              controller: _password,
              onFieldSubmitted: (value) {
                login(_email.text, _password.text, context);
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Por Favor Introdusca la Contraseña';
                }
                return null;
              },
              style: const TextStyle(color: Color.fromARGB(255, 2, 137, 255)),
              decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: GestureDetector(
                    onTap: _toggle,
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                  )),
              obscureText: _obscureText,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ConnectivityWidgetWrapper(
                stacked: false,
                offlineWidget: MaterialButton(
                  minWidth: 400.0,
                  height: 40.0,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Alert(
                        context: context,
                        type: AlertType.error,
                        title: "Error de Conexión",
                        desc:
                            "Comprueba tu conexión de internet y vuelve a intentarlo",
                        buttons: [
                          DialogButton(
                            // ignore: sort_child_properties_last
                            child: const Text(
                              "Aceptar",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                            ),
                            onPressed: () => Navigator.pop(context),
                            width: 120,
                          )
                        ],
                      ).show();
                    }
                  },
                  color: Color.fromARGB(255, 255, 0, 0),
                  child: const Text('ENTRAR',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                ),
                child: MaterialButton(
                  minWidth: 400.0,
                  height: 40.0,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      login(_email.text, _password.text, context);
                    }
                  },
                  color: Colors.lightBlue,
                  child: const Text('ENTRAR',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
