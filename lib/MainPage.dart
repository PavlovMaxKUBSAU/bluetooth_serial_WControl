import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:scoped_model/scoped_model.dart';

import './BackgroundCollectingTask.dart';
import 'Chassis_varieties/ChatPage_4x2_1.dart';
import './SelectBondedDevicePage.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 2), () async {
      // final BluetoothDevice? selectedDevice =
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => SelectBondedDevicePage(checkAvailability: false)),
      );

      // if (selectedDevice != null) {
      //   print('Подключение к ' + selectedDevice.address);
      //   _startChat(context, selectedDevice);
      // } else {
      //   print('Подключение: не выбрано');
      // }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo.png", fit: BoxFit.contain),
            FractionallySizedBox(widthFactor: 0.8, child: FittedBox(fit: BoxFit.contain, child: Text("Весовой контроль", style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w800)))),
          ],
        ),
      ),
    );
  }


  // void _startChat(BuildContext context, BluetoothDevice server) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) {
  //         if (server.name!.substring(9) == "4x2-1")
  //           return ChatPage_4x2_1(server: server);
  //
  //         return Scaffold(
  //           body: Center(
  //             child: Text("Устройство не опознано"),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}
