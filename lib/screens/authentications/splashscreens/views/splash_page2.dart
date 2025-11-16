// views/splash_page2.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_M9p23l.json',
            height: 300,
            width: 300,
          ),
          const SizedBox(height: 40),
          Text(
            'Find Your Role',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            'Whether you are a farmer, vet, or supplier, there is a place for you.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}