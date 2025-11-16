// views/splash_view.dart
import 'package:birdbasket/screens/authentications/splashscreens/views/splash_page1.dart';
import 'package:birdbasket/screens/authentications/splashscreens/views/splash_page2.dart';
import 'package:birdbasket/screens/authentications/splashscreens/views/splash_page3.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';


class SplashView extends StatelessWidget {
  final SplashController controller = Get.put(SplashController());

  SplashView({super.key});

  final List<Widget> _pages = [
    SplashPage1(),
    SplashPage2(),
    SplashPage3(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) => _pages[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Obx(
                        () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: controller.currentPage.value == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == index
                                ? Colors.brown[700]
                                : Colors.grey[400],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                          () => ElevatedButton(
                        onPressed: controller.nextPage,
                        child: Text(
                          controller.currentPage.value == 2
                              ? 'Get Started'
                              : 'Next',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}