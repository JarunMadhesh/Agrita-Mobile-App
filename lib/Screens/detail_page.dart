import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_irrigation/Providers/firebase.dart';
import 'package:smart_irrigation/Providers/threshold.dart';
import 'package:smart_irrigation/Screens/loading_screen.dart';
import 'package:smart_irrigation/Screens/loading_screen2.dart';
import 'package:smart_irrigation/widgets/painter.dart';
import 'dart:math' as math;

// ignore: must_be_immutable
class DetailView extends StatefulWidget {
  String title;
  IconData icon;
  int id;
  Color bgColor;

  String reading;
  int sensorValue;
  int threshold;
  Color threshMax;
  Color readMax;
  late int actualThreshold;

  DetailView(this.title, this.icon, this.id, this.bgColor, this.reading,
      this.sensorValue, this.threshold, this.threshMax, this.readMax,
      {Key? key})
      : super(key: key) {
    actualThreshold = threshold;
  }

  @override
  _DetailViewState createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  bool isloading = false;

  Future setThreshold(BuildContext context) async {
    isloading = true;
    setState(() {});
    Thresholds th =
        Provider.of<ThresholdProvider>(context, listen: false).getThresholds;
    if (widget.id == 0) {
      await FirebaseDB().setData("/temp", widget.threshold);
      th.temperatureThreshold = widget.threshold;
    } else if (widget.id == 1) {
      await FirebaseDB().setData("/hum", widget.threshold);
      th.humidityThreshold = widget.threshold;
    } else if (widget.id == 2) {
      await FirebaseDB().setData("/rainprob", widget.threshold);
      th.rainfallProbabilityThreshold = widget.threshold;
    } else if (widget.id == 3) {
      await FirebaseDB().setData("/s1/moist", widget.threshold);
      th.soilMoistureThreshold = widget.threshold;
    }

    await Provider.of<ThresholdProvider>(context, listen: false)
        .addDataToDb(th);
    widget.actualThreshold = widget.threshold;
    await Future.delayed(const Duration(seconds: 1));
    isloading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: const LoadingScreen2(),
          )
        : WillPopScope(
            onWillPop: () async {
              if (widget.threshold == widget.actualThreshold) {
                return true;
              }
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: const Text("Changes not be saved"),
                        content: const Text(
                            "Do you like to save the changes made to the threshold value?"),
                        actions: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                primary: Colors.black87),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text("Back"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.black87),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await setThreshold(context);
                              Navigator.of(context).pop();
                            },
                            child: const Text("  Save  "),
                          )
                        ],
                      ));
              return false;
            },
            child: Scaffold(
              backgroundColor: widget.bgColor,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                foregroundColor: Colors.white,
              ),
              body: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          alignment: Alignment.bottomCenter,
                          height: MediaQuery.of(context).size.width * 0.6,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: CustomPaint(
                            size: Size(MediaQuery.of(context).size.width * 0.6,
                                MediaQuery.of(context).size.width * 0.6),
                            painter: Painter(
                              color: Colors.white,
                              start: math.pi * 0.75,
                              sweep: math.pi * 1.5,
                              width: 4,
                              cap: StrokeCap.square,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          height: MediaQuery.of(context).size.width * 0.6,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: CustomPaint(
                            size: Size(MediaQuery.of(context).size.width * 0.6,
                                MediaQuery.of(context).size.width * 0.6),
                            painter: Painter(
                              color: widget.threshold > widget.sensorValue
                                  ? widget.threshMax
                                  : widget.readMax,
                              start: widget.threshold > widget.sensorValue
                                  ? math.pi * 0.75 +
                                      (math.pi * 1.5 * widget.sensorValue) / 100
                                  : math.pi * 0.75 +
                                      (math.pi * 1.5 * widget.threshold) / 100,
                              sweep: widget.threshold > widget.sensorValue
                                  ? (math.pi * 1.5 * widget.threshold) / 100 -
                                      (math.pi * 1.5 * widget.sensorValue) / 100
                                  : (math.pi * 1.5 * widget.sensorValue) / 100 -
                                      (math.pi * 1.5 * widget.threshold) / 100,
                              width: 10,
                              cap: StrokeCap.round,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          height: MediaQuery.of(context).size.width * 0.6,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: CustomPaint(
                            size: Size(MediaQuery.of(context).size.width * 0.6,
                                MediaQuery.of(context).size.width * 0.6),
                            painter: Painter(
                              color: Colors.white,
                              start: math.pi * 0.75 +
                                  (math.pi * 1.5 * widget.sensorValue) / 100,
                              sweep: math.pi * 0.001,
                              width: 25,
                              cap: StrokeCap.round,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          height: MediaQuery.of(context).size.width * 0.6,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: CustomPaint(
                            size: Size(MediaQuery.of(context).size.width * 0.6,
                                MediaQuery.of(context).size.width * 0.6),
                            painter: Painter(
                              color: Colors.white,
                              start: math.pi * 0.75 +
                                  (math.pi * 1.5 * widget.threshold) / 100,
                              sweep: math.pi * 0.001,
                              width: 25,
                              cap: StrokeCap.square,
                            ),
                          ),
                        ),
                        Hero(
                          child: Icon(
                            widget.icon,
                            size: 90,
                            color: Colors.white,
                          ),
                          tag: "CenterIcon" + widget.id.toString(),
                          transitionOnUserGestures: true,
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          height: MediaQuery.of(context).size.width * 0.6,
                          width: MediaQuery.of(context).size.width * 0.6,
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            widget.reading,
                            style: const TextStyle(
                                fontSize: 22, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 26, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              onPressed: () {
                                widget.threshold -= 1;
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              )),
                          Container(
                            alignment: Alignment.center,
                            height: MediaQuery.of(context).size.height * 0.04,
                            child: Text(
                              "Threshold: " + widget.threshold.toString(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              widget.threshold += 1;
                              setState(() {});
                            },
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (widget.threshold != widget.actualThreshold)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                        onPressed: () async {
                          await setThreshold(context);
                        },
                        child: Text(
                          "  Set  ",
                          style: TextStyle(color: widget.bgColor, fontSize: 18),
                        ),
                      ),
                    if (widget.threshold == widget.actualThreshold)
                      const SizedBox(height: 47),
                  ],
                ),
              ),
            ),
          );
  }
}
