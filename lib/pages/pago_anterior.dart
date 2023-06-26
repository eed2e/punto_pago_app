import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:prueba_puntopago/pages/registro.dart';
import 'package:http/http.dart' as http;

class pago_anterior extends StatefulWidget {
  final String name;
  pago_anterior(this.name, {super.key});

  @override
  State<pago_anterior> createState() => _pago_anteriorState();
}

class _pago_anteriorState extends State<pago_anterior> {
  final numberFormat = NumberFormat.currency(locale: 'es_MX', symbol: "\$");

  var numero_p = 0;
  var saldo = 0;
  var comision = 0;

  Future<List<Pagos>> _info() async {
    final url2 = Uri.https(
        '3132xxx.pagosdigitalnet.com', '/get_anterior.php', {'q': '{http}'});

    http.Response response3 = await http.post(url2, body: {
      "nombre": widget.name,
    });
    final data3 = jsonDecode(response3.body);
    List<Pagos> items = [];
    if (data3 == "error") {
      Pagos p = Pagos("No se encontarron ", "", "", "", "");
      items.add(p);
    } else {
      for (var pa in data3) {
        Pagos p = Pagos(
            pa['nombre'], pa['numero'], pa['tipo'], pa['monto'], pa['fecha']);
        items.add(p);
      }
    }
    EasyLoading.dismiss();
    return items;
  }

  Future<void> _info_header() async {
    final url2 = Uri.https(
        '3132xxx.pagosdigitalnet.com', '/info_anterior.php', {'q': '{http}'});

    http.Response response3 = await http.post(url2, body: {
      "nombre": widget.name,
    });
    final data3 = jsonDecode(response3.body);
    setState(() {
      numero_p = data3['n_pagos'];
      saldo = data3['saldo'];
      comision = data3['comision'];
    });

    EasyLoading.dismiss();
  }

  @override
  void initState() {
    super.initState();
    _info_header();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(255, 7, 18, 84), width: 2),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          child: Column(
            children: [
              Center(child: Text("Zona: ${widget.name}")),
              Center(
                  child: Text(
                      "Su saldo anterior fue de:  ${numberFormat.format(saldo)}")),
              Center(child: Text("Numero de pagos: $numero_p")),
              Center(
                  child: Text(
                      "Su comision fue de: ${numberFormat.format(comision)}")),
            ],
          ),
        ),
        FutureBuilder(
          future: _info(),
          builder: (_, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: Text("Cargando"),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, index) {
                    return Container(
                      margin: const EdgeInsets.only(
                          left: 8, right: 8, top: 2, bottom: 15),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Color.fromARGB(255, 5, 157, 203), width: 3),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25)),
                      ),
                      child: ListTile(
                        // ignore: prefer_interpolation_to_compose_strings
                        title: Text("Cliente: " +
                            snapshot.data[index].nombre.toString() +
                            "\nN° " +
                            snapshot.data[index].numero.toString() +
                            "\nConcepto: " +
                            snapshot.data[index].tipo.toString() +
                            "\nMonto: \$" +
                            snapshot.data[index].monto.toString() +
                            "      Fecha: " +
                            snapshot.data[index].fecha.toString()),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
