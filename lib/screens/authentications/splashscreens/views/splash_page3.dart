// views/splash_page3.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashPage3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets1.lottiefiles.com/packages/lf20_p8M2rg.json',
            height: 300,
            width: 300,
          ),
          const SizedBox(height: 40),
          Text(
            'Grow Your Business',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            'Streamline operations, connect with partners, and manage your poultry needs.',
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
