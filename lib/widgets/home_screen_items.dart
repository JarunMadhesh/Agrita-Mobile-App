import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_irrigation/Providers/sensor_data.dart';
import 'package:smart_irrigation/Providers/threshold.dart';
import 'package:smart_irrigation/Screens/detail_page.dart';

// ignore: must_be_immutable
class HomeScreenItem extends StatelessWidget {
  late int type;
  late String name;
  late IconData icon;
  late int sensorValue;
  late String reading;
  late int threshold;
  late Color threshMax;
  late Color readMax;

  final List<String> names = [
    "Temperature",
    "Humidity",
    "Rain Probability",
  ];

  final List<IconData> icons = [
    Icons.thermostat_rounded,
    Icons.water_rounded,
    Icons.water_damage_rounded,
  ];

  final List<Color> colors = [
    Colors.purple,
    Colors.blue,
    Colors.teal,
  ];

  HomeScreenItem(this.type, BuildContext context, {Key? key})
      : super(key: key) {
    name = names[type];
    icon = icons[type];
    if (type == 0) {
      sensorValue = Provider.of<SensorDataProvider>(context).getTemperature!;
      reading = sensorValue.toString() + "°C";
      threshold = Provider.of<ThresholdProvider>(context).getTemperature!;
      threshMax = Colors.red;
      readMax = Colors.green;
    } else if (type == 1) {
      sensorValue = Provider.of<SensorDataProvider>(context).getHumidity!;
      reading = sensorValue.toString() + "%RH";
      threshold = Provider.of<ThresholdProvider>(context).getHumidity!;
      threshMax = Colors.red;
      readMax = Colors.green;
    } else if (type == 2) {
      sensorValue =
          Provider.of<SensorDataProvider>(context).getRainfallProbability!;
      reading = sensorValue.toString() + "%";
      threshold =
          Provider.of<ThresholdProvider>(context).getRainfallProbability!;
      threshMax = Colors.green;
      readMax = Colors.red;
    }
  }

  void pushPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailView(
          name,
          icon,
          type,
          colors[type],
          reading,
          sensorValue,
          threshold,
          threshMax,
          readMax,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        pushPage(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              transitionOnUserGestures: true,
              tag: "CenterIcon" + type.toString(),
              child: Icon(
                icon,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            if (type < 4)
              Text(
                reading,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 5),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15.0),
            ),
          ],
        ),
      ),
    );
  }
}
