import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_live_commerce/screen/footer.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoadingScreen();
  }
}

class _LoadingScreen extends State<LoadingScreen> {
  @override
  void initState() {
    Timer(const Duration(milliseconds: 500), () {
      Navigator.pushReplacementNamed(context, "/login");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff2a61be),
              Color(0xff5d48c6),
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/common/logo.png',
              width: 200,
            ),
            const Positioned(bottom: 0, child: FooterArea()),
          ],
        ),
      ),
    );
  }
}
