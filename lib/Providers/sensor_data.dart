import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class SensorData {
  int? id;
  int? motor;
  int? temperature;
  int? humidity;
  int? rainfallProbability;
  int? soilMoisture;
  String? inference = "";

  SensorData({
    this.id,
    this.humidity,
    this.temperature,
    this.rainfallProbability,
    this.soilMoisture,
    this.inference,
    this.motor,
  });
}

class SensorDataProvider extends ChangeNotifier {
  late SensorData sensor = SensorData();

  int? get getTemperature {
    return sensor.temperature;
  }

  int? get getHumidity {
    return sensor.humidity;
  }

  int? get getRainfallProbability {
    return sensor.rainfallProbability;
  }

  int? get getSoilMoisture {
    return sensor.soilMoisture;
  }

  String? get getInference {
    return sensor.inference;
  }

  bool get getMotorStatus {
    return sensor.motor == 1;
  }

  void setMotorStatus(int val) {
    sensor.motor = val;
    notifyListeners();
  }

  static Future<sql.Database> fetchDB() async {
    final dbPath = await sql.getDatabasesPath();

    return sql.openDatabase(path.join(dbPath, "sensorDataDb.db"), version: 1,
        onCreate: (db, version) {
      db.execute(
          "CREATE TABLE sensorData(id INT PRIMARY KEY, temperature INT, humidity INT, soilMoist INT, rainProb INT)");
    });
  }

  Future getSensorDataFromDb() async {
    try {
      final db = await fetchDB();
      SensorData temp = SensorData();
      final records = await db.query("sensorData");
      for (var element in records) {
        temp.id = int.parse(element['id'].toString());
        temp.temperature = int.parse(element['temperature'].toString());
        temp.humidity = int.parse(element['humidity'].toString());
        temp.rainfallProbability = int.parse(element['rainProb'].toString());
        temp.soilMoisture = int.parse(element['soilMoist'].toString());
      }
      sensor = temp;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future addDataToDb(SensorData data) async {
    try {
      final db = await fetchDB();
      await db.insert(
        "sensorData",
        {
          "id": 1,
          "temperature": data.temperature,
          "humidity": data.humidity,
          "rainProb": data.rainfallProbability,
          "soilMoist": data.soilMoisture,
        },
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );

      sensor = data;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
