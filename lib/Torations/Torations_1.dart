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



class Torations_1 extends StatefulWidget {
  final BluetoothDevice server;
  final double optimalSize;

  const Torations_1({required this.server, required this.optimalSize});

  @override
  _Torations_1 createState() => new _Torations_1();
}

class _Torations_1 extends State<Torations_1> {
  Map<String, double?> toration_data = {};
  late double optimalSize;
  late String temp_name = widget.server.name!.substring(5); /// пример: 001_E421_L2
  late int itemCount;

  @override
  void initState() {
    super.initState();
    optimalSize = widget.optimalSize;

    itemCount = int.parse(temp_name.substring(0,1))~/2;	    /// Число осей, на которые могут быть установлены датчики
    for (int i=0; i<itemCount; i++)
      toration_data.addAll({
        'Axis${i+1}_P1': null,
        'Axis${i+1}_P2': null,
        'Axis${i+1}_W1': null,
        'Axis${i+1}_W2': null,
      });

    toration_data.addAll({
      'TR_Axis1_P1': null,
      'TR_Axis1_P2': null,
      'TR_Axis1_W1': null,
      'TR_Axis1_W2': null,
    });
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

      body: ListView.builder(                                                         /// Тягач
        shrinkWrap: true,
        // physics: ScrollPhysics(),
        itemCount: itemCount+2,
        itemBuilder: (BuildContext context, int i) {
          if (i == 0)
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Тягач/одиночный:",
                  style: TextStyle(fontSize: optimalSize*0.85, fontWeight: FontWeight.w900),
                ),
              ]
            );


          if (i < itemCount + 1)
            return Column(
              children: [
                SizedBox(height: 40),
                Container(
                  child: Text(
                    "Ось ${i}:",
                    style: TextStyle(fontSize: optimalSize*0.85, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(height: 10),
                Row(                                            /// 1е измерение данных
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,

                  children: [
                    Row(                                        /// P1
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
                              toration_data["Axis${i}_P1"] = double.tryParse(text.replaceFirst(",", "."));
                            },
                          ),
                        ),
                        Text(
                          " bar",
                          style: TextStyle(fontSize: optimalSize*0.67),
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
                              toration_data["Axis${i}_W1"] = double.tryParse(text.replaceFirst(",", "."));
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
                Row(                                            /// 2е измерение данных
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,

                  children: [
                    Row(                                      /// P2
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
                              toration_data["Axis${i}_P2"] = double.tryParse(text.replaceFirst(",", "."));
                            },
                          ),
                        ),
                        Text(
                          " bar",
                          style: TextStyle(fontSize: optimalSize*0.67),
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
                              toration_data["Axis${i}_W2"] = double.tryParse(text.replaceFirst(",", "."));
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
                      double k =
                        (toration_data['Axis${i}_W2']! - toration_data['Axis${i}_W1']!)
                        /
                        (toration_data['Axis${i}_P2']! - toration_data['Axis${i}_P1']!);
                      double b = (toration_data['Axis${i}_W2']! - k*(toration_data['Axis${i}_P2']!));



                      Torations_coder.Get_localFile("torations").then((file) {
                        List<Torations_coder> torations_file_data = <Torations_coder>[];

                        if (file.lengthSync() > 0) {
                          var decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
                          torations_file_data = decoded.map((d) => Torations_coder.fromJson(d as Map<String, dynamic>)).toList();

                          int index = torations_file_data.indexWhere((element) =>
                            element.device_name == widget.server.name && element.type == 'T' && element.axis == (i));
                          if (index != -1) {
                            torations_file_data[index].k = k;
                            torations_file_data[index].b = b;
                          }
                          else {
                            torations_file_data.add(Torations_coder(device_name: widget.server.name!, type: 'T', axis: i, k: k, b: b));
                          }
                        }
                        else {
                          torations_file_data.add(Torations_coder(device_name: widget.server.name!, type: 'T', axis: i, k: k, b: b));
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
                SizedBox(height: 15),
              ],
            );
          else
            return (temp_name.substring(3,4) == "_") ? Column(                              /// Прицеп
              children: [
                SizedBox(height: 20),
                Divider(thickness: 2),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        "Прицеп:",
                        style: TextStyle(fontSize: optimalSize*0.85, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ]
                ),
                SizedBox(height: 20),
                Row(                                            /// 1е измерение данных
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,

                    children: [
                      Row(                                        /// P1
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
                                toration_data["TR_Axis1_P1"] = double.tryParse(text.replaceFirst(",", "."));
                              },
                            ),
                          ),
                          Text(
                            " bar",
                            style: TextStyle(fontSize: optimalSize*0.67),
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
                                toration_data["TR_Axis1_W1"] = double.tryParse(text.replaceFirst(",", "."));
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
                Row(                                            /// 2е измерение данных
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,

                    children: [
                      Row(                                      /// P2
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
                                toration_data["TR_Axis1_P2"] = double.tryParse(text.replaceFirst(",", "."));
                              },
                            ),
                          ),
                          Text(
                            " bar",
                            style: TextStyle(fontSize: optimalSize*0.67),
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
                                toration_data["TR_Axis1_W2"] = double.tryParse(text.replaceFirst(",", "."));
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
                      double k =
                          (toration_data['TR_Axis1_W2']! - toration_data['TR_Axis1_W1']!)
                              /
                              (toration_data['TR_Axis1_P2']! - toration_data['TR_Axis1_P1']!);
                      double b = (toration_data['TR_Axis1_W2']! - k*(toration_data['TR_Axis1_P2']!));



                      Torations_coder.Get_localFile("torations").then((file) {
                        List<Torations_coder> torations_file_data = <Torations_coder>[];

                        if (file.lengthSync() > 0) {
                          var decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
                          torations_file_data = decoded.map((d) => Torations_coder.fromJson(d as Map<String, dynamic>)).toList();

                          int index = torations_file_data.indexWhere((element) =>
                          element.device_name == widget.server.name && element.type == 'TR' && element.axis == 1);
                          if (index != -1) {
                            torations_file_data[index].k = k;
                            torations_file_data[index].b = b;
                          }
                          else {
                            torations_file_data.add(Torations_coder(device_name: widget.server.name!, type: 'TR', axis: 1, k: k, b: b));
                          }
                        }
                        else {
                          torations_file_data.add(Torations_coder(device_name: widget.server.name!, type: 'TR', axis: 1, k: k, b: b));
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
                SizedBox(height: 30),
              ]
            ) : SizedBox();
        }
      ),
    );
  }
}