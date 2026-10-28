import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'Torations_coder.dart';

import '../Chassis_varieties/ChatPage_4x2_1.dart' show ChatPage_4x2_1;



class Torations_2 extends StatefulWidget {
  final BluetoothDevice server;
  final double optimalSize;

  const Torations_2({required this.server, required this.optimalSize});

  @override
  _Torations_2 createState() => new _Torations_2();
}

class _Torations_2 extends State<Torations_2> {
  Map<String, double?> toration_data = {};
  late double optimalSize;
  late String chassis_formula = widget.server.name!.substring(9,12);
  
  @override
  void initState() {
    super.initState();
    optimalSize = widget.optimalSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text("Тарировка"),
        leading: BackButton(
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      backgroundColor: Colors.white,

      body: Scrollbar(
        child: ListView.builder(
          // shrinkWrap: true,
          // physics: ClampingScrollPhysics(),
          itemCount: (int.parse(chassis_formula.substring(0,1))/2).round(),										/// itemCount - число осей, на которые могут быть установлены датчики
          itemBuilder: (BuildContext context, int i) {
            toration_data.addAll({
              'Axis${i+1}_P11': null,
              'Axis${i+1}_P12': null,
              'Axis${i+1}_P21': null,
              'Axis${i+1}_P22': null,
              'Axis${i+1}_W1':  null,
              'Axis${i+1}_W2':  null,
            });

            return Column(
              children: [
                SizedBox(height: 50),
                Container(
                  child: Text(
                    "Ось ${i+1}:",
                    style: TextStyle(fontSize: optimalSize*0.85, fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(height: 10),
                Row(                                            /// 1е измерение данных
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,

                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,

                        children: [
                          Row(                                      /// P11
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,

                            children: [
                              Text(
                                "P = ",
                                style: TextStyle(fontSize: optimalSize*0.67),
                              ),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (text) {
                                    toration_data["Axis${i+1}_P11"] = double.tryParse(text.replaceFirst(",", "."));
                                  },
                                ),
                              ),
                              Text(
                                " bar",
                                style: TextStyle(fontSize: optimalSize*0.67),
                              ),
                            ],
                          ),
                          Row(                                      /// P12
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,

                            children: [
                              Text(
                                "P = ",
                                style: TextStyle(fontSize: optimalSize*0.67),
                              ),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (text) {
                                    toration_data["Axis${i+1}_P12"] = double.tryParse(text.replaceFirst(",", "."));
                                  },
                                ),
                              ),
                              Text(
                                " bar",
                                style: TextStyle(fontSize: optimalSize*0.67),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(                                      /// W1
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,

                        children: [
                          Text(
                            "W = ",
                            style: TextStyle(fontSize: optimalSize*0.67),
                          ),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (text) {
                                toration_data["Axis${i+1}_W1"] = double.tryParse(text.replaceFirst(",", "."));
                              },
                            ),
                          ),
                          Text(
                            " tons",
                            style: TextStyle(fontSize: optimalSize*0.67),
                          ),
                        ],
                      )
                    ]
                ),
                SizedBox(height: 10),
                Row(                                            /// 2е измерение данных
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,

                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,

                        children: [
                          Row(                                      /// P21
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,

                            children: [
                              Text(
                                "P = ",
                                style: TextStyle(fontSize: optimalSize*0.67),
                              ),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (text) {
                                    toration_data["Axis${i+1}_P21"] = double.tryParse(text.replaceFirst(",", "."));
                                  },
                                ),
                              ),
                              Text(
                                " bar",
                                style: TextStyle(fontSize: optimalSize*0.67),
                              ),
                            ],
                          ),
                          Row(                                      /// P22
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,

                            children: [
                              Text(
                                "P = ",
                                style: TextStyle(fontSize: optimalSize*0.67),
                              ),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  onChanged: (text) {
                                    toration_data["Axis${i+1}_P22"] = double.tryParse(text.replaceFirst(",", "."));
                                  },
                                ),
                              ),
                              Text(
                                " bar",
                                style: TextStyle(fontSize: optimalSize*0.67),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(                                      /// W2
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,

                        children: [
                          Text(
                            "W = ",
                            style: TextStyle(fontSize: optimalSize*0.67),
                          ),
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (text) {
                                toration_data["Axis${i+1}_W2"] = double.tryParse(text.replaceFirst(",", "."));
                              },
                            ),
                          ),
                          Text(
                            " tons",
                            style: TextStyle(fontSize: optimalSize*0.67),
                          ),
                        ],
                      )
                    ]
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.black)
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(160,160,160,1)),
                  ),

                  onPressed: () {
                    try {
                      double P1 = toration_data['Axis${i+1}_P11']! + toration_data['Axis${i+1}_P12']!;
                      double P2 = toration_data['Axis${i+1}_P21']! + toration_data['Axis${i+1}_P22']!;
                      double k =
                        (toration_data['Axis${i+1}_W2']! - toration_data['Axis${i+1}_W1']!)
                        /
                        (P2 - P1);
                      // ChatPage_4x2_1.toration_data["Axis${i+1}_k"] = k;
                      double b = (toration_data['Axis${i+1}_W2']! - k*P2);
                      // ChatPage_4x2_1.toration_data["Axis${i+1}_b"] = b;



                      Torations_coder.Get_localFile("torations").then((file) {
                        List<Torations_coder> torations_file_data = <Torations_coder>[];

                        if (file.lengthSync() > 0) {
                          var decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
                          torations_file_data = decoded.map((d) => Torations_coder.fromJson(d as Map<String, dynamic>)).toList();

                          int index = torations_file_data.indexWhere((element) =>
                            element.device_name == widget.server.name && element.type == 'T' && element.axis == (i+1));
                          if (index != -1) {
                            torations_file_data[index].k = k;
                            torations_file_data[index].b = b;
                          }
                          else {
                            torations_file_data.add(Torations_coder(device_name: widget.server.name!, type: 'T', axis: i+1, k: k, b: b));
                          }
                        }
                        else {
                          torations_file_data.add(Torations_coder(device_name: widget.server.name!, type: 'T', axis: i+1, k: k, b: b));
                        }

                        List<Map<String, dynamic>> lst = torations_file_data.map((m) => m.toJson()).toList();
                        String encoded = jsonEncode(lst);
                        file.deleteSync();
                        file.createSync();
                        file.writeAsString(encoded);

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Успешно"),
                              content: Text("Данные записаны в файл"),
                            );
                          }
                        );
                      });
                    }
                    catch (ex) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Ошибка"),
                            content: Text("Не удалось записать данные!\nПроверьте правльность заполнения"),
                          );
                        }
                      );
                    }
                  },
                  child: Text(
                    "Записать",
                    style: TextStyle(fontSize: optimalSize * 0.5, color: Color.fromRGBO(70,70,70,1)),
                  ),
                ),
                SizedBox(height: 40),
              ],
            );
          }
        ),
      )
    );
  }
}