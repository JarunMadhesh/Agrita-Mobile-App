import 'package:flutter/material.dart';

// ignore: must_be_immutable
class HomeItems extends StatelessWidget {
  late String name;
  late IconData icon;
  late Color bgColor;

  HomeItems(this.name, this.icon, this.bgColor, {Key? key}) : super(key: key);

  void pushPage(BuildContext context) {}

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
              tag: name,
              child: Icon(
                icon,
                size: 57,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
