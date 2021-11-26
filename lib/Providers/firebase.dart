import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:smart_irrigation/Providers/sensor_data.dart';
import 'package:smart_irrigation/Providers/threshold.dart';

class FirebaseDB extends ChangeNotifier {
  Future fetchDB(BuildContext context) async {
    try {
      final DatabaseReference _messagesRef =
          FirebaseDatabase.instance.reference().child('123');
      final DataSnapshot snap = await _messagesRef.get();
      if (snap.exists) {
        final json = snap.value;
        int n = json['nsensr'];

        SensorData sd = SensorData(
          id: int.parse(snap.key.toString()),
          humidity: int.parse(json['sensrd']['hum'].toString()),
          temperature: int.parse(json['sensrd']['temp'].toString()),
          rainfallProbability: int.parse(json['sensrd']['rainprob'].toString()),
          soilMoisture: int.parse(json['sensrd']['s1']['moist'].toString()),
          motor: int.parse(json['motor'].toString()),
        );

        Thresholds th = Thresholds(
          id: int.parse(snap.key.toString()),
          humidityThreshold: int.parse(json['thresh']['hum'].toString()),
          temperatureThreshold: int.parse(json['thresh']['temp'].toString()),
          rainfallProbabilityThreshold:
              int.parse(json['thresh']['rainprob'].toString()),
          soilMoistureThreshold:
              int.parse(json['thresh']['s1']['moist'].toString()),
        );

        sd.inference = "";
        if (sd.soilMoisture! < th.soilMoistureThreshold!) {
          sd.inference =
              sd.inference! + "Soil moisture is below the threshold level. ";
        } else {
          sd.inference =
              sd.inference! + "Soil moisture is above the threshold level. ";
        }
        if (sd.rainfallProbability! > th.rainfallProbabilityThreshold!) {
          sd.inference = sd.inference! + "It is predicted to rain today.";
        } else {
          if (sd.temperature! < th.temperatureThreshold! &&
              sd.humidity! > th.humidityThreshold!) {
            sd.inference = sd.inference! + "It may rain today.";
          } else {
            sd.inference = sd.inference! + "It will not rain today.";
          }
        }

        await Provider.of<SensorDataProvider>(context, listen: false)
            .addDataToDb(sd);

        await Provider.of<ThresholdProvider>(context, listen: false)
            .addDataToDb(th);
      }
    } catch (e) {
      print(e);
    }
  }

  Future setData(String address, int value) async {
    try {
      final DatabaseReference _messagesRef =
          FirebaseDatabase.instance.reference().child('123/thresh' + address);
      await _messagesRef.set(value);
    } catch (e) {
      print(e);
    }
  }

  Future turnOnMotor() async {
    try {
      final DatabaseReference _messagesRef =
          FirebaseDatabase.instance.reference().child('123/motor');
      await _messagesRef.set(1);
    } catch (e) {
      print(e);
    }
  }

  Future turnOffMotor() async {
    try {
      final DatabaseReference _messagesRef =
          FirebaseDatabase.instance.reference().child('123/motor');
      await _messagesRef.set(0);
    } catch (e) {
      print(e);
    }
  }
}
