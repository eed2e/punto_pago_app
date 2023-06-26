import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:prueba_puntopago/pages/pago_actual.dart';
import 'pages/pago_anterior.dart';
import 'package:http/http.dart' as http;

import 'package:prueba_puntopago/pages/registrar_pag.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// [AnimationController]s can be created with `vsync: this` because of
/// [TickerProviderStateMixin].
class _MyStatefulWidgetState extends State<MyStatefulWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _newpass = TextEditingController();
  final _newpass_reply = TextEditingController();
  bool _obscureText = true;
  bool _obscureText_1 = true;
  String es_nuevo = "0";
  var name = "";
  var nuevo = "";

  void _borrar(context) async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyCustomForm()));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  void loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = (prefs.getString('token') ?? "lectura");
      nuevo = (prefs.getString('numero') ?? "lectura");
    });
  }

  @override
  void initState() {
    super.initState();
    loadCounter();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggle_1() {
    setState(() {
      _obscureText_1 = !_obscureText_1;
    });
  }

  Widget _numero(String name, BuildContext context) {
    return TabBarView(
      controller: _tabController,
      children: [
        registra_pag(name),
        pago_actual(name),
        pago_anterior(name),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Pago'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: TextButton(
                  onPressed: () => _borrar(context),
                  child: const Text('Cerrar Sesion'),
                ),
              ),
              const PopupMenuItem(
                child: TextButton(
                  onPressed: _launchUrl,
                  child: Text('Privacidad'),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: "Registrar Pago",
            ),
            Tab(
              text: "Pago Actual",
            ),
            Tab(
              text: "Pago Anterior",
            ),
          ],
        ),
      ),
      body: _numero(name, context),
    );
  }
}

Future<void> _launchUrl() async {
  final Uri _url =
      Uri.parse('https://digitalnetags.com.mx/aviso-de-privacidad/');
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
