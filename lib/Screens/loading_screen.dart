import "package:flutter/material.dart";

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/icon/icon.png",
                fit: BoxFit.contain,
              )),
          const SizedBox(height: 10),
          const Text(
            "Welcome to Irrigate IT",
            style: TextStyle(color: Colors.black54, fontSize: 24),
          ),
          const SizedBox(height: 30),
          Container(
            alignment: Alignment.bottomCenter,
            child: const CircularProgressIndicator(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
