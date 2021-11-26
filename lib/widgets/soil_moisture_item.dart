import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_irrigation/Providers/sensor_data.dart';
import 'package:smart_irrigation/Providers/threshold.dart';
import 'package:smart_irrigation/Screens/detail_page.dart';

// ignore: must_be_immutable
class SoilMoistureWidget extends StatefulWidget {
  late String name;
  late IconData icon;
  late int sensorValue;
  late String reading;
  late Color bgColor;
  late int threshold;
  late Color threshMax;
  late Color readMax;

  SoilMoistureWidget(BuildContext context, {Key? key}) : super(key: key) {
    name = "Soil Moisture";
    icon = Icons.whatshot_outlined;
    // sensorValue = Provider.of<SensorDataProvider>(context).getSoilMoisture!;
    sensorValue = 70;
    reading = sensorValue.toString() + " %";
    bgColor = Colors.brown;
    threshold = Provider.of<ThresholdProvider>(context).getSoilMoisture!;
    threshMax = Colors.red;
    readMax = Colors.green;
  }

  @override
  _SoilMoistureWidget createState() => _SoilMoistureWidget();
}

class _SoilMoistureWidget extends State<SoilMoistureWidget> {
  void pushPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailView(
          widget.name,
          widget.icon,
          3,
          widget.bgColor,
          widget.reading,
          widget.sensorValue,
          widget.threshold,
          widget.threshMax,
          widget.readMax,
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              transitionOnUserGestures: true,
              tag: "CenterIcon3",
              child: Icon(
                widget.icon,
                size: 150,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              widget.reading,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
