import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './BluetoothDeviceListEntry.dart';
import 'BackgroundCollectingTask.dart';
import 'Chassis_varieties/ChatPage_4x2_1.dart';
import 'Chassis_varieties/ChatPage_4x2_2.dart';
import 'Chassis_varieties/ChatPage_6x2_1.dart';
import 'Chassis_varieties/ChatPage_6x2_2.dart';
import 'Chassis_varieties/ChatPage_TR6_1M.dart';


class SelectBondedDevicePage extends StatefulWidget {
  /// If true, on page start there is performed discovery upon the bonded devices.
  /// Then, if they are not avaliable, they would be disabled from the selection.
  final bool checkAvailability;

  const SelectBondedDevicePage({this.checkAvailability = true});

  @override
  _SelectBondedDevicePage createState() => new _SelectBondedDevicePage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _SelectBondedDevicePage extends State<SelectBondedDevicePage> {

  _SelectBondedDevicePage();

  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>.empty(growable: true);

  // Availability
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
  bool _isDiscovering = false;

  late double optimalSize;

  ///
  // String _address = "...";
  // String _name = "...";
  //
  // Timer? _discoverableTimeoutTimer;
  // int _discoverableTimeoutSecondsLeft = 0;
  //
  // BackgroundCollectingTask? _collectingTask;
  //
  // bool _autoAcceptPairingRequests = false;


  @override
  void initState() {
    super.initState();

    ///
    // // Get current state
    // FlutterBluetoothSerial.instance.state.then((state) {
    //   setState(() {
    //     _bluetoothState = state;
    //   });
    // });
    //
    // Future.doWhile(() async {
    //   // Wait if adapter not enabled
    //   if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
    //     return false;
    //   }
    //   await Future.delayed(Duration(milliseconds: 0xDD));
    //   return true;
    // }).then((_) {
    //   // Update the address field
    //   FlutterBluetoothSerial.instance.address.then((address) {
    //     setState(() {
    //       _address = address!;
    //     });
    //   });
    // });
    //
    // FlutterBluetoothSerial.instance.name.then((name) {
    //   setState(() {
    //     _name = name!;
    //   });
    // });
    //
    // // Listen for futher state changes
    // FlutterBluetoothSerial.instance
    //     .onStateChanged()
    //     .listen((BluetoothState state) {
    //   setState(() {
    //     _bluetoothState = state;
    //
    //     // Discoverable mode is disabled when Bluetooth gets disabled
    //     _discoverableTimeoutTimer = null;
    //     _discoverableTimeoutSecondsLeft = 0;
    //   });
    // });
    ///

    _isDiscovering = widget.checkAvailability;

    if (_isDiscovering) {
      _startDiscovery();
    }

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
      .getBondedDevices()
      .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
          .map(
            (device) => _DeviceWithAvailability(
              device,
              widget.checkAvailability
                  ? _DeviceAvailability.maybe
                  : _DeviceAvailability.yes,
            ),
          ).toList();

        /// Для теста
        // BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
        // FlutterBluetoothSerial.instance.state.then((state) {
        //   setState(() {
        //     _bluetoothState = state;
        //     if (_bluetoothState == BluetoothState.STATE_ON)
        //       devices.add(new _DeviceWithAvailability(new BluetoothDevice(address: "1C:33:33:33:33:33", name: "001_E421_L2"), _DeviceAvailability.yes));
        //   });
        // });

      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
      FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
        setState(() {
        Iterator i = devices.iterator;
        while (i.moveNext()) {
          var _device = i.current;
          if (_device.device == r.device) {
            _device.availability = _DeviceAvailability.yes;
            _device.rssi = r.rssi;
          }
        }
      });
    });

    _discoveryStreamSubscription?.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {

    /// Avoid memory leak (`setState` after dispose) and cancel discovery

    _discoveryStreamSubscription?.cancel();
    // FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    // _collectingTask?.dispose();
    // _discoverableTimeoutTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
      .map((_device) => BluetoothDeviceListEntry(
        device: _device.device,
        rssi: _device.rssi,
        enabled: _device.availability == _DeviceAvailability.yes,
        onTap: () {
          // Navigator.of(context).pop(_device.device);
          _startChat(context, _device.device);
        },
      )).toList();

    final f1 = (MediaQuery.of(context).size.height - 50 - MediaQuery.of(context).padding.top) / 380; ///height - высота всего экрана, а не body!
    final f2 = MediaQuery.of(context).size.width / 200;
    optimalSize = f1<f2 ? f1*20 : f2*20;

    return WillPopScope(
      onWillPop: () async { await SystemNavigator.pop(); return false; },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          leading: IconButton(icon: Icon(null), onPressed: () {  },),
          leadingWidth: 0,
          title: Text('Выбор уст-ва'),
          actions: <Widget>[
            _isDiscovering
                ? FittedBox(
                    child: Container(
                      margin: new EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(Icons.replay),
                    onPressed: _restartDiscovery,
                  )
          ],
        ),
        body: Scrollbar(child: ListView(children: list)),
      ),
    );
  }


  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {

          String temp_name = server.name!.substring(5);

          if (temp_name == "421" || temp_name == "421M" || temp_name.substring(0,4) == "421_")
            return ChatPage_4x2_1(server: server, optimalSize: optimalSize);

          if (temp_name == "422" || temp_name == "422M" || temp_name.substring(0,4) == "422_")
            return ChatPage_4x2_2(server: server, optimalSize: optimalSize);

          if (temp_name == "621" || temp_name == "621M" || temp_name.substring(0,4) == "621_")
            return ChatPage_6x2_1(server: server, optimalSize: optimalSize);

          if (temp_name == "622" || temp_name == "622M" || temp_name.substring(0,4) == "622_")
            return ChatPage_6x2_2(server: server, optimalSize: optimalSize);

          // if (temp_name == "TR6-1M")
          //   return ChatPage_TR6_1M(server: server, optimalSize: optimalSize);

          return Scaffold(
            body: Center(
              child: Text("Устройство не опознано"),
            ),
          );
        },
      ),
    );
  }
}
