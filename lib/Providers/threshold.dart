import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class Thresholds {
  int? id;
  int? temperatureThreshold;
  int? humidityThreshold;
  int? soilMoistureThreshold;
  int? rainfallProbabilityThreshold;

  Thresholds({
    this.id,
    this.humidityThreshold,
    this.rainfallProbabilityThreshold,
    this.soilMoistureThreshold,
    this.temperatureThreshold,
  });
}

class ThresholdProvider extends ChangeNotifier {
  Thresholds threshold = Thresholds(
    id: 123,
    temperatureThreshold: 35,
    humidityThreshold: 90,
    rainfallProbabilityThreshold: 75,
    soilMoistureThreshold: 80,
  );

  Thresholds get getThresholds {
    return threshold;
  }

  int? get getTemperature {
    return threshold.temperatureThreshold;
  }

  int? get getHumidity {
    return threshold.humidityThreshold;
  }

  int? get getRainfallProbability {
    return threshold.rainfallProbabilityThreshold;
  }

  int? get getSoilMoisture {
    return threshold.soilMoistureThreshold;
  }

  static Future<sql.Database> fetchDB() async {
    final dbPath = await sql.getDatabasesPath();

    return sql.openDatabase(path.join(dbPath, "sensorThresholdDb.db"),
        version: 1, onCreate: (db, version) {
      db.execute(
          "CREATE TABLE sensorThreshold(id INT PRIMARY KEY, temperatureThreshold INT, humidityThreshold INT, soilMoistureThreshold INT, rainfallProbabilityThreshold INT)");
    });
  }

  Future getThresholdDataFromDb() async {
    try {
      final db = await fetchDB();
      Thresholds temp = Thresholds();
      final records = await db.query("sensorThreshold");
      for (var element in records) {
        temp.id = int.parse(element['id'].toString());
        temp.temperatureThreshold =
            int.parse(element['temperatureThreshold'].toString());
        temp.humidityThreshold =
            int.parse(element['humidityThreshold'].toString());
        temp.rainfallProbabilityThreshold =
            int.parse(element['rainfallProbabilityThreshold'].toString());
        temp.soilMoistureThreshold =
            int.parse(element['soilMoistureThreshold'].toString());
      }
      threshold = temp;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future addDataToDb(Thresholds data) async {
    try {
      final db = await fetchDB();
      await db.insert(
        "sensorThreshold",
        {
          "id": 1,
          "temperatureThreshold": data.temperatureThreshold,
          "humidityThreshold": data.humidityThreshold,
          "rainfallProbabilityThreshold": data.rainfallProbabilityThreshold,
          "soilMoistureThreshold": data.soilMoistureThreshold,
        },
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );

      threshold = data;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
