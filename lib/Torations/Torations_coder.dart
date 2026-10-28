import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:path_provider/path_provider.dart';

class Torations_coder {

  Torations_coder({required this.device_name, required this.type, required this.axis, required this.k, required this.b});

  final String device_name;
  final String type;
  final int axis;
  late double k;
  late double b;

  factory Torations_coder.fromJson(Map<String, dynamic> json) {
    return Torations_coder(
      device_name: json['device_name'] as String,
      type: json['type'] as String,
      axis: int.parse(json['axis']),
      k: double.parse(json['k']),
      b: double.parse(json['b']),
    );
  }

  Map<String, dynamic> toJson() => {
    'device_name': device_name,
    'type': type,
    'axis' : axis.toString(),
    'k': k.toString(),
    'b': b.toString(),
  };

  static Future<File> Get_localFile(String name) async {
    var appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path + '/${name}.json';

    File file = File(appDocPath);

    if (! file.existsSync()) {
      file.createSync();
    }

    return file;
  }
}

