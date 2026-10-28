import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../Torations/Torations_1.dart';
import '../Torations/Torations_coder.dart';




class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class ChatPage_TR6_1M extends StatefulWidget {
  final BluetoothDevice server;
  final optimalSize;

  const ChatPage_TR6_1M({required this.server, required this.optimalSize});

  @override
  _ChatPage_TR6_1M createState() => new _ChatPage_TR6_1M();
}

class _ChatPage_TR6_1M extends State<ChatPage_TR6_1M> {
  static final clientID = 0;
  BluetoothConnection? connection;

  // List<_Message> messages = [new _Message(1, "111")];
  List<_Message> messages = [new _Message(1, "---")];
  // List<_Message> messages = [new _Message(1, "\#10101020")];

  String _messageBuffer = '';
  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;

  Map<String, double?> toration_data = {
    'Axis1_k': null,
    'Axis1_b': null,
  };

  late double optimalSize;
  late BorderRadius border_radius;
  late double border_width;

  Color pressure_Color = Color.fromRGBO(130,250,0,1);
  Color weight_Color = Colors.yellowAccent;

  dynamic pressure1;
  double? weight1;



  @override
  void initState() {
    super.initState();
    optimalSize = widget.optimalSize;
    border_radius = BorderRadius.circular(optimalSize * 0.25);
    border_width = optimalSize * 0.07;

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Подключено');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Отключено локально!');
        } else {
          print('Отключено удаленно!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Ошибка подключения, выброс исключения');
      print(error);
    });

    _load_toration_data();
  }



  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Text> list = messages.map((_message) {
      return (_message.text[0] == String.fromCharCode(13)) ?
      Text(_message.text.substring(1)) :
      Text(_message.text);
    }).toList();


    if (list[0].data![0] != "\#")     /// попробовать сделать цикл (универсально), хотя особо не имеет смысла, но все равно:)
    {
      /// Ось 1
      if (list[0].data!.substring(0,1) == "-") {
        pressure1 = "-----";
        weight1 = null;
      }
      else if (list[0].data!.substring(0,1) == "N") {
        pressure1 = "No calib";
        weight1 = null;
      }
      else {
        pressure1 = double.parse(list[0].data!.substring(0,1) + "." + list[0].data!.substring(1,3));
        if (toration_data['Axis1_k'] != null) {
          if (pressure1 < 0.5)
            weight1 = 0;
          else
            weight1 = toration_data['Axis1_k']! * pressure1 + toration_data['Axis1_b']!;
        }
      }
    }


    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: (isConnecting
            ? Text('Подключение...')
            : isConnected
            ? Text('Подключено')
            : Text('Нет связи!', style: TextStyle(color: Color.fromRGBO(230,50,30,1)),)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return Torations_1(server: widget.server, optimalSize: optimalSize);
                  },
                ),
              );
              _load_toration_data();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,

      body: list[0].data![0] == "\#" ?
        Column(
          children: [
            SizedBox(height: 10),
            Text("Калибровки", style: TextStyle(fontFamily: "RaleWay", fontSize: optimalSize, fontWeight: FontWeight.w500),),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 8,
              itemBuilder: (BuildContext context, int i) {
                return Column(
                  children: [
                    SizedBox(height: 15),
                    list[0].data![i+1] == "0" ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: border_radius,
                                side: BorderSide(color: Colors.black)
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(160,160,160,1)),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Датчик ${i+1}",
                            style: TextStyle(fontSize: optimalSize, color: Color.fromRGBO(70,70,70,1)),
                          ),
                        ),
                        Icon(null, color: pressure_Color, size: optimalSize * 1.5),
                      ]
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: border_radius,
                                  side: BorderSide(color: Colors.black)
                              ),
                            ),
                            //backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(120,120,120,1)),
                          ),

                          onPressed: () { _sendMessage((i+1).toString()); },
                          child: Text(
                            "Датчик ${i+1}",
                            style: TextStyle(fontSize: optimalSize),
                          ),
                        ),
                        list[0].data![i+1] == "1" ? Icon(Icons.close, color: Colors.red, size: optimalSize * 1.5) :
                        Icon(Icons.done, color: Colors.green, size: optimalSize * 1.5),
                      ],
                    ),
                  ],
                );
              }
            ),
          ],
        )


      : Stack(
        children: <Widget>[

          Center(
            child: Image.asset(
              "assets/${widget.server.name!.substring(9)}.png",
              scale: 20/optimalSize,
            )
          ),

          ///Датчик давления 1
          Center(
            child: FittedBox(
              child: Container(
                padding: EdgeInsets.fromLTRB(10,0,10,0),
                decoration: BoxDecoration(
                  borderRadius: border_radius,
                  color: pressure_Color,
                  border: Border.all(
                    color: Colors.black,
                    width: border_width,
                  ),
                ),

                margin: EdgeInsets.only(bottom: optimalSize * 2.3),

                child: Text(
                  (pressure1.runtimeType == double) ? pressure1.toStringAsFixed(2) + " bar" : pressure1.toString(),
                  style: TextStyle(fontSize: optimalSize * 0.7),
                ),
              ),
            ),
          ),

          ///Вес 1
          Center(
            child: FittedBox(
              child: Container(

                padding: EdgeInsets.fromLTRB(10,0,10,0),
                decoration: BoxDecoration(
                  borderRadius: border_radius,
                  color: weight_Color,
                  border: Border.all(
                    color: Colors.black,
                    width: border_width,
                  ),
                ),

                margin: EdgeInsets.only(top: optimalSize * 0.98),

                child: Text(
                  (weight1 != null) ? "${weight1!.toStringAsFixed(2)} tons" : "-----",
                  style: TextStyle(fontSize: optimalSize * 0.7),
                ),
              ),
            ),
          ),

          ///Вес 2
          Center(
            child: FittedBox(
              child: Container(

                padding: EdgeInsets.fromLTRB(10,0,10,0),
                decoration: BoxDecoration(
                  borderRadius: border_radius,
                  color: weight_Color,
                  border: Border.all(
                    color: Colors.black,
                    width: border_width,
                  ),
                ),

                margin: EdgeInsets.only(top: optimalSize * 5.75),

                child: Text(
                  (weight1 != null) ? "${weight1!.toStringAsFixed(2)} tons" : "-----",
                  style: TextStyle(fontSize: optimalSize * 0.7),
                ),
              ),
            ),
          ),

          ///Вес 3
          Center(
            child: FittedBox(
              child: Container(

                padding: EdgeInsets.fromLTRB(10,0,10,0),
                decoration: BoxDecoration(
                  borderRadius: border_radius,
                  color: weight_Color,
                  border: Border.all(
                    color: Colors.black,
                    width: border_width,
                  ),
                ),

                margin: EdgeInsets.only(top: optimalSize * 10.55),

                child: Text(
                  (weight1 != null) ? "${weight1!.toStringAsFixed(2)} tons" : "-----",
                  style: TextStyle(fontSize: optimalSize * 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _load_toration_data() {
    Torations_coder.Get_localFile("").then((file) {
      List<Torations_coder> torations_file_data = <Torations_coder>[];

      if (file.lengthSync() > 0) {
        var decoded = jsonDecode(file.readAsStringSync()) as List<dynamic>;
        torations_file_data = decoded.map((d) => Torations_coder.fromJson(d as Map<String, dynamic>)).toList();

        int index = torations_file_data.indexWhere((element) =>
        element.device_name == widget.server.name && element.axis == 1);
        if (index != -1) {
          toration_data['Axis1_k'] = torations_file_data[index].k;
          toration_data['Axis1_b'] = torations_file_data[index].b;
        }

        index = torations_file_data.indexWhere((element) =>
        element.device_name == widget.server.name && element.axis == 2);
        if (index != -1) {
          toration_data['Axis2_k'] = torations_file_data[index].k;
          toration_data['Axis2_b'] = torations_file_data[index].b;
        }
      }
    });
  }


  void _onDataReceived(Uint8List data) {
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);

    if (~index != 0) {
      messages.clear();
      setState(() {
        messages.add(
            _Message(
                1,
                backspacesCounter > 0
                    ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                    : _messageBuffer + dataString.substring(0, index)
            )
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }


  void _sendMessage(String text) async {
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(ascii.encode(text)));
        await connection!.output.allSent;

        // Future.delayed(Duration(milliseconds: 333)).then((_) {
        //   listScrollController.animateTo(
        //       listScrollController.position.maxScrollExtent,
        //       duration: Duration(milliseconds: 333),
        //       curve: Curves.easeOut);
        // });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}


