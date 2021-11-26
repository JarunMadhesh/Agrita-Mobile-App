import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:smart_irrigation/Providers/firebase.dart';
import 'package:smart_irrigation/Providers/sensor_data.dart';
import 'package:smart_irrigation/Screens/loading_screen2.dart';
import 'package:smart_irrigation/widgets/home_screen_items.dart';
import 'package:smart_irrigation/widgets/soil_moisture_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen2()
        : Scaffold(
            appBar: AppBar(
              title: const Text(
                "Agrita",
                style: TextStyle(fontSize: 23),
              ),
              backgroundColor: Colors.black87,
              elevation: 0,
              centerTitle: true,
            ),
            body: RefreshIndicator(
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              color: Colors.black87,
              onRefresh: () async {
                await FirebaseDB().fetchDB(context);
                // await Provider.of<ThresholdProvider>(context, listen: false)
                //     .getThresholdDataFromDb();
                // await Provider.of<SensorDataProvider>(context, listen: false)
                //     .getSensorDataFromDb();
                setState(() {});
              },
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.black87, Color.fromRGBO(5, 5, 5, 50)],
                    stops: [0.2, 1],
                  ),
                ),
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: MediaQuery.of(context).size.width * 0.05,
                  top: MediaQuery.of(context).size.width * 0.13,
                ),
                alignment: Alignment.center,
                child: ListView(
                  children: [
                    SoilMoistureWidget(context),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        Provider.of<SensorDataProvider>(context).getInference!,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        HomeScreenItem(0, context),
                        HomeScreenItem(1, context),
                        HomeScreenItem(2, context),
                      ],
                    ),
                    const SizedBox(height: 40),

                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        Provider.of<SensorDataProvider>(context, listen: false)
                                .getMotorStatus
                            ? "Motor is ON"
                            : "Motor is OFF",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      onPressed: () async {
                        isLoading = true;
                        setState(() {});
                        if (Provider.of<SensorDataProvider>(context,
                                listen: false)
                            .getMotorStatus) {
                          await FirebaseDB().turnOffMotor();
                          Provider.of<SensorDataProvider>(context,
                                  listen: false)
                              .setMotorStatus(0);
                        } else {
                          await FirebaseDB().turnOnMotor();
                          Provider.of<SensorDataProvider>(context,
                                  listen: false)
                              .setMotorStatus(1);
                        }
                        await Future.delayed(const Duration(seconds: 1));
                        isLoading = false;
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.power_settings_new,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     HomeItems(
                    //         "Analytics", Icons.auto_graph_rounded, Colors.green),
                    //     const SizedBox(width: 50),
                    //     HomeItems("Warning", Icons.error_outline, Colors.orange),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          );
  }
}
