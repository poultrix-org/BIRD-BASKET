// views/splash_page1.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets3.lottiefiles.com/packages/lf20_hsswhx0v.json',
            height: 300,
            width: 300,
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to HenHut',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            'Connecting the entire poultry ecosystem, from farm to supplier.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
